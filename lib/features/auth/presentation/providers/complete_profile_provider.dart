import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación
import 'package:arcinus/features/auth/presentation/state/complete_profile_state.dart';
// TODO: Importar el repositorio cuando esté definido
// import 'package:arcinus/features/auth/data/repositories/user_repository.dart';

// Provider
final completeProfileProvider = StateNotifierProvider.autoDispose<
    CompleteProfileNotifier, CompleteProfileState>((ref) {
  // TODO: Obtener dependencias (repositorio) via ref.watch/read
  // final userRepository = ref.watch(userRepositoryProvider); // Ejemplo
  print('Creando CompleteProfileNotifier'); // Log temporal
  return CompleteProfileNotifier(/* userRepository */);
});

// Notifier
class CompleteProfileNotifier extends StateNotifier<CompleteProfileState> {
  // TODO: Inyectar el repositorio real
  CompleteProfileNotifier(/* this._userRepository */)
      : super(const CompleteProfileState.initial());

  // final UserRepository _userRepository;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> submitProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      state = const CompleteProfileState.loading();
      print('Estado: Cargando'); // Log temporal
      try {
        // Simulación de llamada al repositorio
        await Future.delayed(const Duration(seconds: 2));
        print('Simulación de guardado exitoso');

        // TODO: Reemplazar simulación con llamada real al repositorio
        // final result = await _userRepository.updateProfile(
        //   userId: 'some_user_id', // TODO: Obtener ID del usuario autenticado
        //   name: nameController.text.trim(),
        //   lastName: lastNameController.text.trim(),
        // );

        // result.fold(
        //   (failure) {
        //      print('Estado: Error - $failure'); // Log temporal
        //      state = CompleteProfileState.error(failure);
        //    },
        //   (_) {
        //      print('Estado: Éxito'); // Log temporal
        //      state = const CompleteProfileState.success();
        //      // La navegación debería ocurrir via redirect en GoRouter al detectar el cambio
        //      // o un listener en la UI si es necesario.
        //    },
        // );

        // Resultado simulado de éxito
        state = const CompleteProfileState.success();
         print('Estado: Éxito (simulado)');

      } catch (e) {
         print('Estado: Error (excepción) - $e'); // Log temporal
        // Considerar un tipo de Failure genérico para excepciones inesperadas
        state = CompleteProfileState.error(Failure.serverError(message: e.toString()));
      }
    } else {
       print('Formulario inválido');
    }
  }

  @override
  void dispose() {
    print('Disposing CompleteProfileNotifier controllers'); // Log temporal
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
} 