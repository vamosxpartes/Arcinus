import 'package:arcinus/features/payments/data/models/client_user_model.dart';
import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utilidad para inicializar los planes de suscripción en Firestore
class AppSubscriptionInitializer {
  final Ref _ref;

  AppSubscriptionInitializer(this._ref);

  /// Inicializa los planes de suscripción predeterminados si no existen
  Future<void> initializeDefaultPlans() async {
    final appSubscriptionRepository = _ref.read(appSubscriptionRepositoryProvider);

    // Verificar si ya existen planes
    final existingPlans = await appSubscriptionRepository.getAvailablePlans(
      activeOnly: false,
    );

    // Si ya hay planes creados, no hacer nada
    if (existingPlans.isRight() && 
        (existingPlans.getRight() as List<AppSubscriptionPlanModel>).isNotEmpty) {
      return;
    }

    // Crear planes predeterminados
    final plans = _getDefaultPlans();
    
    // Guardar cada plan en Firestore
    for (final plan in plans) {
      await appSubscriptionRepository.createPlan(plan);
    }
  }

  /// Devuelve los planes predeterminados
  List<AppSubscriptionPlanModel> _getDefaultPlans() {
    return [
      // Plan Gratuito
      AppSubscriptionPlanModel(
        name: 'Plan Gratuito',
        planType: AppSubscriptionPlanType.free,
        price: 0,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 1,
        maxUsersPerAcademy: 10,
        features: [
          AppFeature.multipleAcademies,
        ],
        benefits: [
          '1 academia',
          'Máximo 10 usuarios',
          'Funciones básicas',
        ],
      ),

      // Plan Básico
      AppSubscriptionPlanModel(
        name: 'Plan Básico',
        planType: AppSubscriptionPlanType.basic,
        price: 50000,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 2,
        maxUsersPerAcademy: 30,
        features: [
          AppFeature.multipleAcademies,
          AppFeature.advancedStats,
        ],
        benefits: [
          'Hasta 2 academias',
          'Máximo 30 usuarios por academia',
          'Estadísticas avanzadas',
          'Soporte por email',
        ],
      ),

      // Plan Profesional
      AppSubscriptionPlanModel(
        name: 'Plan Profesional',
        planType: AppSubscriptionPlanType.pro,
        price: 120000,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 5,
        maxUsersPerAcademy: 100,
        features: [
          AppFeature.multipleAcademies,
          AppFeature.advancedStats,
          AppFeature.videoAnalysis,
        ],
        benefits: [
          'Hasta 5 academias',
          'Máximo 100 usuarios por academia',
          'Análisis de video',
          'Estadísticas avanzadas',
          'Soporte prioritario',
        ],
      ),

      // Plan Empresarial
      AppSubscriptionPlanModel(
        name: 'Plan Empresarial',
        planType: AppSubscriptionPlanType.enterprise,
        price: 300000,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 10,
        maxUsersPerAcademy: 500,
        features: [
          AppFeature.multipleAcademies,
          AppFeature.advancedStats,
          AppFeature.videoAnalysis,
          AppFeature.apiAccess,
          AppFeature.customization,
        ],
        benefits: [
          'Hasta 10 academias',
          'Usuarios ilimitados por academia',
          'Todas las características disponibles',
          'API para integraciones',
          'Personalización de la plataforma',
          'Soporte dedicado 24/7',
        ],
      ),
    ];
  }
}

/// Provider para acceder al inicializador de suscripciones
final appSubscriptionInitializerProvider = Provider<AppSubscriptionInitializer>((ref) {
  return AppSubscriptionInitializer(ref);
}); 