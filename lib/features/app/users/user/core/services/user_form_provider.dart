import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para gestionar el estado del formulario de usuarios
final userFormProvider = StateNotifierProvider.autoDispose<UserFormNotifier, UserFormState>((ref) {
  return UserFormNotifier();
});

/// Estado para el formulario de usuarios
class UserFormState {
  final int currentStep;
  final UserRole selectedRole;
  final bool isLoading;
  final String name;
  final String lastName;
  final DateTime? birthDate;
  final String email;
  final String password;
  final String height;
  final String weight;
  final String phone;
  final String address;
  final String emergencyContact;
  final int experienceYears;
  final String specialties;
  final String certifications;
  final String level;
  final String goals;
  final String medicalConditions;
  final String groupId;

  UserFormState({
    this.currentStep = 0,
    this.selectedRole = UserRole.coach,
    this.isLoading = false,
    this.name = '',
    this.lastName = '',
    this.birthDate,
    this.email = '',
    this.password = '',
    this.height = '',
    this.weight = '',
    this.phone = '',
    this.address = '',
    this.emergencyContact = '',
    this.experienceYears = 0,
    this.specialties = '',
    this.certifications = '',
    this.level = '',
    this.goals = '',
    this.medicalConditions = '',
    this.groupId = '',
  });

  UserFormState copyWith({
    int? currentStep,
    UserRole? selectedRole,
    bool? isLoading,
    String? name,
    String? lastName,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? email,
    String? password,
    String? height,
    String? weight,
    String? phone,
    String? address,
    String? emergencyContact,
    int? experienceYears,
    String? specialties,
    String? certifications,
    String? level,
    String? goals,
    String? medicalConditions,
    String? groupId,
  }) {
    return UserFormState(
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      email: email ?? this.email,
      password: password ?? this.password,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      experienceYears: experienceYears ?? this.experienceYears,
      specialties: specialties ?? this.specialties,
      certifications: certifications ?? this.certifications,
      level: level ?? this.level,
      goals: goals ?? this.goals,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      groupId: groupId ?? this.groupId,
    );
  }

  // Validar el paso actual
  bool isCurrentStepValid() {
    switch (currentStep) {
      case 0: // Información personal
        return name.isNotEmpty && lastName.isNotEmpty && birthDate != null;
      case 1: // Información física o de contacto
        if (selectedRole == UserRole.athlete) {
          return height.isNotEmpty && weight.isNotEmpty;
        }
        return true; // No validamos campos opcionales para otros roles
      case 2: // Información de autenticación
        return email.isNotEmpty && email.contains('@') && password.length >= 6;
      case 3: // Información específica por rol
        return true; // Por ahora dejamos esto como opcional
      default:
        return true;
    }
  }

  // Obtener el número total de pasos según el rol
  int getTotalSteps() {
    switch (selectedRole) {
      case UserRole.athlete:
        return 4; // Incluye información física y deportiva
      case UserRole.coach:
        return 4; // Incluye información de experiencia
      default:
        return 3; // Solo información básica y de autenticación
    }
  }

  // Obtener el título del paso actual
  String getCurrentStepTitle() {
    switch (currentStep) {
      case 0:
        return 'Información Personal';
      case 1:
        return selectedRole == UserRole.athlete
            ? 'Información Física'
            : 'Información de Contacto';
      case 2:
        return 'Información de Autenticación';
      case 3:
        return selectedRole == UserRole.coach
            ? 'Experiencia y Especialización'
            : 'Información Deportiva';
      default:
        return '';
    }
  }
}

/// Notifier para manejar los cambios en el formulario
class UserFormNotifier extends StateNotifier<UserFormState> {
  UserFormNotifier() : super(UserFormState());

  // Métodos para actualizar los campos
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }

  void updateBirthDate(DateTime? birthDate) {
    state = state.copyWith(
      birthDate: birthDate,
      clearBirthDate: birthDate == null,
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateHeight(String height) {
    state = state.copyWith(height: height);
  }

  void updateWeight(String weight) {
    state = state.copyWith(weight: weight);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updateEmergencyContact(String contact) {
    state = state.copyWith(emergencyContact: contact);
  }

  void updateExperienceYears(int years) {
    state = state.copyWith(experienceYears: years);
  }

  void updateSpecialties(String specialties) {
    state = state.copyWith(specialties: specialties);
  }

  void updateCertifications(String certifications) {
    state = state.copyWith(certifications: certifications);
  }

  void updateLevel(String level) {
    state = state.copyWith(level: level);
  }

  void updateGoals(String goals) {
    state = state.copyWith(goals: goals);
  }

  void updateMedicalConditions(String conditions) {
    state = state.copyWith(medicalConditions: conditions);
  }

  void updateGroupId(String groupId) {
    state = state.copyWith(groupId: groupId);
  }

  void updateSelectedRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Navegación entre pasos
  void nextStep() {
    if (state.isCurrentStepValid()) {
      if (state.currentStep < state.getTotalSteps() - 1) {
        state = state.copyWith(currentStep: state.currentStep + 1);
      }
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // Resetear el formulario
  void resetForm() {
    state = UserFormState(selectedRole: state.selectedRole);
  }
} 