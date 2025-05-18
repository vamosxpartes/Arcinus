import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_stats_model.dart';
import 'package:arcinus/features/academies/data/models/academy_time_series_model.dart';
import 'package:arcinus/features/academies/data/repositories/academy_stats_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAcademyStatsRepository extends Mock implements AcademyStatsRepository {}

void main() {
  late MockAcademyStatsRepository mockRepository;
  late ProviderContainer container;
  
  const String testAcademyId = 'test-academy-id';
  
  setUp(() {
    mockRepository = MockAcademyStatsRepository();
    
    container = ProviderContainer(
      overrides: [
        academyStatsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('academyStatsProvider', () {
    test('debería retornar datos combinados cuando hay estadísticas actuales y series temporales', () async {
      // Arrange
      // Configurar generateTimeSeriesData para que devuelva éxito
      when(() => mockRepository.generateTimeSeriesData(testAcademyId))
          .thenAnswer((_) async => const Right(true));
      
      // Configurar getAcademyStats para que devuelva datos de prueba
      final statsModel = AcademyStatsModel(
        id: 'current',
        academyId: testAcademyId,
        totalMembers: 42,
        monthlyRevenue: 3500.0,
        attendanceRate: 78.5,
        totalTeams: 5,
        totalStaff: 3,
        retentionRate: 85.0,
        growthRate: 10.0,
        projectedAnnualRevenue: 42000.0,
      );
      
      when(() => mockRepository.getAcademyStats(testAcademyId))
          .thenAnswer((_) async => Right(statsModel));
      
      
      final timeSeriesData = [
        AcademyTimeSeriesModel(
          id: '2023-01',
          academyId: testAcademyId,
          year: 2023,
          month: 1,
          label: 'Ene 2023',
          metrics: {
            'members': 35.0,
            'revenue': 3000.0,
            'attendance': 75.0,
          },
          timestamp: DateTime(2023, 1, 1),
        ),
        AcademyTimeSeriesModel(
          id: '2023-02',
          academyId: testAcademyId,
          year: 2023,
          month: 2,
          label: 'Feb 2023',
          metrics: {
            'members': 38.0,
            'revenue': 3200.0,
            'attendance': 77.0,
          },
          timestamp: DateTime(2023, 2, 1),
        ),
      ];
      
      when(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Right(timeSeriesData));
      
      // Configurar convertToMonthlyData para que devuelva datos formateados
      final memberHistory = [
        MonthlyData(month: 1, year: 2023, value: 35.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 38.0, label: 'Feb 2023'),
      ];
      
      final revenueHistory = [
        MonthlyData(month: 1, year: 2023, value: 3000.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 3200.0, label: 'Feb 2023'),
      ];
      
      final attendanceHistory = [
        MonthlyData(month: 1, year: 2023, value: 75.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 77.0, label: 'Feb 2023'),
      ];
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'members'))
          .thenReturn(memberHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'revenue'))
          .thenReturn(revenueHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'attendance'))
          .thenReturn(attendanceHistory);
      
      // Act
      final result = await container.read(academyStatsProvider(testAcademyId).future);
      
      // Assert
      expect(result, isNotNull);
      expect(result!.totalMembers, 42);
      expect(result.monthlyRevenue, 3500.0);
      expect(result.attendanceRate, 78.5);
      expect(result.totalTeams, 5);
      expect(result.totalStaff, 3);
      expect(result.retentionRate, 85.0);
      // El growthRate se calcula con los datos históricos
      expect(result.growthRate, 8.571428571428571); // (38-35)/35*100
      expect(result.projectedAnnualRevenue, 42000.0);
      expect(result.memberHistory, memberHistory);
      expect(result.revenueHistory, revenueHistory);
      expect(result.attendanceHistory, attendanceHistory);
      
      // Verificar que todos los métodos fueron llamados
      verify(() => mockRepository.generateTimeSeriesData(testAcademyId)).called(1);
      verify(() => mockRepository.getAcademyStats(testAcademyId)).called(1);
      verify(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
      verify(() => mockRepository.convertToMonthlyData(timeSeriesData, 'members')).called(1);
      verify(() => mockRepository.convertToMonthlyData(timeSeriesData, 'revenue')).called(1);
      verify(() => mockRepository.convertToMonthlyData(timeSeriesData, 'attendance')).called(1);
    });

    test('debería usar solo datos históricos cuando no hay estadísticas actuales', () async {
      // Arrange
      // Configurar generateTimeSeriesData para que devuelva éxito
      when(() => mockRepository.generateTimeSeriesData(testAcademyId))
          .thenAnswer((_) async => const Right(true));
      
      // Configurar getAcademyStats para que devuelva error (no hay estadísticas)
      when(() => mockRepository.getAcademyStats(testAcademyId))
          .thenAnswer((_) async => Left(const Failure.notFound(message: 'No hay estadísticas')));
            
      final timeSeriesData = [
        AcademyTimeSeriesModel(
          id: '2023-01',
          academyId: testAcademyId,
          year: 2023,
          month: 1,
          label: 'Ene 2023',
          metrics: {
            'members': 35.0,
            'revenue': 3000.0,
            'attendance': 75.0,
          },
          timestamp: DateTime(2023, 1, 1),
        ),
        AcademyTimeSeriesModel(
          id: '2023-02',
          academyId: testAcademyId,
          year: 2023,
          month: 2,
          label: 'Feb 2023',
          metrics: {
            'members': 38.0,
            'revenue': 3200.0,
            'attendance': 77.0,
          },
          timestamp: DateTime(2023, 2, 1),
        ),
      ];
      
      when(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Right(timeSeriesData));
      
      // Configurar convertToMonthlyData para que devuelva datos formateados
      final memberHistory = [
        MonthlyData(month: 1, year: 2023, value: 35.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 38.0, label: 'Feb 2023'),
      ];
      
      final revenueHistory = [
        MonthlyData(month: 1, year: 2023, value: 3000.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 3200.0, label: 'Feb 2023'),
      ];
      
      final attendanceHistory = [
        MonthlyData(month: 1, year: 2023, value: 75.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 77.0, label: 'Feb 2023'),
      ];
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'members'))
          .thenReturn(memberHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'revenue'))
          .thenReturn(revenueHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'attendance'))
          .thenReturn(attendanceHistory);
      
      // Act
      final result = await container.read(academyStatsProvider(testAcademyId).future);
      
      // Assert
      expect(result, isNotNull);
      // Debería usar el último valor del historial
      expect(result!.totalMembers, 38);
      expect(result.monthlyRevenue, 3200.0);
      expect(result.attendanceRate, 77.0);
      // Estos valores no están disponibles cuando solo hay datos históricos
      expect(result.totalTeams, isNull);
      expect(result.totalStaff, isNull);
      expect(result.retentionRate, isNull);
      // El growthRate se calcula con los datos históricos
      expect(result.growthRate, 8.571428571428571); // (38-35)/35*100
      expect(result.projectedAnnualRevenue, 38400.0); // 3200 * 12
      expect(result.memberHistory, memberHistory);
      expect(result.revenueHistory, revenueHistory);
      expect(result.attendanceHistory, attendanceHistory);
    });

    test('debería retornar null cuando no hay datos históricos ni estadísticas actuales', () async {
      // Arrange
      // Configurar generateTimeSeriesData para que devuelva éxito
      when(() => mockRepository.generateTimeSeriesData(testAcademyId))
          .thenAnswer((_) async => const Right(true));
      
      // Configurar getAcademyStats para que devuelva error (no hay estadísticas)
      when(() => mockRepository.getAcademyStats(testAcademyId))
          .thenAnswer((_) async => Left(const Failure.notFound(message: 'No hay estadísticas')));
      
      // Configurar getTimeSeriesData para que también devuelva error (no hay datos históricos)
      when(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Left(const Failure.notFound(message: 'No hay datos históricos')));
      
      // Act
      final result = await container.read(academyStatsProvider(testAcademyId).future);
      
      // Assert
      expect(result, isNull);
      
      // Verificar que los métodos fueron llamados
      verify(() => mockRepository.generateTimeSeriesData(testAcademyId)).called(1);
      verify(() => mockRepository.getAcademyStats(testAcademyId)).called(1);
      verify(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
    });
  });

  group('filteredStatsProvider', () {
    test('debería devolver null cuando academyStatsProvider devuelve null', () async {
      // Arrange
      when(() => mockRepository.generateTimeSeriesData(testAcademyId))
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.getAcademyStats(testAcademyId))
          .thenAnswer((_) async => Left(const Failure.notFound(message: 'No hay estadísticas')));
      when(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Left(const Failure.notFound(message: 'No hay datos históricos')));
      
      // Esperar a que el estado asíncrono se resuelva
      await container.read(academyStatsProvider(testAcademyId).future).catchError((_) => null);
      
      // Act
      final filteredStats = container.read(filteredStatsProvider(testAcademyId));
      
      // Assert
      expect(filteredStats, isNull);
    });

    test('debería devolver los mismos datos que academyStatsProvider sin filtrar por ahora', () async {
      // Arrange
      // Configurar generateTimeSeriesData para que devuelva éxito
      when(() => mockRepository.generateTimeSeriesData(testAcademyId))
          .thenAnswer((_) async => const Right(true));
      
      // Configurar getAcademyStats para que devuelva datos de prueba
      final statsModel = AcademyStatsModel(
        id: 'current',
        academyId: testAcademyId,
        totalMembers: 42,
        monthlyRevenue: 3500.0,
        attendanceRate: 78.5,
        totalTeams: 5,
        totalStaff: 3,
        retentionRate: 85.0,
        growthRate: 10.0,
        projectedAnnualRevenue: 42000.0,
      );
      
      when(() => mockRepository.getAcademyStats(testAcademyId))
          .thenAnswer((_) async => Right(statsModel));
      
      // Configurar getTimeSeriesData para que devuelva datos de prueba
      final timeSeriesData = [
        AcademyTimeSeriesModel(
          id: '2023-01',
          academyId: testAcademyId,
          year: 2023,
          month: 1,
          label: 'Ene 2023',
          metrics: {
            'members': 35.0,
            'revenue': 3000.0,
            'attendance': 75.0,
          },
          timestamp: DateTime(2023, 1, 1),
        ),
        AcademyTimeSeriesModel(
          id: '2023-02',
          academyId: testAcademyId,
          year: 2023,
          month: 2,
          label: 'Feb 2023',
          metrics: {
            'members': 38.0,
            'revenue': 3200.0,
            'attendance': 77.0,
          },
          timestamp: DateTime(2023, 2, 1),
        ),
      ];
      
      when(() => mockRepository.getTimeSeriesData(
        testAcademyId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Right(timeSeriesData));
      
      // Configurar convertToMonthlyData para que devuelva datos formateados
      final memberHistory = [
        MonthlyData(month: 1, year: 2023, value: 35.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 38.0, label: 'Feb 2023'),
      ];
      
      final revenueHistory = [
        MonthlyData(month: 1, year: 2023, value: 3000.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 3200.0, label: 'Feb 2023'),
      ];
      
      final attendanceHistory = [
        MonthlyData(month: 1, year: 2023, value: 75.0, label: 'Ene 2023'),
        MonthlyData(month: 2, year: 2023, value: 77.0, label: 'Feb 2023'),
      ];
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'members'))
          .thenReturn(memberHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'revenue'))
          .thenReturn(revenueHistory);
      
      when(() => mockRepository.convertToMonthlyData(timeSeriesData, 'attendance'))
          .thenReturn(attendanceHistory);
      
      // Esperar a que el estado asíncrono se resuelva
      await container.read(academyStatsProvider(testAcademyId).future);
      
      // Act
      final filteredStats = container.read(filteredStatsProvider(testAcademyId));
      
      // Assert
      expect(filteredStats, isNotNull);
      expect(filteredStats!.totalMembers, 42);
      expect(filteredStats.monthlyRevenue, 3500.0);
      expect(filteredStats.attendanceRate, 78.5);
      expect(filteredStats.memberHistory, memberHistory);
      expect(filteredStats.revenueHistory, revenueHistory);
      expect(filteredStats.attendanceHistory, attendanceHistory);
    });
  });
} 