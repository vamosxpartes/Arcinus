import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/routes/app_routes.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/create_academy_screen.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/academy_screen.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/manager_create_academy_screen.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/core/auth/presentation/ui/screens/login_screen.dart';
import 'package:arcinus/core/auth/presentation/ui/screens/member_access_screen.dart';
import 'package:arcinus/core/auth/presentation/ui/screens/register_screen.dart';
import 'package:arcinus/core/auth/presentation/ui/screens/welcome_screen.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/core/utils/splash/splash_screen.dart';
import 'package:arcinus/core/utils/screen_under_development.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/features/academy_users/presentation/screens/add_athlete_screen.dart';
import 'package:arcinus/features/academies/presentation/screens/edit_academy_screen.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academy_users/presentation/screens/academy_users_manage_screen.dart';
import 'package:arcinus/features/academy_users/presentation/screens/edit_permissions_screen.dart';
import 'package:arcinus/core/theme/ui/feedback/error_display.dart';
import 'package:arcinus/features/academy_users_payments/presentation/screens/payments_screen.dart';
import 'package:arcinus/features/academy_users_payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/core/utils/app_logger.dart';

// Importar providers necesarios
import 'package:arcinus/features/academy_users/presentation/providers/membership_providers.dart';

// Importar los nuevos Shell Widgets
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/core/navigation/navigation_shells/super_admin_shell/super_admin_shell.dart';
import 'package:arcinus/features/academy_users/presentation/screens/profile_screen.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/screens/subscription_plans_screen.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/manager_dashboard_screen.dart';
import 'package:arcinus/features/super_admin/presentation/screens/super_admin_dashboard_screen.dart';
import 'package:arcinus/features/super_admin/presentation/screens/owners_manage_screen.dart';
import 'package:arcinus/features/super_admin/presentation/screens/owner_details_screen.dart';

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
          AuthRoutes.login,
          AuthRoutes.register,
          AuthRoutes.memberAccess,
          AuthRoutes.forgotPassword,
        ];

        // --- Definir rutas intermedias post-login ---
        final intermediateRoutes = [
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
             // Si es propietario, verificar si necesita crear academia
             if (userRole == AppRole.propietario && currentUserId != null) {
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

             // Si no necesita crear academia, redirigir a la ruta del rol
             String targetRoute;
             if (userRole != null) {
               targetRoute = _getRoleRootRoute(userRole);
             } else {
               targetRoute = AppRoutes.welcome;
             }
             AppLogger.logInfo(
               'Decisión: Desde Splash a ruta de rol',
               className: 'AppRouter',
               functionName: 'redirect',
               params: {'rutaDestino': targetRoute},
             );
             return targetRoute;
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
                return OwnerRoutes.root;
            }
        }

        // 3. Usuario logueado, perfil completo, (propietario con academia):
        if (!isGoingToSplash && (isGoingToPublic || isGoingToIntermediate)) {
            String targetRoute;
            if (userRole != null) {
              targetRoute = _getRoleRootRoute(userRole);
            } else {
              targetRoute = AppRoutes.welcome;
            }
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
          path: AuthRoutes.login, // Usar path completo /auth/login
          name: AuthRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AuthRoutes.register, // Usar path completo /auth/register
          name: AuthRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AuthRoutes.memberAccess, // Usar path completo /auth/member-access
          name: AuthRoutes.memberAccess,
          builder: (context, state) => const MemberAccessScreen(),
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
              path: OwnerRoutes.root,
              name: 'ownerRoot',
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Owner Dashboard'),
            ),
            // Ruta de Perfil del Propietario
            GoRoute(
              path: OwnerRoutes.profile, // Usar la nueva constante para el path completo
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
              name: OwnerRoutes.dashboard,
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
                      name: OwnerRoutes.editAcademy,
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
                      name: OwnerRoutes.academyMembers,
                       builder: (context, state) {
                         final academyId = state.pathParameters['academyId']!;
                         return AcademyMembersScreen(academyId: academyId);
                       },
                      routes: [
                         GoRoute(
                            path: OwnerRoutes.editMemberPermissions.split('/').last, // 'permissions'
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
                                (failure) => AppLogger.logError(
                                  message: 'Error al cargar academia',
                                  error: failure,
                                  className: 'AppRouter',
                                  functionName: 'ownerAcademyPayments',
                                  params: {'academyId': academyId},
                                ),
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
                      ],
                   ),
                   // Asegúrate de que las rutas dentro de academy/:academyId/ NO incluyan 'payments' aquí
                ]
             ),
            GoRoute(
              path: '/owner/members', // Path completo
              name: OwnerRoutes.members,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Miembros de academia'),
            ),
            GoRoute(
              path: '/owner/schedule', // Path completo
              name: OwnerRoutes.schedule,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Horarios'),
            ),
            GoRoute(
              path: '/owner/stats', // Path completo
              name: OwnerRoutes.stats,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Estadísticas'),
            ),
            GoRoute(
              path: '/owner/more', // Path completo
              name: OwnerRoutes.more,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Más opciones'),
            ),
            GoRoute(
              path: '/owner/groups', // Path completo
              name: OwnerRoutes.groups,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Gestión de Grupos/Equipos'),
            ),
            GoRoute(
              path: '/owner/trainings', // Path completo
              name: OwnerRoutes.trainings,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Entrenamientos y Sesiones'),
            ),
            GoRoute(
              path: '/owner/academy_details', // Path completo
              name: OwnerRoutes.academyDetails,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Detalles de la Academia'),
            ),
            GoRoute(
              path: '/owner/settings', // Path completo
              name: OwnerRoutes.settings,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Configuración'),
            ),
            // Ruta de Pagos como hija directa del ShellRoute
            GoRoute(
              path: '/owner/payments', // Path completo
              name: OwnerRoutes.payments,
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Gestión de Pagos'),
            ),
          ],
        ),        
        
        // --- Shell para Manager (Owner + Collaborator) ---
        ShellRoute(
          navigatorKey: ownerShellNavigatorKey,
          builder: (context, state, child) => ManagerShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: ManagerRoutes.root, // Ruta raíz del Shell: /manager
              builder: (context, state) => const ManagerDashboardScreen(),
            ),
            GoRoute(
              path: '/manager/dashboard',
              name: 'managerDashboard',
              builder: (_, __) => const ManagerDashboardScreen(),
            ),
            GoRoute(
              path: '/manager/profile',
              name: 'managerProfile',
              builder: (_, __) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/manager/settings',
              name: 'managerSettings',
              builder: (_, __) => const ScreenUnderDevelopment(message: 'Configuración'),
            ),
            // Añadir ruta para crear academia dentro del shell manager
            GoRoute(
              path: '/manager/create-academy',
              name: 'managerCreateAcademy',
              builder: (_, __) => const ManagerCreateAcademyScreen(),
            ),
            GoRoute(
              path: '/manager/academy/:academyId',
              name: 'managerAcademy',
              builder: (context, state) {
                final academyId = state.pathParameters['academyId']!;
                return AcademyScreen(academyId: academyId);
              },
              routes: [
                GoRoute(
                  path: 'members',
                  name: 'managerAcademyMembers',
                  builder: (context, state) {
                    final academyId = state.pathParameters['academyId']!;
                    return AcademyMembersScreen(academyId: academyId);
                  },
                ),
                GoRoute(
                  path: 'edit',
                  name: 'managerAcademyEdit',
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
                  path: 'payments',
                  name: 'managerAcademyPayments',
                  builder: (context, state) {
                    final academyId = state.pathParameters['academyId']!;
                    return Consumer(
                      builder: (context, ref, child) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          final academyRepository = ref.read(academyRepositoryProvider);
                          final academyResult = await academyRepository.getAcademyById(academyId);
                          academyResult.fold(
                            (failure) => AppLogger.logError(
                              message: 'Error al cargar academia',
                              error: failure,
                              className: 'AppRouter',
                              functionName: 'managerAcademyPayments',
                              params: {'academyId': academyId},
                            ),
                            (academy) {
                              ref.read(currentAcademyProvider.notifier).state = academy;
                            },
                          );
                        });
                        return const PaymentsScreen();
                      },
                    );
                  },
                ),
                GoRoute(
                  path: 'subscription-plans',
                  name: 'managerAcademySubscriptionPlans',
                  builder: (context, state) {
                    final academyId = state.pathParameters['academyId']!;
                    return SubscriptionPlansScreen(academyId: academyId);
                  },
                ),
                // Rutas para nuevas funcionalidades (en desarrollo)
                GoRoute(
                  path: 'inventory',
                  name: 'managerAcademyInventory',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Gestión de inventario',
                      icon: Icons.inventory_2_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Control de equipamiento, instalaciones y recursos de la academia',
                    );
                  },
                ),
                GoRoute(
                  path: 'billing',
                  name: 'managerAcademyBilling',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Sistema de facturación',
                      icon: Icons.receipt_long_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Gestión de facturas, recibos y documentos fiscales',
                    );
                  },
                ),
                GoRoute(
                  path: 'documents',
                  name: 'managerAcademyDocuments',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Normas y documentación',
                      icon: Icons.gavel_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Gestión de reglamentos, protocolos y documentos legales',
                    );
                  },
                ),
                GoRoute(
                  path: 'social',
                  name: 'managerAcademySocial',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Redes sociales',
                      icon: Icons.share_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Integración con plataformas sociales y gestión de contenido',
                    );
                  },
                ),
                GoRoute(
                  path: 'branding',
                  name: 'managerAcademyBranding',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Marca y personalización',
                      icon: Icons.brush_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Configuración de identidad visual, colores y elementos de marca',
                    );
                  },
                ),
                GoRoute(
                  path: 'notifications',
                  name: 'managerAcademyNotifications',
                  builder: (context, state) {
                    return ScreenUnderDevelopment(
                      message: 'Centro de notificaciones',
                      icon: Icons.notifications_outlined,
                      primaryColor: AppTheme.bonfireRed,
                      description: 'Gestión de comunicaciones y anuncios para miembros de la academia',
                    );
                  },
                ),
              ],
            ),
          ],
        ),

         // --- Shell para SuperAdmin ---
        ShellRoute(
          navigatorKey: superAdminShellNavigatorKey,
          builder: (context, state, child) => SuperAdminShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: SuperAdminRoutes.root, // Ruta raíz del Shell: /superadmin
              builder: (context, state) => const SuperAdminDashboardScreen(), // Usar el dashboard real
              routes: [
                 GoRoute(
                    path: SuperAdminRoutes.dashboard, // -> /superadmin/dashboard
                    name: SuperAdminRoutes.dashboard, // Nombre único
                    builder: (context, state) => const SuperAdminDashboardScreen(),
                 ),
                 
                 // --- Gestión de Propietarios ---
                 GoRoute(
                   path: 'owners',
                   name: 'superAdminOwners',
                   builder: (context, state) => const OwnersManageScreen(),
                   routes: [
                     GoRoute(
                       path: ':ownerId',
                       name: 'superAdminOwnerDetails',
                       builder: (context, state) {
                         final ownerId = state.pathParameters['ownerId']!;
                         return OwnerDetailsScreen(ownerId: ownerId);
                       },
                     ),
                   ],
                 ),
                 
                 // --- Gestión de Academias ---
                 GoRoute(
                   path: 'academies',
                   name: 'superAdminAcademies',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Gestión de Academias',
                     icon: Icons.school_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Administración global de todas las academias del sistema',
                   ),
                 ),
                 
                 // --- Gestión de Suscripciones ---
                 GoRoute(
                   path: 'subscriptions',
                   name: 'superAdminSubscriptions',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Gestión de Suscripciones',
                     icon: Icons.subscriptions_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Control de planes de suscripción y facturación global',
                   ),
                 ),
                 
                 // --- Deportes Globales ---
                 GoRoute(
                   path: 'sports',
                   name: 'superAdminSports',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Deportes Globales',
                     icon: Icons.sports_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Configuración global de deportes y categorías del sistema',
                   ),
                 ),
                 
                 // --- Sistema - Respaldos ---
                 GoRoute(
                   path: 'system/backups',
                   name: 'superAdminSystemBackups',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Sistema de Respaldos',
                     icon: Icons.backup_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Gestión de backups y restauración del sistema',
                   ),
                 ),
                 
                 // --- Seguridad ---
                 GoRoute(
                   path: 'security',
                   name: 'superAdminSecurity',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Seguridad y Auditoría',
                     icon: Icons.security_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Control de seguridad, logs de auditoría y sesiones',
                   ),
                 ),
                 
                 // --- Analytics ---
                 GoRoute(
                   path: 'analytics',
                   name: 'superAdminAnalytics',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Analytics y Métricas',
                     icon: Icons.analytics_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Análisis de uso, rendimiento y métricas del sistema',
                   ),
                 ),
                 
                 // --- Configuración ---
                 GoRoute(
                   path: 'settings',
                   name: 'superAdminSettings',
                   builder: (context, state) => ScreenUnderDevelopment(
                     message: 'Configuración Global',
                     icon: Icons.settings_outlined,
                     primaryColor: Colors.deepPurple,
                     description: 'Configuración general del sistema y notificaciones',
                   ),
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
  if (role == null) return AppRoutes.welcome;
  
  switch (role) {
    // Redirigir roles de gestión al shell unificado de Manager
    case AppRole.propietario: 
    case AppRole.colaborador:
      return ManagerRoutes.root; 
    case AppRole.atleta: 
      return AppRoutes.athleteRoot;
    case AppRole.superAdmin: 
      return SuperAdminRoutes.root;
    case AppRole.padre: 
      return AppRoutes.parentRoot;
    default: 
      return AppRoutes.welcome;
  }
}
