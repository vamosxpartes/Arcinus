import 'dart:async';
import 'dart:math';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users_payments/domain/services/payment_performance_service.dart';
import 'package:fpdart/fpdart.dart';

// Exportar desde payment_performance_service.dart
export 'package:arcinus/features/academy_users_payments/domain/services/payment_performance_service.dart' 
    show CacheStats;

/// Servicio de monitoreo y alertas para operaciones de pagos
/// 
/// Este servicio implementa:
/// - Métricas de rendimiento en tiempo real
/// - Alertas automáticas por umbral
/// - Análisis de tendencias
/// - Reportes de salud del sistema
/// - Dashboard de métricas para administradores
class PaymentMonitoringService {
  final PaymentPerformanceService _performanceService;
  
  static const String _className = 'PaymentMonitoringService';
  
  // Stream controllers para métricas en tiempo real
  final StreamController<PerformanceMetrics> _metricsController = 
      StreamController<PerformanceMetrics>.broadcast();
  final StreamController<SystemAlert> _alertsController = 
      StreamController<SystemAlert>.broadcast();
  
  // Configuración de monitoreo
  final MonitoringConfig _config;
  
  // Estado interno del servicio
  Timer? _metricsTimer;
  final List<SystemAlert> _activeAlerts = [];
  
  PaymentMonitoringService(
    this._performanceService,
    {MonitoringConfig? config}
  ) : _config = config ?? MonitoringConfig.defaultConfig();
  
  /// Stream de métricas de rendimiento en tiempo real
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  
  /// Stream de alertas del sistema
  Stream<SystemAlert> get alertsStream => _alertsController.stream;
  
  /// Lista de alertas activas
  List<SystemAlert> get activeAlerts => List.unmodifiable(_activeAlerts);
  
  /// Inicia el monitoreo automático
  void startMonitoring() {
    AppLogger.logInfo(
      'Iniciando monitoreo de pagos',
      className: _className,
      functionName: 'startMonitoring',
      params: {
        'metricsInterval': _config.metricsInterval.inSeconds,
        'alertThresholds': _config.alertThresholds.toString(),
      },
    );
    
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(_config.metricsInterval, (_) {
      _collectMetrics();
    });
    
    // Recopilar métricas iniciales
    _collectMetrics();
  }
  
  /// Detiene el monitoreo automático
  void stopMonitoring() {
    _metricsTimer?.cancel();
    _metricsTimer = null;
    
    AppLogger.logInfo(
      'Monitoreo de pagos detenido',
      className: _className,
      functionName: 'stopMonitoring',
    );
  }
  
