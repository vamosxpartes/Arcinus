import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación
import 'package:arcinus/features/auth/presentation/state/complete_profile_state.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart'; // Para obtener el usuario actual
import 'package:arcinus/features/auth/data/models/user_model.dart'; // Importar UserModel
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart'; // Para invalidar el provider
import 'package:arcinus/features/users/domain/repositories/user_repository.dart'; // <--- Importar interfaz
import 'package:arcinus/features/users/data/repositories/user_repository_impl.dart'; // <--- Importar provider del repo
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:arcinus/features/users/data/models/manager_user_model.dart';
import 'package:arcinus/core/auth/roles.dart';

// Función auxiliar para obtener el GoRouter a través de Riverpod
import 'package:arcinus/core/navigation/app_router.dart' show routerProvider;

// Estado extendido para el formulario de perfil
final completeProfileStateProvider = StateProvider<CompleteProfileExtendedState>((ref) {
  return CompleteProfileExtendedState();
});

// Clase para mantener el estado extendido (incluyendo la imagen)
class CompleteProfileExtendedState {
  final File? profileImage;
  
  CompleteProfileExtendedState({this.profileImage});
  
  CompleteProfileExtendedState copyWith({File? profileImage}) {
    return CompleteProfileExtendedState(
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

// Provider
final completeProfileProvider = StateNotifierProvider.autoDispose<
    CompleteProfileNotifier, CompleteProfileState>((ref) {
  // Obtener las dependencias necesarias
  final userRepository = ref.watch(userRepositoryProvider); // <--- Usar provider del repositorio
  final currentAuthUser = ref.watch(currentUserProvider);
  
  AppLogger.logInfo('Creando CompleteProfileNotifier con userId: ${currentAuthUser?.id}');
  return CompleteProfileNotifier(ref, userRepository);
});

// Notifier
class CompleteProfileNotifier extends StateNotifier<CompleteProfileState> {
  CompleteProfileNotifier(this.ref, this.userRepository)
      : super(const CompleteProfileState.initial());

  final Ref ref;
  final UserRepository userRepository; // <--- Repositorio de usuarios
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  // Método para seleccionar imagen del perfil
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Verificar que el archivo existe
        final File imageFile = File(pickedFile.path);
        final fileExists = await imageFile.exists();
        final fileSize = await imageFile.length();
        
        if (!fileExists || fileSize <= 0) {
          AppLogger.logWarning(
            'La imagen seleccionada está vacía o no existe',
            className: 'CompleteProfileNotifier',
            functionName: 'pickImage'
          );
          return;
        }
        
        try {
          // Guardar en ubicación más persistente
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final targetPath = path.join(appDir.path, fileName);
          
          // Copiar a una ubicación segura
          final File savedImage = await imageFile.copy(targetPath);
          
          // Verificar copia exitosa
          if (await savedImage.exists() && await savedImage.length() > 0) {
            // Actualizar estado con la imagen
            ref.read(completeProfileStateProvider.notifier).state = 
                ref.read(completeProfileStateProvider).copyWith(profileImage: savedImage);
                
            AppLogger.logInfo(
              'Imagen de perfil seleccionada',
              className: 'CompleteProfileNotifier',
              functionName: 'pickImage'
            );
          }
        } catch (e) {
          AppLogger.logError(
            message: 'Error al procesar la imagen',
            error: e,
            className: 'CompleteProfileNotifier',
            functionName: 'pickImage'
          );
        }
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al seleccionar imagen',
        error: e,
        className: 'CompleteProfileNotifier',
        functionName: 'pickImage'
      );
    }
  }
  
  // Método para subir la imagen a Firebase Storage
  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppLogger.logInfo(
        'Imagen de perfil subida con éxito',
        className: 'CompleteProfileNotifier',
        functionName: '_uploadProfileImage',
        params: {'downloadUrl': downloadUrl}
      );
      
      return downloadUrl;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al subir imagen de perfil',
        error: e,
        stackTrace: s,
        className: 'CompleteProfileNotifier',
        functionName: '_uploadProfileImage'
      );
      return null;
    }
  }

  Future<void> submitProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      state = const CompleteProfileState.loading();
      AppLogger.logInfo('Estado: Cargando');
      try {
        // Obtener el usuario actual
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null || currentUser.id.isEmpty) {
          AppLogger.logError(
            message: 'Error: No hay usuario autenticado'
          );
          state = CompleteProfileState.error(const Failure.authError(
            code: 'no-user',
            message: 'No hay usuario autenticado',
          ));
          return;
        }
        
        // 1. Subir imagen de perfil si existe
        String? photoUrl;
        final profileImage = ref.read(completeProfileStateProvider).profileImage;
        if (profileImage != null) {
          photoUrl = await _uploadProfileImage(profileImage, currentUser.id);
        }

        // 2. Crear el modelo de usuario con los datos actualizados
        final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}';
        final now = DateTime.now();
        final userToUpdate = UserModel(
          id: currentUser.id,
          email: currentUser.email,
          displayName: fullName,
          photoUrl: photoUrl,
          profileCompleted: true,
          appRole: currentUser.role,
          createdAt: now,
          updatedAt: now,
        );

        // 3. Llamar al repositorio para guardar/actualizar el usuario
        final result = await userRepository.upsertUser(userToUpdate);

        result.fold(
          (failure) {
            AppLogger.logError(
              message: 'Error guardando perfil: $failure',
              error: failure
            );
            state = CompleteProfileState.error(failure);
          },
          (_) async {
            AppLogger.logInfo('Perfil guardado via repositorio para usuario: ${currentUser.id}');
            
            // 4. Si el usuario es propietario, crear entrada en ManagerUserModel
            if (currentUser.role == AppRole.propietario) {
              try {
                await userRepository.createOrUpdateManagerUser(
                  currentUser.id,
                  '', // academyId se asignará al crear la academia
                  AppRole.propietario,
                  permissions: [ManagerPermission.fullAccess]
                );
                AppLogger.logInfo('ManagerUserModel creado para propietario: ${currentUser.id}');
              } catch (e) {
                AppLogger.logWarning(
                  'No se pudo crear ManagerUserModel, pero continuamos con el flujo',
                  error: e,
                  className: 'CompleteProfileNotifier',
                  functionName: 'submitProfile'
                );
              }
            }
            
            // 5. Actualizar estado a éxito
            state = const CompleteProfileState.success();
            AppLogger.logInfo('Estado: Éxito (guardado via repositorio)');

            // 6. Forzar actualización del userProfileProvider
            ref.invalidate(userProfileProvider(currentUser.id));
            AppLogger.logInfo('userProfileProvider invalidado para forzar actualización');

            // 7. Esperar para propagar actualizaciones
            await Future.delayed(const Duration(milliseconds: 500));
            
            // 8. Redirigir manualmente
            AppLogger.logInfo('Redirigiendo manualmente a la pantalla de creación de academia');
            try {
              final router = ref.read(routerProvider);
              router.go(AppRoutes.createAcademy);
            } catch (e) {
              AppLogger.logWarning(
                'No se pudo redirigir manualmente, dependiendo de GoRouter',
                error: e
              );
            }
          },
        );
      } catch (e, s) {
        AppLogger.logError(
          message: 'Estado: Error (excepción inesperada)',
          error: e,
          stackTrace: s
        );
        state = CompleteProfileState.error(Failure.unexpectedError(error: e, stackTrace: s));
      }
    } else {
      AppLogger.logWarning('Formulario inválido');
    }
  }

  @override
  void dispose() {
    AppLogger.logInfo('Disposing CompleteProfileNotifier controllers');
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
} 