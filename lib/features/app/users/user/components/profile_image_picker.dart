import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/users/user/core/services/user_image_service.dart';
import 'package:arcinus/features/app/users/user/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Un widget que permite seleccionar una imagen de perfil
/// ya sea desde la galería o tomando una foto con la cámara
class ProfileImagePicker extends ConsumerStatefulWidget {
  /// URL de la imagen actual (si existe)
  final String? currentImageUrl;
  
  /// Callback cuando se selecciona una nueva imagen
  /// Ahora devuelve la ruta local de la imagen seleccionada, no la URL de Firebase Storage
  final Function(String) onImageSelected;
  
  /// ID del usuario asociado a la imagen (opcional)
  final String? userId;
  
  /// Tamaño del widget de selección de imagen
  final double size;
  
  /// Color del icono y borde cuando no hay imagen
  final Color? iconColor;
  
  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.userId,
    this.size = 120.0,
    this.iconColor,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  bool _isLoading = false;
  File? _localImageFile;
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _loadImageFromUrl();
  }
  
  @override
  void didUpdateWidget(ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentImageUrl != oldWidget.currentImageUrl) {
      _loadImageFromUrl();
    }
  }
  
  Future<void> _loadImageFromUrl() async {
    if (widget.currentImageUrl == null || widget.currentImageUrl!.isEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userImageService = ref.read(userImageServiceProvider);
      final File? imageFile = await userImageService.getProfileImage(widget.currentImageUrl!);
      
      if (mounted) {
        setState(() {
          _localImageFile = imageFile;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log(
        'Error al cargar imagen de perfil: $e',
        name: 'ProfileImagePicker',
        error: e,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Solo almacenar la imagen localmente, no subir a Firebase
        setState(() {
          _localImageFile = File(pickedFile.path);
        });
        
        // Devolver la ruta local de la imagen
        widget.onImageSelected(pickedFile.path);
      }
    } catch (e) {
      developer.log(
        'Error al seleccionar imagen de galería: $e',
        name: 'ProfileImagePicker',
        error: e,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }
  
  void _takePictureWithCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          userId: widget.userId,
          onImageCaptured: (String localPath) {
            // Actualizar la UI con la imagen capturada
            setState(() {
              _localImageFile = File(localPath);
            });
            
            // Pasar la ruta local de la imagen, no la URL
            widget.onImageSelected(localPath);
          },
        ),
      ),
    );
  }
  
  void _showImageSourceOptions() {
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
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _takePictureWithCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourceOptions,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Contenedor principal de la imagen/placeholder
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveIconColor.withAlpha(50),
                width: 2,
              ),
              color: effectiveIconColor.withAlpha(30),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ClipOval(
                    child: _localImageFile != null
                        ? Image.file(
                            _localImageFile!,
                            fit: BoxFit.cover,
                            width: widget.size,
                            height: widget.size,
                          )
                        : widget.currentImageUrl != null
                            ? Image.network(
                                widget.currentImageUrl!,
                                fit: BoxFit.cover,
                                width: widget.size,
                                height: widget.size,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  developer.log(
                                    'Error al cargar imagen de red: $error',
                                    name: 'ProfileImagePicker',
                                    error: error,
                                  );
                                  return Icon(
                                    Icons.person,
                                    size: widget.size * 0.5,
                                    color: effectiveIconColor,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: widget.size * 0.5,
                                color: effectiveIconColor,
                              ),
                  ),
          ),
          
          // Botón de edición
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: effectiveIconColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt,
              size: widget.size * 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 