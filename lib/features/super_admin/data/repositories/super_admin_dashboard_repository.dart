import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/super_admin/presentation/providers/super_admin_dashboard_provider.dart';

/// Modelo para las métricas del dashboard
class DashboardMetrics {
  const DashboardMetrics({
    required this.totalOwners,
    required this.pendingOwners,
    required this.activeOwners,
    required this.totalAcademies,
    required this.activeAcademies,
    required this.inactiveAcademies,
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    required this.monthlyRevenue,
    required this.revenueGrowth,
    required this.totalRevenue,
    required this.activeSessions,
    required this.averageSessionTime,
    required this.topFeatures,
    required this.systemUptime,
    required this.criticalErrors,
  });

  final int totalOwners;
  final int pendingOwners;
  final int activeOwners;
  final int totalAcademies;
  final int activeAcademies;
  final int inactiveAcademies;
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final double monthlyRevenue;
  final double revenueGrowth;
  final double totalRevenue;
  final int activeSessions;
  final double averageSessionTime;
  final List<String> topFeatures;
  final double systemUptime;
  final int criticalErrors;
}

/// Repositorio para métricas del dashboard del SuperAdmin
abstract class SuperAdminDashboardRepository {
  /// Obtiene las métricas del dashboard
  Future<Either<Failure, DashboardMetrics>> getDashboardMetrics();
  
  /// Obtiene las alertas del sistema
  Future<Either<Failure, List<SystemAlert>>> getSystemAlerts();
}

