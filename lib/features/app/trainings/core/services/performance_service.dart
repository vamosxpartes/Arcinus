import 'package:arcinus/features/app/excersice/core/models/exercise.dart';
import 'package:arcinus/features/app/trainings/core/models/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService(FirebaseFirestore.instance);
});

class PerformanceService {
  final FirebaseFirestore _firestore;

  PerformanceService(this._firestore);

  // Colecciones de Firestore
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');
  CollectionReference get _exercisesCollection => _firestore.collection('exercises');

  // Obtener datos de asistencia para un grupo en un rango de fechas
  Future<Map<String, Map<String, dynamic>>> getAttendanceDataForGroup(
    String groupId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = _sessionsCollection
        .where('groupIds', arrayContains: groupId)
        .where('scheduledDate', isGreaterThanOrEqualTo: startDate)
        .where('scheduledDate', isLessThanOrEqualTo: endDate)
        .orderBy('scheduledDate');

    final querySnapshot = await query.get();
    final sessions = querySnapshot.docs
        .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    final Map<String, Map<String, dynamic>> attendanceData = {};

    // Para cada atleta, rastrear asistencia y porcentaje
    for (final session in sessions) {
      final attendance = session.attendance;
      if (attendance.isEmpty) continue;

      for (final entry in attendance.entries) {
        final athleteId = entry.key;
        final didAttend = entry.value;

        if (!attendanceData.containsKey(athleteId)) {
          attendanceData[athleteId] = {
            'sessionsAttended': 0,
            'totalSessions': 0,
            'attendanceRate': 0.0,
            'sessionDates': <DateTime>[],
            'attendance': <bool>[],
          };
        }

        attendanceData[athleteId]!['totalSessions'] = (attendanceData[athleteId]!['totalSessions'] as int) + 1;
        if (didAttend) {
          attendanceData[athleteId]!['sessionsAttended'] = (attendanceData[athleteId]!['sessionsAttended'] as int) + 1;
        }

        // Actualizar la tasa de asistencia
        final sessionsAttended = attendanceData[athleteId]!['sessionsAttended'] as int;
        final totalSessions = attendanceData[athleteId]!['totalSessions'] as int;
        attendanceData[athleteId]!['attendanceRate'] = totalSessions > 0 
            ? (sessionsAttended / totalSessions) * 100 
            : 0.0;
        
        // Agregar la fecha y asistencia para gráficos de tendencia
        (attendanceData[athleteId]!['sessionDates'] as List<DateTime>).add(session.scheduledDate);
        (attendanceData[athleteId]!['attendance'] as List<bool>).add(didAttend);
      }
    }

    return attendanceData;
  }

  // Obtener datos de rendimiento para un atleta en un rango de fechas
  Future<Map<String, List<Map<String, dynamic>>>> getAthletePerformanceData(
    String athleteId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = _sessionsCollection
        .where('attendance.$athleteId', isEqualTo: true) // Solo sesiones a las que asistió
        .where('scheduledDate', isGreaterThanOrEqualTo: startDate)
        .where('scheduledDate', isLessThanOrEqualTo: endDate)
        .orderBy('scheduledDate');

    final querySnapshot = await query.get();
    final sessions = querySnapshot.docs
        .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Estructurar datos por tipo de ejercicio para trazado de gráficos
    final performanceData = <String, List<Map<String, dynamic>>>{};

    for (final session in sessions) {
      if (!session.performanceData.containsKey(athleteId)) continue;
      
      final athletePerformance = session.performanceData[athleteId] as Map<String, dynamic>?;
      if (athletePerformance == null) continue;

      // Analizar los ejercicios realizados en esta sesión
      if (session.content.containsKey('exercises')) {
        final exercises = List<Map<String, dynamic>>.from(session.content['exercises'] as List<dynamic>);
        
        for (final exerciseData in exercises) {
          final exerciseId = exerciseData['exerciseId'] as String;
          
          // Verificar si hay datos de rendimiento para este ejercicio
          if (athletePerformance.containsKey(exerciseId)) {
            final exercisePerformance = athletePerformance[exerciseId] as Map<String, dynamic>;
            
            // Obtener detalles del ejercicio
            try {
              final exerciseDoc = await _exercisesCollection.doc(exerciseId).get();
              if (exerciseDoc.exists) {
                final exercise = Exercise.fromJson(exerciseDoc.data() as Map<String, dynamic>);
                
                // Crear categoría por tipo de ejercicio
                final category = '${exercise.sport}-${exercise.category}';
                
                if (!performanceData.containsKey(category)) {
                  performanceData[category] = [];
                }
                
                // Agregar datos de rendimiento con contexto
                performanceData[category]!.add({
                  'date': session.scheduledDate,
                  'exerciseId': exerciseId,
                  'exerciseName': exercise.name,
                  'metrics': exercisePerformance,
                  'sessionId': session.id,
                });
              }
            } catch (e) {
              // Manejar error: el ejercicio ya no existe
              continue;
            }
          }
        }
      }
    }

    return performanceData;
  }