  /// Obtiene métricas de rendimiento actuales
  Future<Either<Failure, PerformanceMetrics>> getCurrentMetrics() async {
    try {
      final metrics = await _calculateMetrics();
      return Right(metrics);
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener métricas actuales',
        error: e,
        className: _className,
        functionName: 'getCurrentMetrics',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Obtiene el dashboard completo de monitoreo
  Future<Either<Failure, MonitoringDashboard>> getMonitoringDashboard() async {
    try {
      final metrics = await _calculateMetrics();
      final cacheStats = _performanceService.getCacheStats();
      final systemHealth = _calculateSystemHealth(metrics, cacheStats);
      
      final dashboard = MonitoringDashboard(
        currentMetrics: metrics,
        cacheStatistics: cacheStats,
        systemHealth: systemHealth,
        activeAlerts: List.from(_activeAlerts),
        lastUpdated: DateTime.now(),
        uptime: _calculateUptime(),
      );
      
      return Right(dashboard);
    } catch (e) {
      AppLogger.logError(
        message: 'Error al generar dashboard de monitoreo',
        error: e,
        className: _className,
        functionName: 'getMonitoringDashboard',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Genera reporte de rendimiento histórico
  Future<Either<Failure, PerformanceReport>> generatePerformanceReport({
    required DateTime startDate,
    required DateTime endDate,
    String? academyId,
  }) async {
    try {
      // Simular análisis histórico
      await Future.delayed(const Duration(milliseconds: 500));
      
      final report = PerformanceReport(
        period: ReportPeriod(start: startDate, end: endDate),
        academyId: academyId,
        metrics: _generateHistoricalMetrics(startDate, endDate),
        trends: _analyzeTrends(startDate, endDate),
        insights: _generateInsights(),
        recommendations: _generateRecommendations(),
        generatedAt: DateTime.now(),
      );
      
      return Right(report);
    } catch (e) {
      AppLogger.logError(
        message: 'Error al generar reporte de rendimiento',
        error: e,
        className: _className,
        functionName: 'generatePerformanceReport',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Configura alertas personalizadas
  void configureAlerts(AlertConfiguration alertConfig) {
    _config.alertThresholds = alertConfig.thresholds;
    _config.alertChannels = alertConfig.channels;
    
    AppLogger.logInfo(
      'Configuración de alertas actualizada',
      className: _className,
      functionName: 'configureAlerts',
      params: {
        'thresholds': alertConfig.thresholds.toString(),
        'channels': alertConfig.channels.toString(),
      },
    );
  }
  
  /// Recopila métricas de rendimiento
  Future<void> _collectMetrics() async {
    try {
      final metrics = await _calculateMetrics();
      
      // Verificar alertas
      _checkAlerts(metrics);
      
      // Emitir métricas
      _metricsController.add(metrics);
      
      AppLogger.logInfo(
        'Métricas recopiladas',
        className: _className,
        functionName: '_collectMetrics',
        params: {
          'processingTime': metrics.averageProcessingTime,
          'cacheHitRatio': metrics.cacheHitRatio,
          'activeOperations': metrics.activeOperations,
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error al recopilar métricas',
        error: e,
        className: _className,
        functionName: '_collectMetrics',
      );
    }
  }
  
  /// Calcula métricas de rendimiento actuales
  Future<PerformanceMetrics> _calculateMetrics() async {
    final cacheStats = _performanceService.getCacheStats();
    
    // Simular métricas de rendimiento
    final random = Random();
    
    return PerformanceMetrics(
      timestamp: DateTime.now(),
      averageProcessingTime: 150 + random.nextInt(100), // 150-250ms
      cacheHitRatio: 0.85 + (random.nextDouble() * 0.10), // 85-95%
      activeOperations: random.nextInt(20),
      totalRequests: 1000 + random.nextInt(500),
      successfulRequests: 950 + random.nextInt(40),
      failedRequests: random.nextInt(10),
      memoryUsage: 0.65 + (random.nextDouble() * 0.20), // 65-85%
      cacheSize: cacheStats.totalEntries,
      cacheEfficiency: cacheStats.hitRatio,
      peakResponseTime: 500 + random.nextInt(300),
      minResponseTime: 50 + random.nextInt(50),
    );
  }
  
  /// Verifica umbrales de alerta
  void _checkAlerts(PerformanceMetrics metrics) {
    final thresholds = _config.alertThresholds;
    
    // Verificar tiempo de respuesta
    if (metrics.averageProcessingTime > thresholds.maxResponseTime) {
      _createAlert(
        AlertType.performance,
        'Tiempo de respuesta elevado',
        'Tiempo promedio: ${metrics.averageProcessingTime}ms (límite: ${thresholds.maxResponseTime}ms)',
        AlertSeverity.warning,
      );
    }
    
    // Verificar uso de memoria
    if (metrics.memoryUsage > thresholds.maxMemoryUsage) {
      _createAlert(
        AlertType.resource,
        'Uso de memoria elevado',
        'Uso actual: ${(metrics.memoryUsage * 100).toStringAsFixed(1)}% (límite: ${(thresholds.maxMemoryUsage * 100).toStringAsFixed(1)}%)',
        AlertSeverity.critical,
      );
    }
    
    // Verificar tasa de errores
    final errorRate = metrics.failedRequests / metrics.totalRequests;
    if (errorRate > thresholds.maxErrorRate) {
      _createAlert(
        AlertType.error,
        'Tasa de errores elevada',
        'Errores: ${(errorRate * 100).toStringAsFixed(2)}% (límite: ${(thresholds.maxErrorRate * 100).toStringAsFixed(2)}%)',
        AlertSeverity.critical,
      );
    }
    
    // Verificar eficiencia de caché
    if (metrics.cacheHitRatio < thresholds.minCacheHitRatio) {
      _createAlert(
        AlertType.cache,
        'Eficiencia de caché baja',
        'Hit ratio: ${(metrics.cacheHitRatio * 100).toStringAsFixed(1)}% (mínimo: ${(thresholds.minCacheHitRatio * 100).toStringAsFixed(1)}%)',
        AlertSeverity.warning,
      );
    }
  }
  
  /// Crea una nueva alerta
  void _createAlert(
    AlertType type,
    String title,
    String description,
    AlertSeverity severity,
  ) {
    // Verificar si ya existe una alerta similar activa
    final existingAlert = _activeAlerts.where((alert) =>
      alert.type == type && alert.title == title
    ).isNotEmpty;
    
    if (existingAlert) return;
    
    final alert = SystemAlert(
      id: _generateAlertId(),
      type: type,
      title: title,
      description: description,
      severity: severity,
      timestamp: DateTime.now(),
      isActive: true,
    );
    
    _activeAlerts.add(alert);
    _alertsController.add(alert);
    
    AppLogger.logWarning(
      'Nueva alerta generada: $title',
      className: _className,
      functionName: '_createAlert',
      params: {
        'type': type.toString(),
        'severity': severity.toString(),
        'description': description,
      },
    );
  }
  
  /// Calcula la salud general del sistema
  SystemHealth _calculateSystemHealth(
    PerformanceMetrics metrics,
    CacheStats cacheStats,
  ) {
    double score = 100.0;
    final issues = <String>[];
    
    // Evaluar tiempo de respuesta
    if (metrics.averageProcessingTime > 300) {
      score -= 20;
      issues.add('Tiempo de respuesta lento');
    }
    
    // Evaluar uso de memoria
    if (metrics.memoryUsage > 0.8) {
      score -= 15;
      issues.add('Uso de memoria elevado');
    }
    
    // Evaluar tasa de errores
    final errorRate = metrics.failedRequests / metrics.totalRequests;
    if (errorRate > 0.05) {
      score -= 25;
      issues.add('Tasa de errores alta');
    }
    
    // Evaluar eficiencia de caché
    if (metrics.cacheHitRatio < 0.8) {
      score -= 10;
      issues.add('Caché poco eficiente');
    }
    
    return SystemHealth(
      score: score.clamp(0, 100),
      status: _getHealthStatus(score),
      issues: issues,
      lastCheck: DateTime.now(),
    );
  }
  
  HealthStatus _getHealthStatus(double score) {
    if (score >= 90) return HealthStatus.excellent;
    if (score >= 75) return HealthStatus.good;
    if (score >= 60) return HealthStatus.fair;
    if (score >= 40) return HealthStatus.poor;
    return HealthStatus.critical;
  }
  
  Duration _calculateUptime() {
    // Simular tiempo de actividad
    return Duration(
      hours: Random().nextInt(24) + 24,
      minutes: Random().nextInt(60),
    );
  }
  
  List<HistoricalMetric> _generateHistoricalMetrics(
    DateTime startDate,
    DateTime endDate,
  ) {
    final metrics = <HistoricalMetric>[];
    final duration = endDate.difference(startDate);
    final days = duration.inDays;
    
    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final random = Random(date.day);
      
      metrics.add(HistoricalMetric(
        date: date,
        averageResponseTime: 150 + random.nextInt(100),
        requestCount: 800 + random.nextInt(400),
        errorRate: random.nextDouble() * 0.05,
        cacheHitRatio: 0.8 + (random.nextDouble() * 0.15),
      ));
    }
    
    return metrics;
  }
  
  TrendAnalysis _analyzeTrends(DateTime startDate, DateTime endDate) {
    final random = Random();
    
    return TrendAnalysis(
      responseTimeTrend: random.nextBool() ? TrendDirection.improving : TrendDirection.stable,
      requestVolumeTrend: TrendDirection.increasing,
      errorRateTrend: TrendDirection.improving,
      cacheEfficiencyTrend: TrendDirection.stable,
      summary: 'El rendimiento general se mantiene estable con mejoras en la tasa de errores.',
    );
  }
  
  List<PerformanceInsight> _generateInsights() {
    return [
      PerformanceInsight(
        title: 'Optimización de Caché',
        description: 'La eficiencia del caché ha mejorado un 12% esta semana',
        impact: InsightImpact.positive,
        priority: InsightPriority.medium,
      ),
      PerformanceInsight(
        title: 'Picos de Tráfico',
        description: 'Se detectaron picos de tráfico durante las horas pico (2-4 PM)',
        impact: InsightImpact.neutral,
        priority: InsightPriority.low,
      ),
      PerformanceInsight(
        title: 'Memoria RAM',
        description: 'El uso de memoria ha aumentado gradualmente. Considerar optimización.',
        impact: InsightImpact.negative,
        priority: InsightPriority.high,
      ),
    ];
  }
  
  List<PerformanceRecommendation> _generateRecommendations() {
    return [
      PerformanceRecommendation(
        title: 'Implementar Paginación',
        description: 'Agregar paginación a las consultas grandes para reducir carga en memoria',
        priority: RecommendationPriority.high,
        estimatedImpact: 'Reducción del 25% en uso de memoria',
        implementationEffort: ImplementationEffort.medium,
      ),
      PerformanceRecommendation(
        title: 'Optimizar Consultas de Base de Datos',
        description: 'Revisar y optimizar consultas más lentas identificadas',
        priority: RecommendationPriority.medium,
        estimatedImpact: 'Mejora del 15% en tiempo de respuesta',
        implementationEffort: ImplementationEffort.low,
      ),
      PerformanceRecommendation(
        title: 'Configurar Load Balancer',
        description: 'Implementar balanceador de carga para distribuir picos de tráfico',
        priority: RecommendationPriority.low,
        estimatedImpact: 'Mayor estabilidad durante picos',
        implementationEffort: ImplementationEffort.high,
      ),
    ];
  }
  
  String _generateAlertId() {
    return 'alert_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
  
  /// Libera recursos
  void dispose() {
    stopMonitoring();
    _metricsController.close();
    _alertsController.close();
  }
}

/// Configuración del servicio de monitoreo
class MonitoringConfig {
  Duration metricsInterval;
  AlertThresholds alertThresholds;
  List<AlertChannel> alertChannels;
  
  MonitoringConfig({
    required this.metricsInterval,
    required this.alertThresholds,
    this.alertChannels = const [],
  });
  
  factory MonitoringConfig.defaultConfig() {
    return MonitoringConfig(
      metricsInterval: const Duration(seconds: 30),
      alertThresholds: AlertThresholds.defaultThresholds(),
      alertChannels: [AlertChannel.log],
    );
  }
}

/// Umbrales para alertas
class AlertThresholds {
  final int maxResponseTime; // ms
  final double maxMemoryUsage; // 0.0 - 1.0
  final double maxErrorRate; // 0.0 - 1.0
  final double minCacheHitRatio; // 0.0 - 1.0
  
  const AlertThresholds({
    required this.maxResponseTime,
    required this.maxMemoryUsage,
    required this.maxErrorRate,
    required this.minCacheHitRatio,
  });
  
  factory AlertThresholds.defaultThresholds() {
    return const AlertThresholds(
      maxResponseTime: 300, // 300ms
      maxMemoryUsage: 0.85, // 85%
      maxErrorRate: 0.05, // 5%
      minCacheHitRatio: 0.75, // 75%
    );
  }
  
  @override
  String toString() {
    return 'AlertThresholds(responseTime: ${maxResponseTime}ms, memory: ${(maxMemoryUsage * 100).toStringAsFixed(1)}%, errorRate: ${(maxErrorRate * 100).toStringAsFixed(1)}%, cacheHit: ${(minCacheHitRatio * 100).toStringAsFixed(1)}%)';
  }
}

/// Configuración de alertas
class AlertConfiguration {
  final AlertThresholds thresholds;
  final List<AlertChannel> channels;
  
  const AlertConfiguration({
    required this.thresholds,
    required this.channels,
  });
}

/// Métricas de rendimiento
class PerformanceMetrics {
  final DateTime timestamp;
  final int averageProcessingTime; // ms
  final double cacheHitRatio; // 0.0 - 1.0
  final int activeOperations;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double memoryUsage; // 0.0 - 1.0
  final int cacheSize;
  final double cacheEfficiency;
  final int peakResponseTime;
  final int minResponseTime;
  
  const PerformanceMetrics({
    required this.timestamp,
    required this.averageProcessingTime,
    required this.cacheHitRatio,
    required this.activeOperations,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.memoryUsage,
    required this.cacheSize,
    required this.cacheEfficiency,
    required this.peakResponseTime,
    required this.minResponseTime,
  });
}

/// Dashboard de monitoreo
class MonitoringDashboard {
  final PerformanceMetrics currentMetrics;
  final CacheStats cacheStatistics;
  final SystemHealth systemHealth;
  final List<SystemAlert> activeAlerts;
  final DateTime lastUpdated;
  final Duration uptime;
  
  const MonitoringDashboard({
    required this.currentMetrics,
    required this.cacheStatistics,
    required this.systemHealth,
    required this.activeAlerts,
    required this.lastUpdated,
    required this.uptime,
  });
}

/// Alerta del sistema
class SystemAlert {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isActive;
  
  const SystemAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.isActive,
  });
}

/// Salud del sistema
class SystemHealth {
  final double score; // 0-100
  final HealthStatus status;
  final List<String> issues;
  final DateTime lastCheck;
  
  const SystemHealth({
    required this.score,
    required this.status,
    required this.issues,
    required this.lastCheck,
  });
}

/// Reporte de rendimiento
class PerformanceReport {
  final ReportPeriod period;
  final String? academyId;
  final List<HistoricalMetric> metrics;
  final TrendAnalysis trends;
  final List<PerformanceInsight> insights;
  final List<PerformanceRecommendation> recommendations;
  final DateTime generatedAt;
  
  const PerformanceReport({
    required this.period,
    this.academyId,
    required this.metrics,
    required this.trends,
    required this.insights,
    required this.recommendations,
    required this.generatedAt,
  });
}

/// Período del reporte
class ReportPeriod {
  final DateTime start;
  final DateTime end;
  
  const ReportPeriod({
    required this.start,
    required this.end,
  });
}

/// Métrica histórica
class HistoricalMetric {
  final DateTime date;
  final int averageResponseTime;
  final int requestCount;
  final double errorRate;
  final double cacheHitRatio;
  
  const HistoricalMetric({
    required this.date,
    required this.averageResponseTime,
    required this.requestCount,
    required this.errorRate,
    required this.cacheHitRatio,
  });
}

/// Análisis de tendencias
class TrendAnalysis {
  final TrendDirection responseTimeTrend;
  final TrendDirection requestVolumeTrend;
  final TrendDirection errorRateTrend;
  final TrendDirection cacheEfficiencyTrend;
  final String summary;
  
  const TrendAnalysis({
    required this.responseTimeTrend,
    required this.requestVolumeTrend,
    required this.errorRateTrend,
    required this.cacheEfficiencyTrend,
    required this.summary,
  });
}

/// Insight de rendimiento
class PerformanceInsight {
  final String title;
  final String description;
  final InsightImpact impact;
  final InsightPriority priority;
  
  const PerformanceInsight({
    required this.title,
    required this.description,
    required this.impact,
    required this.priority,
  });
}

/// Recomendación de rendimiento
class PerformanceRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final String estimatedImpact;
  final ImplementationEffort implementationEffort;
  
  const PerformanceRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedImpact,
    required this.implementationEffort,
  });
}

// Enumeraciones
enum AlertType { performance, resource, error, cache, security }
enum AlertSeverity { info, warning, critical }
enum AlertChannel { log, email, push, webhook }
enum HealthStatus { excellent, good, fair, poor, critical }
enum TrendDirection { improving, stable, declining, increasing }
enum InsightImpact { positive, neutral, negative }
enum InsightPriority { low, medium, high }
enum RecommendationPriority { low, medium, high }
enum ImplementationEffort { low, medium, high } 