/// Implementación del repositorio usando Firestore
class SuperAdminDashboardRepositoryImpl implements SuperAdminDashboardRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'SuperAdminDashboardRepositoryImpl';

  SuperAdminDashboardRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Colección de usuarios
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  /// Colección de academias
  CollectionReference get _academiesCollection => _firestore.collection('academies');

  @override
  Future<Either<Failure, DashboardMetrics>> getDashboardMetrics() async {
    try {
      AppLogger.logInfo(
        'Calculando métricas del dashboard desde Firestore',
        className: _className,
        functionName: 'getDashboardMetrics',
      );

      // Obtener métricas de propietarios
      final ownersMetrics = await _getOwnersMetrics();
      if (ownersMetrics.isLeft()) {
        return Left(ownersMetrics.getLeft().getOrElse(() => const Failure.unexpectedError(error: 'Error desconocido')));
      }
      final owners = ownersMetrics.getRight().getOrElse(() => {'total': 0, 'active': 0, 'pending': 0});

      // Obtener métricas de academias
      final academiesMetrics = await _getAcademiesMetrics();
      if (academiesMetrics.isLeft()) {
        return Left(academiesMetrics.getLeft().getOrElse(() => const Failure.unexpectedError(error: 'Error desconocido')));
      }
      final academies = academiesMetrics.getRight().getOrElse(() => {'total': 0, 'active': 0, 'inactive': 0});

      // Obtener métricas de usuarios
      final usersMetrics = await _getUsersMetrics();
      if (usersMetrics.isLeft()) {
        return Left(usersMetrics.getLeft().getOrElse(() => const Failure.unexpectedError(error: 'Error desconocido')));
      }
      final users = usersMetrics.getRight().getOrElse(() => {'total': 0, 'active': 0, 'newThisMonth': 0});

      // Calcular ingresos (estimación)
      final revenueMetrics = _calculateRevenueMetrics(academies['total'] ?? 0);

      // Features más utilizadas (datos simulados por ahora)
      final topFeatures = [
        'Gestión de Miembros',
        'Programación de Clases',
        'Sistema de Pagos',
        'Reportes',
        'Comunicación'
      ];

      final metrics = DashboardMetrics(
        totalOwners: owners['total'] ?? 0,
        pendingOwners: owners['pending'] ?? 0,
        activeOwners: owners['active'] ?? 0,
        totalAcademies: academies['total'] ?? 0,
        activeAcademies: academies['active'] ?? 0,
        inactiveAcademies: academies['inactive'] ?? 0,
        totalUsers: users['total'] ?? 0,
        activeUsers: users['active'] ?? 0,
        newUsersThisMonth: users['newThisMonth'] ?? 0,
        monthlyRevenue: revenueMetrics['monthly'] ?? 0.0,
        revenueGrowth: revenueMetrics['growth'] ?? 0.0,
        totalRevenue: revenueMetrics['total'] ?? 0.0,
        activeSessions: users['active'] ?? 0, // Usar usuarios activos como proxy
        averageSessionTime: 24.5, // Simulado
        topFeatures: topFeatures,
        systemUptime: 99.8, // Simulado
        criticalErrors: 0, // Simulado
      );

      AppLogger.logInfo(
        'Métricas del dashboard calculadas exitosamente',
        className: _className,
        functionName: 'getDashboardMetrics',
        params: {
          'totalOwners': metrics.totalOwners,
          'totalAcademies': metrics.totalAcademies,
          'totalUsers': metrics.totalUsers,
          'monthlyRevenue': metrics.monthlyRevenue,
        },
      );

      return Right(metrics);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener métricas del dashboard',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getDashboardMetrics',
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al obtener métricas del dashboard',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getDashboardMetrics',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<SystemAlert>>> getSystemAlerts() async {
    try {
      AppLogger.logInfo(
        'Obteniendo alertas del sistema',
        className: _className,
        functionName: 'getSystemAlerts',
      );

      // Por ahora, generar alertas basadas en datos reales calculados
      final alerts = <SystemAlert>[];

      // Verificar suscripciones vencidas (simulado)
      alerts.add(SystemAlert(
        id: '1',
        title: 'Suscripciones Vencidas',
        message: 'Revisa las academias con suscripciones próximas a vencer',
        type: SystemAlertType.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionUrl: '/superadmin/subscriptions',
      ));

      // Verificar nuevos propietarios pendientes
      final ownersMetrics = await _getOwnersMetrics();
      final pendingCount = ownersMetrics.fold(
        (failure) => 0,
        (metrics) => metrics['pending'] ?? 0,
      );

      if (pendingCount > 0) {
        alerts.add(SystemAlert(
          id: '2',
          title: 'Nuevos Propietarios Pendientes',
          message: '$pendingCount propietarios esperan aprobación de cuenta',
          type: SystemAlertType.info,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          actionUrl: '/superadmin/owners',
        ));
      }

      // Alerta de respaldo (simulada)
      alerts.add(SystemAlert(
        id: '3',
        title: 'Backup del Sistema',
        message: 'El último respaldo del sistema fue exitoso',
        type: SystemAlertType.success,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ));

      AppLogger.logInfo(
        'Alertas del sistema obtenidas exitosamente',
        className: _className,
        functionName: 'getSystemAlerts',
        params: {'totalAlerts': alerts.length},
      );

      return Right(alerts);
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error al obtener alertas del sistema',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getSystemAlerts',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  /// Obtiene métricas de propietarios
  Future<Either<Failure, Map<String, int>>> _getOwnersMetrics() async {
    try {
      // Obtener todos los usuarios con rol propietario usando el campo correcto 'role'
      final ownersSnapshot = await _usersCollection
          .where('role', isEqualTo: 'propietario')
          .get();

      int total = ownersSnapshot.docs.length;
      int active = 0;
      int pending = 0;

      for (final doc in ownersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final isActive = data['isActive'] as bool? ?? true;
        final profileCompleted = data['profileCompleted'] as bool? ?? false;

        if (!profileCompleted) {
          pending++;
        } else if (isActive) {
          active++;
        }
      }

      return Right({
        'total': total,
        'active': active,
        'pending': pending,
      });
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.unexpectedError(error: e));
    }
  }

  /// Obtiene métricas de academias
  Future<Either<Failure, Map<String, int>>> _getAcademiesMetrics() async {
    try {
      final academiesSnapshot = await _academiesCollection.get();

      int total = academiesSnapshot.docs.length;
      int active = 0;
      int inactive = 0;

      for (final doc in academiesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // Determinar si está activa basado en si tiene miembros
        final membersCount = await _getAcademyMembersCount(doc.id);
        
        if (membersCount > 0) {
          active++;
        } else {
          inactive++;
        }
      }

      return Right({
        'total': total,
        'active': active,
        'inactive': inactive,
      });
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.unexpectedError(error: e));
    }
  }

  /// Obtiene métricas de usuarios
  Future<Either<Failure, Map<String, int>>> _getUsersMetrics() async {
    try {
      final allUsersSnapshot = await _usersCollection.get();
      
      int total = 0;
      int active = 0;
      int newThisMonth = 0;

      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Contar usuarios en todas las academias
      final academiesSnapshot = await _academiesCollection.get();
      
      for (final academyDoc in academiesSnapshot.docs) {
        final usersSnapshot = await _firestore
            .collection('academies')
            .doc(academyDoc.id)
            .collection('users')
            .get();
        
        total += usersSnapshot.docs.length;

        for (final userDoc in usersSnapshot.docs) {
          final data = userDoc.data();
          
          // Contar usuarios activos (han tenido actividad en los últimos 30 días)
          final updatedAt = data['updatedAt'];
          if (updatedAt is Timestamp && updatedAt.toDate().isAfter(thirtyDaysAgo)) {
            active++;
          }

          // Contar usuarios nuevos este mes
          final createdAt = data['createdAt'];
          if (createdAt is Timestamp && createdAt.toDate().isAfter(monthAgo)) {
            newThisMonth++;
          }
        }
      }

      return Right({
        'total': total,
        'active': active,
        'newThisMonth': newThisMonth,
      });
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.unexpectedError(error: e));
    }
  }

  /// Calcula métricas de ingresos
  Map<String, double> _calculateRevenueMetrics(int totalAcademies) {
    // Estimación básica: cada academia paga ~$1500 mensual
    final monthlyRevenue = totalAcademies * 1500.0;
    final totalRevenue = monthlyRevenue * 12; // Estimación anual
    final revenueGrowth = 12.5; // Crecimiento simulado

    return {
      'monthly': monthlyRevenue,
      'total': totalRevenue,
      'growth': revenueGrowth,
    };
  }

  /// Obtiene el número de miembros de una academia
  Future<int> _getAcademyMembersCount(String academyId) async {
    try {
      final snapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('users')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
} 