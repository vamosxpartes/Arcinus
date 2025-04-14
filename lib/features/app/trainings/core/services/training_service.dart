import 'package:arcinus/features/app/excersice/core/models/exercise.dart';
import 'package:arcinus/features/app/trainings/core/models/training.dart';
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
  CollectionReference get _exercisesCollection => _firestore.collection('exercises');

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
  
  // Añadir ejercicio a un entrenamiento
  Future<void> addExerciseToTraining(String trainingId, Exercise exercise, {
    required int order,
    int? duration, // Duración en segundos
    int? sets,     // Número de series
    int? reps,     // Repeticiones por serie
    Map<String, dynamic>? customParameters, // Parámetros específicos para este ejercicio
    String? notes, // Notas específicas para este ejercicio
  }) async {
    final exerciseData = {
      'exerciseId': exercise.id,
      'order': order,
      'duration': duration,
      'sets': sets,
      'reps': reps,
      'customParameters': customParameters ?? {},
      'notes': notes,
    };

    final trainingDoc = await _trainingsCollection.doc(trainingId).get();
    if (!trainingDoc.exists) {
      throw Exception('El entrenamiento no existe');
    }

    final training = Training.fromJson(trainingDoc.data() as Map<String, dynamic>);
    final content = Map<String, dynamic>.from(training.content);
    
    // Asegurarse de que existe la lista de ejercicios
    if (!content.containsKey('exercises')) {
      content['exercises'] = <Map<String, dynamic>>[];
    }
    
    final exercises = List<Map<String, dynamic>>.from(content['exercises'] as List<dynamic>);
    exercises.add(exerciseData);
    
    // Ordenar por el campo 'order'
    exercises.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
    
    content['exercises'] = exercises;
    
    await _trainingsCollection.doc(trainingId).update({
      'content': content,
    });
  }
  
  // Eliminar ejercicio de un entrenamiento
  Future<void> removeExerciseFromTraining(String trainingId, String exerciseId, int order) async {
    final trainingDoc = await _trainingsCollection.doc(trainingId).get();
    if (!trainingDoc.exists) {
      throw Exception('El entrenamiento no existe');
    }

    final training = Training.fromJson(trainingDoc.data() as Map<String, dynamic>);
    final content = Map<String, dynamic>.from(training.content);
    
    if (!content.containsKey('exercises')) {
      return; // No hay ejercicios, nada que eliminar
    }
    
    final exercises = List<Map<String, dynamic>>.from(content['exercises'] as List<dynamic>);
    exercises.removeWhere((e) => e['exerciseId'] == exerciseId && e['order'] == order);
    
    content['exercises'] = exercises;
    
    await _trainingsCollection.doc(trainingId).update({
      'content': content,
    });
  }
  
  // Obtener ejercicios de un entrenamiento con detalles
  Future<List<Map<String, dynamic>>> getTrainingExercisesWithDetails(String trainingId) async {
    final trainingDoc = await _trainingsCollection.doc(trainingId).get();
    if (!trainingDoc.exists) {
      throw Exception('El entrenamiento no existe');
    }

    final training = Training.fromJson(trainingDoc.data() as Map<String, dynamic>);
    final content = training.content;
    
    if (!content.containsKey('exercises')) {
      return []; // No hay ejercicios
    }
    
    final exercises = List<Map<String, dynamic>>.from(content['exercises'] as List<dynamic>);
    final result = <Map<String, dynamic>>[];
    
    for (final exerciseData in exercises) {
      final exerciseId = exerciseData['exerciseId'] as String;
      final exerciseDoc = await _exercisesCollection.doc(exerciseId).get();
      
      if (exerciseDoc.exists) {
        final exercise = Exercise.fromJson(exerciseDoc.data() as Map<String, dynamic>);
        result.add({
          ...exerciseData,
          'exercise': exercise.toJson(),
        });
      } else {
        // Si el ejercicio fue eliminado, seguir mostrando los datos básicos
        result.add(exerciseData);
      }
    }
    
    return result;
  }
} 