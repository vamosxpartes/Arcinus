import 'package:arcinus/shared/models/exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService(FirebaseFirestore.instance);
});

class ExerciseService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ExerciseService(this._firestore);

  // Colecciones de Firestore
  CollectionReference get _exercisesCollection => _firestore.collection('exercises');

  // Obtener un ejercicio por ID
  Stream<Exercise> getExerciseById(String exerciseId) {
    return _exercisesCollection
        .doc(exerciseId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('El ejercicio no existe');
      }
      return Exercise.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Obtener ejercicios por academia
  Stream<List<Exercise>> getExercisesByAcademy(String academyId) {
    return _exercisesCollection
        .where('academyId', isEqualTo: academyId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener ejercicios por deporte
  Stream<List<Exercise>> getExercisesBySport(String academyId, String sport) {
    return _exercisesCollection
        .where('academyId', isEqualTo: academyId)
        .where('sport', isEqualTo: sport)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener ejercicios por categoría
  Stream<List<Exercise>> getExercisesByCategory(String academyId, String category) {
    return _exercisesCollection
        .where('academyId', isEqualTo: academyId)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener ejercicios por dificultad
  Stream<List<Exercise>> getExercisesByDifficulty(String academyId, String difficulty) {
    return _exercisesCollection
        .where('academyId', isEqualTo: academyId)
        .where('difficulty', isEqualTo: difficulty)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Buscar ejercicios
  Stream<List<Exercise>> searchExercises(String academyId, String query) {
    // Firestore no soporta búsqueda de texto completo de forma nativa
    // Esta es una implementación básica que busca coincidencias exactas
    return _exercisesCollection
        .where('academyId', isEqualTo: academyId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final exercises = snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      // Filtrar ejercicios que contienen la consulta en el nombre o descripción
      return exercises.where((exercise) {
        return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
               exercise.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Crear un nuevo ejercicio
  Future<Exercise> createExercise(Exercise exercise) async {
    final id = _uuid.v4();
    final newExercise = exercise.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );

    await _exercisesCollection.doc(id).set(newExercise.toJson());
    return newExercise;
  }

  // Actualizar un ejercicio existente
  Future<void> updateExercise(Exercise exercise) async {
    final updatedExercise = exercise.copyWith(
      updatedAt: DateTime.now(),
    );

    await _exercisesCollection.doc(exercise.id).update(updatedExercise.toJson());
  }

  // Eliminar un ejercicio
  Future<void> deleteExercise(String exerciseId) async {
    await _exercisesCollection.doc(exerciseId).delete();
  }
} 