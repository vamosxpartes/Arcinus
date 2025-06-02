import 'dart:io';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:arcinus/features/academy_users/presentation/state/add_athlete_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academy_users/presentation/providers/academy_providers.dart';

part 'add_athlete_providers.g.dart';

// Definición manual de StateNotifier
class AddAthleteStateNotifier extends StateNotifier<AddAthleteState> {
  final _imagePicker = ImagePicker();
  static const String _className = 'AddAthleteNotifier';
  final Ref ref;
  
  AddAthleteStateNotifier(this.ref) : super(const AddAthleteState());
  
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
  
  void updateEmergencyContactPhone(String? emergencyContactPhone) {
    state = state.copyWith(emergencyContactPhone: emergencyContactPhone);
  }
  
  void updatePosition(String? position) {
    state = state.copyWith(position: position);
  }
  
  void updateExperience(String? experience) {
    state = state.copyWith(experience: experience);
  }
  
  void updateSpecialization(String? specialization) {
    state = state.copyWith(specialization: specialization);
  }
  
  void updateProfileImage(File? profileImage) {
    state = state.copyWith(profileImage: profileImage);
  }
  
  void updateSubscriptionPlan(String? subscriptionPlanId) {
    AppLogger.logInfo(
      'Actualizando plan de suscripción',
      className: _className,
      functionName: 'updateSubscriptionPlan',
      params: {'planId': subscriptionPlanId},
    );
    state = state.copyWith(subscriptionPlanId: subscriptionPlanId);
  }
  
  void updateSubscriptionStartDate(DateTime? startDate) {
    AppLogger.logInfo(
      'Actualizando fecha de inicio de suscripción',
      className: _className,
      functionName: 'updateSubscriptionStartDate',
      params: {'startDate': startDate?.toString()},
    );
    state = state.copyWith(subscriptionStartDate: startDate);
  }
  
