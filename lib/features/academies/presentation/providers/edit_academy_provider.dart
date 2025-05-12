import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/academies/presentation/providers/state/edit_academy_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Provider para el Notifier de edición de academia.
///
/// Se necesita pasar el [AcademyModel] inicial como argumento familiar.
final editAcademyProvider = StateNotifierProvider.autoDispose
    .family<EditAcademyNotifier, EditAcademyState, AcademyModel>(
        (ref, initialAcademy) {
  final academyRepository = ref.watch(academyRepositoryProvider);
  final firebaseStorage = FirebaseStorage.instance;
  return EditAcademyNotifier(academyRepository, initialAcademy, firebaseStorage);
});

/// Notifier para manejar el estado de edición de una academia
class EditAcademyNotifier extends StateNotifier<EditAcademyState> {
  final AcademyRepository _academyRepository;
  final AcademyModel _initialAcademy;
  final FirebaseStorage _storage;

  /// Controladores para los campos de texto del formulario
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  EditAcademyNotifier(this._academyRepository, this._initialAcademy, this._storage) 
      : super(const EditAcademyState.initial()) {
    // Inicializar controladores con los valores actuales
    nameController.text = _initialAcademy.name;
    descriptionController.text = _initialAcademy.description;
    phoneController.text = _initialAcademy.phone;
    emailController.text = _initialAcademy.email;
    addressController.text = _initialAcademy.address;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Guarda los cambios en la academia
  Future<void> saveChanges() async {
    if (formKey.currentState?.validate() != true) {
      // No continuar si el formulario no es válido
      return;
    }

    state = const EditAcademyState.loading();

    // Creamos un nuevo modelo de academia con los datos actualizados
    final updatedAcademy = _initialAcademy.copyWith(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
    );

    // Guardamos los cambios
    final result = await _academyRepository.updateAcademy(updatedAcademy);

    result.fold(
      (failure) {
        state = EditAcademyState.error(failure);
      },
      (_) {
        state = const EditAcademyState.success();
      },
    );
  }
  
  /// Guarda los cambios incluyendo la actualización del logo
  Future<void> saveChangesWithLogo(File logoFile) async {
    if (formKey.currentState?.validate() != true) {
      // No continuar si el formulario no es válido
      return;
    }

    state = const EditAcademyState.loading();
    
    try {
      // 1. Primero subimos la imagen al storage
      final String fileExtension = logoFile.path.split('.').last;
      final String fileName = '${const Uuid().v4()}.$fileExtension';
      final String storagePath = 'academies/logos/$fileName';
      
      final storageRef = _storage.ref().child(storagePath);
      await storageRef.putFile(logoFile);
      final String logoUrl = await storageRef.getDownloadURL();
      
      // 2. Creamos un nuevo modelo con la URL del logo y los demás datos
      final updatedAcademy = _initialAcademy.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        logoUrl: logoUrl,
      );
      
      // 3. Guardamos los cambios
      final result = await _academyRepository.updateAcademy(updatedAcademy);
      
      result.fold(
        (failure) {
          state = EditAcademyState.error(failure);
        },
        (_) {
          state = const EditAcademyState.success();
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error al subir el logo',
        error: e,
      );
      state = EditAcademyState.error(
        Failure.unexpectedError(error: 'Error al subir el logo: $e')
      );
    }
  }
} 