  // Calcular efectividad de un entrenamiento basado en el rendimiento
  Future<Map<String, dynamic>> calculateTrainingEffectiveness(
    String trainingId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = _sessionsCollection
        .where('trainingId', isEqualTo: trainingId)
        .where('scheduledDate', isGreaterThanOrEqualTo: startDate)
        .where('scheduledDate', isLessThanOrEqualTo: endDate)
        .where('isCompleted', isEqualTo: true)
        .orderBy('scheduledDate');

    final querySnapshot = await query.get();
    final sessions = querySnapshot.docs
        .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    if (sessions.isEmpty) {
      return {
        'attendanceRate': 0.0,
        'completionRate': 0.0,
        'performanceImprovementRate': 0.0,
        'sessionCount': 0,
      };
    }

    // Métricas de efectividad
    int totalAttendancePossible = 0;
    int totalAttendanceActual = 0;
    double completionRateSum = 0.0;
    
    // Datos de progreso por atleta
    final athleteProgress = <String, Map<String, List<dynamic>>>{};

    for (final session in sessions) {
      // Calcular tasa de asistencia
      final attendance = session.attendance;
      totalAttendancePossible += attendance.length;
      totalAttendanceActual += attendance.values.where((attended) => attended).length;
      
      // Procesar datos de rendimiento para seguimiento de progreso
      final performanceData = session.performanceData;
      for (final entry in performanceData.entries) {
        final athleteId = entry.key;
        final athletePerformance = entry.value as Map<String, dynamic>;
        
        if (!athleteProgress.containsKey(athleteId)) {
          athleteProgress[athleteId] = {};
        }
        
        // Procesar cada ejercicio
        for (final exerciseEntry in athletePerformance.entries) {
          final exerciseId = exerciseEntry.key;
          final metrics = exerciseEntry.value as Map<String, dynamic>;
          
          for (final metricEntry in metrics.entries) {
            final metricName = metricEntry.key;
            final metricValue = metricEntry.value;
            
            // Solo procesar valores numéricos
            if (metricValue is num) {
              final progressKey = '$exerciseId-$metricName';
              
              if (!athleteProgress[athleteId]!.containsKey(progressKey)) {
                athleteProgress[athleteId]![progressKey] = [];
              }
              
              athleteProgress[athleteId]![progressKey]!.add({
                'date': session.scheduledDate,
                'value': metricValue,
              });
            }
          }
        }
      }
      
      // Calcular tasa de finalización basado en ejercicios completados
      if (session.content.containsKey('exercises')) {
        final exercises = List<Map<String, dynamic>>.from(session.content['exercises'] as List<dynamic>);
        final totalExercises = exercises.length;
        int completedExercises = 0;
        
        // Un ejercicio se considera completado si al menos un atleta registró rendimiento
        for (final exerciseData in exercises) {
          final exerciseId = exerciseData['exerciseId'] as String;
          bool exerciseCompleted = false;
          
          for (final perf in performanceData.values) {
            final athletePerformance = perf as Map<String, dynamic>;
            if (athletePerformance.containsKey(exerciseId)) {
              exerciseCompleted = true;
              break;
            }
          }
          
          if (exerciseCompleted) {
            completedExercises++;
          }
        }
        
        final sessionCompletionRate = totalExercises > 0 
            ? completedExercises / totalExercises 
            : 0.0;
        completionRateSum += sessionCompletionRate;
      }
    }
    
    // Calcular tasa de mejora de rendimiento
    double overallImprovementRate = 0.0;
    int metricsWithImprovement = 0;
    
    for (final athleteData in athleteProgress.values) {
      for (final progressList in athleteData.values) {
        if (progressList.length >= 2) {
          // Verificar si hay suficientes puntos de datos para calcular progreso
          // Ordenar por fecha si es necesario 
          progressList.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
          
          final firstValue = progressList.first['value'] as num;
          final lastValue = progressList.last['value'] as num;
          
          // Calcular tasa de mejora (el significado depende del tipo de métrica)
          final improvement = lastValue - firstValue;
          if (improvement != 0) {
            metricsWithImprovement++;
            // Porcentaje de mejora normalizado
            final improvementRate = (improvement / firstValue.abs()) * 100;
            overallImprovementRate += improvementRate;
          }
        }
      }
    }
    
    // Calcular promedios finales
    final attendanceRate = totalAttendancePossible > 0 
        ? (totalAttendanceActual / totalAttendancePossible) * 100 
        : 0.0;
    
    final completionRate = sessions.isNotEmpty 
        ? (completionRateSum / sessions.length) * 100 
        : 0.0;
    
    final performanceImprovementRate = metricsWithImprovement > 0 
        ? overallImprovementRate / metricsWithImprovement 
        : 0.0;
    
    return {
      'attendanceRate': attendanceRate,
      'completionRate': completionRate,
      'performanceImprovementRate': performanceImprovementRate,
      'sessionCount': sessions.length,
      'athleteProgressData': athleteProgress,
    };
  }
} 