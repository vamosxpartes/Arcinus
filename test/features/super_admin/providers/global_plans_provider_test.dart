import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/app_subscription_repository.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:arcinus/features/super_admin/presentation/providers/global_plans_provider.dart';
import 'package:arcinus/core/utils/error/failures.dart';

// Mock del repository
class MockAppSubscriptionRepository extends Mock implements AppSubscriptionRepository {}

// Fake class para AppSubscriptionPlanModel
class FakeAppSubscriptionPlanModel extends Fake implements AppSubscriptionPlanModel {}

void main() {
  late MockAppSubscriptionRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    // Registrar fallback value para mocktail
    registerFallbackValue(FakeAppSubscriptionPlanModel());
  });

  setUp(() {
    mockRepository = MockAppSubscriptionRepository();
    container = ProviderContainer(
      overrides: [
        // Override del provider del repository para usar el mock
        appSubscriptionRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GlobalPlansProvider', () {
    test('debe inicializar con estado de loading', () {
      final notifier = container.read(globalPlansProvider.notifier);
      // ignore: strict_raw_type
      expect(notifier.state, isA<AsyncLoading>());
    });

    test('debe cargar planes exitosamente', () async {
      // Arrange
      final testPlans = [
        const AppSubscriptionPlanModel(
          id: '1',
          name: 'Plan Test',
          planType: AppSubscriptionPlanType.basic,
          price: 29.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          maxAcademies: 1,
          maxUsersPerAcademy: 50,
          features: [],
          benefits: ['Test benefit'],
          isActive: true,
        ),
      ];

      when(() => mockRepository.getAvailablePlans(activeOnly: false))
          .thenAnswer((_) async => Right(testPlans));

      // Act
      final notifier = container.read(globalPlansProvider.notifier);
      await notifier.loadPlans();

      // Assert
      final state = container.read(globalPlansProvider);
      // ignore: strict_raw_type
      expect(state, isA<AsyncData>());
      expect(state.value, equals(testPlans));
      verify(() => mockRepository.getAvailablePlans(activeOnly: false)).called(1);
    });

    test('debe manejar errores al cargar planes', () async {
      // Arrange
      const failure = ServerFailure(message: 'Error de conexión');
      when(() => mockRepository.getAvailablePlans(activeOnly: false))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final notifier = container.read(globalPlansProvider.notifier);
      await notifier.loadPlans();

      // Assert
      final state = container.read(globalPlansProvider);
      // ignore: strict_raw_type
      expect(state, isA<AsyncError>());
      expect(state.error, equals('Error de conexión'));
    });

    test('debe crear un plan exitosamente', () async {
      // Arrange
      const newPlan = AppSubscriptionPlanModel(
        name: 'Nuevo Plan',
        planType: AppSubscriptionPlanType.pro,
        price: 79.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 3,
        maxUsersPerAcademy: 200,
        features: [AppFeature.advancedStats],
        benefits: ['Test benefit'],
        isActive: true,
      );

      const createdPlan = AppSubscriptionPlanModel(
        id: '2',
        name: 'Nuevo Plan',
        planType: AppSubscriptionPlanType.pro,
        price: 79.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 3,
        maxUsersPerAcademy: 200,
        features: [AppFeature.advancedStats],
        benefits: ['Test benefit'],
        isActive: true,
      );

      when(() => mockRepository.createPlan(newPlan))
          .thenAnswer((_) async => const Right(createdPlan));

      // Act
      final notifier = container.read(globalPlansProvider.notifier);
      final result = await notifier.createPlan(newPlan);

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.createPlan(newPlan)).called(1);
    });

    test('debe filtrar planes correctamente', () async {
      // Arrange
      final allPlans = [
        const AppSubscriptionPlanModel(
          id: '1',
          name: 'Plan Básico',
          planType: AppSubscriptionPlanType.basic,
          price: 29.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          maxAcademies: 1,
          maxUsersPerAcademy: 50,
          features: [],
          benefits: [],
          isActive: true,
        ),
        const AppSubscriptionPlanModel(
          id: '2',
          name: 'Plan Profesional',
          planType: AppSubscriptionPlanType.pro,
          price: 79.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          maxAcademies: 3,
          maxUsersPerAcademy: 200,
          features: [AppFeature.advancedStats],
          benefits: [],
          isActive: true,
        ),
        const AppSubscriptionPlanModel(
          id: '3',
          name: 'Plan Empresarial',
          planType: AppSubscriptionPlanType.enterprise,
          price: 299.99,
          currency: 'USD',
          billingCycle: BillingCycle.annual,
          maxAcademies: 999,
          maxUsersPerAcademy: 2000,
          features: [AppFeature.advancedStats, AppFeature.apiAccess],
          benefits: [],
          isActive: false,
        ),
      ];

      when(() => mockRepository.getAvailablePlans(activeOnly: false))
          .thenAnswer((_) async => Right(allPlans));

      // Act
      final notifier = container.read(globalPlansProvider.notifier);
      await notifier.loadPlans();

      // Test filtro por tipo de plan
      notifier.filterPlans(planType: AppSubscriptionPlanType.pro);
      
      // Assert
      final state = container.read(globalPlansProvider);
      expect(state.value?.length, equals(1));
      expect(state.value?.first.planType, equals(AppSubscriptionPlanType.pro));
    });

    test('debe actualizar un plan exitosamente', () async {
      // Arrange
      const planId = '1';

      const updatedPlan = AppSubscriptionPlanModel(
        id: planId,
        name: 'Plan Actualizado',
        planType: AppSubscriptionPlanType.basic,
        price: 39.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        maxAcademies: 1,
        maxUsersPerAcademy: 50,
        features: [],
        benefits: [],
        isActive: true,
      );

      when(() => mockRepository.updatePlan(planId, updatedPlan))
          .thenAnswer((_) async => const Right(updatedPlan));

      // Act
      final notifier = container.read(globalPlansProvider.notifier);
      final result = await notifier.updatePlan(planId, updatedPlan);

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.updatePlan(planId, updatedPlan)).called(1);
    });
  });
} 