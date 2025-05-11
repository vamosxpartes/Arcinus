import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/create_academy_screen.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/academy_screen.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/complete_profile_screen.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/member_access_screen.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/register_screen.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/welcome_screen.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/features/splash/presentation/screens/splash_screen.dart';
import 'package:arcinus/features/utils/screens/screen_under_development.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/features/memberships/presentation/screens/invite_member_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/add_athlete_screen.dart';
import 'package:arcinus/features/academies/presentation/screens/edit_academy_screen.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_members_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/edit_permissions_screen.dart';
import 'package:arcinus/features/theme/ui/feedback/error_display.dart';
import 'package:arcinus/features/payments/presentation/screens/payments_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/athlete_payments_screen.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/core/utils/app_logger.dart';

// Importar providers necesarios
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';

// Importar los nuevos Shell Widgets
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/navigation_shells/super_admin_shell/super_admin_shell.dart';

import 'package:arcinus/features/users/presentation/ui/screens/profile_screen.dart';

/// Provider que expone el router de la aplicación.
final routerProvider = Provider<GoRouter>((ref) {
  AppLogger.logInfo(
    'Creando instancia de GoRouter',
    className: 'AppRouter',
    functionName: 'routerProvider',
  );
  
  try {
    // Observar el estado de autenticación para el refreshListenable
    final authStateListenable = GoRouterRefreshStream(ref, authStateNotifierProvider);
    AppLogger.logInfo(
      'GoRouterRefreshStream creado',
      className: 'AppRouter',
      functionName: 'routerProvider',
    );

    // Clave global para el Navigator principal
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    // Claves separadas para los Navigators de cada Shell
    final ownerShellNavigatorKey        = GlobalKey<NavigatorState>(debugLabel: 'ownerShell');
    final superAdminShellNavigatorKey   = GlobalKey<NavigatorState>(debugLabel: 'superAdminShell');

    AppLogger.logInfo(
      'Claves de navegación creadas',
      className: 'AppRouter',
      functionName: 'routerProvider',
    );

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: authStateListenable, // Escuchar solo cambios de AuthState
      redirect: (BuildContext context, GoRouterState state) async {
        AppLogger.logInfo(
          'Redirección iniciada',
          className: 'AppRouter',
          functionName: 'redirect',
          params: {
            'rutaActual': state.matchedLocation,
            'rutaDestino': state.uri.toString(),
          },
        );
        
        // --- Leer el estado de autenticación y perfil ---
        final authState = ref.read(authStateNotifierProvider);
        final isLoggedIn = authState.isAuthenticated;
        final currentUserId = authState.user?.id;
        final userRole = authState.user?.role;
        
        AppLogger.logInfo(
          'Estado de autenticación',
          className: 'AppRouter',
          functionName: 'redirect',
          params: {
            'isLoggedIn': isLoggedIn.toString(),
            'userId': currentUserId ?? 'null',
            'role': userRole?.name ?? 'null',
          },
        );

        // --- Definir rutas públicas/de autenticación ---
        final publicRoutes = [
          AppRoutes.splash,
          AppRoutes.welcome,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.memberAccess,
          AppRoutes.forgotPassword,
        ];

        // --- Definir rutas intermedias post-login ---
        final intermediateRoutes = [
          AppRoutes.completeProfile,
          AppRoutes.createAcademy,
        ];

        final currentLocation = state.matchedLocation;
        final isGoingToPublic = publicRoutes.contains(currentLocation);
        final isGoingToIntermediate = intermediateRoutes.contains(currentLocation);
        final isGoingToSplash = currentLocation == AppRoutes.splash;
        
        AppLogger.logInfo(
          'Categorías de ruta',
          className: 'AppRouter',
          functionName: 'redirect',
          params: {
            'isPublic': isGoingToPublic.toString(),
            'isIntermediate': isGoingToIntermediate.toString(),
            'isSplash': isGoingToSplash.toString(),
          },
        );

        // --- Lógica de Splash ---
        if (authState == const AuthState.initial() || (authState.isLoading && isGoingToSplash)) {
           AppLogger.logInfo(
             'Decisión: Mantener en Splash (inicial/cargando)',
             className: 'AppRouter',
             functionName: 'redirect',
           );
           return isGoingToSplash ? null : AppRoutes.splash;
        }
        if (isGoingToSplash && !(authState == const AuthState.initial()) && !authState.isLoading) {
           // Si el usuario está autenticado, redirigir a la ruta apropiada según la lógica subsiguiente
           if (isLoggedIn) {
             // Si necesita completar perfil, redirigir a completar perfil
             if (currentUserId != null) {
               final profileState = ref.read(userProfileProvider(currentUserId));
               final needsProfileCompletion = profileState.maybeWhen(
                 data: (profile) => profile == null || (profile.name?.isEmpty ?? true),
                 loading: () => false,
                 orElse: () => false,
               );

               if (needsProfileCompletion) {
                 AppLogger.logInfo(
                   'Decisión: Desde Splash - necesita completar perfil',
                   className: 'AppRouter',
                   functionName: 'redirect',
                 );
                 return AppRoutes.completeProfile;
               }

               // Si es propietario, verificar si necesita crear academia
               if (userRole == AppRole.propietario) {
                 final academiesState = ref.read(ownerHasAcademiesProvider(currentUserId));
                 final needsToCreateAcademy = academiesState.maybeWhen(
                   data: (hasAcademies) => !hasAcademies,
                   loading: () => false,
                   orElse: () => false,
                 );

                 if (needsToCreateAcademy) {
                   AppLogger.logInfo(
                     'Decisión: Desde Splash - propietario necesita crear academia',
                     className: 'AppRouter',
                     functionName: 'redirect',
                   );
                   return AppRoutes.createAcademy;
                 }
               }

               // Si no necesita completar perfil ni crear academia, redirigir a la ruta del rol
               final targetRoute = _getRoleRootRoute(userRole);
               AppLogger.logInfo(
                 'Decisión: Desde Splash a ruta de rol',
                 className: 'AppRouter',
                 functionName: 'redirect',
                 params: {'rutaDestino': targetRoute},
               );
               return targetRoute;
             }
           } else {
             AppLogger.logInfo(
               'Decisión: Desde Splash a Welcome',
               className: 'AppRouter',
               functionName: 'redirect',
             );
             return AppRoutes.welcome;
           }
        }

        // --- Lógica Principal de Redirección ---
        if (!isLoggedIn) {
          if (!isGoingToPublic) {
            AppLogger.logInfo(
              'Decisión: No autenticado, redirigiendo a Welcome',
              className: 'AppRouter',
              functionName: 'redirect',
            );
            return AppRoutes.welcome;
          }
          AppLogger.logInfo(
            'Decisión: No autenticado, permaneciendo en ruta pública',
            className: 'AppRouter',
            functionName: 'redirect',
          );
          return null; // Stay on public route
        }

        // --- Usuario Logueado ---
        if (currentUserId == null) {
          AppLogger.logInfo(
            'Decisión: Autenticado pero sin userId, redirigiendo a Welcome',
            className: 'AppRouter',
            functionName: 'redirect',
          );
          return AppRoutes.welcome;
        }

        // 1. ¿Necesita completar perfil?
        AsyncValue<dynamic> profileState;
        
        // Caso especial: Si estamos en la pantalla de completar perfil,
        // asumimos que el usuario ha completado o está completando su perfil
        if (currentLocation == AppRoutes.completeProfile) {
          // Esto es crítico: si el usuario ya ha completado su perfil,
          // debemos permitirle continuar y no quedarnos en un bucle
          final needsProfileCompletion = false;
          
          AppLogger.logInfo(
            'Estado de perfil (en pantalla de completar perfil)',
            className: 'AppRouter',
            functionName: 'redirect',
            params: {'needsCompletion': needsProfileCompletion.toString()},
          );
          
          // No necesita redirección mientras está en completar perfil
          if (needsProfileCompletion == false) {
            AppLogger.logInfo(
              'Decisión: En pantalla de completar perfil, sin redirección',
              className: 'AppRouter',
              functionName: 'redirect',
            );
            return null;
          }
        }
        
        // Para otras rutas, verificar normalmente
        profileState = ref.read(userProfileProvider(currentUserId));
        final needsProfileCompletion = profileState.maybeWhen(
          data: (profile) {
            // Verificar si hay un perfil y tiene nombre (verificación simple)
            final hasProfile = profile != null;
            final hasName = hasProfile && 
                ((profile.toString().contains('displayName') && 
                  profile.toString().contains('displayName: ') && 
                  !profile.toString().contains('displayName: null')) ||
                 (profile.toString().contains('name') && 
                  profile.toString().contains('name: ') && 
                  !profile.toString().contains('name: null')));
            
            return !hasProfile || !hasName;
          },
          loading: () => false, // Durante la carga permitimos continuar
          error: (_, __) => true, // En caso de error, asumir que necesita completar
          orElse: () => true, // Por defecto, asumir que necesita completar
        );
        
        AppLogger.logInfo(
          'Estado de perfil',
          className: 'AppRouter',
          functionName: 'redirect',
          params: {'needsCompletion': needsProfileCompletion.toString()},
        );

        if (needsProfileCompletion) {
            if (currentLocation != AppRoutes.completeProfile) {
              AppLogger.logInfo(
                'Decisión: Necesita completar perfil, redirigiendo a CompleteProfile',
                className: 'AppRouter',
                functionName: 'redirect',
              );
              return AppRoutes.completeProfile;
            }
            AppLogger.logInfo(
              'Decisión: Necesita completar perfil, permaneciendo en CompleteProfile',
              className: 'AppRouter',
              functionName: 'redirect',
            );
            return null; // Stay on complete profile
        }
        if (currentLocation == AppRoutes.completeProfile && !needsProfileCompletion) {
            final targetRoute = _getRoleRootRoute(userRole);
            AppLogger.logInfo(
              'Decisión: Perfil completo, redirigiendo DESDE CompleteProfile',
              className: 'AppRouter',
              functionName: 'redirect',
              params: {'rutaDestino': targetRoute},
            );
            return targetRoute;
        }

        // 2. ¿Es Propietario y necesita crear academia?
        if (userRole == AppRole.propietario) {
            // Caso especial: Si estamos en la pantalla de crear academia,
            // permitimos que el usuario complete el proceso sin redirecciones
            if (currentLocation == AppRoutes.createAcademy) {
              AppLogger.logInfo(
                'Decisión: En pantalla de crear academia, sin redirección',
                className: 'AppRouter',
                functionName: 'redirect',
              );
              return null;
            }
            
            // Para otras rutas, verificar normalmente
            final academiesState = ref.read(ownerHasAcademiesProvider(currentUserId));
            final needsToCreateAcademy = academiesState.maybeWhen(
                data: (hasAcademies) => !hasAcademies,
                loading: () => false,
                orElse: () => false,
            );
            AppLogger.logInfo(
              'Estado de academia (propietario)',
              className: 'AppRouter',
              functionName: 'redirect',
              params: {'needsToCreate': needsToCreateAcademy.toString()},
            );

            if (needsToCreateAcademy) {
                AppLogger.logInfo(
                  'Decisión: Propietario necesita academia, redirigiendo a CreateAcademy',
                  className: 'AppRouter',
                  functionName: 'redirect',
                );
                return AppRoutes.createAcademy;
            }
            // Si NO necesita crear academia pero está en la pantalla de crear academia,
            // redirigir al dashboard de propietario
            else if (currentLocation == AppRoutes.createAcademy) {
                AppLogger.logInfo(
                  'Decisión: Propietario ya tiene academia, redirigiendo desde CreateAcademy',
                  className: 'AppRouter',
                  functionName: 'redirect',
                );
                return AppRoutes.ownerRoot;
            }
        }

        // 3. Usuario logueado, perfil completo, (propietario con academia):
        if (!isGoingToSplash && (isGoingToPublic || isGoingToIntermediate)) {
            final targetRoute = _getRoleRootRoute(userRole);
            AppLogger.logInfo(
              'Decisión: Autenticado, redirigiendo DESDE pública/intermedia',
              className: 'AppRouter',
              functionName: 'redirect',
              params: {'rutaDestino': targetRoute},
            );
            return targetRoute;
        }

        // 4. Si no aplica ninguna redirección
        AppLogger.logInfo(
          'Decisión: No se necesita redirección, permitiendo acceso a la ruta actual',
          className: 'AppRouter',
          functionName: 'redirect',
          params: {'rutaActual': state.matchedLocation},
        );
        return null;
      },
      routes: <RouteBase>[
        // --- Rutas Públicas / Autenticación ---
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        // --- Rutas de Autenticación (ahora nivel superior) ---
        GoRoute(
          path: AppRoutes.login, // Usar path completo /auth/login
          name: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register, // Usar path completo /auth/register
          name: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.memberAccess, // Usar path completo /auth/member-access
          name: AppRoutes.memberAccess,
          builder: (context, state) => const MemberAccessScreen(),
        ),
        GoRoute(
          path: AppRoutes.completeProfile, // Usar path completo /auth/complete-profile
          name: AppRoutes.completeProfile,
          builder: (context, state) => const CompleteProfileScreen(),
        ),
        // --- Rutas Intermedias ---
         GoRoute(
          path: AppRoutes.createAcademy, // Ruta intermedia
          name: AppRoutes.createAcademy,
          builder: (context, state) => const CreateAcademyScreen(),
        ),

         // --- Ruta de Desarrollo (Accesible siempre?) ---
         GoRoute(
          path: AppRoutes.underDevelopment,
          builder: (context, state) => const ScreenUnderDevelopment(message: '',),
        ),

        // --- Shell para Propietario ---
        ShellRoute(
          navigatorKey: ownerShellNavigatorKey,
          builder: (context, state, child) => ManagerShell(child: child),
          routes: <RouteBase>[
            // Ruta raíz del Shell: /owner (puede mostrar el dashboard por defecto)
            GoRoute(
              path: AppRoutes.ownerRoot,
              name: 'ownerRoot',
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Owner Dashboard'),
            ),
            // Ruta de Perfil del Propietario
            GoRoute(
              path: AppRoutes.ownerProfileRoute, // Usar la nueva constante para el path completo
              name: 'ownerProfile', // Nombre de la ruta, puede ser el mismo que antes o uno nuevo si se prefiere
              builder: (context, state) {
                AppLogger.logInfo(
                  'Navegando a la pantalla de perfil del propietario',
                  className: 'AppRouter',
                  functionName: 'ownerProfile',
                );
                return const ProfileScreen(); // Construir la nueva pantalla de perfil
              },
            ),
            // --- Secciones Principales como hijas directas del ShellRoute ---
            GoRoute(
              path: '/owner/dashboard', // Path completo ahora
              name: AppRoutes.ownerDashboard,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Owner Dashboard'),
            ),
             GoRoute(
                path: '/owner/academy/:academyId', // Path completo
                name: 'ownerAcademyBase',
                 builder: (context, state) {
                   final academyId = state.pathParameters['academyId']!;
                   // Mostrar la AcademyScreen en lugar de ScreenUnderDevelopment
                   return AcademyScreen(academyId: academyId);
                 },
                routes: [ // Rutas anidadas de academia (edit, members, etc.) sí van aquí
                   GoRoute(
                      path: 'edit',
                      name: AppRoutes.ownerEditAcademy,
                      builder: (context, state) {
                         final academyId = state.pathParameters['academyId']!;
                         // Utilizar Consumer para obtener la academia real
                         return Consumer(
                           builder: (context, ref, child) {
                             final academyAsyncValue = ref.watch(academyProvider(academyId));
                             // No necesitamos comprobar si es null, el provider lanza error
                             return academyAsyncValue.when(
                               data: (academy) {
                                 // Añadir chequeo de nulidad
                                 if (academy == null) {
                                    return Scaffold(
                                       appBar: AppBar(title: const Text('Error')),
                                       body: const Center(child: Text('Academia no encontrada.')),
                                    );
                                 }
                                 // Pasar la academia real (ahora no nula) a EditAcademyScreen
                                 return EditAcademyScreen(academy: academy, initialAcademy: academy);
                               },
                               loading: () => const Scaffold(
                                 body: Center(child: CircularProgressIndicator()),
                               ),
                               error: (error, stackTrace) => Scaffold(
                                 body: Center(child: Text('Error cargando academia: $error')),
                               ),
                             );
                           },
                         );
                      },
                   ),
                   GoRoute(
                      path: 'members',
                      name: AppRoutes.ownerAcademyMembers,
                       builder: (context, state) {
                         final academyId = state.pathParameters['academyId']!;
                         return AcademyMembersScreen(academyId: academyId);
                       },
                      routes: [
                         GoRoute(
                            path: 'invite',
                            name: AppRoutes.ownerInviteMember,
                             builder: (context, state) {
                               final academyId = state.pathParameters['academyId']!;
                               return InviteMemberScreen(academyId: academyId);
                             },
                         ),
                         GoRoute(
                            path: AppRoutes.ownerEditMemberPermissions.split('/').last, // 'permissions'
                            name: 'ownerEditMemberPermissions',
                             builder: (context, state) {
                               final academyId = state.pathParameters['academyId']!;
                               final membershipId = state.pathParameters['membershipId']!;
                               return Consumer(
                                   builder: (context, ref, child) {
                                       final membershipAsyncValue = ref.watch(membershipByIdProvider(membershipId));
                                       return membershipAsyncValue.when(
                                           data: (membership) {
                                               return EditPermissionsScreen(
                                                   academyId: academyId,
                                                   membershipId: membershipId,
                                                   membership: membership,
                                               );
                                           },
                                           loading: () => const Scaffold(
                                               body: Center(child: CircularProgressIndicator()),
                                           ),
                                           error: (error, stackTrace) => Scaffold(
                                               appBar: AppBar(title: const Text('Error')),
                                               body: Center(child: Text('Error cargando membresía: $error')),
                                           ),
                                       );
                                   },
                               );
                             },
                         ),
                         // Nueva ruta para añadir atletas
                         GoRoute(
                           path: 'add-athlete', // o la ruta que definiste en AcademyMembersListScreen
                           name: 'addAthleteToAcademy', // Nombre único para la ruta
                           builder: (context, state) {
                             final academyId = state.pathParameters['academyId']!;
                             return AddAthleteScreen(academyId: academyId);
                           },
                         ),
                      ]
                   ),
                   // Añadir la ruta de pagos para la academia específica
                   GoRoute(
                      path: 'payments',
                      name: 'ownerAcademyPayments',
                      builder: (context, state) {
                        final academyId = state.pathParameters['academyId']!;
                        // Actualizar currentAcademyId en el provider para asegurar que los pagos se carguen correctamente
                        return Consumer(
                          builder: (context, ref, child) {
                            // Establecer la academia actual usando el academyId
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              // Cargar el objeto AcademyModel completo usando el repositorio
                              final academyRepository = ref.read(academyRepositoryProvider);
                              final academyResult = await academyRepository.getAcademyById(academyId);
                              academyResult.fold(
                                (failure) => print('Error al cargar academia: $failure'),
                                (academy) {
                                  // Establecer la academia completa
                                  ref.read(currentAcademyProvider.notifier).state = academy;
                                },
                              );
                            });
                            return const PaymentsScreen();
                          },
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'register',
                          name: 'ownerAcademyRegisterPayment',
                          builder: (context, state) {
                            return RegisterPaymentScreen();
                          },
                        ),
                        GoRoute(
                          path: ':paymentId',
                          name: 'ownerAcademyPaymentDetails',
                          builder: (context, state) {
                            final academyId = state.pathParameters['academyId']!;
                            final paymentId = state.pathParameters['paymentId']!;
                            return ScreenUnderDevelopment(message: 'Detalles del pago $paymentId de academia $academyId');
                          },
                          routes: [
                            GoRoute(
                              path: 'edit',
                              name: 'ownerAcademyEditPayment',
                              builder: (context, state) {
                                final academyId = state.pathParameters['academyId']!;
                                final paymentId = state.pathParameters['paymentId']!;
                                return ScreenUnderDevelopment(message: 'Editar pago $paymentId de academia $academyId');
                              },
                            ),
                          ],
                        ),
                        // Ruta para ver pagos de un atleta específico
                        GoRoute(
                          path: 'athlete/:athleteId',
                          name: 'ownerAcademyAthletePayments',
                          builder: (context, state) {
                            final academyId = state.pathParameters['academyId']!;
                            final athleteId = state.pathParameters['athleteId']!;
                            final athleteName = state.extra is Map ? (state.extra as Map)['athleteName'] as String? : null;
                            
                            return Consumer(
                              builder: (context, ref, child) {
                                // Establecer la academia actual usando el academyId
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  // Cargar el objeto AcademyModel completo usando el repositorio
                                  final academyRepository = ref.read(academyRepositoryProvider);
                                  final academyResult = await academyRepository.getAcademyById(academyId);
                                  academyResult.fold(
                                    (failure) => print('Error al cargar academia: $failure'),
                                    (academy) {
                                      // Establecer la academia completa
                                      ref.read(currentAcademyProvider.notifier).state = academy;
                                    },
                                  );
                                });
                                return AthletePaymentsScreen(
                                  athleteId: athleteId,
                                  athleteName: athleteName,
                                );
                              },
                            );
                          },
                        ),
                      ],
                   ),
                   // Asegúrate de que las rutas dentro de academy/:academyId/ NO incluyan 'payments' aquí
                ]
             ),
            GoRoute(
              path: '/owner/members', // Path completo
              name: AppRoutes.ownerMembers,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Miembros de academia'),
            ),
            GoRoute(
              path: '/owner/schedule', // Path completo
              name: AppRoutes.ownerSchedule,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Horarios'),
            ),
            GoRoute(
              path: '/owner/stats', // Path completo
              name: AppRoutes.ownerStats,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Estadísticas'),
            ),
            GoRoute(
              path: '/owner/more', // Path completo
              name: AppRoutes.ownerMore,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Más opciones'),
            ),
            GoRoute(
              path: '/owner/groups', // Path completo
              name: AppRoutes.ownerGroups,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Gestión de Grupos/Equipos'),
            ),
            GoRoute(
              path: '/owner/trainings', // Path completo
              name: AppRoutes.ownerTrainings,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Entrenamientos y Sesiones'),
            ),
            GoRoute(
              path: '/owner/academy_details', // Path completo
              name: AppRoutes.ownerAcademyDetails,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Detalles de la Academia'),
            ),
            GoRoute(
              path: '/owner/settings', // Path completo
              name: AppRoutes.ownerSettings,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Configuración'),
            ),
            // Ruta de Pagos como hija directa del ShellRoute
            GoRoute(
              path: '/owner/payments', // Path completo
              name: AppRoutes.ownerPayments,
              builder: (context, state) {
                return PaymentsScreen();
              },
              routes: [ // Rutas anidadas de pagos (register, :paymentId) sí van aquí
                  GoRoute(
                    path: 'register',
                    name: AppRoutes.ownerRegisterPayment,
                    builder: (context, state) {
                      return RegisterPaymentScreen();
                    },
                  ),
                  GoRoute(
                    path: ':paymentId',
                    name: AppRoutes.ownerPaymentDetails,
                    builder: (context, state) {
                      final paymentId = state.pathParameters['paymentId']!;
                      return ScreenUnderDevelopment(message: 'Detalles del pago $paymentId');
                    },
                    routes: [
                        GoRoute(
                          path: 'edit',
                          name: AppRoutes.ownerEditPayment,
                          builder: (context, state) {
                            final paymentId = state.pathParameters['paymentId']!;
                            return ScreenUnderDevelopment(message: 'Editar pago $paymentId');
                          },
                        ),
                    ],
                  ),
              ],
            ),
            GoRoute(
              path: AppRoutes.payments,
              name: AppRoutes.payments,
              builder: (context, state) => const PaymentsScreen(),
            ),
          ],
        ),        
        

         // --- Shell para SuperAdmin ---
        ShellRoute(
          navigatorKey: superAdminShellNavigatorKey,
          builder: (context, state, child) => SuperAdminShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.superAdminRoot, // Ruta raíz del Shell: /superadmin
              builder: (context, state) => const ScreenUnderDevelopment(message: 'SuperAdmin Dashboard'), // Placeholder
              routes: [
                 GoRoute(
                    path: AppRoutes.superAdminDashboard, // -> /superadmin/dashboard
                    name: AppRoutes.superAdminDashboard, // Nombre único
                    builder: (context, state) => const ScreenUnderDevelopment(message: 'SuperAdmin Dashboard'), // <- Builder añadido
                 ),
                 // Otras rutas específicas para superadmins...
              ]
            ),
          ],
        ),

      ],
      errorBuilder: (context, state) {
         AppLogger.logError(
           message: 'Error de GoRouter',
           error: state.error,
           className: 'AppRouter',
           functionName: 'errorBuilder',
           params: {'error': state.error?.toString() ?? 'desconocido'},
         );
         return Scaffold(
            appBar: AppBar(title: const Text('Error de Navegación')),
            body: ErrorDisplay(error: state.error?.toString() ?? 'Error desconocido'),
         );
      }
    );
    
    AppLogger.logInfo(
      'Instancia de GoRouter creada exitosamente',
      className: 'AppRouter',
      functionName: 'routerProvider',
    );
    
    return router;
  } catch (e, stackTrace) {
    AppLogger.logError(
      message: 'ERROR CRÍTICO durante la creación de GoRouter',
      error: e,
      stackTrace: stackTrace,
      className: 'AppRouter',
      functionName: 'routerProvider',
    );
    // Rethrow para que Riverpod lo maneje o propague
    rethrow;
  }
});

