import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/app_subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAcademyRepository extends Mock implements AcademyRepository {}
class MockAppSubscriptionRepository extends Mock implements AppSubscriptionRepository {}

void main() {
  late AcademyRepository mockAcademyRepository;
  late AppSubscriptionRepository mockAppSubscriptionRepository;
  late ProviderContainer container;

  setUp(() {
    mockAcademyRepository = MockAcademyRepository();
    mockAppSubscriptionRepository = MockAppSubscriptionRepository();

    container = ProviderContainer(
      overrides: [
        academyRepositoryProvider.overrideWithValue(mockAcademyRepository),
        appSubscriptionRepositoryProvider.overrideWithValue(mockAppSubscriptionRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Academy Notifier', () {
    const academyId = 'test-academy-id';
    const ownerId = 'test-owner-id';
    
    final testAcademy = AcademyModel(
      id: academyId,
      ownerId: ownerId,
      name: 'Test Academy',
      sportCode: 'soccer',
      description: 'Test Description',
      address: 'Test Address',
      phone: '123456789',
      email: 'test@example.com',
    );

    final testSubscription = AppSubscriptionModel(
      id: 'subscription-id',
      ownerId: ownerId,
      planId: 'plan-id',
      status: 'active',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      plan: AppSubscriptionPlanModel(
        id: 'plan-id',
        name: 'Test Plan',
        planType: AppSubscriptionPlanType.pro,
        price: 10.0,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        features: [AppFeature.videoAnalysis, AppFeature.advancedStats],
      ),
    );

    test('should return academy when getAcademyById is successful', () async {
      // Arrange
      when(() => mockAcademyRepository.getAcademyById(academyId))
          .thenAnswer((_) async => Right(testAcademy));
      
      when(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId))
          .thenAnswer((_) async => Right(testSubscription));

      // Act
      final result = container.read(academyProvider(academyId));
      
      // Assert
      expect(result, isA<AsyncLoading<AcademyModel?>>());
      
      await container.read(academyProvider(academyId).future);
      
      // Verificar el estado final
      final finalResult = container.read(academyProvider(academyId));
      expect(finalResult.value?.id, academyId);
      expect(finalResult.value?.ownerId, ownerId);
      expect(finalResult.value?.name, 'Test Academy');
      expect(finalResult.value?.ownerSubscriptionId, 'subscription-id');
      expect(finalResult.value?.inheritedFeatures, [AppFeature.videoAnalysis, AppFeature.advancedStats]);
      
      // Verificar las llamadas
      verify(() => mockAcademyRepository.getAcademyById(academyId)).called(1);
      verify(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId)).called(1);
    });

    test('should return academy without subscription features when getOwnerSubscription fails', () async {
      // Arrange
      when(() => mockAcademyRepository.getAcademyById(academyId))
          .thenAnswer((_) async => Right(testAcademy));
      
      when(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId))
          .thenAnswer((_) async => Left(const Failure.serverError(message: 'Error obtaining subscription')));

      // Act
      final result = container.read(academyProvider(academyId));
      
      // Assert
      expect(result, isA<AsyncLoading<AcademyModel?>>());
      
      await container.read(academyProvider(academyId).future);
      
      // Verificar el estado final
      final finalResult = container.read(academyProvider(academyId));
      expect(finalResult.value?.id, academyId);
      expect(finalResult.value?.ownerId, ownerId);
      expect(finalResult.value?.name, 'Test Academy');
      expect(finalResult.value?.ownerSubscriptionId, null);
      expect(finalResult.value?.inheritedFeatures, isEmpty);
      
      // Verificar las llamadas
      verify(() => mockAcademyRepository.getAcademyById(academyId)).called(1);
      verify(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId)).called(1);
    });

    test('should return academy without subscription features when owner subscription is null', () async {
      // Arrange
      when(() => mockAcademyRepository.getAcademyById(academyId))
          .thenAnswer((_) async => Right(testAcademy));
      
      when(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = container.read(academyProvider(academyId));
      
      // Assert
      expect(result, isA<AsyncLoading<AcademyModel?>>());
      
      await container.read(academyProvider(academyId).future);
      
      // Verificar el estado final
      final finalResult = container.read(academyProvider(academyId));
      expect(finalResult.value?.id, academyId);
      expect(finalResult.value?.ownerId, ownerId);
      expect(finalResult.value?.name, 'Test Academy');
      expect(finalResult.value?.ownerSubscriptionId, null);
      expect(finalResult.value?.inheritedFeatures, isEmpty);
      
      // Verificar las llamadas
      verify(() => mockAcademyRepository.getAcademyById(academyId)).called(1);
      verify(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId)).called(1);
    });

    test('should throw exception when getAcademyById fails', () async {
      // Arrange
      when(() => mockAcademyRepository.getAcademyById(academyId))
          .thenAnswer((_) async => Left(const Failure.notFound(message: 'Academy not found')));

      // Act
      final result = container.read(academyProvider(academyId));
      
      // Assert
      expect(result, isA<AsyncLoading<AcademyModel?>>());
      
      // La operación debería fallar
      await expectLater(
        container.read(academyProvider(academyId).future),
        throwsA(isA<Exception>()),
      );
      
      // Verificar el estado final
      final finalResult = container.read(academyProvider(academyId));
      expect(finalResult.hasError, true);
      expect(finalResult.error.toString(), contains('No encontrado'));
      
      // Verificar las llamadas
      verify(() => mockAcademyRepository.getAcademyById(academyId)).called(1);
      verifyNever(() => mockAppSubscriptionRepository.getOwnerSubscription(any()));
    });

    test('should return null when academyId is empty', () async {
      // Act
      final result = container.read(academyProvider(''));
      
      // Assert
      expect(result, isA<AsyncLoading<AcademyModel?>>());
      
      await container.read(academyProvider('').future);
      
      // Verificar el estado final
      final finalResult = container.read(academyProvider(''));
      expect(finalResult.value, isNull);
      
      // Verificar que no se hicieron llamadas al repositorio
      verifyNever(() => mockAcademyRepository.getAcademyById(any()));
      verifyNever(() => mockAppSubscriptionRepository.getOwnerSubscription(any()));
    });

    // Prueba para el provider isFeatureAvailableForAcademy
    group('isFeatureAvailableForAcademy Provider', () {
      test('should return true when academy has the feature', () async {
        // Arrange
        when(() => mockAcademyRepository.getAcademyById(academyId))
            .thenAnswer((_) async => Right(testAcademy));
        
        when(() => mockAppSubscriptionRepository.getOwnerSubscription(ownerId))
            .thenAnswer((_) async => Right(testSubscription));

        // Esperar a que la academia se cargue
        await container.read(academyProvider(academyId).future);

        // Act & Assert
        expect(
          container.read(isFeatureAvailableForAcademyProvider(academyId, AppFeature.videoAnalysis)),
          true,
        );
        expect(
          container.read(isFeatureAvailableForAcademyProvider(academyId, AppFeature.advancedStats)),
          true,
        );
        expect(
          container.read(isFeatureAvailableForAcademyProvider(academyId, AppFeature.multipleAcademies)),
          false,
        );
      });

      test('should return false when academy loading or error', () async {
        // Arrange
        when(() => mockAcademyRepository.getAcademyById(academyId))
            .thenAnswer((_) async => Left(const Failure.serverError(message: 'Error')));

        // Act & Assert (sin esperar a que la carga termine)
        expect(
          container.read(isFeatureAvailableForAcademyProvider(academyId, AppFeature.videoAnalysis)),
          false,
        );
      });

      test('should return false when academy is null', () async {
        // Arrange - No hay academia
        // Act & Assert
        expect(
          container.read(isFeatureAvailableForAcademyProvider('non-existent-id', AppFeature.videoAnalysis)),
          false,
        );
      });
    });
  });
} 