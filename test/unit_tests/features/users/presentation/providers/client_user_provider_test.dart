import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/domain/repositories/client_user_repository.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockClientUserRepository extends Mock implements ClientUserRepository {}

// Fixtures
final testAcademy = AcademyModel(
  id: 'academy-id-1',
  name: 'Academia Test',
  sportCode: 'futbol',
  ownerId: 'owner-1',
);

// MIGRACIÓN: ClientUserModel ahora solo contiene campos básicos
// La información de períodos se obtiene por separado usando AthletePeriodsHelper
final testClientUser = ClientUserModel(
  id: 'client-1',
  userId: 'client-1',
  academyId: 'academy-id-1',
  clientType: AppRole.atleta,
  paymentStatus: PaymentStatus.active,
  linkedAccounts: const [],
  metadata: const {},
);

final testClientUser2 = ClientUserModel(
  id: 'client-2',
  userId: 'client-2',
  academyId: 'academy-id-1',
  clientType: AppRole.padre,
  paymentStatus: PaymentStatus.overdue,
  linkedAccounts: const [],
  metadata: const {},
);

void main() {
  late MockClientUserRepository mockClientUserRepository;
  late ProviderContainer container;

  setUp(() {
    mockClientUserRepository = MockClientUserRepository();
    
    // Configurar el container de providers con los mocks
    container = ProviderContainer(
      overrides: [
        clientUserRepositoryProvider.overrideWithValue(mockClientUserRepository),
        // Inicializar con una academia
        currentAcademyProvider.overrideWith((ref) => testAcademy),
      ],
    );
    
    addTearDown(() => container.dispose());
  });

  group('clientUserProvider', () {
    test('devuelve el usuario cliente cuando la consulta es exitosa', () async {
      // Arrange
      when(() => mockClientUserRepository.getClientUser(any(), any()))
        .thenAnswer((_) async => Right(testClientUser));
      
      // Act
      final result = await container.read(clientUserProvider('client-1').future);
      
      // Assert
      expect(result, equals(testClientUser));
      verify(() => mockClientUserRepository.getClientUser('academy-id-1', 'client-1')).called(1);
    });

    test('devuelve null cuando ocurre un error', () async {
      // Arrange
      when(() => mockClientUserRepository.getClientUser(any(), any()))
        .thenAnswer((_) async => const Left(Failure.notFound(message: 'Usuario no encontrado')));
      
      // Act
      final result = await container.read(clientUserProvider('client-1').future);
      
      // Assert
      expect(result, isNull);
      verify(() => mockClientUserRepository.getClientUser('academy-id-1', 'client-1')).called(1);
    });

    test('devuelve null cuando no hay academia actual', () async {
      // Arrange
      // Sobreescribir el provider de academia para que devuelva null
      final containerSinAcademia = ProviderContainer(
        overrides: [
          clientUserRepositoryProvider.overrideWithValue(mockClientUserRepository),
          currentAcademyProvider.overrideWith((ref) => null),
        ],
      );
      
      // Act
      final result = await containerSinAcademia.read(clientUserProvider('client-1').future);
      
      // Assert
      expect(result, isNull);
      // No se debería llamar al repository
      verifyNever(() => mockClientUserRepository.getClientUser(any(), any()));
      
      // Cleanup
      addTearDown(() => containerSinAcademia.dispose());
    });
  });

  group('clientUsersByRoleProvider', () {
    test('devuelve lista de usuarios filtrados por rol atleta', () async {
      // Arrange
      final lista = [testClientUser]; // Solo usuarios atletas
      when(() => mockClientUserRepository.getClientUsers(
        any(), 
        clientType: any(named: 'clientType'),
        paymentStatus: any(named: 'paymentStatus'),
      )).thenAnswer((_) async => Right(lista));
      
      // Act
      final result = await container.read(
        clientUsersByRoleProvider(('academy-id-1', AppRole.atleta)).future
      );
      
      // Assert
      expect(result, equals(lista));
      verify(() => mockClientUserRepository.getClientUsers(
        'academy-id-1', 
        clientType: AppRole.atleta,
        paymentStatus: null,
      )).called(1);
    });

    test('devuelve lista vacía cuando ocurre un error', () async {
      // Arrange
      when(() => mockClientUserRepository.getClientUsers(
        any(), 
        clientType: any(named: 'clientType'),
        paymentStatus: any(named: 'paymentStatus'),
      )).thenAnswer((_) async => const Left(Failure.serverError(message: 'Error de servidor')));
      
      // Act
      final result = await container.read(
        clientUsersByRoleProvider(('academy-id-1', AppRole.atleta)).future
      );
      
      // Assert
      expect(result, isEmpty);
      verify(() => mockClientUserRepository.getClientUsers(
        'academy-id-1', 
        clientType: AppRole.atleta,
        paymentStatus: null,
      )).called(1);
    });
  });

  group('clientUsersByPaymentStatusProvider', () {
    test('devuelve lista de usuarios filtrados por estado de pago activo', () async {
      // Arrange
      final lista = [testClientUser]; // Solo usuarios activos
      when(() => mockClientUserRepository.getClientUsers(
        any(), 
        clientType: any(named: 'clientType'),
        paymentStatus: any(named: 'paymentStatus'),
      )).thenAnswer((_) async => Right(lista));
      
      // Act
      final result = await container.read(
        clientUsersByPaymentStatusProvider(('academy-id-1', PaymentStatus.active)).future
      );
      
      // Assert
      expect(result, equals(lista));
      verify(() => mockClientUserRepository.getClientUsers(
        'academy-id-1', 
        clientType: null,
        paymentStatus: PaymentStatus.active,
      )).called(1);
    });

    test('devuelve lista vacía cuando ocurre un error', () async {
      // Arrange
      when(() => mockClientUserRepository.getClientUsers(
        any(), 
        clientType: any(named: 'clientType'),
        paymentStatus: any(named: 'paymentStatus'),
      )).thenAnswer((_) async => const Left(Failure.serverError(message: 'Error de servidor')));
      
      // Act
      final result = await container.read(
        clientUsersByPaymentStatusProvider(('academy-id-1', PaymentStatus.overdue)).future
      );
      
      // Assert
      expect(result, isEmpty);
      verify(() => mockClientUserRepository.getClientUsers(
        'academy-id-1', 
        clientType: null,
        paymentStatus: PaymentStatus.overdue,
      )).called(1);
    });
  });
} 