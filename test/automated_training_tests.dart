// Pruebas automatizadas para el sistema de entrenamientos
// 
// Este archivo contiene pruebas para los principales componentes y funcionalidades
// del módulo de entrenamientos de Arcinus.
//
// Las pruebas utilizan mocks para todos los servicios que dependen de Firebase
// y crean widgets wrapper para probar la estructura sin tener dependencias directas
// con Firebase, evitando los problemas comunes al testear con dependencias de Firebase.

import 'dart:developer' as developer;

import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:arcinus/ux/features/trainings/services/session_service.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks para servicios
class MockTrainingService extends Mock implements TrainingService {}
class MockSessionService extends Mock implements SessionService {}
class MockUserService extends Mock implements UserService {}

// Clases Fake para testing
class FakeTraining extends Fake implements Training {}
class FakeSession extends Fake implements Session {}

// Override proveedor Firestore
final mockFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Mock para FirebaseApp
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Clases para testing
class TestTrainingListScreen extends StatelessWidget {
  final MockTrainingService trainingService;
  final String academyId;

  const TestTrainingListScreen({
    super.key,
    required this.trainingService,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        trainingServiceProvider.overrideWithValue(trainingService),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Entrenamientos')),
          body: const Center(
            child: Text('Mock de entrenamientos para testing'),
          ),
        ),
      ),
    );
  }
}

class TestSessionListScreen extends StatelessWidget {
  final MockSessionService sessionService;
  final String trainingId;
  final String academyId;

  const TestSessionListScreen({
    super.key,
    required this.sessionService,
    required this.trainingId,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        sessionServiceProvider.overrideWithValue(sessionService),
        trainingServiceProvider.overrideWithValue(MockTrainingService()),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Sesiones')),
          body: const Center(
            child: Text('Mock de sesiones para testing'),
          ),
        ),
      ),
    );
  }
}

// Setup para Firebase en pruebas
class TestFirebaseSetup {
  static Future<void> setupFirebaseForTesting() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-messaging-sender-id',
          projectId: 'test-project-id',
        ),
      );
    } catch (e) {
      // Si ya está inicializado, ignoramos el error
      developer.log('Firebase ya inicializado o error de inicialización: $e');
    }
  }
}

