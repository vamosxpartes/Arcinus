import 'package:arcinus/features/app/trainings/core/models/session.dart';
import 'package:arcinus/features/app/trainings/core/services/session_service.dart';
import 'package:arcinus/features/app/users/athlete/core/services/athlete_repository.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String academyId;

  const AttendanceScreen({
    super.key,
    required this.sessionId,
    required this.academyId,
  });

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Map<String, bool> _attendance = {};
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final sessionService = ref.watch(sessionServiceProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Registro de Asistencia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<Session>(
                  stream: sessionService.getSessionById(widget.sessionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    
                    final session = snapshot.data;
                    
                    if (session == null) {
                      return const Center(
                        child: Text('No se encontró la sesión'),
                      );
                    }
                    
                    // Inicializar la asistencia si es necesario
                    if (_attendance.isEmpty && !_isLoading) {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      // Cargar asistentes para esta sesión
                      _loadAttendees(session);
                      
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fecha: ${session.scheduledDate.day}/${session.scheduledDate.month}/${session.scheduledDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Asistentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildAttendeesListView(),
                          ),
                          if (_attendance.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _saveAttendance(session),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: _isSaving
                                    ? const CircularProgressIndicator()
                                    : const Text('Guardar Asistencia'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withAlpha(90),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendeesListView() {
    if (_attendance.isEmpty) {
      return const Center(
        child: Text('No hay atletas asignados a esta sesión'),
      );
    }
    
    final sortedKeys = _attendance.keys.toList()..sort();
    
    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final athleteId = sortedKeys[index];
        final isPresent = _attendance[athleteId] ?? false;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent ? Colors.green : Colors.grey,
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: FutureBuilder<User?>(
              future: ref.read(userServiceProvider).getUserById(athleteId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Cargando...');
                }
                return Text(snapshot.data?.name ?? 'Atleta $athleteId');
              },
            ),
            trailing: Switch(
              value: isPresent,
              onChanged: (value) {
                setState(() {
                  _attendance[athleteId] = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  void _loadAttendees(Session session) async {
    // Obtener la lista de atletas de los grupos asignados a la sesión
    if (session.groupIds.isEmpty) {
      setState(() {
        _attendance = {};
        _isLoading = false;
      });
      return;
    }
    
    // Primero, usamos la asistencia guardada si existe
    final existingAttendance = session.attendance;
    
    if (existingAttendance.isNotEmpty) {
      setState(() {
        _attendance = Map<String, bool>.from(existingAttendance);
        _isLoading = false;
      });
    } else {
      // Si no hay asistencia guardada, obtenemos los atletas de los grupos asignados
      try {
        final athleteRepository = ref.read(athleteRepositoryProvider);
        Map<String, bool> attendance = {};
        
        // Para cada grupo en la sesión, obtenemos sus atletas
        for (final groupId in session.groupIds) {
          final athletes = await athleteRepository.getAthletesByGroup(widget.academyId, groupId);
          for (final athlete in athletes) {
            attendance[athlete.id] = false;
          }
        }
        
        if (mounted) {
          setState(() {
            _attendance = attendance;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar atletas: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _saveAttendance(Session session) async {
    if (_attendance.isEmpty) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final sessionService = ref.read(sessionServiceProvider);
      await sessionService.recordAttendance(session.id, _attendance);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia guardada con éxito')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
} 