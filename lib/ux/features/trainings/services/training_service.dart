import 'package:arcinus/shared/models/training.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final trainingServiceProvider = Provider<TrainingService>((ref) {
  return TrainingService(FirebaseFirestore.instance);
});

class TrainingService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  TrainingService(this._firestore);

  // Colecciones de Firestore
  CollectionReference get _trainingsCollection => _firestore.collection('trainings');

  // Obtener un entrenamiento por ID
  Stream<Training> getTrainingById(String trainingId) {
    return _trainingsCollection
        .doc(trainingId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('El entrenamiento no existe');
      }
      return Training.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Obtener entrenamientos por academia
  Stream<List<Training>> getTrainingsByAcademy(String academyId) {
    return _trainingsCollection
        .where('academyId', isEqualTo: academyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Training.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener entrenamientos por grupo
  Stream<List<Training>> getTrainingsByGroup(String groupId) {
    return _trainingsCollection
        .where('groupIds', arrayContains: groupId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Training.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener entrenamientos por entrenador
  Stream<List<Training>> getTrainingsByCoach(String coachId) {
    return _trainingsCollection
        .where('coachIds', arrayContains: coachId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Training.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener plantillas de entrenamiento
  Stream<List<Training>> getTrainingTemplates(String academyId) {
    return _trainingsCollection
        .where('academyId', isEqualTo: academyId)
        .where('isTemplate', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Training.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Crear un nuevo entrenamiento
  Future<Training> createTraining(Training training) async {
    final id = _uuid.v4();
    final newTraining = training.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );

    await _trainingsCollection.doc(id).set(newTraining.toJson());
    return newTraining;
  }

  // Actualizar un entrenamiento existente
  Future<void> updateTraining(Training training) async {
    final updatedTraining = training.copyWith(
      updatedAt: DateTime.now(),
    );

    await _trainingsCollection.doc(training.id).update(updatedTraining.toJson());
  }

  // Eliminar un entrenamiento
  Future<void> deleteTraining(String trainingId) async {
    await _trainingsCollection.doc(trainingId).delete();
  }

  // Clonar una plantilla de entrenamiento
  Future<Training> cloneTrainingTemplate(String templateId, {
    required String academyId,
    required List<String> groupIds,
    required List<String> coachIds,
    required String createdBy,
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    bool isRecurring = false,
    String? recurrencePattern,
    List<String>? recurrenceDays,
    int? recurrenceInterval,
  }) async {
    // Obtener la plantilla
    final docSnapshot = await _trainingsCollection.doc(templateId).get();
    if (!docSnapshot.exists) {
      throw Exception('La plantilla de entrenamiento no existe');
    }

    final template = Training.fromJson(docSnapshot.data() as Map<String, dynamic>);
    
    // Crear el nuevo entrenamiento basado en la plantilla
    final newTraining = template.copyWith(
      id: _uuid.v4(),
      name: name,
      academyId: academyId,
      groupIds: groupIds,
      coachIds: coachIds,
      isTemplate: false,
      isRecurring: isRecurring,
      startDate: startDate,
      endDate: endDate,
      recurrencePattern: recurrencePattern,
      recurrenceDays: recurrenceDays,
      recurrenceInterval: recurrenceInterval,
      sessionIds: [],
      createdAt: DateTime.now(),
      createdBy: createdBy,
      updatedAt: null,
      updatedBy: null,
    );

    await _trainingsCollection.doc(newTraining.id).set(newTraining.toJson());
    return newTraining;
  }
} 