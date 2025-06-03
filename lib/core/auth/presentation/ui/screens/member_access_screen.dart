import 'package:arcinus/core/utils/constants/app_assets.dart';
import 'package:arcinus/core/navigation/routes/app_routes.dart';
import 'package:arcinus/core/navigation/routes/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla para que los miembros/invitados accedan al sistema.
///
/// Permite ingresar un código de invitación o buscar una academia.
class MemberAccessScreen extends ConsumerStatefulWidget {
  /// Crea una instancia de [MemberAccessScreen].
  const MemberAccessScreen({super.key});

  @override
  ConsumerState<MemberAccessScreen> createState() => _MemberAccessScreenState();
}

class _MemberAccessScreenState extends ConsumerState<MemberAccessScreen> {
  final _invitationCodeController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _invitationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso para Miembros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Arcinus
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Image.asset(
                AppAssets.logoBlack,
                height: 80,
              ),
            ),

            Text(
              'Acceso para Miembros',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu código de invitación o busca tu academia',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Formulario de código de invitación
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tengo un código de invitación',
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _invitationCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de invitación',
                        hintText: 'Ej. ABC123',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // Para el MVP, simplemente navegamos a la pantalla de login
                                context.push(AuthRoutes.login);
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('CONTINUAR'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text('- O -', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Botón para buscar academia
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Buscar mi academia',
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Si no tienes un código de invitación, puedes buscar tu academia y solicitar acceso.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Esta funcionalidad estará disponible próximamente',
                              ),
                            ),
                          );
                        },
                        child: const Text('BUSCAR ACADEMIA'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 