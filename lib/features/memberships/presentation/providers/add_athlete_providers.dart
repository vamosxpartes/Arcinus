import 'dart:io';
import 'package:arcinus/features/memberships/domain/state/add_athlete_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

part 'add_athlete_providers.g.dart';

// Provider para el estado del formulario de atleta
@riverpod
class AddAthleteNotifier extends _$AddAthleteNotifier {
  final _imagePicker = ImagePicker();
  
  @override
  AddAthleteState build() {
    return const AddAthleteState();
  }
  
  // Métodos para actualizar campos individuales
  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }
  
  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }
  
  void updateBirthDate(DateTime birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }
  
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }
  
  void updateHeight(String heightCm) {
    double? parsedHeight = double.tryParse(heightCm);
    state = state.copyWith(heightCm: parsedHeight);
  }
  
  void updateWeight(String weightKg) {
    double? parsedWeight = double.tryParse(weightKg);
    state = state.copyWith(weightKg: parsedWeight);
  }
  
  void updateAllergies(String allergies) {
    state = state.copyWith(allergies: allergies);
  }
  
  void updateMedicalConditions(String medicalConditions) {
    state = state.copyWith(medicalConditions: medicalConditions);
  }
  
  void updateEmergencyContactName(String name) {
    state = state.copyWith(emergencyContactName: name);
  }
  
  void updateEmergencyContactPhone(String phone) {
    state = state.copyWith(emergencyContactPhone: phone);
  }
  
  void updatePosition(String position) {
    state = state.copyWith(position: position);
  }
  
  // Métodos para manejar pasos del formulario
  void nextStep() {
    if (state.currentStep < 4) { // 5 pasos en total (0-4)
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
  
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }
  
  // Manejo de imágenes
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Verificar que el archivo existe y no está vacío
        final File imageFile = File(pickedFile.path);
        final fileExists = await imageFile.exists();
        final fileSize = await imageFile.length();
        
        if (!fileExists || fileSize <= 0) {
          state = state.copyWith(
            isError: true,
            errorMessage: 'Error: La imagen seleccionada está vacía o no existe',
          );
          return;
        }
        
        try {
          // Evitar usar el directorio temporal para reducir problemas de eliminación automática
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = 'athlete_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final targetPath = path.join(appDir.path, fileName);
          
          // Copiar a ubicación más segura
          final File savedImage = await imageFile.copy(targetPath);
          
          // Verificar que la copia se realizó correctamente
          if (await savedImage.exists() && await savedImage.length() > 0) {
            state = state.copyWith(profileImage: savedImage);
          } else {
            state = state.copyWith(
              isError: true,
              errorMessage: 'Error al guardar la imagen',
            );
          }
        } catch (e) {
          state = state.copyWith(
            isError: true,
            errorMessage: 'Error al procesar la imagen: $e',
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isError: true,
        errorMessage: 'Error al seleccionar imagen: $e',
      );
    }
  }
  
  // Método para enviar el formulario completo
  Future<void> submitForm(String academyId, String userId) async {
    if (!state.canSubmit) return;
    
    state = state.copyWith(isSubmitting: true, isError: false, errorMessage: null);
    
    try {
      // 1. Subir la imagen si existe
      if (state.profileImage != null) {
      }
      
      // TODO: Crear el documento del atleta en Firestore
      // ...
      
      // Éxito
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isError: true,
        errorMessage: 'Error al guardar atleta: $e',
      );
    }
  }
  
  // Método para resetear el formulario
  void resetForm() {
    state = const AddAthleteState();
  }
  
  // Método para resetear solo la imagen
  void resetImage() {
    if (state.profileImage != null) {
      try {
        // Intentar eliminar el archivo físico
        // ignore: body_might_complete_normally_catch_error
        state.profileImage!.delete().catchError((_) {
          // Ignorar errores al eliminar el archivo
        });
      } catch (_) {
        // Ignorar cualquier error
      } finally {
        // Siempre actualizar el estado para quitar la referencia
        state = state.copyWith(profileImage: null);
      }
    }
  }
  
  // Método para cargar datos de prueba
  void cargarDatosDePrueba() {
    final now = DateTime.now();
    final fechaNacimiento = DateTime(now.year - 15, now.month, now.day); // 15 años atrás
    
    // Actualizar estado con datos de prueba
    state = state.copyWith(
      firstName: 'Carlos',
      lastName: 'Rodríguez',
      birthDate: fechaNacimiento,
      phoneNumber: '655123456',
      heightCm: 176.5,
      weightKg: 68.2,
      allergies: 'Ninguna conocida',
      medicalConditions: 'Asma leve',
      emergencyContactName: 'Ana Rodríguez',
      emergencyContactPhone: '655789012',
      position: 'Defensa central'
    );
    
    // Actualizar los controladores para reflejar los datos
    if (ref.exists(addAthleteControllersProvider)) {
      final controllers = ref.read(addAthleteControllersProvider);
      controllers['firstName']?.text = state.firstName ?? '';
      controllers['lastName']?.text = state.lastName ?? '';
      controllers['birthDate']?.text = state.birthDate != null 
          ? DateFormat('dd/MM/yyyy').format(state.birthDate!) 
          : '';
      controllers['phoneNumber']?.text = state.phoneNumber ?? '';
      controllers['heightCm']?.text = state.heightCm?.toString() ?? '';
      controllers['weightKg']?.text = state.weightKg?.toString() ?? '';
      controllers['allergies']?.text = state.allergies ?? '';
      controllers['medicalConditions']?.text = state.medicalConditions ?? '';
      controllers['emergencyContactName']?.text = state.emergencyContactName ?? '';
      controllers['emergencyContactPhone']?.text = state.emergencyContactPhone ?? '';
      controllers['position']?.text = state.position ?? '';
    }
  }
}

// Provider para los controladores del formulario
@riverpod
class AddAthleteControllers extends _$AddAthleteControllers {
  @override
  Map<String, TextEditingController> build() {
    final controllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
      'birthDate': TextEditingController(),
      'phoneNumber': TextEditingController(),
      'heightCm': TextEditingController(),
      'weightKg': TextEditingController(),
      'allergies': TextEditingController(),
      'medicalConditions': TextEditingController(),
      'emergencyContactName': TextEditingController(),
      'emergencyContactPhone': TextEditingController(),
      'position': TextEditingController(),
    };
    
    // Liberar los controladores cuando se destruye el provider
    ref.onDispose(() {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
    
    return controllers;
  }
  
  // Método para formatear la fecha en el controlador
  void setDateText(DateTime date) {
    state['birthDate']!.text = DateFormat('dd/MM/yyyy').format(date);
  }
} 