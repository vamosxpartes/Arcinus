import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Provider that checks if an owner has at least one academy.
///
/// Returns `true` if one or more academies exist for the given ownerId,
/// `false` otherwise.
final ownerHasAcademiesProvider =
    StreamProvider.family<bool, String>((ref, ownerId) {
  if (ownerId.isEmpty) {
    return Stream.value(false); // No owner ID, no academies
  }
  final firestore = ref.watch(firestoreProvider);

  // Query for academies owned by the user, limiting to 1 result for efficiency
  final query = firestore
      .collection('academies')
      .where('ownerId', isEqualTo: ownerId)
      .limit(1);

  // Escuchar los snapshots de la query
  final snapshots = query.snapshots();

  // Mapear el snapshot a un booleano (si hay algún documento, tiene academias)
  return snapshots.map((querySnapshot) => querySnapshot.docs.isNotEmpty);
});

/// Provider que obtiene todas las academias de un propietario.
///
/// Retorna una lista de [AcademyModel] para el propietario con el ID proporcionado.
final ownerAcademiesProvider = 
    StreamProvider.family<List<AcademyModel>, String>((ref, ownerId) {
  if (ownerId.isEmpty) {
    return Stream.value([]); // No owner ID, no academies
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  // Intentamos consultar con ordenamiento primero
  try {
    // Consultar todas las academias del propietario con orden
    final query = firestore
        .collection('academies')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true); // Ordenar por fecha de creación (más reciente primero)
    
    // Escuchar los snapshots de la consulta
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        AppLogger.logInfo('Intentando procesar documento (ordenado): ${doc.id}');
        AppLogger.logInfo('Datos crudos (ordenado) ${doc.id}: $data');
        if (data.containsKey('createdAt')) {
          AppLogger.logInfo('Campo createdAt (ordenado) ${doc.id} - Tipo: ${data['createdAt'].runtimeType}, Valor: ${data['createdAt']}');
        } else {
          AppLogger.logWarning('Campo createdAt (ordenado) ${doc.id} no encontrado en los datos.');
        }
        try {
        // Convertir a AcademyModel y asignar ID
          final academy = AcademyModel.fromJson(data).copyWith(id: doc.id);
          AppLogger.logInfo('Academia convertida (ordenado) ${doc.id}: ${academy.name}, CreatedAt: ${academy.createdAt}');
          return academy;
        } catch (e, s) {
          AppLogger.logError(
            message: 'Error convirtiendo AcademyModel.fromJson (ordenado) para ${doc.id}: $e',
            error: e,
            stackTrace: s
          );
          AppLogger.logError(
            message: 'Datos que causaron el error (ordenado) ${doc.id}: $data'
          );
          // Propagar el error para que lo maneje handleError o el catch externo
          throw Exception('Fallo al convertir datos para ${doc.id} (ordenado): $e');
        }
      }).toList();
    }).handleError((error, stackTrace) {
      AppLogger.logError(
        message: 'Error en Stream de consulta ordenada de academias: $error',
        error: error,
        stackTrace: stackTrace as StackTrace?
      );
      // Si hay un error (posiblemente falta de índice), lanzamos una excepción para que pase al catch
      throw Exception('Error en consulta ordenada: $error');
    });
  } catch (e) {
    AppLogger.logWarning(
      'Usando consulta alternativa sin ordenamiento debido a: $e',
      error: e
    );
    
    // Consulta alternativa sin ordenamiento (no requiere índice)
    final fallbackQuery = firestore
        .collection('academies')
        .where('ownerId', isEqualTo: ownerId);
        
    // Escuchar los snapshots de la consulta fallback
    return fallbackQuery.snapshots().map((snapshot) {
      final academies = snapshot.docs.map((doc) {
        final data = doc.data();
        AppLogger.logInfo('Intentando procesar documento (fallback): ${doc.id}');
        AppLogger.logInfo('Datos crudos (fallback) ${doc.id}: $data');
        if (data.containsKey('createdAt')) {
          AppLogger.logInfo('Campo createdAt (fallback) ${doc.id} - Tipo: ${data['createdAt'].runtimeType}, Valor: ${data['createdAt']}');
        } else {
          AppLogger.logWarning('Campo createdAt (fallback) ${doc.id} no encontrado en los datos.');
        }
        try {
          // Convertir a AcademyModel y asignar ID
          final academy = AcademyModel.fromJson(data).copyWith(id: doc.id);
          AppLogger.logInfo('Academia convertida (fallback) ${doc.id}: ${academy.name}, CreatedAt: ${academy.createdAt}');
          return academy;
        } catch (e, s) {
          AppLogger.logError(
            message: 'Error convirtiendo AcademyModel.fromJson (fallback) para ${doc.id}: $e',
            error: e,
            stackTrace: s
          );
          AppLogger.logError(
            message: 'Datos que causaron el error (fallback) ${doc.id}: $data'
          );
          // Propagar el error
          throw Exception('Fallo al convertir datos para ${doc.id} (fallback): $e');
        }
      }).toList();
      
      // Ordenamos manually en memoria
      academies.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1900);
        final bDate = b.createdAt ?? DateTime(1900);
        return bDate.compareTo(aDate); // Orden descendente (más reciente primero)
      });
      
      return academies;
    });
  }
}); 