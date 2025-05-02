import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/ui/screens/create_academy_screen.dart';
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
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/screens/edit_academy_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_members_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/edit_permissions_screen.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/theme/ui/feedback/error_display.dart';
import 'package:arcinus/features/payments/presentation/screens/payments_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';

// Importar los nuevos Shell Widgets
import 'package:arcinus/features/navigation_shells/owner_shell.dart';
import 'package:arcinus/features/navigation_shells/athlete_shell.dart';
import 'package:arcinus/features/navigation_shells/collaborator_shell.dart';
import 'package:arcinus/features/navigation_shells/super_admin_shell.dart';
import 'package:arcinus/features/navigation_shells/parent_shell.dart';

// Importar pantallas Dashboard (placeholders por ahora)
// TODO: Crear estas pantallas
// import 'package:arcinus/features/dashboard/owner_dashboard_screen.dart';
// import 'package:arcinus/features/dashboard/athlete_dashboard_screen.dart';
// import 'package:arcinus/features/dashboard/collaborator_dashboard_screen.dart';
// import 'package:arcinus/features/dashboard/super_admin_dashboard_screen.dart';

import 'dart:developer' as developer;

/// Provider que expone el router de la aplicación.
final routerProvider = Provider<GoRouter>((ref) {
  developer.log('routerProvider: Creating GoRouter instance...', name: 'AppLifecycle');
  try {
    // Observar el estado de autenticación para el refreshListenable
    final authStateListenable = GoRouterRefreshStream(ref, authStateNotifierProvider);
    developer.log('routerProvider: GoRouterRefreshStream created', name: 'AppLifecycle');

    // Clave global para el Navigator principal
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    // Claves separadas para los Navigators de cada Shell
    final ownerShellNavigatorKey        = GlobalKey<NavigatorState>(debugLabel: 'ownerShell');
    final athleteShellNavigatorKey      = GlobalKey<NavigatorState>(debugLabel: 'athleteShell');
    final collaboratorShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'collaboratorShell');
    final superAdminShellNavigatorKey   = GlobalKey<NavigatorState>(debugLabel: 'superAdminShell');
    final parentShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'parentShell');

    developer.log('routerProvider: Navigator keys created', name: 'AppLifecycle');

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: authStateListenable, // Escuchar solo cambios de AuthState
      redirect: (BuildContext context, GoRouterState state) async {
        developer.log('Redirect triggered: current=${state.matchedLocation}, target=${state.uri}', name: 'AppRouter.Redirect');
        // --- Leer el estado de autenticación y perfil ---
        final authState = ref.read(authStateNotifierProvider);
        final isLoggedIn = authState.isAuthenticated;
        final currentUserId = authState.user?.id;
        final userRole = authState.user?.role;
        developer.log('Auth state: isLoggedIn=$isLoggedIn, userId=$currentUserId, role=$userRole', name: 'AppRouter.Redirect');

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
        developer.log('Route categories: isPublic=$isGoingToPublic, isIntermediate=$isGoingToIntermediate, isSplash=$isGoingToSplash', name: 'AppRouter.Redirect');

        // --- Lógica de Splash ---
        if (authState == const AuthState.initial() || (authState.isLoading && isGoingToSplash)) {
           developer.log('Redirect decision: Keep on Splash (initial/loading)', name: 'AppRouter.Redirect');
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
                 developer.log('Redirect decision: From Splash - needs profile completion', name: 'AppRouter.Redirect');
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
                   developer.log('Redirect decision: From Splash - owner needs academy', name: 'AppRouter.Redirect');
                   return AppRoutes.createAcademy;
                 }
               }
               
               // Si no necesita completar perfil ni crear academia, redirigir a la ruta del rol
               final targetRoute = _getRoleRootRoute(userRole);
               developer.log('Redirect decision: From Splash to $targetRoute', name: 'AppRouter.Redirect');
               return targetRoute;
             }
           } else {
             developer.log('Redirect decision: From Splash to Welcome', name: 'AppRouter.Redirect');
             return AppRoutes.welcome;
           }
        }

        // --- Lógica Principal de Redirección ---
        if (!isLoggedIn) {
          if (!isGoingToPublic) {
            developer.log('Redirect decision: Not logged in, redirecting to Welcome', name: 'AppRouter.Redirect');
            return AppRoutes.welcome;
          }
          developer.log('Redirect decision: Not logged in, staying on public route', name: 'AppRouter.Redirect');
          return null; // Stay on public route
        }

        // --- Usuario Logueado ---
        if (currentUserId == null) {
          developer.log('Redirect decision: Logged in but no userId, redirecting to Welcome', name: 'AppRouter.Redirect');
          return AppRoutes.welcome;
        }

        // 1. ¿Necesita completar perfil?
        final profileState = ref.read(userProfileProvider(currentUserId));
        final needsProfileCompletion = profileState.maybeWhen(
           data: (profile) => profile == null || (profile.name?.isEmpty ?? true),
           loading: () => false,
           orElse: () => false,
        );
        developer.log('Profile state: needsCompletion=$needsProfileCompletion', name: 'AppRouter.Redirect');

        if (needsProfileCompletion) {
            if (currentLocation != AppRoutes.completeProfile) {
              developer.log('Redirect decision: Needs profile completion, redirecting to CompleteProfile', name: 'AppRouter.Redirect');
              return AppRoutes.completeProfile;
            }
            developer.log('Redirect decision: Needs profile completion, staying on CompleteProfile', name: 'AppRouter.Redirect');
            return null; // Stay on complete profile
        }
        if (currentLocation == AppRoutes.completeProfile && !needsProfileCompletion) {
            final targetRoute = _getRoleRootRoute(userRole);
            developer.log('Redirect decision: Profile complete, redirecting FROM CompleteProfile to $targetRoute', name: 'AppRouter.Redirect');
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
            developer.log('Academy state (owner): needsToCreate=$needsToCreateAcademy', name: 'AppRouter.Redirect');

            if (needsToCreateAcademy) {
                if (currentLocation != AppRoutes.createAcademy) {
                  developer.log('Redirect decision: Owner needs academy, redirecting to CreateAcademy', name: 'AppRouter.Redirect');
                  return AppRoutes.createAcademy;
                }
                developer.log('Redirect decision: Owner needs academy, staying on CreateAcademy', name: 'AppRouter.Redirect');
                return null; // Stay on create academy
            }
             if (currentLocation == AppRoutes.createAcademy && !needsToCreateAcademy) {
                 developer.log('Redirect decision: Owner has academy, redirecting FROM CreateAcademy to Owner root', name: 'AppRouter.Redirect');
                 return AppRoutes.ownerRoot;
             }
        }

        // 3. Usuario logueado, perfil completo, (propietario con academia):
        if (!isGoingToSplash && (isGoingToPublic || isGoingToIntermediate)) {
            final targetRoute = _getRoleRootRoute(userRole);
            developer.log('Redirect decision: Logged in, redirecting FROM public/intermediate to $targetRoute', name: 'AppRouter.Redirect');
            return targetRoute;
        }

        // 4. Si no aplica ninguna redirección
        developer.log('Redirect decision: No redirection needed, allowing access to ${state.matchedLocation}', name: 'AppRouter.Redirect');
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
              name: 'ownerRoot', // Darle un nombre único a la raíz
              builder: (context, state) => const ScreenUnderDevelopment(message: 'Owner Dashboard'),
              // Ya no anidamos las secciones principales aquí
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
                   return ScreenUnderDevelopment(message: 'Academy Base: $academyId');
                 },
                routes: [ // Rutas anidadas de academia (edit, members, etc.) sí van aquí
                   GoRoute(
                      path: 'edit', 
                      name: AppRoutes.ownerEditAcademy,
                      builder: (context, state) {
                         final academyId = state.pathParameters['academyId']!;
                         // TODO: Obtener la academia real
                         final dummyAcademy = AcademyModel(
                           id: academyId,
                           name: 'Academia $academyId',
                           sportCode: 'test',
                           ownerId: 'test-owner',
                           location: 'Ubicación Ficticia', // Añadido location
                           createdAt: DateTime.now(), // Añadir si es necesario
                           // Añadir otros campos requeridos si los hay
                         );
                         return EditAcademyScreen(academy: dummyAcademy, initialAcademy: dummyAcademy);
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
                               // TODO: Obtener la membresía real
                               final dummyMembership = MembershipModel(id: membershipId, userId: 'test', academyId: academyId, role: AppRole.colaborador, addedAt: DateTime.now());
                               return EditPermissionsScreen(academyId: academyId, membershipId: membershipId, membership: dummyMembership);
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
                    // TODO: Crear AthleteDashboardScreen
                   GoRoute(
                      path: AppRoutes.athleteDashboard, // -> /athlete/dashboard
                      name: AppRoutes.athleteDashboard, // Nombre único
                      builder: (context, state) => const ScreenUnderDevelopment(message: 'Athlete Dashboard'), // Placeholder
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
                 // TODO: Crear CollaboratorDashboardScreen
                 GoRoute(
                    path: AppRoutes.collaboratorDashboard, // -> /collaborator/dashboard
                    name: AppRoutes.collaboratorDashboard, // Nombre único
                    builder: (context, state) => const ScreenUnderDevelopment(message: 'Collaborator Dashboard'), // Placeholder
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
                 // TODO: Crear SuperAdminDashboardScreen
                 GoRoute(
                    path: AppRoutes.superAdminDashboard, // -> /superadmin/dashboard
                    name: AppRoutes.superAdminDashboard, // Nombre único
                    builder: (context, state) => const ScreenUnderDevelopment(message: 'SuperAdmin Dashboard'), // Placeholder
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
                // TODO: Crear ParentDashboardScreen
                GoRoute(
                  path: AppRoutes.parentDashboard, // -> /parent/dashboard
                  name: AppRoutes.parentDashboard, // Nombre único
                  builder: (context, state) => const ScreenUnderDevelopment(message: 'Parent Dashboard'), // Placeholder
                ),
                // Otras rutas específicas para padres...
              ],
            ),
          ],
        ),

      ],
      errorBuilder: (context, state) {
         developer.log('GoRouter ErrorBuilder triggered', error: state.error, name: 'AppRouter.Error');
         return Scaffold(
            appBar: AppBar(title: const Text('Error de Navegación')),
            body: ErrorDisplay(error: state.error?.toString() ?? 'Error desconocido'),
         );
      }
    );
    developer.log('routerProvider: GoRouter instance created successfully', name: 'AppLifecycle');
    return router;
  } catch (e, stackTrace) {
    developer.log('routerProvider: CRITICAL ERROR during GoRouter creation', error: e, stackTrace: stackTrace, name: 'AppLifecycle.Error');
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
