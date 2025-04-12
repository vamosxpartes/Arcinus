import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/ux/features/trainings/services/exercise_service.dart';
import 'package:arcinus/ux/features/trainings/services/performance_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final exerciseService = ref.watch(exerciseServiceProvider);
  final performanceService = ref.watch(performanceServiceProvider);
  return RecommendationService(
    FirebaseFirestore.instance,
    exerciseService,
    performanceService,
  );
});

class RecommendationService {
  final FirebaseFirestore _firestore;
  final ExerciseService _exerciseService;
  final PerformanceService _performanceService;

  RecommendationService(
    this._firestore,
    this._exerciseService,
    this._performanceService,
  );

  // Colecciones de Firestore
  CollectionReference get _athletesCollection => _firestore.collection('athletes');
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');

  // Obtener ejercicios recomendados para un atleta basado en su historial
  Future<List<Map<String, dynamic>>> getRecommendedExercisesForAthlete(
    String athleteId,
    String academyId,
    String sport, {
    int limit = 10,
  }) async {
    // 1. Obtener datos de rendimiento del atleta en los últimos 3 meses
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    
    final performanceData = await _performanceService.getAthletePerformanceData(
      athleteId,
      startDate: threeMonthsAgo,
      endDate: now,
    );
    
    // 2. Analizar áreas de mejora
    final Map<String, double> categoryScores = {};
    final Map<String, int> categoryCount = {};
    final Set<String> exercisesPerformed = {};
    
    // Procesar datos de rendimiento para identificar áreas de mejora
    performanceData.forEach((category, exercises) {
      for (final exerciseData in exercises) {
        final exerciseId = exerciseData['exerciseId'] as String;
        exercisesPerformed.add(exerciseId);
        
        // Normalizar puntajes por categoría
        if (!categoryScores.containsKey(category)) {
          categoryScores[category] = 0.0;
          categoryCount[category] = 0;
        }
        
        // Analizar métricas (simplificado - se podría hacer más sofisticado)
        final metrics = exerciseData['metrics'] as Map<String, dynamic>;
        double exerciseScore = 0.0;
        
        // Calcular un puntaje simple basado en cuántas métricas se registraron
        exerciseScore = metrics.length.toDouble();
        
        categoryScores[category] = categoryScores[category]! + exerciseScore;
        categoryCount[category] = categoryCount[category]! + 1;
      }
    });
    
    // Calcular puntajes promedio por categoría
    final Map<String, double> categoryAverages = {};
    categoryScores.forEach((category, score) {
      categoryAverages[category] = score / categoryCount[category]!;
    });
    
    // 3. Identificar categorías con puntajes más bajos (áreas de mejora)
    final sortedCategories = categoryAverages.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // 4. Buscar ejercicios en esas categorías
    final recommendedExercises = <Map<String, dynamic>>[];
    
    // Máximo 3 categorías principales para mejorar
    for (int i = 0; i < sortedCategories.length && i < 3; i++) {
      final categoryParts = sortedCategories[i].key.split('-');
      if (categoryParts.length != 2) continue;
      
      final exerciseSport = categoryParts[0];
      final exerciseCategory = categoryParts[1];
      
      // Solo recomendar ejercicios del mismo deporte
      if (exerciseSport != sport) continue;
      
      // Obtener ejercicios de esta categoría
      final exercisesStream = _exerciseService.getExercisesByCategory(academyId, exerciseCategory);
      final exercises = await exercisesStream.first;
      
      // Filtrar ejercicios que el atleta no ha realizado recientemente
      final newExercises = exercises.where(
        (exercise) => !exercisesPerformed.contains(exercise.id)
      ).toList();
      
      // Agregar a las recomendaciones con un puntaje de relevancia
      for (final exercise in newExercises) {
        recommendedExercises.add({
          'exercise': exercise.toJson(),
          'relevanceScore': 100 - (i * 10), // Mayor puntaje para categorías más débiles
          'reason': 'Mejora tu rendimiento en ${exercise.category}',
        });
      }
    }
    
    // 5. Conseguir ejercicios complementarios (otros deportes o categorías)
    if (recommendedExercises.length < limit) {
      final exercisesStream = _exerciseService.getExercisesByAcademy(academyId);
      final allExercises = await exercisesStream.first;
      
      // Filtrar ejercicios ya recomendados y recientemente realizados
      final recommendedIds = recommendedExercises
          .map((e) => (e['exercise'] as Map<String, dynamic>)['id'] as String)
          .toSet();
      
      final complementaryExercises = allExercises.where(
        (exercise) => !recommendedIds.contains(exercise.id) && 
                       !exercisesPerformed.contains(exercise.id)
      ).toList();
      
      // Agregar ejercicios complementarios hasta alcanzar el límite
      for (final exercise in complementaryExercises) {
        if (recommendedExercises.length >= limit) break;
        
        recommendedExercises.add({
          'exercise': exercise.toJson(),
          'relevanceScore': 50, // Puntaje medio para ejercicios complementarios
          'reason': 'Ejercicio complementario para tu entrenamiento',
        });
      }
    }
    
    // 6. Ordenar por relevancia
    recommendedExercises.sort((a, b) => 
      (b['relevanceScore'] as num).compareTo(a['relevanceScore'] as num)
    );
    
    // Limitar resultados
    return recommendedExercises.take(limit).toList();
  }

