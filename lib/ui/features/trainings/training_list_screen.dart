import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainingListScreen extends ConsumerStatefulWidget {
  final String academyId;

  const TrainingListScreen({
    super.key,
    required this.academyId,
  });

  @override
  ConsumerState<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends ConsumerState<TrainingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Entrenamientos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildAddTrainingButton(context),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Activos'),
              Tab(text: 'Plantillas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrainingList(false),
                _buildTrainingList(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTrainingButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.add),
      onSelected: (value) {
        switch (value) {
          case 'training':
            Navigator.pushNamed(context, '/trainings/new');
            break;
          case 'template':
            Navigator.pushNamed(context, '/trainings/template/new');
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'training',
          child: Row(
            children: [
              Icon(Icons.fitness_center),
              SizedBox(width: 8),
              Text('Nuevo Entrenamiento'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'template',
          child: Row(
            children: [
              Icon(Icons.content_copy),
              SizedBox(width: 8),
              Text('Nueva Plantilla'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingList(bool isTemplate) {
    final trainingService = ref.watch(trainingServiceProvider);
    
    return isTemplate
      ? StreamBuilder<List<Training>>(
          stream: trainingService.getTrainingTemplates(widget.academyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final templates = snapshot.data ?? [];
            
            if (templates.isEmpty) {
              return const Center(
                child: Text('No hay plantillas de entrenamiento disponibles'),
              );
            }
            
            return ListView.builder(
              itemCount: templates.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTrainingCard(template);
              },
            );
          },
        )
      : StreamBuilder<List<Training>>(
          stream: trainingService.getTrainingsByAcademy(widget.academyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final trainings = snapshot.data
                ?.where((training) => !training.isTemplate)
                .toList() ?? [];
            
            if (trainings.isEmpty) {
              return const Center(
                child: Text('No hay entrenamientos activos'),
              );
            }
            
            return ListView.builder(
              itemCount: trainings.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final training = trainings[index];
                return _buildTrainingCard(training);
              },
            );
          },
        );
  }

  Widget _buildTrainingCard(Training training) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (training.isTemplate) {
            _showTemplateOptionsDialog(training);
          } else {
            Navigator.pushNamed(
              context, 
              '/trainings/sessions',
              arguments: training.id,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      training.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (training.isTemplate)
                    Chip(
                      label: const Text('Plantilla'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  if (training.isRecurring)
                    Chip(
                      label: const Text('Recurrente'),
                      backgroundColor: Colors.green.shade100,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                training.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.group,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${training.groupIds.length} grupos',
                    style: TextStyle(
                      fontSize: 12,
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
                    '${training.coachIds.length} entrenadores',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (training.sessionIds != null && training.sessionIds!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${training.sessionIds!.length} sesiones',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplateOptionsDialog(Training template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Plantilla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Usar como entrenamiento'),
              onTap: () {
                Navigator.pop(context);
                
                // Crear una copia de la plantilla para usarla como base para un nuevo entrenamiento
                final currentUser = ref.read(authStateProvider).valueOrNull;
                
                // Crear un nuevo entrenamiento basado en la plantilla pero sin configuración de recurrencia
                final newTraining = template.copyWith(
                  id: '', // ID vacío para que se cree uno nuevo
                  isTemplate: false, // Ya no es una plantilla
                  sessionIds: [], // Sin sesiones asociadas
                  createdAt: DateTime.now(),
                  createdBy: currentUser?.id ?? 'unknownUser',
                  updatedAt: null,
                  updatedBy: null,
                  // Mantenemos el contenido, grupos, entrenadores, etc. de la plantilla
                );
                
                // Navegar a la pantalla de edición con el nuevo entrenamiento como base
                Navigator.pushNamed(
                  context,
                  '/trainings/new',
                  arguments: {'training': newTraining, 'isTemplate': false},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar plantilla'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/trainings/edit',
                  arguments: template,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
} 