/// Un [ChangeNotifier] que se actualiza cuando un [ProviderListenable] (como un Provider de Riverpod) emite un nuevo estado.
/// Usado para el `refreshListenable` de GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final ProviderSubscription _subscription;

  /// Crea una instancia que escucha un [ProviderListenable].
  GoRouterRefreshStream(Ref ref, ProviderListenable<dynamic> provider) {
    // Escuchar el provider y notificar a GoRouter en cada cambio.
    // Usamos ref.listen directamente.
    _subscription = ref.listen<dynamic>(
      provider,
      (previous, next) {
        notifyListeners();
      },
      // fireImmediately: false, // ref.listen no tiene este parámetro
    );
  }

  @override
  void dispose() {
    _subscription.close(); // Cancelar la suscripción al provider
    super.dispose();
  }
}

// Función helper para obtener la ruta raíz según el rol
String _getRoleRootRoute(AppRole? role) {
  switch (role) {
    // Asegurarse que devuelva la ruta RAÍZ del shell, no una sub-ruta
    case AppRole.propietario: return AppRoutes.ownerRoot; // Sigue siendo /owner
    case AppRole.atleta: return AppRoutes.athleteRoot;
    case AppRole.colaborador: return AppRoutes.collaboratorRoot;
    case AppRole.superAdmin: return AppRoutes.superAdminRoot;
    case AppRole.padre: return AppRoutes.parentRoot;
    default: return AppRoutes.welcome;
  }
}