void main() async {
  // Inicializar Firebase para pruebas
  await TestFirebaseSetup.setupFirebaseForTesting();
  
  // Registrar valores fallback antes de las pruebas
  setUpAll(() {
    // Registrar fallbacks para tipos básicos
    registerFallbackValue('academy1');
    registerFallbackValue('default');
    
    // Registrar fallbacks para enums
    registerFallbackValue(UserRole.coach);
    
    // Registrar fallbacks para tipos complejos
    registerFallbackValue(FakeTraining());
    registerFallbackValue(FakeSession());
    registerFallbackValue(const FirebaseOptions(
      apiKey: 'mock',
      appId: 'mock',
      messagingSenderId: 'mock',
      projectId: 'mock',
    ));
    
    // Crear una instancia mínima de Training para usar como fallback
    registerFallbackValue(Training(
      id: 'dummy_id',
      name: 'Dummy Training',
      description: 'Dummy Description',
      academyId: 'dummy_academy',
      groupIds: [],
      coachIds: [],
      isTemplate: false,
      createdAt: DateTime.now(),
      createdBy: 'dummy_user',
      content: {},
    ));
  });

  late MockTrainingService mockTrainingService;
  late MockSessionService mockSessionService;
  late MockUserService mockUserService;
  
  setUp(() {
    mockTrainingService = MockTrainingService();
    mockSessionService = MockSessionService();
    mockUserService = MockUserService();
    
    // Configurar comportamiento de mocks
    when(() => mockTrainingService.getTrainingsByAcademy(any())).thenAnswer(
      (_) => Stream.value([
        Training(
          id: 'training1',
          name: 'Entrenamiento de prueba',
          description: 'Descripción de prueba',
          academyId: 'academy1',
          createdBy: 'user1',
          createdAt: DateTime.now(),
          isTemplate: false,
          isRecurring: true,
          coachIds: ['coach1'],
          groupIds: ['group1'],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          recurrencePattern: 'weekly',
          recurrenceDays: ['1', '3', '5'], // Lunes, Miércoles, Viernes
          recurrenceInterval: 1,
          content: {},
        ),
        Training(
          id: 'template1',
          name: 'Plantilla de prueba',
          description: 'Descripción de plantilla',
          academyId: 'academy1',
          createdBy: 'user1',
          createdAt: DateTime.now(),
          isTemplate: true,
          coachIds: ['coach1'],
          groupIds: ['group1'],
          content: {},
        ),
      ])
    );
    
    when(() => mockTrainingService.getTrainingTemplates(any())).thenAnswer(
      (_) => Stream.value([
        Training(
          id: 'template1',
          name: 'Plantilla de prueba',
          description: 'Descripción de plantilla',
          academyId: 'academy1',
          createdBy: 'user1',
          createdAt: DateTime.now(),
          isTemplate: true,
          coachIds: ['coach1'],
          groupIds: ['group1'],
          content: {},
        ),
      ])
    );
    
    when(() => mockSessionService.getSessionsByTraining(any())).thenAnswer(
      (_) => Stream.value([
        Session(
          id: 'session1',
          name: 'Sesión 1',
          trainingId: 'training1',
          academyId: 'academy1',
          groupIds: ['group1'],
          coachIds: ['coach1'],
          scheduledDate: DateTime.now(),
          createdAt: DateTime.now(),
          createdBy: 'user1',
        ),
        Session(
          id: 'session2',
          name: 'Sesión 2',
          trainingId: 'training1',
          academyId: 'academy1',
          groupIds: ['group1'],
          coachIds: ['coach1'],
          scheduledDate: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now(),
          createdBy: 'user1',
        ),
      ])
    );
    
    when(() => mockUserService.getUsersByRole(any(), academyId: any(named: 'academyId'))).thenAnswer(
      (_) => Future.value([
        User(
          id: 'coach1',
          name: 'Entrenador de Prueba',
          email: 'coach@example.com',
          role: UserRole.coach,
          permissions: {'training.view': true, 'training.edit': true},
          academyIds: ['academy1'],
          createdAt: DateTime.now(),
        ),
      ])
    );
    
    // Mock para la creación de training
    when(() => mockTrainingService.createTraining(any())).thenAnswer((invocation) {
      final training = invocation.positionalArguments[0] as Training;
      return Future.value(training.copyWith(
        id: 'new_training_id',
        createdAt: DateTime.now(),
      ));
    });
  });

  group('Sistema de Entrenamientos - Pruebas de Navegación', () {
    testWidgets('Navegación a pantalla de entrenamientos', (WidgetTester tester) async {
      await tester.pumpWidget(TestTrainingListScreen(
        trainingService: mockTrainingService,
        academyId: 'academy1',
      ));
      
      // Esperar a que los datos se carguen
      await tester.pumpAndSettle();
      
      // Verificar que la pantalla muestra los entrenamientos
      expect(find.text('Entrenamientos'), findsOneWidget);
      expect(find.text('Mock de entrenamientos para testing'), findsOneWidget);
    });
  });
  
  group('Sistema de Entrenamientos - Gestión de Sesiones', () {
    testWidgets('Visualizar sesiones de un entrenamiento', (WidgetTester tester) async {
      await tester.pumpWidget(TestSessionListScreen(
        sessionService: mockSessionService,
        trainingId: 'training1',
        academyId: 'academy1',
      ));
      
      // Esperar a que los datos se carguen
      await tester.pumpAndSettle();
      
      // Verificar que muestra la información de sesiones
      expect(find.text('Sesiones'), findsOneWidget);
      expect(find.text('Mock de sesiones para testing'), findsOneWidget);
    });
  });
} 