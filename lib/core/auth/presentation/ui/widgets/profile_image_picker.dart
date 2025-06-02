import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Provider para gestionar el estado de la imagen de perfil
final profileImageProvider = StateNotifierProvider<ProfileImageNotifier, ProfileImageState>((ref) {
  return ProfileImageNotifier();
});

/// Estado para la imagen de perfil
class ProfileImageState {
  /// Archivo de la imagen seleccionada
  final File? image;
  
  /// Indica si se está cargando la imagen
  final bool isLoading;

  /// Constructor
  ProfileImageState({
    this.image,
    this.isLoading = false,
  });

  /// Crea un estado con carga en progreso
  ProfileImageState copyWithLoading() {
    return ProfileImageState(
      image: image,
      isLoading: true,
    );
  }

  /// Crea un estado con una nueva imagen
  ProfileImageState copyWithImage(File? newImage) {
    return ProfileImageState(
      image: newImage,
      isLoading: false,
    );
  }
}

/// Notificador para gestionar el estado de la imagen de perfil
class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  /// Constructor
  ProfileImageNotifier() : super(ProfileImageState());

  /// Selecciona una imagen de la galería
  Future<void> pickImageFromGallery() async {
    state = state.copyWithLoading();
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        state = state.copyWithImage(File(pickedFile.path));
      } else {
        state = state.copyWithImage(state.image); // Mantener imagen actual
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al seleccionar imagen de galería',
        error: e,
      );
      state = state.copyWithImage(state.image); // Mantener imagen actual en caso de error
    }
  }

  /// Toma una foto con la cámara
  Future<void> takePhoto() async {
    state = state.copyWithLoading();
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        state = state.copyWithImage(File(pickedFile.path));
      } else {
        state = state.copyWithImage(state.image); // Mantener imagen actual
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al tomar foto con cámara',
        error: e,
      );
      state = state.copyWithImage(state.image); // Mantener imagen actual en caso de error
    }
  }

  /// Elimina la imagen seleccionada
  void removeImage() {
    state = state.copyWithImage(null);
  }
}

/// Widget para seleccionar y gestionar la imagen de perfil
class ProfileImagePicker extends ConsumerWidget {
  /// Constructor
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileImageProvider);
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageOptions(context, ref),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              image: profileState.image != null
                ? DecorationImage(
                    image: FileImage(profileState.image!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: profileState.isLoading
                ? const CircularProgressIndicator()
                : profileState.image == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                    : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showImageOptions(context, ref),
          icon: const Icon(Icons.photo_camera),
          label: const Text('Cambiar foto'),
        ),
      ],
    );
  }

  /// Muestra las opciones para seleccionar imagen
  void _showImageOptions(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileImageProvider.notifier);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.of(context).pop();
                notifier.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.of(context).pop();
                notifier.takePhoto();
              },
            ),
            if (ref.read(profileImageProvider).image != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  notifier.removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }
} 