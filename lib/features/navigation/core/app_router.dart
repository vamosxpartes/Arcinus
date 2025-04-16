import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/academy/screens/academy_create_screen.dart';
import 'package:arcinus/features/app/excersice/core/models/exercise.dart';
import 'package:arcinus/features/app/excersice/screens/exercise_detail_screen.dart';
import 'package:arcinus/features/app/excersice/screens/exercise_library_screen.dart';
import 'package:arcinus/features/app/excersice/screens/exercise_selector_screen.dart';
import 'package:arcinus/features/app/trainings/core/models/training.dart';
import 'package:arcinus/features/app/trainings/screens/attendance_screen.dart';
import 'package:arcinus/features/app/trainings/screens/performance_dashboard_screen.dart';
import 'package:arcinus/features/app/trainings/screens/session_list_screen.dart';
import 'package:arcinus/features/app/trainings/screens/training_form_screen.dart';
import 'package:arcinus/features/app/trainings/screens/training_list_screen.dart';
import 'package:arcinus/features/app/users/user/screens/profile_screen.dart';
import 'package:arcinus/features/app/users/user/screens/user_management_screen.dart';
import 'package:arcinus/features/auth/screens/activation_screen.dart';
import 'package:arcinus/features/auth/screens/forgot_password_screen.dart';
import 'package:arcinus/features/auth/screens/login_screen.dart';
import 'package:arcinus/features/auth/screens/pre_register_screen.dart';
import 'package:arcinus/features/auth/screens/register_screen.dart';
import 'package:arcinus/features/auth/screens/select_academy_screen.dart';
import 'package:arcinus/features/auth/screens/signin_screen.dart';
import 'package:arcinus/features/navigation/main_screen.dart';
import 'package:arcinus/features/navigation/screens/chat_list_screen.dart';
import 'package:arcinus/features/navigation/screens/notifications_screen.dart';
import 'package:arcinus/features/navigation/screens/splash_screen.dart';
import 'package:arcinus/features/navigation/screens/under_development_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/signin': (context) => const SignInScreen(),
    '/register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/pre-register': (context) => const PreRegisterScreen(),
    '/select-academy': (context) => const SelectAcademyScreen(),
    '/main': (context) => const MainScreen(),
    '/dashboard': (context) => const MainScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/user-management': (context) => const UserManagementScreen(),
    '/create-academy': (context) => const CreateAcademyScreen(),
    '/training-list': (context) => Consumer(
      builder: (context, ref, _) => TrainingListScreen(
        academyId: ref.read(currentAcademyIdProvider) ?? '',
      ),
    ),
    '/performance-dashboard': (context) => const PerformanceDashboardScreen(),
    '/exercise-library': (context) => const ExerciseLibraryScreen(),
    '/chats': (context) => const ChatListScreen(), // Usamos la pantalla movida
    '/chat': (context) => const UnderDevelopmentScreen(title: 'Chat'), // Placeholder
    '/notifications': (context) => const NotificationsScreen(), // Usamos la pantalla movida
    '/trainings': (context) => Consumer(
      builder: (context, ref, _) => TrainingListScreen(
        academyId: ref.read(currentAcademyIdProvider) ?? '',
      ),
    ),
    '/calendar': (context) => const UnderDevelopmentScreen(title: 'Calendario'),
    '/stats': (context) => const UnderDevelopmentScreen(title: 'Estadísticas'),
    '/settings': (context) => const UnderDevelopmentScreen(title: 'Configuración'),
    '/payments': (context) => const UnderDevelopmentScreen(title: 'Pagos'),
    '/academies': (context) => const UnderDevelopmentScreen(title: 'Academias'),
    '/academy-details': (context) => const UnderDevelopmentScreen(title: 'Detalles de Academia'),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    developer.log('DEBUG: AppRouter.onGenerateRoute - Name: ${settings.name}, Args: ${settings.arguments}');

    if (settings.name == '/activate') {
      final academyId = settings.arguments as String?;
      if (academyId != null) {
        return MaterialPageRoute(
          builder: (context) => ActivationScreen(academyId: academyId),
        );
      } else {
        developer.log('ERROR: AppRouter.onGenerateRoute - /activate llamado sin academyId, redirigiendo a selección');
        return MaterialPageRoute(builder: (context) => const SelectAcademyScreen());
      }
    }

    if (settings.name?.startsWith('/trainings/') ?? false) {
      return MaterialPageRoute(
        builder: (context) {
          return Consumer(
            builder: (context, ref, _) {
              final academyId = ref.read(currentAcademyIdProvider) ?? '';

              switch (settings.name) {
                case '/trainings/new':
                  return TrainingFormScreen(
                    academyId: academyId,
                  );

                case '/trainings/template/new':
                  return TrainingFormScreen(
                    academyId: academyId,
                    isTemplate: true,
                  );

                case '/trainings/edit':
                  final training = settings.arguments as Training;
                  return TrainingFormScreen(
                    academyId: academyId,
                    training: training,
                    isTemplate: training.isTemplate,
                  );

                case '/trainings/sessions':
                  final trainingId = settings.arguments as String;
                  return SessionListScreen(
                    trainingId: trainingId,
                    academyId: academyId,
                  );

                case '/trainings/attendance':
                  final sessionId = settings.arguments as String;
                  return AttendanceScreen(
                    sessionId: sessionId,
                    academyId: academyId,
                  );

                case '/trainings/performance':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return PerformanceDashboardScreen(
                    athleteId: args?['athleteId'] as String?,
                    groupId: args?['groupId'] as String?,
                    trainingId: args?['trainingId'] as String?,
                    academyId: args?['academyId'] as String? ?? academyId,
                  );

                case '/trainings/exercises':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return ExerciseSelectorScreen(
                    initiallySelectedExercises: args?['selectedExercises'] as List<Exercise>?,
                    allowMultiple: args?['allowMultiple'] as bool? ?? true,
                  );
                default:
                  return const UnderDevelopmentScreen(title: 'Ruta de Entrenamiento no encontrada');
              }
            },
          );
        },
      );
    }

    if (settings.name == '/exercise-details') {
      final exercise = settings.arguments as Exercise;
      return MaterialPageRoute(
        builder: (context) => Consumer(
          builder: (context, ref, _) => ExerciseDetailScreen(
            exercise: exercise,
            academyId: ref.read(currentAcademyIdProvider) ?? '',
          ),
        ),
      );
    }
    if (settings.name == '/exercise-selector') {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (context) => ExerciseSelectorScreen(
          initiallySelectedExercises: args?['selectedExercises'] as List<Exercise>?,
          allowMultiple: args?['allowMultiple'] as bool? ?? true,
        ),
      );
    }

    developer.log('WARN: AppRouter.onGenerateRoute - Ruta no manejada: ${settings.name}');
    // Si la ruta no está en el mapa de rutas principales Y no fue manejada por onGenerateRoute,
    // puede que sea una ruta base que no requiere generación dinámica.
    // Devolver null aquí permite que MaterialApp intente buscarla en el mapa `routes`.
    return null; 
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    developer.log('WARN: AppRouter.onUnknownRoute - Ruta desconocida: ${settings.name}');
    return MaterialPageRoute(
      builder: (context) => const UnderDevelopmentScreen(
        title: 'Página no encontrada',
      ),
    );
  }
} 