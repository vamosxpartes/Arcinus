import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:arcinus/config/firebase/analytics_service.dart';
import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/theme/app_theme.dart';
import 'package:arcinus/ui/features/auth/screens/forgot_password_screen.dart';
import 'package:arcinus/ui/features/auth/screens/login_screen.dart';
import 'package:arcinus/ui/features/auth/screens/profile_screen.dart';
import 'package:arcinus/ui/features/auth/screens/register_screen.dart';
import 'package:arcinus/ui/features/auth/screens/user_management_screen.dart';
import 'package:arcinus/ui/features/home/screens/main_screen.dart';
import 'package:arcinus/ui/features/splash/splash_screen.dart';
import 'package:arcinus/ui/features/trainings/attendance_screen.dart';
import 'package:arcinus/ui/features/trainings/performance_dashboard_screen.dart';
import 'package:arcinus/ui/features/trainings/session_list_screen.dart';
import 'package:arcinus/ui/features/trainings/training_form_screen.dart';
import 'package:arcinus/ui/features/trainings/training_list_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para controlar cuando se ha cargado el splash
final splashCompletedProvider = StateProvider<bool>((ref) => false);

// Provider para controlar si se muestra el diálogo de confirmación para salir
final confirmExitProvider = StateProvider<bool>((ref) => true);

class ArcinusApp extends ConsumerWidget {
  const ArcinusApp({super.key});

  // Método para confirmar la salida de la aplicación
  Future<bool> _confirmExit(BuildContext context, WidgetRef ref) async {
    // Si la característica está desactivada, permitir salir directamente
    if (!ref.read(confirmExitProvider)) {
      return true;
    }
    
    // En iOS, no es común mostrar diálogos de confirmación para salir
    if (Platform.isIOS) {
      return true;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Seguro que quieres salir?'),
        content: const Text('¿Estás seguro de que quieres salir de Arcinus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsObserver = AnalyticsService().getAnalyticsObserver();
    final authState = ref.watch(authStateProvider);
    final splashCompleted = ref.watch(splashCompletedProvider);
    
    // Asegurar que se cargue la academia automáticamente
    ref.watch(autoLoadAcademyProvider);
    
    // Crear un efecto para realizar carga inicial de academias cuando cambie el estado de autenticación
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasValue && next.valueOrNull != null) {
        // Cuando el usuario se autentica, iniciar la carga de academias
        developer.log('DEBUG: App - Usuario autenticado, iniciando carga de academias');
        ref.invalidate(userAcademiesProvider);
      }
    });
    
    // Observar cambios en la academia actual para depuración
    ref.listen(currentAcademyProvider, (previous, current) {
      if (current != previous) {
        if (current != null) {
          developer.log('DEBUG: App - Academia actual cambiada: ${current.id} - ${current.name}');
        } else {
          developer.log('DEBUG: App - Academia actual limpiada (null)');
        }
      }
    });
    
