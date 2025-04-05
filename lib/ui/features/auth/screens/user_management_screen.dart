import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.coach;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _emailController.clear();
    _nameController.clear();
    setState(() {
      _selectedRole = UserRole.coach;
    });
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí iría la implementación real para enviar invitaciones
      // Por ahora mostramos un mensaje de éxito simulado
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitación enviada correctamente')),
      );
      
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar invitación: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final bool canManageAllUsers = user?.role == UserRole.owner || user?.role == UserRole.manager;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Invitar'),
            Tab(text: 'Usuarios'),
            Tab(text: 'Pendientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de Invitación
          _buildInvitationTab(theme, canManageAllUsers),
          
          // Tab de Usuarios Existentes
          _buildUsersTab(),
          
          // Tab de Invitaciones Pendientes
          _buildPendingInvitationsTab(),
        ],
      ),
    );
  }

  Widget _buildInvitationTab(ThemeData theme, bool canManageAllUsers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invitar nuevo usuario',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Envía una invitación para que un nuevo usuario se una a tu academia.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            
            // Campos del formulario
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un correo electrónico';
                }
                if (!value.contains('@')) {
                  return 'Por favor ingresa un correo electrónico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Selección de rol
            DropdownButtonFormField<UserRole>(
              decoration: const InputDecoration(
                labelText: 'Rol del usuario',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              value: _selectedRole,
              items: [
                if (canManageAllUsers) ...[
                  DropdownMenuItem(
                    value: UserRole.manager,
                    child: _buildRoleItem(Icons.admin_panel_settings, 'Gerente'),
                  ),
                ],
                DropdownMenuItem(
                  value: UserRole.coach,
                  child: _buildRoleItem(Icons.sports, 'Entrenador'),
                ),
                DropdownMenuItem(
                  value: UserRole.athlete,
                  child: _buildRoleItem(Icons.fitness_center, 'Atleta'),
                ),
                DropdownMenuItem(
                  value: UserRole.parent,
                  child: _buildRoleItem(Icons.family_restroom, 'Padre/Responsable'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            
            // Descripción del rol seleccionado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permisos del rol: ${_getRoleName(_selectedRole)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_getRoleDescription(_selectedRole)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Botón de enviar invitación
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendInvitation,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Enviar Invitación',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Funcionalidad en desarrollo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('La lista de usuarios se implementará próximamente.'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad no implementada')),
              );
            },
            child: const Text('Ver Usuarios (Próximamente)'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingInvitationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mail, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Funcionalidad en desarrollo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('La lista de invitaciones pendientes se implementará próximamente.'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad no implementada')),
              );
            },
            child: const Text('Ver Invitaciones (Próximamente)'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Responsable';
      default:
        return '';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Puede gestionar todos los aspectos de la academia, incluyendo usuarios, grupos, pagos y configuraciones.';
      case UserRole.coach:
        return 'Puede gestionar sus grupos asignados, crear entrenamientos, registrar asistencia y evaluar atletas.';
      case UserRole.athlete:
        return 'Puede ver sus entrenamientos, clases y evaluaciones de rendimiento.';
      case UserRole.parent:
        return 'Puede ver información de sus atletas vinculados, incluyendo asistencia, pagos y rendimiento.';
      default:
        return '';
    }
  }
} 