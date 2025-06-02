import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/data/models/academy_stats_model.dart';
import 'package:arcinus/features/academies/data/models/academy_time_series_model.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';

/// Repositorio para gestionar estadísticas de academias en Firestore
class AcademyStatsRepository {
  final FirebaseFirestore _firestore;
  
  /// Nombres de meses abreviados en español
  final List<String> _monthNames = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  AcademyStatsRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtiene las estadísticas actuales de una academia
  Future<Either<Failure, AcademyStatsModel>> getAcademyStats(String academyId) async {
    try {
      final docRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('stats')
          .doc('current');
      
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        return Left(const Failure.notFound(message: 'No se encontraron estadísticas para esta academia'));
      }
      
      final statsData = docSnapshot.data()!;
      return Right(AcademyStatsModel.fromJson({
        ...statsData,
        'academyId': academyId,
      }).copyWith(id: docSnapshot.id));
      
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener estadísticas de academia',
        error: e,
        stackTrace: s,
        className: 'AcademyStatsRepository',
        params: {'academyId': academyId},
      );
      return Left(Failure.serverError(message: e.toString()));
    }
  }

  /// Obtiene datos históricos (series temporales) de una academia para un período específico
  Future<Either<Failure, List<AcademyTimeSeriesModel>>> getTimeSeriesData(
    String academyId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('historical_academy_stats')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp')
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return Left(const Failure.notFound(message: 'No se encontraron datos históricos para esta academia'));
      }
      
      final timeSeriesData = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AcademyTimeSeriesModel.fromJson({
          ...data,
          'academyId': academyId,
        }).copyWith(id: doc.id);
      }).toList();
      
      return Right(timeSeriesData);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener datos históricos de academia',
        error: e,
        stackTrace: s,
        className: 'AcademyStatsRepository',
        params: {'academyId': academyId},
      );
      return Left(Failure.serverError(message: e.toString()));
    }
  }

  /// Convierte datos de series temporales al formato MonthlyData para los gráficos
  List<MonthlyData> convertToMonthlyData(
    List<AcademyTimeSeriesModel> timeSeriesData,
    String metricKey, // "members", "revenue", "attendance"
  ) {
    return timeSeriesData.map((timeSeries) {
      final value = timeSeries.metrics[metricKey] ?? 0.0;
      
      return MonthlyData(
        month: timeSeries.month,
        year: timeSeries.year,
        value: value,
        label: timeSeries.label,
      );
    }).toList();
  }
  
  /// Genera una etiqueta de mes en formato "Mmm YYYY"
  String _generateMonthLabel(int month, int year) {
    return '${_monthNames[month - 1]} $year';
  }

  /// Genera y almacena datos faltantes de series temporales
  Future<Either<Failure, bool>> generateTimeSeriesData(String academyId) async {
    try {
      final now = DateTime.now();
      final lastSixMonths = <DateTime>[];
      
      // Generar fechas para los últimos 6 meses
      for (var i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        lastSixMonths.add(date);
      }
      
      // Verificar datos existentes
      final querySnapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('historical_academy_stats')
          .orderBy('timestamp', descending: true)
          .limit(6)
          .get();
      
      final existingDates = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DateTime(data['year'] as int, data['month'] as int, 1);
      }).toList();
      
      // Filtrar fechas que no existen en la base de datos
      final datesToCreate = lastSixMonths.where((date) {
        return !existingDates.any((existing) => 
            existing.year == date.year && existing.month == date.month);
      }).toList();
      
      // Si no hay fechas que crear, terminamos
      if (datesToCreate.isEmpty) {
        return const Right(true);
      }
      
      // Obtener estadísticas actuales para basarse en ellas
      final statsResult = await getAcademyStats(academyId);
      
      final baseMembers = statsResult.fold(
        (failure) => 35, // Valor por defecto si no hay estadísticas
        (stats) => stats.totalMembers,
      );
      
      final baseRevenue = statsResult.fold(
        (failure) => 3000.0, 
        (stats) => stats.monthlyRevenue ?? 3000.0,
      );
      
      final baseAttendance = statsResult.fold(
        (failure) => 75.0, 
        (stats) => stats.attendanceRate ?? 75.0,
      );
      
      // Crear documentos para cada fecha faltante
      final batch = _firestore.batch();
      
      for (var i = 0; i < datesToCreate.length; i++) {
        final date = datesToCreate[i];
        final monthLabel = _generateMonthLabel(date.month, date.year);
        
        // Crear valores con variación aleatoria para simular cambios realistas
        final variationFactor = (i / 10) + 0.9; // Factor entre 0.9 y 1.4
        
        final membersValue = (baseMembers * variationFactor).round().toDouble();
        final revenueValue = baseRevenue * variationFactor;
        final attendanceValue = baseAttendance * (0.95 + (i * 0.01)); // Incremento gradual
        
        final timeSeriesRef = _firestore
            .collection('academies')
            .doc(academyId)
            .collection('historical_academy_stats')
            .doc('${date.year}-${date.month.toString().padLeft(2, '0')}');
            
        final timeSeriesData = {
          'academyId': academyId,
          'year': date.year,
          'month': date.month,
          'label': monthLabel,
          'metrics': {
            'members': membersValue,
            'revenue': revenueValue,
            'attendance': attendanceValue,
          },
          'timestamp': Timestamp.fromDate(date),
          'additionalData': {},
        };
        
        batch.set(timeSeriesRef, timeSeriesData);
      }
      
      // Ejecutar el batch
      await batch.commit();
      
      return const Right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al generar datos históricos de academia',
        error: e,
        stackTrace: s,
        className: 'AcademyStatsRepository',
        params: {'academyId': academyId},
      );
      return Left(Failure.serverError(message: e.toString()));
    }
  }
} 