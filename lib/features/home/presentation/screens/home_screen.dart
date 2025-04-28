import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal de la aplicación.
///
/// Esta pantalla se muestra después de que el usuario ha iniciado sesión
/// y ha completado todos los flujos iniciales requeridos.
class HomeScreen extends ConsumerWidget {
  /// ID de la academia actual, si se especifica.
  final String? academyId;

  /// Crea una instancia de [HomeScreen].
  const HomeScreen({super.key, this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;
    final role = user?.role ?? AppRole.desconocido;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcinus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Navegar al perfil del usuario
            },
            tooltip: 'Mi Perfil',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado del drawer
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuario'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            // Elementos del menú
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context); // Cerrar el drawer
                if (academyId != null) {
                  context.go('/academy/$academyId');
                } else {
                  context.go('/home');
                }
              },
            ),
            
            if (role == AppRole.propietario || role == AppRole.colaborador) ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Miembros'),
                onTap: () {
                  Navigator.pop(context);
                  if (academyId != null) {
                    context.go('/academy/$academyId/members');
                  }
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text('Pagos'),
                onTap: () {
                  Navigator.pop(context);
                  if (academyId != null) {
                    context.go('/academy/$academyId/payments');
                  }
                },
              ),
            ],
            
            const Divider(),
            
            if (role == AppRole.propietario) ...[
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración Academia'),
                onTap: () {
                  Navigator.pop(context);
                  if (academyId != null) {
                    context.go('/academy/$academyId/edit');
                  }
                },
              ),
            ],
            
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Mostrar información sobre la app
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a Arcinus',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (academyId != null)
              Text(
                'Academia ID: $academyId',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 32),
            Text(
              'Rol: ${role.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            const Text(
              'Selecciona una opción del menú lateral para comenzar',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 