    // Si el splash no ha terminado, lo mostramos
    if (!splashCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        home: Consumer(
          builder: (context, ref, _) {
            // Simulamos una carga por 2 segundos y luego marcamos el splash como completado
            Future.delayed(const Duration(seconds: 2), () {
              ref.read(splashCompletedProvider.notifier).state = true;
            });
            return const SplashScreen();
          },
        ),
      );
    }
    
    return MaterialApp(
      title: 'Arcinus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      navigatorObservers: [
        if (analyticsObserver != null) analyticsObserver,
      ],
      builder: (context, child) {
        // Envolver la aplicación en WillPopScope para manejar el botón de retroceso en Android
        return PopScope(
          canPop: false,
          // ignore: deprecated_member_use
          onPopInvoked: (didPop) async {
            if (didPop) return;
            
            final navigatorState = Navigator.of(context);
            
            // Si se puede hacer pop en el navigator, hacer pop normalmente
            if (navigatorState.canPop()) {
              navigatorState.pop();
              return;
            }
            
            // Si no se puede hacer pop, mostrar diálogo de confirmación
            final shouldExit = await _confirmExit(context, ref);
            if (shouldExit) {
              // Salir de la aplicación
              await SystemNavigator.pop();
            }
          },
          child: child!,
        );
      },
      // Usamos un consumer builder para determinar si mostrar la pantalla de login o la de dashboard
      home: authState.when(
        loading: () => const LoadingScreen(),
        error: (_, __) => const LoginScreen(),
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          } else {
            // Verificar si el usuario es propietario y necesita crear academia
            return Consumer(
              builder: (context, ref, child) {
                final needsAcademyCreation = ref.watch(needsAcademyCreationProvider);
                
                return needsAcademyCreation.when(
                  data: (needsCreation) {
                    developer.log('DEBUG: Usuario autenticado, rol: ${user.role}, necesita crear academia: $needsCreation');
                    if (user.role == UserRole.owner && needsCreation) {
                      developer.log('DEBUG: Redirigiendo a crear academia');
                      return const UnderDevelopmentScreen(title: 'Crear Academia');
                    } else {
                      developer.log('DEBUG: Redirigiendo a dashboard');
                      return const MainScreen();
                    }
                  },
                  loading: () => const LoadingScreen(),
                  error: (error, stack) {
                    developer.log('DEBUG: Error verificando si necesita crear academia: $error');
                    return const MainScreen();
                  },
                );
              },
            );
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/dashboard': (context) {
          // En lugar de crear una nueva instancia, navegamos a MainScreen 
          // que ya contiene el DashboardScreen y establecemos el índice a 0
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen())
            );
          });
          // Devolvemos un widget temporal mientras se realiza la navegación
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
        '/users-management': (context) => const UserManagementScreen(),
        '/chats': (context) => const UnderDevelopmentScreen(title: 'Chats'),
        '/chat': (context) => const UnderDevelopmentScreen(title: 'Chat'),
        '/notifications': (context) => const UnderDevelopmentScreen(title: 'Notificaciones'),
        '/trainings': (context) => TrainingListScreen(
          academyId: ref.read(currentAcademyIdProvider) ?? '',
        ),
        '/calendar': (context) => const UnderDevelopmentScreen(title: 'Calendario'),
        '/stats': (context) => const UnderDevelopmentScreen(title: 'Estadísticas'),
        '/settings': (context) => const UnderDevelopmentScreen(title: 'Configuración'),
        '/payments': (context) => const UnderDevelopmentScreen(title: 'Pagos'),
        '/academies': (context) => const UnderDevelopmentScreen(title: 'Academias'),
        '/create-academy': (context) => const UnderDevelopmentScreen(title: 'Crear Academia'),
        '/academy-details': (context) => const UnderDevelopmentScreen(title: 'Detalles de Academia'),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/trainings/') ?? false) {
          final academyId = ref.read(currentAcademyIdProvider) ?? '';
          
          switch (settings.name) {
            case '/trainings/new':
              return MaterialPageRoute(
                builder: (context) => TrainingFormScreen(
                  academyId: academyId,
                ),
              );
              
            case '/trainings/template/new':
              return MaterialPageRoute(
                builder: (context) => TrainingFormScreen(
                  academyId: academyId,
                  isTemplate: true,
                ),
              );
              
            case '/trainings/edit':
              final training = settings.arguments as Training;
              return MaterialPageRoute(
                builder: (context) => TrainingFormScreen(
                  academyId: academyId,
                  training: training,
                  isTemplate: training.isTemplate,
                ),
              );
              
            case '/trainings/sessions':
              final trainingId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => SessionListScreen(
                  trainingId: trainingId,
                  academyId: academyId,
                ),
              );
              
            case '/trainings/attendance':
              final sessionId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => AttendanceScreen(
                  sessionId: sessionId,
                  academyId: academyId,
                ),
              );
              
            case '/trainings/performance':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => PerformanceDashboardScreen(
                  athleteId: args?['athleteId'] as String?,
                  groupId: args?['groupId'] as String?,
                  trainingId: args?['trainingId'] as String?,
                  academyId: args?['academyId'] as String? ?? academyId,
                ),
              );
          }
        }
        
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const UnderDevelopmentScreen(
            title: 'Página no encontrada',
          ),
        );
      },
    );
  }
}

// Pantalla de carga
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                isDarkMode ? 'assets/icons/Logo_white.png' : 'assets/icons/Logo_black.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.sports, size: 120),
              ),
              const SizedBox(height: 32),
              // Indicador de carga
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de lista de chats
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,  // Chats de ejemplo
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text('Chat ${index + 1}'),
              subtitle: Text(index % 2 == 0 
                  ? 'Último mensaje recibido' 
                  : 'Tú: Último mensaje enviado'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '12:${index * 5}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (index % 3 == 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Navegación a chat individual
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat individual en desarrollo')),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crear nuevo chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear chat en desarrollo')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Pantalla de notificaciones
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 15, // Notificaciones de ejemplo
          itemBuilder: (context, index) {
            // Alternamos tipos de notificaciones para el ejemplo
            final notificationType = index % 4;
            IconData icon;
            Color color;
            String title;
            String time = '${index + 1}h';
            
            switch (notificationType) {
              case 0:
                icon = Icons.calendar_today;
                color = Colors.blue;
                title = 'Nueva clase programada';
                break;
              case 1:
                icon = Icons.person_add;
                color = Colors.green;
                title = 'Nuevo usuario registrado';
                break;
              case 2:
                icon = Icons.money;
                color = Colors.orange;
                title = 'Pago registrado';
                break;
              default:
                icon = Icons.announcement;
                color = Colors.red;
                title = 'Anuncio importante';
            }
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(60),
                  child: Icon(icon, color: color),
                ),
                title: Text(title),
                subtitle: Text('Detalles de la notificación ${index + 1}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hace $time',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    if (index < 5)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Acción al pulsar en la notificación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Abrir notificación $index')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Pantalla para secciones en desarrollo
class UnderDevelopmentScreen extends StatelessWidget {
  final String title;
  
  const UnderDevelopmentScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'En desarrollo',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Esta funcionalidad se encuentra actualmente en desarrollo. ¡Vuelve pronto!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 