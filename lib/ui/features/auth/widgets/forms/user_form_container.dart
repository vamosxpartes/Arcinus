import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/athlete_specific_step.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/auth_info_step.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/coach_specific_step.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/contact_info_step.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/personal_info_step.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/steps/physical_info_step.dart';
import 'package:arcinus/ux/features/auth/providers/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserFormContainer extends ConsumerWidget {
  final bool canManageAllUsers;
  final VoidCallback onCancel;
  final Function(UserRole) onSubmit;

  const UserFormContainer({
    super.key,
    this.canManageAllUsers = false,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Encabezado con pasos
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear nuevo ${_getRoleName(formState.selectedRole)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                    formState.getTotalSteps(),
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: index <= formState.currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formState.getCurrentStepTitle(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Contenido del paso actual
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: _buildCurrentStepContent(formState),
              ),
            ),
          ),
          
          // Barra inferior con botones
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: formState.currentStep == 0 ? onCancel : formNotifier.previousStep,
                  child: Text(formState.currentStep == 0 ? 'Cancelar' : 'Atrás'),
                ),
                ElevatedButton(
                  onPressed: formState.isLoading 
                      ? null 
                      : (formState.currentStep == formState.getTotalSteps() - 1 
                          ? () => _handleSubmit(formState, formNotifier) 
                          : formNotifier.nextStep),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          formState.currentStep == formState.getTotalSteps() - 1
                              ? 'Crear Usuario'
                              : 'Siguiente',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent(UserFormState formState) {
    switch (formState.currentStep) {
      case 0:
        return PersonalInfoStep(canManageAllUsers: canManageAllUsers);
      case 1:
        return formState.selectedRole == UserRole.athlete
            ? const PhysicalInfoStep()
            : const ContactInfoStep();
      case 2:
        return const AuthInfoStep();
      case 3:
        return formState.selectedRole == UserRole.coach
            ? const CoachSpecificStep()
            : const AthleteSpecificStep();
      default:
        return Container();
    }
  }

  void _handleSubmit(UserFormState formState, UserFormNotifier formNotifier) {
    if (formState.isCurrentStepValid()) {
      formNotifier.setLoading(true);
      
      // Aquí iría la implementación real para enviar la información
      // Por ahora, simular un pequeño retraso
      Future.delayed(const Duration(seconds: 1), () {
        onSubmit(formState.selectedRole);
        formNotifier.setLoading(false);
        formNotifier.resetForm();
      });
    }
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
      case UserRole.owner:
        return 'Owner';
      default:
        return '';
    }
  }
} 