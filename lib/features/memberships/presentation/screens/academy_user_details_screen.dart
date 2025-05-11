import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AcademyUserDetailsScreen extends ConsumerWidget {
  final String academyId;
  final String userId;
  final AcademyUserModel? initialUserData; // Datos iniciales si ya tenemos el objeto

  const AcademyUserDetailsScreen({
    super.key,
    required this.academyId,
    required this.userId,
    this.initialUserData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si tenemos datos iniciales los usamos, sino cargamos del provider
    final userAsyncValue = initialUserData != null
        ? AsyncValue.data(initialUserData!)
        : ref.watch(academyUserDetailsProvider(academyId, userId));

    return Scaffold(
      appBar: AppBar(
        title: userAsyncValue.maybeWhen(
          data: (user) => Text('Detalles de ${user?.fullName ?? "Usuario"}'),
          orElse: () => const Text('Detalles de usuario'),
        ),
        actions: [
          PermissionGate(
            academyId: academyId,
            requiredPermission: AppPermissions.manageMemberships,
            child: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar usuario',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo: Editar usuario')),
                );
              },
            ),
          ),
        ],
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          return _buildUserDetails(context, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar los detalles: $error'),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, AcademyUserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil y datos básicos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Foto de perfil
                  Center(
                    child: Hero(
                      tag: 'user_avatar_${user.id}',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: _getRoleColor(user.role),
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nombre completo
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  // Rol
                  Chip(
                    label: Text(_getRoleName(user.role)),
                    backgroundColor: _getRoleColor(user.role).withAlpha(20),
                    labelStyle: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Posición si es un atleta
                  if (user.position != null && user.position!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Posición: ${user.position}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información personal
          _buildSectionCard(
            context,
            'Información Personal',
            Icons.person,
            [
              _buildInfoRow(context, 'Fecha de nacimiento', user.birthDate != null 
                  ? DateFormat('dd/MM/yyyy').format(user.birthDate!)
                  : 'No disponible'),
              _buildInfoRow(context, 'Teléfono', user.phoneNumber ?? 'No disponible'),
              if (user.heightCm != null)
                _buildInfoRow(context, 'Altura', '${user.heightCm} cm'),
              if (user.weightKg != null)
                _buildInfoRow(context, 'Peso', '${user.weightKg} kg'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información médica
          _buildSectionCard(
            context,
            'Información Médica',
            Icons.medical_services,
            [
              _buildInfoRow(context, 'Alergias', user.allergies ?? 'Ninguna registrada'),
              _buildInfoRow(context, 'Condiciones médicas', user.medicalConditions ?? 'Ninguna registrada'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contacto de emergencia
          if (user.emergencyContact != null && user.emergencyContact!.isNotEmpty)
            _buildSectionCard(
              context,
              'Contacto de Emergencia',
              Icons.emergency,
              [
                _buildInfoRow(context, 'Nombre', user.emergencyContact!['name']?.toString() ?? 'No disponible'),
                _buildInfoRow(context, 'Teléfono', user.emergencyContact!['phone']?.toString() ?? 'No disponible'),
              ],
            ),
            
          const SizedBox(height: 16),
          
          // Información adicional
          _buildSectionCard(
            context,
            'Información Adicional',
            Icons.info,
            [
              _buildInfoRow(context, 'Miembro desde', DateFormat('dd/MM/yyyy').format(user.createdAt)),
              _buildInfoRow(context, 'Última actualización', DateFormat('dd/MM/yyyy').format(user.updatedAt)),
              _buildInfoRow(context, 'ID', user.id),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para construir una sección de información
  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget para construir una fila de información
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Obtener un color para el rol
  Color _getRoleColor(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return Colors.purple;
      case AppRole.colaborador:
        return Colors.blue;
      case AppRole.atleta:
        return Colors.green;
      case AppRole.padre:
        return Colors.orange;
      case AppRole.superAdmin:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Obtener un nombre amigable para el rol
  String _getRoleName(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return 'Propietario';
      case AppRole.colaborador:
        return 'Colaborador';
      case AppRole.atleta:
        return 'Atleta';
      case AppRole.padre:
        return 'Padre/Responsable';
      case AppRole.superAdmin:
        return 'Administrador';
      default:
        return 'Desconocido';
    }
  }
} 