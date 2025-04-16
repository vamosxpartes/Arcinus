import 'dart:async';
import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/academy/screens/academy_create_screen.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/auth/screens/login_screen.dart';
import 'package:arcinus/features/navigation/core/app_router.dart';
import 'package:arcinus/features/navigation/core/services/route_observer.dart';
import 'package:arcinus/features/navigation/main_screen.dart';
import 'package:arcinus/features/navigation/screens/splash_screen.dart';
import 'package:arcinus/features/navigation/utils/exit_confirmation.dart';
import 'package:arcinus/features/storage/storage_firebase/analytics_service.dart';
import 'package:arcinus/features/theme/core/app_theme.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsObserver = AnalyticsService().getAnalyticsObserver();
    final authStateChanges = ref.watch(authStateChangesProvider);
    final splashCompleted = ref.watch(splashCompletedProvider);
    
    // Observador de rutas personalizado
    final appRouteObserver = AppRouteObserver(ref);
    
    // Asegurar que se cargue la academia automáticamente
    ref.watch(autoLoadAcademyProvider);
    
    // Crear un efecto para realizar carga inicial de academias cuando cambie el estado de autenticación
    ref.listen(authStateChangesProvider, (previous, next) {
      if (next.hasValue && next.valueOrNull != null) {
        // Cuando el usuario se autentica, iniciar la carga de academias
        developer.log('DEBUG: App - Usuario autenticado via stream, iniciando carga de academias');
        ref.invalidate(userAcademiesProvider);
      }
    });
    
    // Observar cambios en la academia actual para depuración
    ref.listen(currentAcademyProvider, (previous, current) {
      if (current != previous) {
        if (current != null) {
          developer.log('DEBUG: App - Academia actual cambiada: ${current.academyId} - ${current.academyName}');
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
        home: StatefulBuilder(
          builder: (context, setState) {
            // Usar initState en un StatefulBuilder para manejar correctamente la vida útil
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Agregar un delay y verificar si el contexto sigue siendo válido
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  ref.read(splashCompletedProvider.notifier).state = true;
                }
              });
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
        appRouteObserver,
      ],
      builder: (context, child) {
        // Envolver la aplicación en PopScope para manejar el botón de retroceso en Android
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            
            final navigatorState = Navigator.of(context);
            
            // Si se puede hacer pop en el navigator, hacer pop normalmente
            if (navigatorState.canPop()) {
              navigatorState.pop();
              return;
            }
            
            // Si no se puede hacer pop, mostrar diálogo de confirmación
            final shouldExit = await confirmAppExit(context, ref); // Usar la función importada
            if (shouldExit) {
              // Salir de la aplicación
              await SystemNavigator.pop();
            }
          },
          child: child!,
        );
      },
      // Usamos authStateChangesProvider para determinar la pantalla inicial
      home: authStateChanges.when(
        loading: () => const LoadingScreen(), // Usar el widget importado
        error: (error, stackTrace) {
          // Loguear el error y mostrar LoginScreen como fallback
          developer.log('ERROR: App - Error en authStateChanges stream', error: error, stackTrace: stackTrace);
          return const LoginScreen(); 
        },
        data: (user) {
          // La lógica aquí permanece igual: si user es null -> Login, si no -> verificar academia o MainScreen
          if (user == null) {
            developer.log('DEBUG: App - No hay usuario (authStateChanges), mostrando LoginScreen');
            return const LoginScreen();
          } else {
            developer.log('DEBUG: App - Usuario autenticado (authStateChanges): ${user.id}, Rol: ${user.role}');
            // Verificar si el usuario es propietario y necesita crear academia
            return Consumer(
              builder: (context, ref, child) {
                final needsAcademyCreation = ref.watch(needsAcademyCreationProvider);
                
                return needsAcademyCreation.when(
                  data: (needsCreation) {
                    developer.log('DEBUG: Usuario autenticado, rol: ${user.role}, necesita crear academia: $needsCreation');
                    if (user.role == UserRole.owner && needsCreation) {
                      developer.log('DEBUG: Redirigiendo a crear academia');
                      return const CreateAcademyScreen();
                    } else {
                      developer.log('DEBUG: Redirigiendo a dashboard (MainScreen)');
                      return const MainScreen();
                    }
                  },
                  loading: () => const LoadingScreen(), // Usar el widget importado
                  error: (error, stack) {
                    developer.log('DEBUG: Error verificando si necesita crear academia: $error');
                    // Fallback a MainScreen en caso de error
                    return const MainScreen(); 
                  },
                );
              },
            );
          }
        },
      ),
      routes: AppRouter.routes, // Usar las rutas importadas
      onGenerateRoute: AppRouter.onGenerateRoute, // Usar el generador importado
      onUnknownRoute: AppRouter.onUnknownRoute, // Usar el manejador importado
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