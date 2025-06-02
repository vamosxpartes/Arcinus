import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/period_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implementación del repositorio de períodos usando Firestore
class PeriodRepositoryImpl implements PeriodRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'PeriodRepositoryImpl';
  
  PeriodRepositoryImpl(this._firestore);
  
  /// Obtiene la referencia de la colección de períodos para una academia
  CollectionReference _getPeriodsCollection(String academyId) {
    return _firestore
        .collection('academies')
        .doc(academyId)
        .collection('subscription_assignments');
  }
  
  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> createPeriod(
    SubscriptionAssignmentModel period,
  ) async {
    try {
      AppLogger.logInfo(
        'Creando período de suscripción',
        className: _className,
        functionName: 'createPeriod',
        params: {
          'academyId': period.academyId,
          'athleteId': period.athleteId,
          'startDate': period.startDate.toString(),
          'endDate': period.endDate.toString(),
        },
      );
      
      final collection = _getPeriodsCollection(period.academyId);
      final docRef = collection.doc();
      
      final periodWithId = period.copyWith(id: docRef.id);
      
      await docRef.set(periodWithId.toJson());
      
      AppLogger.logInfo(
        'Período creado exitosamente',
        className: _className,
        functionName: 'createPeriod',
        params: {'periodId': periodWithId.id},
      );
      
      return Right(periodWithId);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al crear período',
        error: e,
        className: _className,
        functionName: 'createPeriod',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> createMultiplePeriods(
    List<SubscriptionAssignmentModel> periods,
  ) async {
    if (periods.isEmpty) {
      return const Right([]);
    }
    
    try {
      AppLogger.logInfo(
        'Creando múltiples períodos de suscripción',
        className: _className,
        functionName: 'createMultiplePeriods',
        params: {
          'academyId': periods.first.academyId,
          'periodsCount': periods.length,
        },
      );
      
      // *** DIAGNÓSTICO: Log detallado de cada período antes de guardar ***
      for (int i = 0; i < periods.length; i++) {
        final period = periods[i];
        final now = DateTime.now();
        AppLogger.logInfo(
          'DIAGNÓSTICO: Período a crear',
          className: _className,
          functionName: 'createMultiplePeriods',
          params: {
            'periodIndex': i + 1,
            'athleteId': period.athleteId,
            'subscriptionPlanId': period.subscriptionPlanId,
            'startDate': period.startDate.toIso8601String(),
            'endDate': period.endDate.toIso8601String(),
            'status': period.status.name,
            'amountPaid': period.amountPaid,
            'currency': period.currency,
            'paymentDate': period.paymentDate.toIso8601String(),
            'now': now.toIso8601String(),
            'startDateIsBeforeNow': period.startDate.isBefore(now),
            'endDateIsAfterNow': period.endDate.isAfter(now),
            'daysFromNowToStart': period.startDate.difference(now).inDays,
            'daysFromNowToEnd': period.endDate.difference(now).inDays,
          },
        );
      }
      
      final academyId = periods.first.academyId;
      final collection = _getPeriodsCollection(academyId);
      final batch = _firestore.batch();
      
      final periodsWithIds = <SubscriptionAssignmentModel>[];
      
      for (final period in periods) {
        final docRef = collection.doc();
        final periodWithId = period.copyWith(id: docRef.id);
        batch.set(docRef, periodWithId.toJson());
        periodsWithIds.add(periodWithId);
        
        AppLogger.logInfo(
          'DIAGNÓSTICO: Período con ID asignado',
          className: _className,
          functionName: 'createMultiplePeriods',
          params: {
            'periodId': docRef.id,
            'athleteId': period.athleteId,
            'jsonData': periodWithId.toJson().toString(),
          },
        );
      }
      
      await batch.commit();
      
      AppLogger.logInfo(
        'Múltiples períodos creados exitosamente',
        className: _className,
        functionName: 'createMultiplePeriods',
        params: {
          'createdCount': periodsWithIds.length,
          'periodIds': periodsWithIds.map((p) => p.id).toList(),
        },
      );
      
      return Right(periodsWithIds);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al crear múltiples períodos',
        error: e,
        className: _className,
        functionName: 'createMultiplePeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAthletesPeriods(
    String academyId,
    String athleteId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo períodos del atleta',
        className: _className,
        functionName: 'getAthletesPeriods',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
          'status': status?.name,
          'fromDate': fromDate?.toString(),
          'toDate': toDate?.toString(),
        },
      );
      
      Query query = _getPeriodsCollection(academyId)
          .where('athleteId', isEqualTo: athleteId);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      
      if (fromDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      
      if (toDate != null) {
        query = query.where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      
      query = query.orderBy('startDate', descending: false);
      
      final querySnapshot = await query.get();
      
      final periods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      
      AppLogger.logInfo(
        'Períodos del atleta obtenidos exitosamente',
        className: _className,
        functionName: 'getAthletesPeriods',
        params: {
          'foundPeriods': periods.length,
        },
      );
      
      return Right(periods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos del atleta',
        error: e,
        className: _className,
        functionName: 'getAthletesPeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, SubscriptionAssignmentModel?>> getCurrentPeriod(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo período actual',
        className: _className,
        functionName: 'getCurrentPeriod',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
        },
      );
      
      final now = DateTime.now();
      
      // Consulta simplificada para evitar índices complejos
      final querySnapshot = await _getPeriodsCollection(academyId)
          .where('athleteId', isEqualTo: athleteId)
          .where('status', isEqualTo: SubscriptionAssignmentStatus.active.name)
          .get();
      
      // Filtrar y encontrar el período actual en memoria
      final currentPeriods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .where((period) => 
              period.startDate.isBefore(now) || period.startDate.isAtSameMomentAs(now))
          .where((period) => period.endDate.isAfter(now))
          .toList();
      
      // Ordenar por fecha de fin y tomar el primero
      if (currentPeriods.isNotEmpty) {
        currentPeriods.sort((a, b) => a.endDate.compareTo(b.endDate));
        
        AppLogger.logInfo(
          'Período actual encontrado',
          className: _className,
          functionName: 'getCurrentPeriod',
          params: {
            'periodId': currentPeriods.first.id,
            'endDate': currentPeriods.first.endDate.toString(),
          },
        );
        
        return Right(currentPeriods.first);
      }
      
      AppLogger.logInfo(
        'No se encontró período actual',
        className: _className,
        functionName: 'getCurrentPeriod',
      );
      
      return const Right(null);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener período actual',
        error: e,
        className: _className,
        functionName: 'getCurrentPeriod',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getActivePeriods(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo períodos activos',
        className: _className,
        functionName: 'getActivePeriods',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
        },
      );
      
      final now = DateTime.now();
      
      // Simplificada la consulta para evitar el índice compuesto complejo
      // Primero obtenemos por athleteId y status
      final querySnapshot = await _getPeriodsCollection(academyId)
          .where('athleteId', isEqualTo: athleteId)
          .where('status', isEqualTo: SubscriptionAssignmentStatus.active.name)
          .get();
      
      AppLogger.logInfo(
        'Consulta Firestore completada',
        className: _className,
        functionName: 'getActivePeriods',
        params: {
          'totalDocsFound': querySnapshot.docs.length,
          'queryFilters': 'athleteId=$athleteId, status=${SubscriptionAssignmentStatus.active.name}',
        },
      );
      
      // Procesar todos los documentos y loggear detalles
      final allPeriods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      
      // Log detallado de todos los períodos encontrados
      for (int i = 0; i < allPeriods.length; i++) {
        final period = allPeriods[i];
        final isAfterNow = period.endDate.isAfter(now);
        AppLogger.logInfo(
          'Período encontrado en consulta',
          className: _className,
          functionName: 'getActivePeriods',
          params: {
            'periodIndex': i + 1,
            'periodId': period.id ?? 'null',
            'startDate': period.startDate.toIso8601String(),
            'endDate': period.endDate.toIso8601String(),
            'status': period.status.name,
            'athleteId': period.athleteId,
            'subscriptionPlanId': period.subscriptionPlanId,
            'now': now.toIso8601String(),
            'endDateIsAfterNow': isAfterNow,
            'daysDifference': period.endDate.difference(now).inDays,
          },
        );
      }
      
      // Filtramos en memoria para evitar índices complejos
      final periods = allPeriods
          .where((period) => period.endDate.isAfter(now)) // Filtro en memoria
          .toList();
      
      // Ordenamos en memoria
      periods.sort((a, b) => a.endDate.compareTo(b.endDate));
      
      AppLogger.logInfo(
        'Períodos activos obtenidos exitosamente',
        className: _className,
        functionName: 'getActivePeriods',
        params: {
          'foundPeriodsTotal': allPeriods.length,
          'foundPeriodsActive': periods.length,
          'filteredOutCount': allPeriods.length - periods.length,
        },
      );
      
      return Right(periods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos activos',
        error: e,
        className: _className,
        functionName: 'getActivePeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getUpcomingPeriods(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo períodos próximos',
        className: _className,
        functionName: 'getUpcomingPeriods',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
        },
      );
      
      final now = DateTime.now();
      
      // Consulta simplificada para evitar índices complejos
      final querySnapshot = await _getPeriodsCollection(academyId)
          .where('athleteId', isEqualTo: athleteId)
          .where('status', isEqualTo: SubscriptionAssignmentStatus.active.name)
          .get();
      
      // Filtrar períodos futuros en memoria
      final periods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .where((period) => period.startDate.isAfter(now)) // Filtro en memoria
          .toList();
      
      // Ordenar en memoria
      periods.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      AppLogger.logInfo(
        'Períodos próximos obtenidos exitosamente',
        className: _className,
        functionName: 'getUpcomingPeriods',
        params: {
          'foundPeriods': periods.length,
        },
      );
      
      return Right(periods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos próximos',
        error: e,
        className: _className,
        functionName: 'getUpcomingPeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriodStatus(
    String academyId,
    String periodId,
    SubscriptionAssignmentStatus newStatus,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando estado del período',
        className: _className,
        functionName: 'updatePeriodStatus',
        params: {
          'periodId': periodId,
          'newStatus': newStatus.name,
        },
      );
      
      final docRef = _getPeriodsCollection(academyId).doc(periodId);
      
      await docRef.update({
        'status': newStatus.name,
        'lastModified': Timestamp.now(),
      });
      
      final doc = await docRef.get();
      if (!doc.exists) {
        return Left(ValidationFailure(message: 'Período no encontrado'));
      }
      
      final updatedPeriod = SubscriptionAssignmentModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      
      return Right(updatedPeriod);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al actualizar estado del período',
        error: e,
        className: _className,
        functionName: 'updatePeriodStatus',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriod(
    String academyId,
    String periodId,
    SubscriptionAssignmentModel updatedPeriod,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando período completo',
        className: _className,
        functionName: 'updatePeriod',
        params: {'periodId': periodId},
      );
      
      final docRef = _getPeriodsCollection(academyId).doc(periodId);
      
      final periodData = updatedPeriod.toJson()
        ..['lastModified'] = Timestamp.now();
      
      await docRef.update(periodData);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        return Left(ValidationFailure(message: 'Período no encontrado'));
      }
      
      final period = SubscriptionAssignmentModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      
      return Right(period);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al actualizar período',
        error: e,
        className: _className,
        functionName: 'updatePeriod',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deletePeriod(
    String academyId,
    String periodId,
  ) async {
    try {
      AppLogger.logInfo(
        'Eliminando período (soft delete)',
        className: _className,
        functionName: 'deletePeriod',
        params: {'periodId': periodId},
      );
      
      final docRef = _getPeriodsCollection(academyId).doc(periodId);
      
      await docRef.update({
        'status': SubscriptionAssignmentStatus.cancelled.name,
        'lastModified': Timestamp.now(),
      });
      
      return const Right(true);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al eliminar período',
        error: e,
        className: _className,
        functionName: 'deletePeriod',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getPeriodsExpiringInRange(
    String academyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _getPeriodsCollection(academyId)
          .where('status', isEqualTo: SubscriptionAssignmentStatus.active.name)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('endDate', descending: false)
          .get();
      
      final periods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      
      return Right(periods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos que vencen',
        error: e,
        className: _className,
        functionName: 'getPeriodsExpiringInRange',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAcademyPeriods(
    String academyId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    try {
      Query query = _getPeriodsCollection(academyId);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      
      if (fromDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      
      if (toDate != null) {
        query = query.where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      
      query = query.orderBy('startDate', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      
      final periods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      
      return Right(periods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos de la academia',
        error: e,
        className: _className,
        functionName: 'getAcademyPeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Método optimizado para obtener todos los períodos activos de un atleta
  /// en una sola consulta y procesarlos en memoria
  Future<Either<Failure, Map<String, List<SubscriptionAssignmentModel>>>> getAllActivePeriodsOptimized(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo todos los períodos activos optimizado',
        className: _className,
        functionName: 'getAllActivePeriodsOptimized',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
        },
      );
      
      final now = DateTime.now();
      
      // Una sola consulta para obtener todos los períodos activos
      final querySnapshot = await _getPeriodsCollection(academyId)
          .where('athleteId', isEqualTo: athleteId)
          .where('status', isEqualTo: SubscriptionAssignmentStatus.active.name)
          .get();
      
      final allActivePeriods = querySnapshot.docs
          .map((doc) => SubscriptionAssignmentModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      
      // Clasificar períodos en memoria
      final activePeriods = allActivePeriods
          .where((period) => period.endDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
      
      final currentPeriods = allActivePeriods
          .where((period) => 
              (period.startDate.isBefore(now) || period.startDate.isAtSameMomentAs(now)) &&
              period.endDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
      
      final upcomingPeriods = allActivePeriods
          .where((period) => period.startDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      
      final result = {
        'active': activePeriods,
        'current': currentPeriods,
        'upcoming': upcomingPeriods,
      };
      
      AppLogger.logInfo(
        'Períodos optimizados obtenidos exitosamente',
        className: _className,
        functionName: 'getAllActivePeriodsOptimized',
        params: {
          'totalActive': activePeriods.length,
          'current': currentPeriods.length,
          'upcoming': upcomingPeriods.length,
        },
      );
      
      return Right(result);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos optimizados',
        error: e,
        className: _className,
        functionName: 'getAllActivePeriodsOptimized',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
} 