  // Métodos para manejar pasos del formulario
  void nextStep() {
    if (state.currentStep < 5) { // 6 pasos en total (0-5)
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
  
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
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
  
  // Método privado para subir imagen a Firebase Storage
  Future<String?> _uploadImageToStorage(File imageFile, String academyId, String filename) async {
    try {
      // Crear una referencia a la ubicación donde se guardará la imagen
      // Estructura: academies/{academyId}/users/images/{filename}
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('academies')
          .child(academyId)
          .child('users')
          .child('images')
          .child(filename);
      
      // Comenzar la subida de la imagen
      final uploadTask = storageRef.putFile(imageFile);
      
      // Esperar a que termine la subida y obtener la referencia
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Obtener la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppLogger.logInfo(
        'Imagen subida con éxito',
        className: _className,
        functionName: '_uploadImageToStorage',
        params: {'downloadUrl': downloadUrl},
      );
      return downloadUrl;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al subir imagen',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: '_uploadImageToStorage',
      );
      return null;
    }
  }
  
  // Método para enviar el formulario completo
  Future<void> submitForm(String academyId, String userId) async {
    if (!state.canSubmit) return;
    
    state = state.copyWith(isSubmitting: true, isError: false, errorMessage: null);
    
    try {
      String? profileImageUrl;
      // 1. Subir la imagen si existe
      if (state.profileImage != null) {
        // Generar un nombre de archivo único usando timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = 'profile_${userId}_$timestamp.jpg';
        
        // Subir la imagen y obtener la URL
        profileImageUrl = await _uploadImageToStorage(state.profileImage!, academyId, filename);
        
        if (profileImageUrl == null) {
          AppLogger.logWarning(
            'No se pudo subir la imagen del perfil',
            className: _className,
            functionName: 'submitForm',
            params: {'academyId': academyId, 'userId': userId, 'filename': filename},
          );
        }
      }
      
      // 2. Crear el documento del atleta/usuario en Firestore
      // CORREGIDO: Usar solo los campos que espera el modelo AcademyUserModel
      final userData = {
        'firstName': state.firstName,
        'lastName': state.lastName,
        'birthDate': state.birthDate != null ? Timestamp.fromDate(state.birthDate!) : null,
        'phoneNumber': state.phoneNumber,
        'heightCm': state.heightCm,
        'weightKg': state.weightKg,
        'profileImageUrl': profileImageUrl,
        'allergies': state.allergies,
        'medicalConditions': state.medicalConditions,
        'position': state.position,
        'role': 'atleta', // Establecer explícitamente el rol como atleta (en minúsculas)
        'createdBy': userId, // ID del usuario que crea este registro
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Información de contacto de emergencia en el formato correcto
      if (state.emergencyContactName?.isNotEmpty == true || 
          state.emergencyContactPhone?.isNotEmpty == true) {
        userData['emergencyContact'] = {
          'name': state.emergencyContactName ?? '',
          'phone': state.emergencyContactPhone ?? '',
        };
      } else {
        userData['emergencyContact'] = <String, dynamic>{};
      }
      
      // Metadatos adicionales para información que no está directamente en el modelo
      final metadata = <String, dynamic>{};
      
      // Agregar información deportiva a metadata si existe
      if (state.position != null || state.experience != null || state.specialization != null) {
        metadata['sportData'] = {
          if (state.position != null) 'position': state.position,
          if (state.experience != null) 'experience': state.experience,
          if (state.specialization != null) 'specialization': state.specialization,
        };
      }
      
      // Agregar métricas físicas a metadata si existen
      if (state.heightCm != null || state.weightKg != null) {
        metadata['metrics'] = {
          if (state.heightCm != null) 'height': state.heightCm,
          if (state.weightKg != null) 'weight': state.weightKg,
        };
      }
      
      // Agregar información médica a metadata si existe
      if (state.allergies?.isNotEmpty == true || state.medicalConditions?.isNotEmpty == true) {
        metadata['medicalInfo'] = {
          if (state.allergies?.isNotEmpty == true) 'allergies': state.allergies,
          if (state.medicalConditions?.isNotEmpty == true) 'conditions': state.medicalConditions,
        };
      }
      
      // Agregar información de contacto a metadata si existe
      if (state.emergencyContactName?.isNotEmpty == true || 
          state.emergencyContactPhone?.isNotEmpty == true) {
        metadata['contactInfo'] = {
          if (state.emergencyContactName?.isNotEmpty == true) 'emergencyName': state.emergencyContactName,
          if (state.emergencyContactPhone?.isNotEmpty == true) 'emergencyPhone': state.emergencyContactPhone,
        };
      }
      
      // Solo agregar metadata si tiene contenido
      if (metadata.isNotEmpty) {
        userData['metadata'] = metadata;
      } else {
        userData['metadata'] = <String, dynamic>{};
      }
      
      // Información de cliente para pagos/suscripciones
      if (state.subscriptionPlanId != null) {
        AppLogger.logInfo(
          'Asignando plan de suscripción al atleta',
          className: _className,
          functionName: 'submitForm',
          params: {
            'subscriptionPlanId': state.subscriptionPlanId,
            'startDate': state.subscriptionStartDate
          },
        );
        
        // Datos de cliente base (se actualizarán completos al asignar plan)
        metadata['clientData'] = {
          'subscriptionPlanId': state.subscriptionPlanId,
          'paymentStatus': 'active', // Marcamos como activo inicialmente
        };
        userData['metadata'] = metadata;
      }
      
      AppLogger.logInfo(
        'Guardando atleta con datos compatibles con AcademyUserModel',
        className: _className,
        functionName: 'submitForm',
        params: {
          'academyId': academyId, 
          'userId': userId,
          'userData': userData,
          'hasMetadata': metadata.isNotEmpty,
        },
      );
      
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('academies')
          .doc(academyId)
          .collection('users') // Subcolección 'users'
          .add(userData);

      // Si se ha especificado un plan, asignarlo ahora
      if (state.subscriptionPlanId != null) {
        try {
          final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
          final startDate = state.subscriptionStartDate ?? DateTime.now();
          
          final result = await subscriptionRepository.assignPlanToUser(
            academyId, 
            docRef.id, 
            state.subscriptionPlanId!, 
            startDate
          );
          
          result.fold(
            (failure) => AppLogger.logError(
              message: 'Error al asignar plan de suscripción',
              error: failure,
              className: _className,
              functionName: 'submitForm',
              params: {
                'academyId': academyId,
                'userId': docRef.id,
                'planId': state.subscriptionPlanId,
              },
            ),
            (_) => AppLogger.logInfo(
              'Plan de suscripción asignado correctamente',
              className: _className,
              functionName: 'submitForm',
              params: {
                'academyId': academyId,
                'userId': docRef.id,
                'planId': state.subscriptionPlanId,
              },
            ),
          );
        } catch (e, s) {
          // Capturar errores de asignación de plan pero no fallar el registro completo
          AppLogger.logError(
            message: 'Error durante asignación de plan',
            error: e,
            stackTrace: s,
            className: _className,
            functionName: 'submitForm',
            params: {
              'academyId': academyId,
              'userId': docRef.id,
              'planId': state.subscriptionPlanId,
            },
          );
        }
      }

      AppLogger.logInfo(
        'Usuario/Atleta guardado en Firestore',
        className: _className,
        functionName: 'submitForm',
        params: {'docId': docRef.id, 'academyId': academyId},
      );
      
      // Éxito
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      );
    } catch (e, s) {
      state = state.copyWith(
        isSubmitting: false,
        isError: true,
        errorMessage: 'Error al guardar atleta. Consulta los logs para más detalles.',
      );
      AppLogger.logError(
        message: 'Error al guardar atleta',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'submitForm',
        params: {'academyId': academyId, 'userId': userId},
      );
    }
  }
  
  // Método para resetear el formulario
  void resetForm() {
    AppLogger.logInfo(
      'Reseteando estado del formulario de atleta',
      className: _className,
      functionName: 'resetForm'
    );
    
    // Primero resetear el estado
    state = const AddAthleteState();
    
    // Luego, intentar crear nuevos controladores
    // Usamos Future.microtask para asegurarnos de que esto ocurra después
    // del actual ciclo de widget building
    Future.microtask(() {
      try {
        // Notificar al provider de controladores para que se reinicien
        // Solo si el provider sigue disponible
        if (!ref.exists(addAthleteControllersProvider)) {
          AppLogger.logWarning(
            'El provider de controladores ya no existe, no se pueden resetear',
            className: _className,
            functionName: 'resetForm'
          );
          return;
        }
        
        ref.read(addAthleteControllersProvider.notifier).resetControllers();
        
        AppLogger.logInfo(
          'Controladores reseteados correctamente',
          className: _className,
          functionName: 'resetForm'
        );
      } catch (e) {
        AppLogger.logError(
          message: 'Error al resetear controladores',
          error: e,
          className: _className,
          functionName: 'resetForm'
        );
      }
    });
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
  void cargarDatosDePrueba() async {
    final now = DateTime.now();
    
    // Generar datos dinámicos y variados
    final nombres = ['Carlos', 'María', 'Andrés', 'Sofía', 'Julián', 'Isabella', 'Diego', 'Valentina'];
    final apellidos = ['Rodríguez', 'García', 'López', 'Martínez', 'González', 'Pérez', 'Sánchez', 'Ramírez'];
    final nivelesExperiencia = ['Principiante (0-1 años)', 'Intermedio (2-3 años)', 'Avanzado (4-5 años)', 'Experto (6+ años)'];
    
    // Seleccionar datos aleatorios
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final nombreIndex = random % nombres.length;
    final apellidoIndex = (random + 3) % apellidos.length;
    final experienciaIndex = random % nivelesExperiencia.length;
    
    // Generar edad entre 12 y 18 años
    final edadAnios = 12 + (random % 7);
    final fechaNacimiento = DateTime(now.year - edadAnios, now.month, now.day);
    
    // Generar datos físicos realistas según la edad
    final alturaBase = 140 + (edadAnios - 12) * 8; // Entre 140cm (12 años) y 188cm (18 años)
    final alturaVariacion = (random % 20) - 10; // +/- 10cm de variación
    final altura = (alturaBase + alturaVariacion).toDouble();
    
    final pesoBase = 35 + (edadAnios - 12) * 6; // Entre 35kg (12 años) y 71kg (18 años)
    final pesoVariacion = (random % 10) - 5; // +/- 5kg de variación
    final peso = (pesoBase + pesoVariacion).toDouble();
    
    // Generar datos de contacto dinámicos
    final telefonos = ['655', '601', '634', '625', '648', '657'];
    final telefonoBase = telefonos[random % telefonos.length];
    final numeroAleatorio = 100000 + (random * 7) % 900000;
    
    // Generar información médica variada
    final alergias = [
      'Ninguna conocida',
      'Polen y ácaros del polvo',
      'Frutos secos',
      'Lactosa',
      'Medicamentos (penicilina)',
      'Picaduras de insectos'
    ];
    final condicionesMedicas = [
      'Ninguna',
      'Asma leve',
      'Miopía',
      'Antecedentes de esguinces de tobillo',
      'Intolerancia alimentaria leve',
      'Historial de lesiones deportivas menores'
    ];
    
    final alergiaIndex = random % alergias.length;
    final condicionIndex = random % condicionesMedicas.length;
    
    // Información deportiva básica
    final experienciaSeleccionada = nivelesExperiencia[experienciaIndex];
    
    // Posición dinámica (se intentará obtener del provider)
    String? posicionSeleccionada;
    
    // Especialización dinámica (se intentará obtener del provider)
    String? especializacionSeleccionada;
    
    try {
      // Obtener la academia actual
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = currentAcademy?.id;
      
      if (academyId != null && academyId.isNotEmpty) {
        // Obtener las posiciones dinámicas de la academia
        final positionsAsync = await ref.read(sportPositionsProvider(academyId).future);
        
        if (positionsAsync.isNotEmpty) {
          // Seleccionar posición aleatoria de las disponibles
          final posicionIndex = random % positionsAsync.length;
          posicionSeleccionada = positionsAsync[posicionIndex];
          
          AppLogger.logInfo(
            'Posición dinámica seleccionada',
            className: _className,
            functionName: 'cargarDatosDePrueba',
            params: {
              'academyId': academyId,
              'position': posicionSeleccionada,
              'available': positionsAsync,
            },
          );
        }
        
        // Obtener las características deportivas de la academia para especializaciones
        final characteristicsAsync = await ref.read(academySportCharacteristicsProvider(academyId).future);
        
        if (characteristicsAsync != null && characteristicsAsync.athleteSpecializations.isNotEmpty) {
          // Seleccionar especialización aleatoria de las disponibles
          final especializacionIndex = random % characteristicsAsync.athleteSpecializations.length;
          especializacionSeleccionada = characteristicsAsync.athleteSpecializations[especializacionIndex];
          
          AppLogger.logInfo(
            'Especialización dinámica seleccionada',
            className: _className,
            functionName: 'cargarDatosDePrueba',
            params: {
              'academyId': academyId,
              'especialization': especializacionSeleccionada,
              'available': characteristicsAsync.athleteSpecializations,
            },
          );
        }
      }
    } catch (e) {
      AppLogger.logWarning(
        'No se pudieron obtener datos deportivos dinámicos, usando fallback',
        className: _className,
        functionName: 'cargarDatosDePrueba',
        params: {'error': e.toString()},
      );
    }
    
    // Fallback para posición si no se pudo obtener dinámica
    if (posicionSeleccionada == null) {
      final posicionesFallback = ['Portero', 'Defensa central', 'Lateral derecho', 'Lateral izquierdo', 'Mediocentro defensivo', 'Mediocentro', 'Extremo derecho', 'Extremo izquierdo', 'Delantero'];
      final posicionIndex = random % posicionesFallback.length;
      posicionSeleccionada = posicionesFallback[posicionIndex];
      
      AppLogger.logInfo(
        'Usando posición fallback',
        className: _className,
        functionName: 'cargarDatosDePrueba',
        params: {'position': posicionSeleccionada},
      );
    }
    
    // Fallback para especialización si no se pudo obtener dinámica
    if (especializacionSeleccionada == null) {
      final especializacionesFallback = ['Velocidad', 'Técnica', 'Fuerza', 'Resistencia', 'Liderazgo', 'Precisión', 'Agilidad', 'Táctica'];
      final especializacionIndex = random % especializacionesFallback.length;
      especializacionSeleccionada = especializacionesFallback[especializacionIndex];
      
      AppLogger.logInfo(
        'Usando especialización fallback',
        className: _className,
        functionName: 'cargarDatosDePrueba',
        params: {'especialization': especializacionSeleccionada},
      );
    }
    
    // Actualizar estado con datos de prueba dinámicos
    state = state.copyWith(
      // Información personal
      firstName: nombres[nombreIndex],
      lastName: apellidos[apellidoIndex],
      birthDate: fechaNacimiento,
      phoneNumber: '$telefonoBase$numeroAleatorio',
      
      // Información física
      heightCm: altura,
      weightKg: peso,
      
      // Información de salud
      allergies: alergias[alergiaIndex],
      medicalConditions: condicionesMedicas[condicionIndex],
      emergencyContactName: '${nombres[(nombreIndex + 1) % nombres.length]} ${apellidos[apellidoIndex]} (Madre)',
      emergencyContactPhone: '${telefonos[(random + 1) % telefonos.length]}${100000 + (random * 11) % 900000}',
      
      // Información deportiva completa con datos dinámicos
      position: posicionSeleccionada,
      experience: experienciaSeleccionada,
      specialization: especializacionSeleccionada,
      
      // Fecha de inicio de suscripción (si aplica)
      subscriptionStartDate: now,
    );
    
    AppLogger.logInfo(
      'Datos de prueba cargados dinámicamente',
      className: _className,
      functionName: 'cargarDatosDePrueba',
      params: {
        'atleta': '${nombres[nombreIndex]} ${apellidos[apellidoIndex]}',
        'edad': '$edadAnios años',
        'posicion': posicionSeleccionada,
        'especializacion': especializacionSeleccionada,
        'experiencia': experienciaSeleccionada,
      },
    );
    
    // El resto de la lógica para actualizar controladores es manejada por el widget
  }
}

// Provider para el notifier manual
final addAthleteProvider = StateNotifierProvider<AddAthleteStateNotifier, AddAthleteState>((ref) {
  return AddAthleteStateNotifier(ref);
});

// Provider generado por riverpod (mantener para compatibilidad)
@riverpod
class AddAthleteNotifier extends _$AddAthleteNotifier {
  @override
  AddAthleteState build() {
    return const AddAthleteState();
  }
  
  // Dejar los métodos vacíos porque usaremos el StateNotifier manual
}

// Definición manual del provider de controladores
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
      'experience': TextEditingController(),
    };
    
    ref.onDispose(() {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
    
    return controllers;
  }
  
  // Método para setear el texto de fecha
  void setDateText(DateTime date) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    state['birthDate']?.text = formattedDate;
  }
  
  // Método para resetear controladores de manera segura
  void resetControllers() {
    AppLogger.logInfo(
      'Reseteo seguro de controladores',
      className: 'AddAthleteControllers',
      functionName: 'resetControllers'
    );
    
    // Necesitamos crear nuevos controladores en lugar de modificar los existentes
    // ya que podrían haber sido eliminados
    final newControllers = <String, TextEditingController>{};
    
    for (final key in state.keys) {
      try {
        // Solo crear un nuevo controlador si el antiguo existe
        if (state[key] != null) {
          newControllers[key] = TextEditingController();
        }
      } catch (e) {
        AppLogger.logError(
          message: 'Error al resetear controlador $key',
          error: e,
          className: 'AddAthleteControllers',
          functionName: 'resetControllers'
        );
      }
    }
    
    // Actualizar el estado con los nuevos controladores
    state = newControllers;
  }
} 