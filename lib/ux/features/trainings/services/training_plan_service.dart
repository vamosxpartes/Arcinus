import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/models/training_plan.dart';
import 'package:arcinus/ux/features/trainings/services/session_service.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final trainingPlanServiceProvider = Provider<TrainingPlanService>((ref) {
  final trainingService = ref.watch(trainingServiceProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return TrainingPlanService(
    FirebaseFirestore.instance,
    trainingService,
    sessionService,
  );
});

class TrainingPlanService {
  final FirebaseFirestore _firestore;
  final TrainingService _trainingService;
  final SessionService _sessionService;
  final _uuid = const Uuid();

  TrainingPlanService(this._firestore, this._trainingService, this._sessionService);

  // Colecciones de Firestore
  CollectionReference get _plansCollection => _firestore.collection('training_plans');

  // Obtener un plan por ID
  Stream<TrainingPlan> getTrainingPlanById(String planId) {
    return _plansCollection
        .doc(planId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('El plan de entrenamiento no existe');
      }
      return TrainingPlan.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Obtener planes por academia
  Stream<List<TrainingPlan>> getTrainingPlansByAcademy(String academyId) {
    return _plansCollection
        .where('academyId', isEqualTo: academyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainingPlan.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener planes por grupo
  Stream<List<TrainingPlan>> getTrainingPlansByGroup(String groupId) {
    return _plansCollection
        .where('groupIds', arrayContains: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainingPlan.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener planes activos
  Stream<List<TrainingPlan>> getActiveTrainingPlans(String academyId) {
    return _plansCollection
        .where('academyId', isEqualTo: academyId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainingPlan.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Crear un nuevo plan
  Future<TrainingPlan> createTrainingPlan(TrainingPlan plan) async {
    final id = _uuid.v4();
    final newPlan = plan.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );

    await _plansCollection.doc(id).set(newPlan.toJson());
    return newPlan;
  }

  // Actualizar un plan existente
  Future<void> updateTrainingPlan(TrainingPlan plan) async {
    final updatedPlan = plan.copyWith(
      updatedAt: DateTime.now(),
    );

    await _plansCollection.doc(plan.id).update(updatedPlan.toJson());
  }

  // Eliminar un plan
  Future<void> deleteTrainingPlan(String planId) async {
    await _plansCollection.doc(planId).delete();
  }

  // Activar un plan de entrenamiento (genera los entrenamientos y sesiones)
  Future<void> activateTrainingPlan(String planId, String activatedBy) async {
    // Obtener el plan
    final planDoc = await _plansCollection.doc(planId).get();
    if (!planDoc.exists) {
      throw Exception('El plan de entrenamiento no existe');
    }

    final plan = TrainingPlan.fromJson(planDoc.data() as Map<String, dynamic>);
    
    // Verificar que tenga fecha de inicio
    if (plan.startDate == null) {
      throw Exception('El plan debe tener una fecha de inicio para ser activado');
    }
    
    // Calcular fecha de fin basada en la duración
    final endDate = plan.startDate!.add(Duration(days: 7 * plan.durationInWeeks));
    
    // Actualizar el plan como activo
    await _plansCollection.doc(planId).update({
      'isActive': true,
      'endDate': endDate,
      'updatedAt': DateTime.now(),
      'updatedBy': activatedBy,
    });
    
    // Generar sesiones para cada fase
    DateTime currentPhaseStartDate = plan.startDate!;
    
    for (final phase in plan.phases) {
      // Calcular fecha de fin de la fase
      final phaseEndDate = currentPhaseStartDate.add(Duration(days: phase.durationInDays));
      
      // Actualizar las fechas de la fase
      await _plansCollection.doc(planId).update({
        'phases': FieldValue.arrayRemove([phase.toJson()]),
      });
      
      final updatedPhase = phase.copyWith(
        startDate: currentPhaseStartDate,
        endDate: phaseEndDate,
      );
      
      await _plansCollection.doc(planId).update({
        'phases': FieldValue.arrayUnion([updatedPhase.toJson()]),
      });
      
      // Generar sesiones para esta fase
      for (final plannedSession in phase.plannedSessions) {
        // Calcular la fecha de la sesión dentro de la fase
        final sessionDate = currentPhaseStartDate.add(Duration(days: plannedSession.dayOffset));
        
        String trainingId;
        
        // Crear un entrenamiento basado en la plantilla o uno nuevo
        if (plannedSession.trainingTemplateId != null) {
          // Clonar desde una plantilla existente
          final training = await _trainingService.cloneTrainingTemplate(
            plannedSession.trainingTemplateId!,
            academyId: plan.academyId,
            groupIds: plan.groupIds,
            coachIds: plan.coachIds,
            createdBy: activatedBy,
            name: '${plan.name} - ${phase.name} - ${plannedSession.name}',
            startDate: sessionDate,
            endDate: sessionDate,
          );
          
          trainingId = training.id;
        } else {
          // Crear un nuevo entrenamiento
          final training = Training(
            id: '',
            name: '${plan.name} - ${phase.name} - ${plannedSession.name}',
            description: plannedSession.description ?? 'Sesión del plan de entrenamiento',
            academyId: plan.academyId,
            groupIds: plan.groupIds,
            coachIds: plan.coachIds,
            isTemplate: false,
            startDate: sessionDate,
            endDate: sessionDate,
            content: plannedSession.content,
            createdAt: DateTime.now(),
            createdBy: activatedBy,
          );
          
          final createdTraining = await _trainingService.createTraining(training);
          trainingId = createdTraining.id;
        }
        
        // Crear la sesión
        final session = Session(
          id: '',
          name: plannedSession.name,
          trainingId: trainingId,
          academyId: plan.academyId,
          groupIds: plan.groupIds,
          coachIds: plan.coachIds,
          scheduledDate: sessionDate,
          createdAt: DateTime.now(),
          createdBy: activatedBy,
          content: plannedSession.content,
        );
        
        final createdSession = await _sessionService.createSession(session);
        
        // Actualizar la referencia en el plan
        await _plansCollection.doc(planId).update({
          'phases': FieldValue.arrayRemove([updatedPhase.toJson()]),
        });
        
        // Actualizar la lista de sesiones planeadas
        final updatedPlannedSessions = updatedPhase.plannedSessions.map((ps) {
          if (ps.id == plannedSession.id) {
            return ps.copyWith(generatedSessionId: createdSession.id);
          }
          return ps;
        }).toList();
        
        final newUpdatedPhase = updatedPhase.copyWith(
          plannedSessions: updatedPlannedSessions,
        );
        
        await _plansCollection.doc(planId).update({
          'phases': FieldValue.arrayUnion([newUpdatedPhase.toJson()]),
        });
      }
      
      // Actualizar la fecha de inicio para la siguiente fase
      currentPhaseStartDate = phaseEndDate.add(const Duration(days: 1));
    }
  }

  // Desactivar un plan de entrenamiento
  Future<void> deactivateTrainingPlan(String planId, String deactivatedBy) async {
    await _plansCollection.doc(planId).update({
      'isActive': false,
      'updatedAt': DateTime.now(),
      'updatedBy': deactivatedBy,
    });
  }

  // Añadir una fase al plan
  Future<void> addPhaseToTrainingPlan(String planId, TrainingPlanPhase phase) async {
    final id = _uuid.v4();
    final newPhase = phase.copyWith(id: id);
    
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayUnion([newPhase.toJson()]),
      'updatedAt': DateTime.now(),
    });
  }

  // Eliminar una fase del plan
  Future<void> removePhaseFromTrainingPlan(String planId, String phaseId) async {
    // Obtener el plan actual
    final planDoc = await _plansCollection.doc(planId).get();
    if (!planDoc.exists) {
      throw Exception('El plan de entrenamiento no existe');
    }
    
    final plan = TrainingPlan.fromJson(planDoc.data() as Map<String, dynamic>);
    
    // Encontrar la fase a eliminar
    final phaseToRemove = plan.phases.firstWhere(
      (phase) => phase.id == phaseId,
      orElse: () => throw Exception('La fase no existe en este plan'),
    );
    
    // Eliminar la fase
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayRemove([phaseToRemove.toJson()]),
      'updatedAt': DateTime.now(),
    });
  }

  // Añadir una sesión planificada a una fase
  Future<void> addSessionToPlanPhase(
    String planId,
    String phaseId,
    TrainingPlanSession session,
  ) async {
    // Obtener el plan actual
    final planDoc = await _plansCollection.doc(planId).get();
    if (!planDoc.exists) {
      throw Exception('El plan de entrenamiento no existe');
    }
    
    final plan = TrainingPlan.fromJson(planDoc.data() as Map<String, dynamic>);
    
    // Encontrar la fase
    final phaseIndex = plan.phases.indexWhere((phase) => phase.id == phaseId);
    if (phaseIndex == -1) {
      throw Exception('La fase no existe en este plan');
    }
    
    // Crear una nueva sesión con ID
    final id = _uuid.v4();
    final newSession = session.copyWith(id: id);
    
    // Remover la fase antigua
    final oldPhase = plan.phases[phaseIndex];
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayRemove([oldPhase.toJson()]),
    });
    
    // Añadir la fase actualizada con la nueva sesión
    final updatedSessions = [...oldPhase.plannedSessions, newSession];
    final newPhase = oldPhase.copyWith(plannedSessions: updatedSessions);
    
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayUnion([newPhase.toJson()]),
      'updatedAt': DateTime.now(),
    });
  }

  // Eliminar una sesión planificada de una fase
  Future<void> removeSessionFromPlanPhase(
    String planId,
    String phaseId,
    String sessionId,
  ) async {
    // Obtener el plan actual
    final planDoc = await _plansCollection.doc(planId).get();
    if (!planDoc.exists) {
      throw Exception('El plan de entrenamiento no existe');
    }
    
    final plan = TrainingPlan.fromJson(planDoc.data() as Map<String, dynamic>);
    
    // Encontrar la fase
    final phaseIndex = plan.phases.indexWhere((phase) => phase.id == phaseId);
    if (phaseIndex == -1) {
      throw Exception('La fase no existe en este plan');
    }
    
    final oldPhase = plan.phases[phaseIndex];
    
    // Encontrar la sesión a eliminar
    final sessionIndex = oldPhase.plannedSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('La sesión no existe en esta fase');
    }
    
    // Remover la fase antigua
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayRemove([oldPhase.toJson()]),
    });
    
    // Añadir la fase actualizada sin la sesión eliminada
    final updatedSessions = [...oldPhase.plannedSessions];
    updatedSessions.removeAt(sessionIndex);
    
    final newPhase = oldPhase.copyWith(plannedSessions: updatedSessions);
    
    await _plansCollection.doc(planId).update({
      'phases': FieldValue.arrayUnion([newPhase.toJson()]),
      'updatedAt': DateTime.now(),
    });
  }
} 