import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalInfoStep extends ConsumerWidget {
  final bool canManageAllUsers;

  const PersonalInfoStep({
    super.key,
    this.canManageAllUsers = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingresa la información personal del usuario:'),
        const SizedBox(height: 24),
        
        TextFormField(
          initialValue: formState.name,
          decoration: const InputDecoration(
            labelText: 'Nombre',
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
          onChanged: (value) => formNotifier.updateName(value),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          initialValue: formState.lastName,
          decoration: const InputDecoration(
            labelText: 'Apellidos',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa los apellidos';
            }
            return null;
          },
          onChanged: (value) => formNotifier.updateLastName(value),
        ),
        const SizedBox(height: 16),
        
        // Selector de fecha de nacimiento
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: formState.birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1940),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              formNotifier.updateBirthDate(picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de Nacimiento',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              formState.birthDate == null
                  ? 'Seleccionar fecha'
                  : '${formState.birthDate!.day}/${formState.birthDate!.month}/${formState.birthDate!.year}',
            ),
          ),
        ),
        
        if (formState.selectedRole == UserRole.coach || formState.selectedRole == UserRole.manager) ...[
          const SizedBox(height: 24),
          const Text('Rol a asignar:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          DropdownButtonFormField<UserRole>(
            decoration: const InputDecoration(
              labelText: 'Rol del usuario',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
            value: formState.selectedRole,
            items: _buildRoleItems(formState.currentStep, canManageAllUsers),
            onChanged: (value) {
              if (value != null) {
                formNotifier.updateSelectedRole(value);
              }
            },
          ),
        ],
      ],
    );
  }

  List<DropdownMenuItem<UserRole>> _buildRoleItems(int currentTabIndex, bool canManageAllUsers) {
    final List<DropdownMenuItem<UserRole>> items = [];
    
    if (currentTabIndex == 0 || canManageAllUsers) {
      items.add(
        DropdownMenuItem(
          value: UserRole.manager,
          child: _buildRoleItem(Icons.admin_panel_settings, 'Gerente'),
        ),
      );
    }
    
    if (currentTabIndex <= 1) {
      items.add(
        DropdownMenuItem(
          value: UserRole.coach,
          child: _buildRoleItem(Icons.sports, 'Entrenador'),
        ),
      );
    }
    
    if (currentTabIndex <= 2) {
      items.add(
        DropdownMenuItem(
          value: UserRole.athlete,
          child: _buildRoleItem(Icons.fitness_center, 'Atleta'),
        ),
      );
    }
    
    items.add(
      DropdownMenuItem(
        value: UserRole.parent,
        child: _buildRoleItem(Icons.family_restroom, 'Padre/Responsable'),
      ),
    );
    
    return items;
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
} 