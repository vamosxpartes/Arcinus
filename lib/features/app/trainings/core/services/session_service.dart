import 'package:arcinus/features/app/trainings/core/models/session.dart';
import 'package:arcinus/features/app/trainings/core/models/training.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(FirebaseFirestore.instance);
});

class SessionService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  SessionService(this._firestore);

  // Colecciones de Firestore
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');
  CollectionReference get _trainingsCollection => _firestore.collection('trainings');

  // Obtener una sesión por ID
  Stream<Session> getSessionById(String sessionId) {
    return _sessionsCollection
        .doc(sessionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('La sesión no existe');
      }
      return Session.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Obtener sesiones por entrenamiento
  Stream<List<Session>> getSessionsByTraining(String trainingId) {
    return _sessionsCollection
        .where('trainingId', isEqualTo: trainingId)
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener sesiones por academia
  Stream<List<Session>> getSessionsByAcademy(String academyId, {DateTime? fromDate, DateTime? toDate}) {
    Query query = _sessionsCollection.where('academyId', isEqualTo: academyId);
    
    if (fromDate != null) {
      query = query.where('scheduledDate', isGreaterThanOrEqualTo: fromDate);
    }
    
    if (toDate != null) {
      query = query.where('scheduledDate', isLessThanOrEqualTo: toDate);
    }
    
    return query
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener sesiones por grupo
  Stream<List<Session>> getSessionsByGroup(String groupId, {DateTime? fromDate, DateTime? toDate}) {
    Query query = _sessionsCollection.where('groupIds', arrayContains: groupId);
    
    if (fromDate != null) {
      query = query.where('scheduledDate', isGreaterThanOrEqualTo: fromDate);
    }
    
    if (toDate != null) {
      query = query.where('scheduledDate', isLessThanOrEqualTo: toDate);
    }
    
    return query
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtener sesiones por entrenador
  Stream<List<Session>> getSessionsByCoach(String coachId, {DateTime? fromDate, DateTime? toDate}) {
    Query query = _sessionsCollection.where('coachIds', arrayContains: coachId);
    
    if (fromDate != null) {
      query = query.where('scheduledDate', isGreaterThanOrEqualTo: fromDate);
    }
    
    if (toDate != null) {
      query = query.where('scheduledDate', isLessThanOrEqualTo: toDate);
    }
    
    return query
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Session.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Crear una nueva sesión
  Future<Session> createSession(Session session) async {
    final id = _uuid.v4();
    final newSession = session.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );

    await _sessionsCollection.doc(id).set(newSession.toJson());
    
    // Actualizar el entrenamiento para agregar esta sesión
    await _trainingsCollection.doc(session.trainingId).update({
      'sessionIds': FieldValue.arrayUnion([id])
    });
    
    return newSession;
  }

  // Crear múltiples sesiones para un entrenamiento recurrente
  Future<List<Session>> createRecurringSessions(
    Training training, {
    required DateTime startDate,
    required DateTime endDate,
    required String name,
    required String createdBy,
  }) async {
    if (!training.isRecurring || 
        training.recurrencePattern == null || 
        training.recurrenceInterval == null) {
      throw Exception('El entrenamiento no está configurado como recurrente');
    }

    final List<Session> createdSessions = [];
    DateTime currentDate = startDate;
    
    // Generar fechas según el patrón de recurrencia
    final List<DateTime> sessionDates = [];
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      switch (training.recurrencePattern) {
        case 'daily':
          sessionDates.add(currentDate);
          currentDate = currentDate.add(Duration(days: training.recurrenceInterval!));
          break;
          
        case 'weekly':
          if (training.recurrenceDays != null && training.recurrenceDays!.isNotEmpty) {
            // Si el día actual está en los días de recurrencia, agregar
            final weekday = currentDate.weekday.toString();
            if (training.recurrenceDays!.contains(weekday)) {
              sessionDates.add(currentDate);
            }
            // Avanzar al siguiente día
            currentDate = currentDate.add(const Duration(days: 1));
          } else {
            // Si no hay días específicos, usar el intervalo semanal
            sessionDates.add(currentDate);
            currentDate = currentDate.add(Duration(days: 7 * training.recurrenceInterval!));
          }
          break;
          
        case 'monthly':
          sessionDates.add(currentDate);
          // Avanzar al mismo día del mes siguiente
          final year = currentDate.month + training.recurrenceInterval! > 12 
              ? currentDate.year + 1 
              : currentDate.year;
          final month = (currentDate.month + training.recurrenceInterval! - 1) % 12 + 1;
          currentDate = DateTime(year, month, currentDate.day);
          break;
          
        default:
          throw Exception('Patrón de recurrencia no soportado');
      }
    }

    // Crear sesiones para cada fecha
    for (final date in sessionDates) {
      final session = Session(
        id: '', // Se asignará en createSession
        name: name,
        trainingId: training.id,
        academyId: training.academyId,
        groupIds: training.groupIds,
        coachIds: training.coachIds,
        scheduledDate: date,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        content: training.content,
      );
      
      final createdSession = await createSession(session);
      createdSessions.add(createdSession);
    }
    
    return createdSessions;
  }

  // Actualizar una sesión existente
  Future<void> updateSession(Session session) async {
    final updatedSession = session.copyWith(
      updatedAt: DateTime.now(),
    );

    await _sessionsCollection.doc(session.id).update(updatedSession.toJson());
  }

  // Eliminar una sesión
  Future<void> deleteSession(Session session) async {
    await _sessionsCollection.doc(session.id).delete();
    
    // Actualizar el entrenamiento para quitar esta sesión
    await _trainingsCollection.doc(session.trainingId).update({
      'sessionIds': FieldValue.arrayRemove([session.id])
    });
  }

  // Registrar asistencia para una sesión
  Future<void> recordAttendance(String sessionId, Map<String, bool> attendance) async {
    await _sessionsCollection.doc(sessionId).update({
      'attendance': attendance,
    });
  }

  // Registrar datos de rendimiento para una sesión
  Future<void> recordPerformanceData(String sessionId, Map<String, dynamic> performanceData) async {
    await _sessionsCollection.doc(sessionId).update({
      'performanceData': performanceData,
    });
  }

  // Marcar una sesión como completada
  Future<void> markSessionAsCompleted(String sessionId, {String? notes}) async {
    final updateData = <String, dynamic>{
      'isCompleted': true,
      'endTime': DateTime.now(),
    };
    
    if (notes != null) {
      updateData['notes'] = notes;
    }
    
    await _sessionsCollection.doc(sessionId).update(updateData);
  }
} 