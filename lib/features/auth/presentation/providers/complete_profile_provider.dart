import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación
import 'package:arcinus/features/auth/presentation/state/complete_profile_state.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart'; // Para obtener el usuario actual
import 'package:arcinus/core/providers/firebase_providers.dart'; // Para acceder a Firestore
import 'package:cloud_firestore/cloud_firestore.dart'; // Para SetOptions
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart'; // Para invalidar el provider
// TODO: Importar el repositorio cuando esté definido
// import 'package:arcinus/features/auth/data/repositories/user_repository.dart';

// Provider
final completeProfileProvider = StateNotifierProvider.autoDispose<
    CompleteProfileNotifier, CompleteProfileState>((ref) {
  // Obtener las dependencias necesarias
  final firestore = ref.watch(firestoreProvider);
  final currentAuthUser = ref.watch(currentUserProvider);
  
  developer.log('Creando CompleteProfileNotifier con userId: ${currentAuthUser?.id}'); // Log temporal
  return CompleteProfileNotifier(ref, firestore);
});

// Notifier
class CompleteProfileNotifier extends StateNotifier<CompleteProfileState> {
  CompleteProfileNotifier(this.ref, this.firestore)
      : super(const CompleteProfileState.initial());

  final Ref ref;
  final firestore;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> submitProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      state = const CompleteProfileState.loading();
      developer.log('Estado: Cargando'); // Log temporal
      try {
        // Obtener el usuario actual
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null || currentUser.id.isEmpty) {
          developer.log('Error: No hay usuario autenticado');
          state = CompleteProfileState.error(const Failure.authError(
            code: 'no-user',
            message: 'No hay usuario autenticado',
          ));
          return;
        }

        // Guardar en Firestore
        final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}';
        await firestore.collection('users').doc(currentUser.id).set({
          'id': currentUser.id,
          'email': currentUser.email,
          'name': fullName,
          'createdAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        developer.log('Perfil guardado en Firestore para usuario: ${currentUser.id}');
        
        // Actualizar estado a éxito
        state = const CompleteProfileState.success();
        developer.log('Estado: Éxito (guardado real en Firestore)');
        
        // Importante: Forzar actualización del userProfileProvider
        ref.invalidate(userProfileProvider(currentUser.id));
        developer.log('userProfileProvider invalidado para forzar actualización');
        
        // Esperar un momento para que se propague la actualización
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        developer.log('Estado: Error (excepción) - $e'); // Log temporal
        // Considerar un tipo de Failure genérico para excepciones inesperadas
        state = CompleteProfileState.error(Failure.serverError(message: e.toString()));
      }
    } else {
      developer.log('Formulario inválido');
    }
  }

  @override
  void dispose() {
    developer.log('Disposing CompleteProfileNotifier controllers'); // Log temporal
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
} 