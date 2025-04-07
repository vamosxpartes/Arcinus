import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/trainings/services/session_service.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SessionListScreen extends ConsumerWidget {
  final String trainingId;
  final String academyId;

  const SessionListScreen({
    super.key,
    required this.trainingId,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionService = ref.watch(sessionServiceProvider);
    final trainingService = ref.watch(trainingServiceProvider);
    
    return Scaffold(
      body: Column(
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
                  'Sesiones de Entrenamiento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _AddSessionButton(trainingId: trainingId, academyId: academyId),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<Training>(
              stream: trainingService.getTrainingById(trainingId),
              builder: (context, trainingSnapshot) {
                if (trainingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (trainingSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${trainingSnapshot.error}'),
                  );
                }
                
                final training = trainingSnapshot.data;
                
                if (training == null) {
                  return const Center(
                    child: Text('No se encontró el entrenamiento'),
                  );
                }
                
                return StreamBuilder<List<Session>>(
                  stream: sessionService.getSessionsByTraining(trainingId),
                  builder: (context, sessionsSnapshot) {
                    if (sessionsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (sessionsSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${sessionsSnapshot.error}'),
                      );
                    }
                    
                    final sessions = sessionsSnapshot.data ?? [];
                    
                    if (sessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No hay sesiones programadas',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Crear Sesión'),
                              onPressed: () {
                                // Navegar a la pantalla de creación de sesión
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Ordenar sesiones por fecha
                    sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
                    
                    return ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _SessionCard(
                          session: session,
                          academyId: academyId,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSessionButton extends ConsumerWidget {
  final String trainingId;
  final String academyId;

  const _AddSessionButton({
    required this.trainingId,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingService = ref.watch(trainingServiceProvider);
    
    return StreamBuilder<Training>(
      stream: trainingService.getTrainingById(trainingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        final training = snapshot.data;
        
        if (training == null) {
          return const SizedBox.shrink();
        }
        
        // Si es un entrenamiento recurrente, mostrar botones para crear sesiones recurrentes
        if (training.isRecurring) {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'single',
                child: Text('Crear Sesión Individual'),
              ),
              const PopupMenuItem(
                value: 'recurring',
                child: Text('Generar Sesiones Recurrentes'),
              ),
            ],
            onSelected: (value) {
              if (value == 'single') {
                // Navegar a la pantalla de creación de sesión individual
              } else if (value == 'recurring') {
                // Mostrar diálogo para generar sesiones recurrentes
                _showRecurringSessionDialog(context, ref, training);
              }
            },
          );
        } else {
          // Si no es recurrente, mostrar solo un botón para crear sesión individual
          return FloatingActionButton.small(
            child: const Icon(Icons.add),
            onPressed: () {
              // Navegar a la pantalla de creación de sesión individual
            },
          );
        }
      },
    );
  }

  void _showRecurringSessionDialog(BuildContext context, WidgetRef ref, Training training) {
    DateTime startDate = training.startDate ?? DateTime.now();
    DateTime endDate = training.endDate ?? startDate.add(const Duration(days: 30));
    String name = training.name;
    final nameController = TextEditingController(text: name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Sesiones Recurrentes'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecciona el rango de fechas para generar sesiones:'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha inicio',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              endDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha fin',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre de las sesiones',
                    border: OutlineInputBorder(),
                  ),
                  controller: nameController,
                  onChanged: (value) {
                    name = value;
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final sessionService = ref.read(sessionServiceProvider);
              
              try {
                // Actualizar el nombre desde el controlador
                name = nameController.text;
                
                // Crear sesiones recurrentes
                final currentUser = ref.read(authStateProvider).valueOrNull;
                final userID = currentUser?.id ?? 'unknownUser';
                
                final sessions = await sessionService.createRecurringSessions(
                  training,
                  startDate: startDate,
                  endDate: endDate,
                  name: name,
                  createdBy: userID,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Se han creado ${sessions.length} sesiones'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final Session session;
  final String academyId;

  const _SessionCard({
    required this.session,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navegar a la pantalla de detalles de la sesión
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: session.isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Row(
                children: [
                  Icon(
                    session.isCompleted ? Icons.check_circle : Icons.pending,
                    color: session.isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(session.scheduledDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: session.isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (session.startTime != null)
                    Text(
                      timeFormat.format(session.startTime!),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.groupIds.length} grupos',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.coachIds.length} entrenadores',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (session.isCompleted) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Asistencia: ${session.attendance.values.where((v) => v).length}/${session.attendance.length}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!session.isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Registrar Asistencia'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/trainings/attendance',
                          arguments: session.id,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Completar'),
                      onPressed: () {
                        _showCompleteSessionDialog(context, ref);
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCompleteSessionDialog(BuildContext context, WidgetRef ref) {
    String notes = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Sesión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas marcar esta sesión como completada?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                notes = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final sessionService = ref.read(sessionServiceProvider);
              
              try {
                await sessionService.markSessionAsCompleted(session.id, notes: notes);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión marcada como completada'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }
} 