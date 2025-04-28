import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/academies/presentation/providers/state/edit_academy_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el Notifier de edición de academia.
///
/// Se necesita pasar el [AcademyModel] inicial como argumento familiar.
final editAcademyProvider = StateNotifierProvider.autoDispose
    .family<EditAcademyNotifier, EditAcademyState, AcademyModel>(
        (ref, initialAcademy) {
  final academyRepository = ref.watch(academyRepositoryProvider);
  return EditAcademyNotifier(academyRepository, initialAcademy);
});

class EditAcademyNotifier extends StateNotifier<EditAcademyState> {
  final AcademyRepository _academyRepository;
  final AcademyModel _initialAcademy;

  // Controllers para los campos editables
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  // logoUrl se manejaría diferente (upload)
  // sportCode no debería ser editable aquí

  final formKey = GlobalKey<FormState>();

  EditAcademyNotifier(this._academyRepository, this._initialAcademy)
      : super(const EditAcademyState.initial()) {
    // Inicializar controllers con datos existentes
    nameController = TextEditingController(text: _initialAcademy.name);
    descriptionController = TextEditingController(text: _initialAcademy.description);
    phoneController = TextEditingController(text: _initialAcademy.phone);
    emailController = TextEditingController(text: _initialAcademy.email);
    addressController = TextEditingController(text: _initialAcademy.address);
  }

  Future<void> saveChanges() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return; // No guardar si el formulario no es válido
    }

    state = const EditAcademyState.loading();

    final updatedAcademy = _initialAcademy.copyWith(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      // updatedAt se manejará en el repositorio
    );

    try {
      final result = await _academyRepository.updateAcademy(updatedAcademy);

      result.fold(
        (failure) {
          state = EditAcademyState.error(failure);
          _clearErrorAfterDelay();
        },
        (_) {
          state = const EditAcademyState.success();
          // Opcional: podrías invalidar el provider de la academia para refrescar datos
          // ref.invalidate(academyProvider(_initialAcademy.id!));
        },
      );
    } catch (e, stackTrace) {
      state = EditAcademyState.error(Failure.unexpectedError(error: e, stackTrace: stackTrace));
      _clearErrorAfterDelay();
    }
  }

  /// Limpia el estado de error después de un tiempo.
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
        state = const EditAcademyState.initial();
      }
    });
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
} 