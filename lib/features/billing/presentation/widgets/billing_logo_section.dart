import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Widget para la sección del logo en la configuración de facturación
class BillingLogoSection extends StatefulWidget {
  /// ID de la academia
  final String academyId;
  
  /// Archivo de logo actual
  final File? logoFile;
  
  /// URL del logo actual
  final String? logoUrl;
  
  /// Si hay un logo inválido
  final bool hasInvalidLogo;
  
  /// Si está cargando
  final bool isLoading;
  
  /// Callback cuando se actualiza el logo
  final Function(File? logoFile, String? logoUrl, bool hasInvalidLogo) onLogoUpdated;
  
  /// Callback cuando cambia el estado de carga
  final Function(bool isLoading) onLoadingChanged;

  /// Constructor
  const BillingLogoSection({
    required this.academyId,
    required this.logoFile,
    required this.logoUrl,
    required this.hasInvalidLogo,
    required this.isLoading,
    required this.onLogoUpdated,
    required this.onLoadingChanged,
    super.key,
  });

  @override
  State<BillingLogoSection> createState() => _BillingLogoSectionState();
}

class _BillingLogoSectionState extends State<BillingLogoSection> {
  
  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onLoadingChanged(true);

        final File imageFile = File(image.path);
        
        try {
          // Generar nombre único para el archivo
          final String fileExtension = image.path.split('.').last;
          final String fileName = '${const Uuid().v4()}.$fileExtension';
          final String storagePath = 'academies/${widget.academyId}/billing/logos/$fileName';
          
          // Subir imagen a Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          await storageRef.putFile(imageFile);
          
          // Obtener URL de descarga
          final String downloadUrl = await storageRef.getDownloadURL();
          
          widget.onLogoUpdated(imageFile, downloadUrl, false);

          AppLogger.logInfo(
            'Logo subido exitosamente para facturación',
            className: '_BillingLogoSectionState',
            functionName: '_pickLogo',
            params: {
              'academyId': widget.academyId, 
              'logoUrl': downloadUrl,
              'logoFileExists': imageFile.existsSync().toString(),
              'logoFilePath': imageFile.path,
            },
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logo subido correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (storageError) {
          widget.onLoadingChanged(false);
          
          AppLogger.logError(
            message: 'Error al subir logo a Firebase Storage',
            error: storageError,
            className: '_BillingLogoSectionState',
            functionName: '_pickLogo',
            params: {'academyId': widget.academyId},
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir logo: ${storageError.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          widget.onLoadingChanged(false);
        }
      }
    } catch (e) {
      widget.onLoadingChanged(false);
      
      AppLogger.logError(
        message: 'Error al seleccionar logo',
        error: e,
        className: '_BillingLogoSectionState',
        functionName: '_pickLogo',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar la imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLogo() async {
    // Si hay una URL, intentar eliminar de Firebase Storage
    if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty && !widget.logoUrl!.contains('example.com')) {
      try {
        await FirebaseStorage.instance.refFromURL(widget.logoUrl!).delete();
        AppLogger.logInfo(
          'Logo eliminado de Firebase Storage',
          className: '_BillingLogoSectionState',
          functionName: '_deleteLogo',
          params: {'logoUrl': widget.logoUrl},
        );
      } catch (e) {
        AppLogger.logWarning(
          'No se pudo eliminar el logo de Storage (puede que ya no exista)',
          className: '_BillingLogoSectionState',
          functionName: '_deleteLogo',
          params: {'error': e.toString()},
        );
      }
    }
    
    widget.onLogoUpdated(null, '', false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo eliminado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo para Facturas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mostrar alerta si hay logo inválido
            if (widget.hasInvalidLogo)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se detectó un logo inválido. Sube un nuevo logo para facturas.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onLogoUpdated(widget.logoFile, widget.logoUrl, false);
                      },
                      child: Text(
                        'Ocultar',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.isLoading && widget.logoFile == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : widget.logoFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.logoFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : widget.logoUrl != null && widget.logoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.logoUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        AppLogger.logError(
                                          message: 'Error al cargar imagen desde URL',
                                          error: error,
                                          className: '_BillingLogoSectionState',
                                          functionName: 'build',
                                          params: {
                                            'logoUrl': widget.logoUrl ?? 'null',
                                            'errorType': error.runtimeType.toString(),
                                          },
                                        );
                                        
                                        // Marcar como logo inválido al fallar la carga
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (mounted) {
                                            widget.onLogoUpdated(widget.logoFile, '', true);
                                          }
                                        });
                                        
                                        return const Icon(
                                          Icons.image,
                                          size: 64,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.isLoading ? null : _pickLogo,
                    icon: widget.isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    label: Text(widget.isLoading ? 'Subiendo...' : 'Subir Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.embers,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if ((widget.logoUrl != null && widget.logoUrl!.isNotEmpty) || widget.logoFile != null)
                    TextButton(
                      onPressed: widget.isLoading ? null : _deleteLogo,
                      child: const Text('Eliminar logo'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 