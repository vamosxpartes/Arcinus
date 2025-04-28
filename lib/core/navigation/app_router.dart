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
import 'package:arcinus/features/home/presentation/screens/home_screen.dart';
import 'package:arcinus/features/splash/presentation/providers/splash_controller.dart';
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

/// Provider que expone el router de la aplicación.
final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    // Eliminar refreshListenable por ahora para simplificar
    // refreshListenable: GoRouterRefreshStream(authStateNotifierProvider.stream), 
    redirect: (BuildContext context, GoRouterState state) async {
      // --- Splash y Estados --- 
      final splashCompleted = ref.read(splashCompletedProvider); // Usar read dentro de redirect
      // Leer el estado de autenticación actual
      final currentAuthState = ref.read(authStateNotifierProvider); 
      final currentUserId = currentAuthState.user?.id;
      
      if (!splashCompleted) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }
      
      final isLoggedIn = currentAuthState.isAuthenticated;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnWelcome = state.matchedLocation == AppRoutes.welcome;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.memberAccess;
      final isOnCompleteProfile = state.matchedLocation == AppRoutes.completeProfile;
      final isOnCreateAcademy = state.matchedLocation == AppRoutes.createAcademy;

      // --- Lógica de Redirección ---
      if (!isLoggedIn) {
        // No logueado: Solo permitir splash, welcome y auth.
        return (isOnSplash || isOnWelcome || isOnAuth) ? null : AppRoutes.welcome;
      }

      // --- Usuario Logueado ---
      // 1. Necesita completar perfil?
      final profileState = ref.read(userProfileProvider(currentUserId!)); // Leer perfil
      final needsProfileCompletion = profileState.maybeWhen(
         data: (profile) => profile == null || (profile.name?.isEmpty ?? true),
         loading: () => true, // Asumir que necesita si está cargando
         orElse: () => false,
      );

      if (needsProfileCompletion) {
          return isOnCompleteProfile ? null : AppRoutes.completeProfile;
      }

      // 2. Es Propietario y necesita crear academia?
      final isOwner = currentAuthState.user?.role == AppRole.propietario;
      if (isOwner) {
          final academiesState = ref.read(ownerHasAcademiesProvider(currentUserId));
          final needsToCreateAcademy = academiesState.maybeWhen(
              data: (hasAcademies) => !hasAcademies,
              loading: () => true, // Asumir que necesita si está cargando
              orElse: () => false,
          );
          if (needsToCreateAcademy) {
              return isOnCreateAcademy ? null : AppRoutes.createAcademy;
          }
      }
      
      // 3. Redirigir fuera de pantallas iniciales si ya no aplican
      if (isOnWelcome || isOnAuth || isOnCompleteProfile || isOnCreateAcademy) {
          return AppRoutes.home; 
      }

      // 4. Si no aplica ninguna redirección, permitir acceso.
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.memberAccess,
        builder: (context, state) => const MemberAccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAcademy,
        builder: (context, state) => const CreateAcademyScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.underDevelopment,
        builder: (context, state) => const ScreenUnderDevelopment(message: '',),
      ),
      GoRoute(
        name: 'academy',
        path: '/academy/:academyId',
        builder: (context, state) {
          final academyId = state.pathParameters['academyId']!;
          return HomeScreen(academyId: academyId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editAcademy',
            builder: (context, state) {
              final academyId = state.pathParameters['academyId']!;
              // TODO: Obtener la academia real desde el repository
              final dummyAcademy = AcademyModel(
                id: academyId,
                name: 'Academia de prueba',
                sportCode: 'basketball',
                ownerId: 'owner-id',
                location: 'Ubicación de prueba',
                phone: '1234567890',
                email: 'academia@ejemplo.com',
                createdAt: DateTime.now(),
              );
              return EditAcademyScreen(academy: dummyAcademy, initialAcademy: dummyAcademy,);
            },
          ),
          GoRoute(
            path: 'members',
            name: AppRoutes.academyMembers,
            builder: (context, state) {
               final academyId = state.pathParameters['academyId']!;
               return AcademyMembersScreen(academyId: academyId);
            },
            routes: [
              GoRoute(
                path: 'invite',
                name: AppRoutes.inviteMember,
                builder: (context, state) {
                  final academyId = state.pathParameters['academyId']!;
                  return InviteMemberScreen(academyId: academyId);
                },
              ),
              GoRoute(
                path: AppRoutes.editMemberPermissions,
                name: 'editMemberPermissions',
                builder: (context, state) {
                  final academyId = state.pathParameters['academyId']!;
                  final membershipId = state.pathParameters['membershipId']!;
                  
                  // TODO: Obtener la membresía real desde el repositorio
                  // Para el MVP, usamos una membresía ficticia
                  final dummyMembership = MembershipModel(
                    id: membershipId,
                    userId: 'user-id',
                    academyId: academyId,
                    role: AppRole.colaborador,
                    addedAt: DateTime.now(),
                    permissions: const ['view_members', 'view_athletes'],
                  );
                  
                  return EditPermissionsScreen(
                    academyId: academyId,
                    membershipId: membershipId,
                    membership: dummyMembership,
                  );
                },
              ),
            ]
          ),
          // Rutas de pagos
          GoRoute(
            path: 'payments',
            name: 'payments',
            builder: (context, state) {
              final academyId = state.pathParameters['academyId']!;
              return PaymentsScreen();
            },
            routes: [
              GoRoute(
                path: 'register',
                name: 'registerPayment',
                builder: (context, state) {
                  final academyId = state.pathParameters['academyId']!;
                  return RegisterPaymentScreen();
                },
              ),
              GoRoute(
                path: ':paymentId',
                name: 'paymentDetails',
                builder: (context, state) {
                  final paymentId = state.pathParameters['paymentId']!;
                  // TODO: Implementar la pantalla de detalles del pago
                  return ScreenUnderDevelopment(
                    message: 'Detalles del pago $paymentId',
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editPayment',
                    builder: (context, state) {
                      final academyId = state.pathParameters['academyId']!;
                      final paymentId = state.pathParameters['paymentId']!;
                      // TODO: Implementar la pantalla de edición de pago
                      return ScreenUnderDevelopment(
                        message: 'Editar pago $paymentId',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorDisplay(error: state.error.toString()),
  );
});

// Eliminar GoRouterRefreshStream por ahora
// class GoRouterRefreshStream extends ChangeNotifier { ... }
