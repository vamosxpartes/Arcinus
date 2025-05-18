import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/screens/edit_athlete_screen.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:arcinus/features/payments/presentation/screens/athlete_payments_screen.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
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
                if (userAsyncValue.value == null) return;
                
                final user = userAsyncValue.value!;
                final userRole = user.role != null
                    ? AppRole.values.firstWhere(
                        (r) => r.name == user.role,
                        orElse: () => AppRole.atleta,
                      )
                    : AppRole.atleta;
                    
                if (userRole == AppRole.atleta) {
                  // Si es atleta, navegamos a la pantalla de edición específica para atletas
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditAthleteScreen(
                        academyId: academyId,
                        userId: userId,
                        initialUserData: user,
                      ),
                    ),
                  );
                } else {
                  // Para otros roles, mostramos mensaje que está en desarrollo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función en desarrollo: Editar usuario no atleta')),
                  );
                }
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
          
          final userRole = user.role != null
              ? AppRole.values.firstWhere(
                  (r) => r.name == user.role,
                  orElse: () => AppRole.atleta,
                )
              : AppRole.atleta;
              
          return _buildUserDetails(context, ref, user, userRole);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar los detalles: $error'),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, WidgetRef ref, AcademyUserModel user, AppRole userRole) {
    final isAthlete = userRole == AppRole.atleta;
    
    // Si es atleta, también cargamos la información de suscripción
    final clientUserAsync = isAthlete 
        ? ref.watch(clientUserProvider(user.id))
        : null;
    
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
          
          // Tarjeta de suscripción para atletas
          if (isAthlete && clientUserAsync != null)
            clientUserAsync.when(
              data: (clientUser) {
                if (clientUser == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay información de suscripción disponible'),
                    ),
                  );
                }
                
                // Colores según estado de pago
                final Color statusColor;
                switch (clientUser.paymentStatus) {
                  case PaymentStatus.active:
                    statusColor = Colors.green;
                    break;
                  case PaymentStatus.overdue:
                    statusColor = Colors.orange;
                    break;
                  case PaymentStatus.inactive:
                  // ignore: unreachable_switch_default
                  default:
                    statusColor = Colors.grey;
                    break;
                }

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Suscripción Actual',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 150,
                                height: 50,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.receipt_long),
                                  label: const Text('Ver pagos'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AthletePaymentsScreen(
                                          athleteId: user.id,
                                          athleteName: user.fullName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Divider(height: 1),
                      
                      // Estado de pago
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              clientUser.paymentStatus == PaymentStatus.active
                                  ? Icons.check_circle
                                  : (clientUser.paymentStatus == PaymentStatus.overdue
                                      ? Icons.warning
                                      : Icons.cancel),
                              color: statusColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estado: ${clientUser.paymentStatus.displayName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Detalles del plan
                      if (clientUser.subscriptionPlan != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan: ${clientUser.subscriptionPlan!.name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Monto: ${clientUser.subscriptionPlan!.amount} ${clientUser.subscriptionPlan!.currency}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Ciclo: ${clientUser.subscriptionPlan!.billingCycle.displayName}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (clientUser.subscriptionPlan!.benefits.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Beneficios:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...clientUser.subscriptionPlan!.benefits.map((benefit) => 
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, size: 14, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          benefit,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      
                      // Información de fechas y progreso
                      if (clientUser.nextPaymentDate != null && clientUser.lastPaymentDate != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información de Pago:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Último pago: ${DateFormat('dd/MM/yyyy').format(clientUser.lastPaymentDate!)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Próximo pago: ${DateFormat('dd/MM/yyyy').format(clientUser.nextPaymentDate!)}',
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: clientUser.remainingDays != null && clientUser.remainingDays! < 5
                                    ? Colors.red
                                    : AppTheme.darkGray,
                                ),
                              ),
                              
                              // Barra de progreso
                              if (clientUser.remainingDays != null) ...[
                                const SizedBox(height: 12),
                                
                                // Cálculo para la barra de progreso
                                Builder(
                                  builder: (context) {
                                    final now = DateTime.now();
                                    final lastPayment = clientUser.lastPaymentDate!;
                                    final nextPayment = clientUser.nextPaymentDate!;
                                    
                                    // Solo mostrar si las fechas son lógicas
                                    if (nextPayment.isAfter(now) && nextPayment.isAfter(lastPayment)) {
                                      // Cálculo de días totales y restantes
                                      final totalDays = nextPayment.difference(lastPayment).inDays;
                                      final daysElapsed = now.difference(lastPayment).inDays;
                                      
                                      // Evitar división por cero
                                      final double progressPercent = totalDays > 0 
                                          ? daysElapsed / totalDays 
                                          : 0.0;
                                      
                                      // Límites para asegurar que está entre 0 y 1
                                      final double clampedProgress = progressPercent.clamp(0.0, 1.0);
                                      
                                      // Color según días restantes
                                      final Color progressColor;
                                      if (clientUser.remainingDays! < 5) {
                                        progressColor = Colors.red;
                                      } else if (clientUser.remainingDays! < 15) {
                                        progressColor = Colors.orange;
                                      } else {
                                        progressColor = Colors.green;
                                      }
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Información sobre días restantes
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Período actual:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.darkGray,
                                                ),
                                              ),
                                              Text(
                                                '${clientUser.remainingDays} días restantes',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: clientUser.remainingDays! < 5 ? Colors.red : AppTheme.darkGray,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Barra de progreso
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: clampedProgress,
                                              backgroundColor: Colors.grey.withAlpha(60),
                                              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                              minHeight: 5,
                                            ),
                                          ),
                                          
                                          // Fechas de inicio y fin
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(lastPayment),
                                                style: TextStyle(fontSize: 10, color: AppTheme.darkGray),
                                              ),
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(nextPayment),
                                                style: TextStyle(fontSize: 10, color: AppTheme.darkGray),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                    
                                    return const SizedBox.shrink();
                                  }
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error al cargar información de suscripción: $error'),
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