  // Recomendar entrenamientos para un atleta
  Future<List<Map<String, dynamic>>> getRecommendedTrainingsForAthlete(
    String athleteId,
    String academyId, {
    int limit = 5,
  }) async {
    // Obtener datos del perfil del atleta
    final athleteDoc = await _athletesCollection.doc(athleteId).get();
    if (!athleteDoc.exists) {
      throw Exception('El atleta no existe');
    }
    
    final athlete = athleteDoc.data() as Map<String, dynamic>;
    final sport = athlete['sport'] as String? ?? '';
    
    // Obtener sesiones asistidas recientemente
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    
    final query = _sessionsCollection
        .where('attendance.$athleteId', isEqualTo: true)
        .where('scheduledDate', isGreaterThanOrEqualTo: sixMonthsAgo)
        .orderBy('scheduledDate', descending: true)
        .limit(20);
    
    final querySnapshot = await query.get();
    final sessions = querySnapshot.docs
        .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    
    // Analizar efectividad de los entrenamientos
    final Set<String> trainingIds = {};
    final Map<String, double> trainingEffectiveness = {};
    
    for (final session in sessions) {
      final trainingId = session.trainingId;
      trainingIds.add(trainingId);
      
      // Verificar si hay datos de rendimiento registrados
      if (session.performanceData.containsKey(athleteId)) {
        final performanceData = session.performanceData[athleteId] as Map<String, dynamic>;
        
        // Simple métrica de efectividad: cantidad de ejercicios con datos registrados
        final effectivenessScore = performanceData.length.toDouble();
        
        if (!trainingEffectiveness.containsKey(trainingId)) {
          trainingEffectiveness[trainingId] = 0.0;
        }
        
        trainingEffectiveness[trainingId] = trainingEffectiveness[trainingId]! + effectivenessScore;
      }
    }
    
    // Calcular efectividad promedio para entrenamientos con múltiples sesiones
    final Map<String, int> trainingCount = {};
    for (final session in sessions) {
      final trainingId = session.trainingId;
      trainingCount[trainingId] = (trainingCount[trainingId] ?? 0) + 1;
    }
    
    final Map<String, double> trainingAverages = {};
    trainingEffectiveness.forEach((trainingId, score) {
      trainingAverages[trainingId] = score / trainingCount[trainingId]!;
    });
    
    // Ordenar por efectividad
    final sortedTrainings = trainingAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Preparar recomendaciones
    final recommendedTrainings = <Map<String, dynamic>>[];
    
    // Recomendar los entrenamientos más efectivos
    for (final entry in sortedTrainings.take(limit)) {
      final trainingId = entry.key;
      final effectivenessScore = entry.value;
      
      try {
        final trainingDoc = await _firestore.collection('trainings').doc(trainingId).get();
        if (trainingDoc.exists) {
          final training = Training.fromJson(trainingDoc.data() as Map<String, dynamic>);
          
          recommendedTrainings.add({
            'training': training.toJson(),
            'relevanceScore': effectivenessScore * 10, // Escalar a un rango similar a ejercicios
            'reason': 'Entrenamiento efectivo basado en tu historial',
            'effectiveness': effectivenessScore,
          });
        }
      } catch (e) {
        // Manejar error: el entrenamiento ya no existe
        continue;
      }
    }
    
    // Si no hay suficientes, recomendar plantillas populares
    if (recommendedTrainings.length < limit) {
      final templatesQuery = _firestore.collection('trainings')
          .where('academyId', isEqualTo: academyId)
          .where('isTemplate', isEqualTo: true)
          .where('sport', isEqualTo: sport)
          .limit(limit - recommendedTrainings.length);
      
      final templatesSnapshot = await templatesQuery.get();
      final templates = templatesSnapshot.docs
          .map((doc) => Training.fromJson(doc.data()))
          .toList();
      
      for (final template in templates) {
        recommendedTrainings.add({
          'training': template.toJson(),
          'relevanceScore': 50, // Puntaje medio para plantillas genéricas
          'reason': 'Plantilla recomendada para tu deporte',
        });
      }
    }
    
    // Ordenar por relevancia
    recommendedTrainings.sort((a, b) => 
      (b['relevanceScore'] as num).compareTo(a['relevanceScore'] as num)
    );
    
    // Limitar resultados
    return recommendedTrainings.take(limit).toList();
  }
} 