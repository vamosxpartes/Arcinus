import 'package:arcinus/config/firebase/analytics_service.dart';
import 'package:arcinus/ui/features/auth/screens/auth_screens.dart';
import 'package:arcinus/ui/features/dashboard/screens/dashboard_screens.dart';
import 'package:arcinus/ui/features/splash/splash_screen.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para controlar cuando se ha cargado el splash
final splashCompletedProvider = StateProvider<bool>((ref) => false);

class ArcinusApp extends ConsumerWidget {
  const ArcinusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsObserver = AnalyticsService().getAnalyticsObserver();
    final authState = ref.watch(authStateProvider);
    final splashCompleted = ref.watch(splashCompletedProvider);
    
    // Si el splash no ha terminado, lo mostramos
    if (!splashCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3E7BFA),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3E7BFA),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E7BFA),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E7BFA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
      // Usamos un consumer builder para determinar si mostrar la pantalla de login o la de dashboard
      home: authState.when(
        loading: () => const LoadingScreen(),
        error: (_, __) => const LoginScreen(),
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          } else {
            return const DashboardScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/users-management': (context) => const UserManagementScreen(),
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
      body: Center(
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
    );
  }
} 