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
import 'package:arcinus/features/academies/presentation/screens/edit_academy_screen.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_members_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/edit_permissions_screen.dart';
import 'package:arcinus/features/theme/ui/feedback/error_display.dart';
import 'package:arcinus/features/payments/presentation/screens/payments_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';

// Importar providers necesarios
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';

// Importar los nuevos Shell Widgets
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:arcinus/features/navigation_shells/athlete_shell.dart';
import 'package:arcinus/features/navigation_shells/collaborator_shell.dart';
import 'package:arcinus/features/navigation_shells/super_admin_shell.dart';
import 'package:arcinus/features/navigation_shells/parent_shell.dart';

import 'package:logger/logger.dart'; // Importar logger

import 'package:arcinus/features/users/presentation/ui/screens/profile_screen.dart';

// Instancia de Logger
final _logger = Logger();

/// Provider que expone el router de la aplicación.
final routerProvider = Provider<GoRouter>((ref) {
  _logger.d('routerProvider: Creating GoRouter instance...'); // Reemplazado
  try {
    // Observar el estado de autenticación para el refreshListenable
    final authStateListenable = GoRouterRefreshStream(ref, authStateNotifierProvider);
    _logger.d('routerProvider: GoRouterRefreshStream created'); // Reemplazado

    // Clave global para el Navigator principal
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    // Claves separadas para los Navigators de cada Shell
    final ownerShellNavigatorKey        = GlobalKey<NavigatorState>(debugLabel: 'ownerShell');
    final athleteShellNavigatorKey      = GlobalKey<NavigatorState>(debugLabel: 'athleteShell');
    final collaboratorShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'collaboratorShell');
    final superAdminShellNavigatorKey   = GlobalKey<NavigatorState>(debugLabel: 'superAdminShell');
    final parentShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'parentShell');

    _logger.d('routerProvider: Navigator keys created'); // Reemplazado

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: authStateListenable, // Escuchar solo cambios de AuthState
      redirect: (BuildContext context, GoRouterState state) async {
        _logger.d('AppRouter.Redirect - Redirect triggered: current=${state.matchedLocation}, target=${state.uri}'); // Reemplazado
        // --- Leer el estado de autenticación y perfil ---
        final authState = ref.read(authStateNotifierProvider);
        final isLoggedIn = authState.isAuthenticated;
        final currentUserId = authState.user?.id;
        final userRole = authState.user?.role;
        _logger.d('AppRouter.Redirect - Auth state: isLoggedIn=$isLoggedIn, userId=$currentUserId, role=$userRole'); // Reemplazado

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

        final currentLocation         = state.matchedLocation;
        final isGoingToPublic       = publicRoutes.contains(currentLocation);
        final isGoingToIntermediate = intermediateRoutes.contains(currentLocation);
        final isGoingToSplash       = currentLocation == AppRoutes.splash;
        _logger.d('AppRouter.Redirect - Route categories: isPublic=$isGoingToPublic, isIntermediate=$isGoingToIntermediate, isSplash=$isGoingToSplash'); // Reemplazado

        // --- Lógica de Splash ---
        if (authState == const AuthState.initial() || (authState.isLoading && isGoingToSplash)) {
           _logger.d('AppRouter.Redirect - Redirect decision: Keep on Splash (initial/loading)'); // Reemplazado
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
                 _logger.d('AppRouter.Redirect - Redirect decision: From Splash - needs profile completion'); // Reemplazado
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
                   _logger.d('AppRouter.Redirect - Redirect decision: From Splash - owner needs academy'); // Reemplazado
                   return AppRoutes.createAcademy;
                 }
               }

               // Si no necesita completar perfil ni crear academia, redirigir a la ruta del rol
               final targetRoute = _getRoleRootRoute(userRole);
               _logger.d('AppRouter.Redirect - Redirect decision: From Splash to $targetRoute'); // Reemplazado
               return targetRoute;
             }
           } else {
             _logger.d('AppRouter.Redirect - Redirect decision: From Splash to Welcome'); // Reemplazado
             return AppRoutes.welcome;
           }
        }

        // --- Lógica Principal de Redirección ---
        if (!isLoggedIn) {
          if (!isGoingToPublic) {
            _logger.d('AppRouter.Redirect - Redirect decision: Not logged in, redirecting to Welcome'); // Reemplazado
            return AppRoutes.welcome;
          }
          _logger.d('AppRouter.Redirect - Redirect decision: Not logged in, staying on public route'); // Reemplazado
          return null; // Stay on public route
        }

        // --- Usuario Logueado ---
        if (currentUserId == null) {
          _logger.d('AppRouter.Redirect - Redirect decision: Logged in but no userId, redirecting to Welcome'); // Reemplazado
          return AppRoutes.welcome;
        }

        // 1. ¿Necesita completar perfil?
        final profileState = ref.read(userProfileProvider(currentUserId));
        final needsProfileCompletion = profileState.maybeWhen(
           data: (profile) => profile == null || (profile.name?.isEmpty ?? true),
           loading: () => false,
           orElse: () => false,
        );
        _logger.d('AppRouter.Redirect - Profile state: needsCompletion=$needsProfileCompletion'); // Reemplazado

        if (needsProfileCompletion) {
            if (currentLocation != AppRoutes.completeProfile) {
              _logger.d('AppRouter.Redirect - Redirect decision: Needs profile completion, redirecting to CompleteProfile'); // Reemplazado
              return AppRoutes.completeProfile;
            }
            _logger.d('AppRouter.Redirect - Redirect decision: Needs profile completion, staying on CompleteProfile'); // Reemplazado
            return null; // Stay on complete profile
        }
        if (currentLocation == AppRoutes.completeProfile && !needsProfileCompletion) {
            final targetRoute = _getRoleRootRoute(userRole);
            _logger.d('AppRouter.Redirect - Redirect decision: Profile complete, redirecting FROM CompleteProfile to $targetRoute'); // Reemplazado
            return targetRoute;
        }

        // 2. ¿Es Propietario y necesita crear academia?
        if (userRole == AppRole.propietario) {
            final academiesState = ref.read(ownerHasAcademiesProvider(currentUserId));
            final needsToCreateAcademy = academiesState.maybeWhen(
                data: (hasAcademies) => !hasAcademies,
                loading: () => false,
                orElse: () => false,
            );
            _logger.d('AppRouter.Redirect - Academy state (owner): needsToCreate=$needsToCreateAcademy'); // Reemplazado

            if (needsToCreateAcademy) {
                if (currentLocation != AppRoutes.createAcademy) {
                  _logger.d('AppRouter.Redirect - Redirect decision: Owner needs academy, redirecting to CreateAcademy'); // Reemplazado
                  return AppRoutes.createAcademy;
                }
                _logger.d('AppRouter.Redirect - Redirect decision: Owner needs academy, staying on CreateAcademy'); // Reemplazado
                return null; // Stay on create academy
            }
             if (currentLocation == AppRoutes.createAcademy && !needsToCreateAcademy) {
                 _logger.d('AppRouter.Redirect - Redirect decision: Owner has academy, redirecting FROM CreateAcademy to Owner root'); // Reemplazado
                 return AppRoutes.ownerRoot;
             }
        }

        // 3. Usuario logueado, perfil completo, (propietario con academia):
        if (!isGoingToSplash && (isGoingToPublic || isGoingToIntermediate)) {
            final targetRoute = _getRoleRootRoute(userRole);
            _logger.d('AppRouter.Redirect - Redirect decision: Logged in, redirecting FROM public/intermediate to $targetRoute'); // Reemplazado
            return targetRoute;
        }

        // 4. Si no aplica ninguna redirección
        _logger.d('AppRouter.Redirect - Redirect decision: No redirection needed, allowing access to ${state.matchedLocation}'); // Reemplazado
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
          builder: (context, state, child) => OwnerShell(child: child),
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
                _logger.d('Navigating to Owner Profile Screen');
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

                               // Usar Consumer para obtener la membresía real
                               return Consumer(
                                   builder: (context, ref, child) {
                                       // Asume que membershipByIdProvider(membershipId) existe
                                       final membershipAsyncValue = ref.watch(membershipByIdProvider(membershipId));

                                       return membershipAsyncValue.when(
                                           data: (membership) {
                                               // Pasar la membresía real a EditPermissionsScreen
                                               return EditPermissionsScreen(
                                                   academyId: academyId,
                                                   membershipId: membershipId,
                                                   membership: membership, // <- Membresía real
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
                      ]
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

        // --- Shell para Atleta ---
        ShellRoute(
          navigatorKey: athleteShellNavigatorKey,
          builder: (context, state, child) => AthleteShell(child: child),
          routes: <RouteBase>[
             GoRoute(
                path: AppRoutes.athleteRoot, // Ruta raíz del Shell: /athlete
                 // En lugar de redirigir, construimos directamente el dashboard
                 builder: (context, state) => const ScreenUnderDevelopment(message: 'Athlete Dashboard'), // Placeholder
                routes: [
                   GoRoute(
                      path: AppRoutes.athleteDashboard, // -> /athlete/dashboard
                      name: AppRoutes.athleteDashboard, // Nombre único
                      builder: (context, state) => const ScreenUnderDevelopment(message: 'Athlete Dashboard'), // <- Builder añadido
                   ),
                   // Otras rutas específicas para atletas...
                ]
             ),
          ],
        ),

        // --- Shell para Colaborador ---
        ShellRoute(
          navigatorKey: collaboratorShellNavigatorKey,
          builder: (context, state, child) => CollaboratorShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.collaboratorRoot, // Ruta raíz del Shell: /collaborator
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Collaborator Dashboard'), // Placeholder
              routes: [
                 GoRoute(
                    path: AppRoutes.collaboratorDashboard, // -> /collaborator/dashboard
                    name: AppRoutes.collaboratorDashboard, // Nombre único
                    builder: (context, state) => const ScreenUnderDevelopment(message: 'Collaborator Dashboard'), // <- Builder añadido
                 ),
                 // Otras rutas específicas para colaboradores...
              ]
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

        // --- Shell para Padre/Responsable ---
        ShellRoute(
          navigatorKey: parentShellNavigatorKey,
          builder: (context, state, child) => ParentShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.parentRoot, // Ruta raíz del Shell: /parent
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Parent Dashboard'), // Placeholder
              routes: [
                GoRoute(
                  path: AppRoutes.parentDashboard, // -> /parent/dashboard
                  name: AppRoutes.parentDashboard, // Nombre único
                  builder: (context, state) => const ScreenUnderDevelopment(message: 'Parent Dashboard'), // <- Builder añadido
                ),
                // Otras rutas específicas para padres...
              ],
            ),
          ],
        ),

      ],
      errorBuilder: (context, state) {
         _logger.e('AppRouter.Error - GoRouter ErrorBuilder triggered', error: state.error); // Reemplazado
         return Scaffold(
            appBar: AppBar(title: const Text('Error de Navegación')),
            body: ErrorDisplay(error: state.error?.toString() ?? 'Error desconocido'),
         );
      }
    );
    _logger.d('routerProvider: GoRouter instance created successfully'); // Reemplazado
    return router;
  } catch (e, stackTrace) {
    _logger.e('routerProvider: CRITICAL ERROR during GoRouter creation', error: e, stackTrace: stackTrace); // Reemplazado
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
