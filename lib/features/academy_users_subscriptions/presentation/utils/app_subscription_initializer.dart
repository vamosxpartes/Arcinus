import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utilidad para inicializar los planes de suscripción en Firestore
class AppSubscriptionInitializer {
  final Ref _ref;
  static const String _className = 'AppSubscriptionInitializer';

  AppSubscriptionInitializer(this._ref);

  /// Inicializa los planes de suscripción predeterminados si no existen
  Future<void> initializeDefaultPlans() async {
    try {
      AppLogger.logInfo(
        'Iniciando inicialización de planes predeterminados',
        className: _className,
        functionName: 'initializeDefaultPlans',
      );

      final appSubscriptionRepository = _ref.read(appSubscriptionRepositoryProvider);

      // Verificar si ya existen planes
      final existingPlans = await appSubscriptionRepository.getAvailablePlans(
        activeOnly: false,
      );

      // Si ya hay planes creados, no hacer nada
      final shouldSkip = existingPlans.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al verificar planes existentes: ${failure.message}',
            className: _className,
            functionName: 'initializeDefaultPlans',
          );
          return false; // Continuar con la inicialización en caso de error
        },
        (plans) {
          AppLogger.logInfo(
            'Planes existentes encontrados: ${plans.length}',
            className: _className,
            functionName: 'initializeDefaultPlans',
            params: {'existingPlansCount': plans.length},
          );
          return plans.isNotEmpty;
        },
      );

      if (shouldSkip) {
        AppLogger.logInfo(
          'Saltando inicialización - planes ya existen',
          className: _className,
          functionName: 'initializeDefaultPlans',
        );
        return;
      }

      // Crear planes predeterminados
      final plans = _getDefaultPlans();
      
      AppLogger.logInfo(
        'Creando ${plans.length} planes predeterminados',
        className: _className,
        functionName: 'initializeDefaultPlans',
        params: {'plansToCreate': plans.length},
      );
      
      // Guardar cada plan en Firestore
      int createdCount = 0;
      for (final plan in plans) {
        final result = await appSubscriptionRepository.createPlan(plan);
        
        result.fold(
          (failure) {
            AppLogger.logError(
              message: 'Error al crear plan ${plan.name}: ${failure.message}',
              className: _className,
              functionName: 'initializeDefaultPlans',
              params: {'planName': plan.name},
            );
          },
          (createdPlan) {
            createdCount++;
            AppLogger.logInfo(
              'Plan creado exitosamente: ${createdPlan.name}',
              className: _className,
              functionName: 'initializeDefaultPlans',
              params: {'planId': createdPlan.id, 'planName': createdPlan.name},
            );
          },
        );
      }

      AppLogger.logInfo(
        'Inicialización completada - planes creados: $createdCount/${plans.length}',
        className: _className,
        functionName: 'initializeDefaultPlans',
        params: {'createdCount': createdCount, 'totalCount': plans.length},
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado durante inicialización de planes: $e',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'initializeDefaultPlans',
      );
    }
  }

  /// Devuelve los planes predeterminados de Arcinus
  List<AppSubscriptionPlanModel> _getDefaultPlans() {
    return [
      // Plan de Prueba - Gratuito para evaluación
      const AppSubscriptionPlanModel(
        name: 'Plan de Prueba',
        planType: AppSubscriptionPlanType.basic,
        price: 0.0,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 1,
        maxUsersPerAcademy: 10,
        features: [],
        benefits: [
          'Plan de prueba - 30 días',
          'Gestión básica de atletas',
          'Hasta 10 usuarios',
          'Soporte por email',
          'Acceso completo por tiempo limitado',
        ],
        isActive: true,
      ),
      
      // Plan Básico - Para academias pequeñas
      const AppSubscriptionPlanModel(
        name: 'Plan Básico',
        planType: AppSubscriptionPlanType.basic,
        price: 119900.0, // ~$30 USD en COP
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 1,
        maxUsersPerAcademy: 50,
        features: [],
        benefits: [
          'Gestión básica de atletas',
          'Estadísticas simples',
          'Hasta 50 usuarios',
          'Soporte por email',
        ],
        isActive: true,
      ),
      
      // Plan Profesional - Para academias medianas
      const AppSubscriptionPlanModel(
        name: 'Plan Profesional',
        planType: AppSubscriptionPlanType.pro,
        price: 319900.0, // ~$80 USD en COP
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 3,
        maxUsersPerAcademy: 200,
        features: [
          AppFeature.advancedStats,
        ],
        benefits: [
          'Gestión avanzada de atletas',
          'Estadísticas avanzadas',
          'Gestión de pagos',
          'Hasta 3 academias',
          'Hasta 200 usuarios por academia',
          'Soporte prioritario',
        ],
        isActive: true,
      ),
      
      // Plan Empresarial - Para organizaciones grandes
      const AppSubscriptionPlanModel(
        name: 'Plan Empresarial',
        planType: AppSubscriptionPlanType.enterprise,
        price: 1199900.0, // ~$300 USD en COP
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 999,
        maxUsersPerAcademy: 2000,
        features: [
          AppFeature.advancedStats,
          AppFeature.videoAnalysis,
          AppFeature.multipleAcademies,
          AppFeature.apiAccess,
          AppFeature.customization,
        ],
        benefits: [
          'Academias ilimitadas',
          'Usuarios ilimitados',
          'API completa',
          'Personalización total',
          'Análisis de video',
          'Integración personalizada',
          'Manager dedicado',
          'SLA garantizado',
        ],
        isActive: true,
      ),
      
      // Plan Anual Básico - Con descuento
      const AppSubscriptionPlanModel(
        name: 'Plan Básico Anual',
        planType: AppSubscriptionPlanType.basic,
        price: 1199900.0, // 2 meses gratis - ~$300 USD en COP
        currency: 'COP',
        billingCycle: BillingCycle.annual,
        maxAcademies: 1,
        maxUsersPerAcademy: 50,
        features: [],
        benefits: [
          'Gestión básica de atletas',
          'Estadísticas simples',
          'Hasta 50 usuarios',
          'Soporte por email',
          '17% de descuento (2 meses gratis)',
        ],
        isActive: true,
      ),
      
      // Plan Anual Profesional - Con descuento
      const AppSubscriptionPlanModel(
        name: 'Plan Profesional Anual',
        planType: AppSubscriptionPlanType.pro,
        price: 3199900.0, // 2 meses gratis - ~$800 USD en COP
        currency: 'COP',
        billingCycle: BillingCycle.annual,
        maxAcademies: 3,
        maxUsersPerAcademy: 200,
        features: [
          AppFeature.advancedStats,
        ],
        benefits: [
          'Gestión avanzada de atletas',
          'Estadísticas avanzadas',
          'Gestión de pagos',
          'Hasta 3 academias',
          'Hasta 200 usuarios por academia',
          'Soporte prioritario',
          '17% de descuento (2 meses gratis)',
        ],
        isActive: true,
      ),
    ];
  }

  /// Obtiene un plan específico por ID o crea uno de prueba
  AppSubscriptionPlanModel getTestPlan() {
    return const AppSubscriptionPlanModel(
      id: 'test-plan',
      name: 'Plan de Prueba',
      planType: AppSubscriptionPlanType.basic,
      price: 0.0,
      currency: 'COP',
      billingCycle: BillingCycle.monthly,
      maxAcademies: 1,
      maxUsersPerAcademy: 10,
      features: [],
      benefits: ['Plan de prueba - 30 días'],
      isActive: true,
    );
  }
}

/// Provider para acceder al inicializador de suscripciones
final appSubscriptionInitializerProvider = Provider<AppSubscriptionInitializer>((ref) {
  return AppSubscriptionInitializer(ref);
}); 