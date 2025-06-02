import 'dart:async';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/period_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Servicio de optimización de rendimiento para operaciones de pagos y períodos
/// 
/// Este servicio implementa:
/// - Caché en memoria para consultas frecuentes
/// - Operaciones batch para múltiples períodos
/// - Optimización de consultas de base de datos
/// - Gestión de memoria y limpieza automática
class PaymentPerformanceService {
  final PeriodRepository _periodRepository;
  static const String _className = 'PaymentPerformanceService';
  
  // Caché en memoria para períodos activos por atleta
  final Map<String, CachedAthleteData> _athleteCache = {};
  
  // Timer para limpieza automática del caché
  Timer? _cacheCleanupTimer;
  
  // Configuración de caché
  static const Duration _cacheExpiration = Duration(minutes: 15);
  static const Duration _cleanupInterval = Duration(minutes: 30);
  static const int _maxCacheSize = 1000;
  
  PaymentPerformanceService(this._periodRepository) {
    _initializeCacheCleanup();
  }
  
  /// Inicializa la limpieza automática del caché
  void _initializeCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpiredCache();
    });
  }
  
  /// Obtiene períodos activos de un atleta con caché optimizado
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getActivePeriodsOptimized(
    String academyId,
    String athleteId,
  ) async {
    try {
      final cacheKey = '${academyId}_$athleteId';
      
      // Verificar caché primero
      if (_athleteCache.containsKey(cacheKey)) {
        final cachedData = _athleteCache[cacheKey]!;
        if (!cachedData.isExpired) {
          AppLogger.logInfo(
            'Períodos obtenidos desde caché',
            className: _className,
            functionName: 'getActivePeriodsOptimized',
            params: {'athleteId': athleteId, 'cacheHit': true},
          );
          return Right(cachedData.activePeriods);
        }
      }
      
      // Si no está en caché o expiró, consultar base de datos
      final result = await _periodRepository.getActivePeriods(academyId, athleteId);
      
      return result.fold(
        (failure) => Left(failure),
        (periods) {
          // Guardar en caché
          _athleteCache[cacheKey] = CachedAthleteData(
            activePeriods: periods,
            cachedAt: DateTime.now(),
          );
          
          // Verificar límite de caché
          _enforceMaxCacheSize();
          
          AppLogger.logInfo(
            'Períodos obtenidos desde base de datos y cacheados',
            className: _className,
            functionName: 'getActivePeriodsOptimized',
            params: {'athleteId': athleteId, 'periodsCount': periods.length},
          );
          
          return Right(periods);
        },
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener períodos optimizados',
        error: e,
        className: _className,
        functionName: 'getActivePeriodsOptimized',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Crea múltiples períodos con optimización batch
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> createMultiplePeriodsOptimized(
    List<SubscriptionAssignmentModel> periods,
  ) async {
    try {
      if (periods.isEmpty) {
        return const Right([]);
      }
      
      AppLogger.logInfo(
        'Iniciando creación batch de períodos',
        className: _className,
        functionName: 'createMultiplePeriodsOptimized',
        params: {
          'periodsCount': periods.length,
          'academyId': periods.first.academyId,
        },
      );
      
      // Agrupar por academia para optimizar operaciones
      final periodsByAcademy = <String, List<SubscriptionAssignmentModel>>{};
      for (final period in periods) {
        periodsByAcademy.putIfAbsent(period.academyId, () => []).add(period);
      }
      
      final allCreatedPeriods = <SubscriptionAssignmentModel>[];
      
      // Procesar cada academia por separado
      for (final entry in periodsByAcademy.entries) {
        final academyId = entry.key;
        final academyPeriods = entry.value;
        
        final result = await _periodRepository.createMultiplePeriods(academyPeriods);
        
        final createdPeriods = result.fold(
          (failure) => throw Exception('Error creando períodos para academia $academyId: ${failure.message}'),
          (periods) => periods,
        );
        
        allCreatedPeriods.addAll(createdPeriods);
        
        // Invalidar caché para atletas afectados
        for (final period in createdPeriods) {
          _invalidateAthleteCache(academyId, period.athleteId);
        }
      }
      
      AppLogger.logInfo(
        'Creación batch completada exitosamente',
        className: _className,
        functionName: 'createMultiplePeriodsOptimized',
        params: {'totalCreated': allCreatedPeriods.length},
      );
      
      return Right(allCreatedPeriods);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error en creación batch de períodos',
        error: e,
        className: _className,
        functionName: 'createMultiplePeriodsOptimized',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Obtiene estadísticas de períodos para múltiples atletas de forma optimizada
  Future<Either<Failure, Map<String, AthletePeriodsStats>>> getMultipleAthleteStatsOptimized(
    String academyId,
    List<String> athleteIds,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo estadísticas para múltiples atletas',
        className: _className,
        functionName: 'getMultipleAthleteStatsOptimized',
        params: {
          'academyId': academyId,
          'athleteCount': athleteIds.length,
        },
      );
      
      final stats = <String, AthletePeriodsStats>{};
      final uncachedAthletes = <String>[];
      
      // Verificar caché para cada atleta
      for (final athleteId in athleteIds) {
        final cacheKey = '${academyId}_$athleteId';
        if (_athleteCache.containsKey(cacheKey) && !_athleteCache[cacheKey]!.isExpired) {
          final cachedData = _athleteCache[cacheKey]!;
          stats[athleteId] = _calculateStatsFromPeriods(cachedData.activePeriods);
        } else {
          uncachedAthletes.add(athleteId);
        }
      }
      
      // Obtener datos para atletas no cacheados
      if (uncachedAthletes.isNotEmpty) {
        final batchResult = await _batchGetAthletePeriods(academyId, uncachedAthletes);
        
        batchResult.fold(
          (failure) => throw Exception('Error obteniendo datos batch: ${failure.message}'),
          (batchData) {
            for (final entry in batchData.entries) {
              final athleteId = entry.key;
              final periods = entry.value;
              
              // Cachear datos
              final cacheKey = '${academyId}_$athleteId';
              _athleteCache[cacheKey] = CachedAthleteData(
                activePeriods: periods,
                cachedAt: DateTime.now(),
              );
              
              // Calcular estadísticas
              stats[athleteId] = _calculateStatsFromPeriods(periods);
            }
          },
        );
      }
      
      AppLogger.logInfo(
        'Estadísticas obtenidas exitosamente',
        className: _className,
        functionName: 'getMultipleAthleteStatsOptimized',
        params: {
          'cacheHits': athleteIds.length - uncachedAthletes.length,
          'dbQueries': uncachedAthletes.length,
        },
      );
      
      return Right(stats);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error obteniendo estadísticas múltiples',
        error: e,
        className: _className,
        functionName: 'getMultipleAthleteStatsOptimized',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Obtiene períodos de múltiples atletas en una sola operación
  Future<Either<Failure, Map<String, List<SubscriptionAssignmentModel>>>> _batchGetAthletePeriods(
    String academyId,
    List<String> athleteIds,
  ) async {
    // En una implementación real, esto podría usar una consulta optimizada
    // que obtenga todos los períodos de una vez usando 'where in'
    final results = <String, List<SubscriptionAssignmentModel>>{};
    
    for (final athleteId in athleteIds) {
      final result = await _periodRepository.getActivePeriods(academyId, athleteId);
      
      final periods = result.fold(
        (failure) => <SubscriptionAssignmentModel>[],
        (periods) => periods,
      );
      
      results[athleteId] = periods;
    }
    
    return Right(results);
  }
  
  /// Calcula estadísticas a partir de una lista de períodos
  AthletePeriodsStats _calculateStatsFromPeriods(List<SubscriptionAssignmentModel> periods) {
    if (periods.isEmpty) {
      return AthletePeriodsStats(
        totalActivePeriods: 0,
        totalRemainingDays: 0,
        nextExpirationDate: null,
        totalValue: 0.0,
      );
    }
    
    final now = DateTime.now();
    final activePeriods = periods.where((p) => p.endDate.isAfter(now)).toList();
    
    final totalRemainingDays = activePeriods.fold<int>(
      0,
      (sum, period) => sum + period.daysRemaining,
    );
    
    final totalValue = activePeriods.fold<double>(
      0.0,
      (sum, period) => sum + period.amountPaid,
    );
    
    final nextExpiration = activePeriods.isNotEmpty
        ? activePeriods.map((p) => p.endDate).reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    
    return AthletePeriodsStats(
      totalActivePeriods: activePeriods.length,
      totalRemainingDays: totalRemainingDays,
      nextExpirationDate: nextExpiration,
      totalValue: totalValue,
    );
  }
  
  /// Invalida el caché para un atleta específico
  void _invalidateAthleteCache(String academyId, String athleteId) {
    final cacheKey = '${academyId}_$athleteId';
    _athleteCache.remove(cacheKey);
  }
  
  /// Limpia entradas expiradas del caché
  void _cleanupExpiredCache() {
    final expiredKeys = <String>[];
    
    for (final entry in _athleteCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _athleteCache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      AppLogger.logInfo(
        'Caché limpiado automáticamente',
        className: _className,
        functionName: '_cleanupExpiredCache',
        params: {'removedEntries': expiredKeys.length},
      );
    }
  }
  
  /// Aplica el límite máximo de tamaño del caché
  void _enforceMaxCacheSize() {
    if (_athleteCache.length <= _maxCacheSize) return;
    
    // Remover las entradas más antiguas
    final entries = _athleteCache.entries.toList()
      ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));
    
    final toRemove = _athleteCache.length - _maxCacheSize;
    for (int i = 0; i < toRemove; i++) {
      _athleteCache.remove(entries[i].key);
    }
    
    AppLogger.logInfo(
      'Caché reducido por límite de tamaño',
      className: _className,
      functionName: '_enforceMaxCacheSize',
      params: {'removedEntries': toRemove},
    );
  }
  
  /// Limpia todo el caché manualmente
  void clearCache() {
    final size = _athleteCache.length;
    _athleteCache.clear();
    
    AppLogger.logInfo(
      'Caché limpiado manualmente',
      className: _className,
      functionName: 'clearCache',
      params: {'clearedEntries': size},
    );
  }
  
  /// Obtiene estadísticas del caché
  CacheStats getCacheStats() {
    int expiredEntries = 0;
    
    for (final entry in _athleteCache.values) {
      if (entry.isExpired) expiredEntries++;
    }
    
    return CacheStats(
      totalEntries: _athleteCache.length,
      expiredEntries: expiredEntries,
      activeEntries: _athleteCache.length - expiredEntries,
      maxSize: _maxCacheSize,
      hitRatio: 0.0, // Se calcularía con métricas adicionales
    );
  }
  
  /// Libera recursos
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _athleteCache.clear();
  }
}

/// Datos cacheados para un atleta
class CachedAthleteData {
  final List<SubscriptionAssignmentModel> activePeriods;
  final DateTime cachedAt;
  
  const CachedAthleteData({
    required this.activePeriods,
    required this.cachedAt,
  });
  
  /// Verifica si los datos han expirado
  bool get isExpired {
    return DateTime.now().difference(cachedAt) > PaymentPerformanceService._cacheExpiration;
  }
}

/// Estadísticas de períodos de un atleta
class AthletePeriodsStats {
  final int totalActivePeriods;
  final int totalRemainingDays;
  final DateTime? nextExpirationDate;
  final double totalValue;
  
  const AthletePeriodsStats({
    required this.totalActivePeriods,
    required this.totalRemainingDays,
    this.nextExpirationDate,
    required this.totalValue,
  });
}

/// Estadísticas del caché
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeEntries;
  final int maxSize;
  final double hitRatio;
  
  const CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeEntries,
    required this.maxSize,
    required this.hitRatio,
  });
  
  /// Porcentaje de uso del caché
  double get usagePercentage => (totalEntries / maxSize) * 100;
  
  /// Indica si el caché está cerca del límite
  bool get isNearLimit => usagePercentage > 80;
} 