import 'package:arcinus/config/firebase/analytics_service.dart';
import 'package:arcinus/ui/features/auth/screens/auth_screens.dart';
import 'package:arcinus/ui/features/chat/screens/chat_screen.dart';
import 'package:arcinus/ui/features/chat/screens/chats_list_screen.dart';
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
        '/chats': (context) => const ChatsListScreen(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/trainings': (context) => const UnderDevelopmentScreen(title: 'Entrenamientos'),
        '/calendar': (context) => const UnderDevelopmentScreen(title: 'Calendario'),
        '/stats': (context) => const UnderDevelopmentScreen(title: 'Estadísticas'),
        '/settings': (context) => const UnderDevelopmentScreen(title: 'Configuración'),
        '/payments': (context) => const UnderDevelopmentScreen(title: 'Pagos'),
        '/academies': (context) => const UnderDevelopmentScreen(title: 'Academias'),
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

// Pantalla de lista de chats
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView.separated(
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
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marcar todas como leídas')),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: ListView.builder(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'En desarrollo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Esta funcionalidad se encuentra actualmente en desarrollo. ¡Vuelve pronto!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
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
    );
  }
} 