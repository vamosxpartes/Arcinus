import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_athlete_state.freezed.dart';

@freezed
class AddAthleteState with _$AddAthleteState {
  const factory AddAthleteState({
    // Paso 1: Información personal
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? phoneNumber,
    
    // Paso 2: Información física
    double? heightCm,
    double? weightKg,
    
    // Paso 3: Información de salud
    String? allergies,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    
    // Paso 4: Información deportiva
    String? position,
    
    // Paso 5: Imagen de perfil
    File? profileImage,
    
    // Estado general del formulario
    @Default(0) int currentStep,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _AddAthleteState;
  
  const AddAthleteState._();
  
  // Validadores
  bool get isPersonalInfoValid => 
      firstName != null && 
      firstName!.isNotEmpty && 
      lastName != null && 
      lastName!.isNotEmpty &&
      birthDate != null;
  
  bool get isPhysicalInfoValid => true; // Opcional, siempre válido
  
  bool get isHealthInfoValid => true; // Opcional, siempre válido
  
  bool get isSportsInfoValid => true; // Opcional, siempre válido
  
  bool get isImageValid => true; // Opcional, siempre válido
  
  bool get canSubmit => 
      isPersonalInfoValid && 
      !isSubmitting &&
      !isError;
  
  bool get isStepValid {
    switch (currentStep) {
      case 0:
        return isPersonalInfoValid;
      case 1:
        return isPhysicalInfoValid;
      case 2:
        return isHealthInfoValid;
      case 3:
        return isSportsInfoValid;
      case 4:
        return isImageValid;
      default:
        return false;
    }
  }
} 