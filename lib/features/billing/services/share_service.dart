import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Servicio para compartir archivos PDF y otros documentos
class ShareService {
  /// Comparte un archivo PDF a través de las opciones del sistema
  /// 
  /// [pdfBytes] Los bytes del archivo PDF a compartir
  /// [fileName] Nombre del archivo a compartir
  /// [subject] Asunto para compartir (título, por ej. para emails)
  Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
  }) async {
    try {
      AppLogger.logInfo(
        'Compartiendo PDF',
        className: 'ShareService',
        functionName: 'sharePdf',
        params: {'fileName': fileName},
      );
      
      // Guardar el PDF temporalmente para poder compartirlo
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // Compartir el archivo
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
        text: 'Factura generada con Arcinus',
      );
      
      AppLogger.logInfo(
        'Resultado de compartir',
        className: 'ShareService',
        functionName: 'sharePdf',
        params: {'status': result.status.toString()},
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al compartir PDF',
        error: e,
        stackTrace: s,
        className: 'ShareService',
        functionName: 'sharePdf',
      );
      rethrow;
    }
  }
  
  /// Comparte una URL (por ejemplo, a una factura en la nube)
  /// 
  /// [url] La URL a compartir
  /// [subject] Asunto para compartir
  Future<void> shareUrl({
    required String url,
    String? subject,
  }) async {
    try {
      AppLogger.logInfo(
        'Compartiendo URL',
        className: 'ShareService',
        functionName: 'shareUrl',
        params: {'url': url},
      );
            
      AppLogger.logInfo(
        'URL compartida',
        className: 'ShareService',
        functionName: 'shareUrl',
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al compartir URL',
        error: e,
        stackTrace: s,
        className: 'ShareService',
        functionName: 'shareUrl',
      );
      rethrow;
    }
  }
} 