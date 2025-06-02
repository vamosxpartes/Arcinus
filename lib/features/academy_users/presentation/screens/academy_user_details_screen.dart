import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/academy_users/presentation/providers/academy_users_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';
import 'package:arcinus/features/academy_users/presentation/widgets/user_profile_header.dart';
import 'package:arcinus/features/academy_users/presentation/widgets/user_info_section.dart';

class AcademyUserDetailsScreen extends ConsumerStatefulWidget {
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
  ConsumerState<AcademyUserDetailsScreen> createState() => _AcademyUserDetailsScreenState();
}

class _AcademyUserDetailsScreenState extends ConsumerState<AcademyUserDetailsScreen> {
  bool _titlePushed = false;

  @override
  void initState() {
    super.initState();
    
    // Si tenemos datos iniciales, actualizar el título inmediatamente
    if (widget.initialUserData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_titlePushed) {
          ref.read(titleManagerProvider.notifier).pushTitle('Detalles de ${widget.initialUserData!.fullName}');
          _titlePushed = true;
        }
      });
    }
  }

  void _updateTitleIfNeeded(AcademyUserModel user) {
    if (!_titlePushed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(titleManagerProvider.notifier).pushTitle('Detalles de ${user.fullName}');
          _titlePushed = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si tenemos datos iniciales los usamos, sino cargamos del provider
    final userAsyncValue = widget.initialUserData != null
        ? AsyncValue.data(widget.initialUserData!)
        : ref.watch(academyUserDetailsProvider(widget.academyId, widget.userId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _titlePushed) {
          // Restaurar el título anterior cuando se hace pop
          ref.read(titleManagerProvider.notifier).popTitle();
        }
      },
      child: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          
          // Actualizar título solo si no se ha hecho antes
          _updateTitleIfNeeded(user);
          
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
    // Si es atleta, cargamos la información completa usando el nuevo sistema de períodos
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con foto de perfil y datos básicos
          UserProfileHeader(user: user),
          
          const SizedBox(height: 16),
          
          // Información personal
          UserInfoSection(
            title: 'Información Personal',
            icon: Icons.person,
            children: [
              UserInfoRow(
                label: 'Fecha de nacimiento',
                value: user.birthDate != null 
                    ? DateFormat('dd/MM/yyyy').format(user.birthDate!)
                    : 'No disponible',
              ),
              UserInfoRow(
                label: 'Teléfono',
                value: user.phoneNumber ?? 'No disponible',
              ),
              if (user.heightCm != null)
                UserInfoRow(
                  label: 'Altura',
                  value: '${user.heightCm} cm',
                ),
              if (user.weightKg != null)
                UserInfoRow(
                  label: 'Peso',
                  value: '${user.weightKg} kg',
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información médica
          UserInfoSection(
            title: 'Información Médica',
            icon: Icons.medical_services,
            children: [
              UserInfoRow(
                label: 'Alergias',
                value: user.allergies ?? 'Ninguna registrada',
              ),
              UserInfoRow(
                label: 'Condiciones médicas',
                value: user.medicalConditions ?? 'Ninguna registrada',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contacto de emergencia
          if (user.emergencyContact.isNotEmpty)
            UserInfoSection(
              title: 'Contacto de Emergencia',
              icon: Icons.emergency,
              children: [
                UserInfoRow(
                  label: 'Nombre',
                  value: user.emergencyContact['name']?.toString() ?? 'No disponible',
                ),
                UserInfoRow(
                  label: 'Teléfono',
                  value: user.emergencyContact['phone']?.toString() ?? 'No disponible',
                ),
              ],
            ),
            
          const SizedBox(height: 16),
          
          // Información adicional
          UserInfoSection(
            title: 'Información Adicional',
            icon: Icons.info,
            children: [
              UserInfoRow(
                label: 'Miembro desde',
                value: DateFormat('dd/MM/yyyy').format(user.createdAt),
              ),
              UserInfoRow(
                label: 'Última actualización',
                value: DateFormat('dd/MM/yyyy').format(user.updatedAt),
              ),
              UserInfoRow(
                label: 'ID',
                value: user.id ?? 'No disponible',
              ),
            ],
          ),
        ],
      ),
    );
  }
} 