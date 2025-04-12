import 'package:arcinus/shared/models/group.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:arcinus/ux/features/groups/services/group_service.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainingFormScreen extends ConsumerStatefulWidget {
  final String academyId;
  final Training? training; // Nulo si es creación, no nulo si es edición
  final bool isTemplate; // Indica si se está creando una plantilla

  const TrainingFormScreen({
    super.key,
    required this.academyId,
    this.training,
    this.isTemplate = false,
  });

  @override
  ConsumerState<TrainingFormScreen> createState() => _TrainingFormScreenState();
}

class _TrainingFormScreenState extends ConsumerState<TrainingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isRecurring = false;
  String _recurrencePattern = 'daily';
  final List<String> _recurrenceDays = [];
  int _recurrenceInterval = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _selectedGroupIds = [];
  final List<String> _selectedCoachIds = [];
  
  Map<String, dynamic> _content = {};

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.training != null) {
      _nameController.text = widget.training!.name;
      _descriptionController.text = widget.training!.description;
      _selectedGroupIds.addAll(widget.training!.groupIds);
      _selectedCoachIds.addAll(widget.training!.coachIds);
      _content = Map<String, dynamic>.from(widget.training!.content);
      
      if (widget.training!.isRecurring) {
        _isRecurring = true;
        if (widget.training!.recurrencePattern != null) {
          _recurrencePattern = widget.training!.recurrencePattern!;
        }
        if (widget.training!.recurrenceDays != null) {
          _recurrenceDays.addAll(widget.training!.recurrenceDays!);
        }
        if (widget.training!.recurrenceInterval != null) {
          _recurrenceInterval = widget.training!.recurrenceInterval!;
        }
      }
      
      _startDate = widget.training!.startDate;
      _endDate = widget.training!.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTraining() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final trainingService = ref.read(trainingServiceProvider);
    final academyId = widget.training?.academyId ?? ref.read(currentAcademyIdProvider) ?? '';
    
    // Obtener datos del usuario actual
    final currentUser = ref.read(authStateProvider).valueOrNull;
    final userID = currentUser?.id ?? 'unknownUser';
    
    if (academyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró una academia activa')),
      );
      return;
    }
    
    final training = Training(
      id: widget.training?.id ?? '',
      academyId: academyId,
      name: _nameController.text,
      description: _descriptionController.text,
      groupIds: _selectedGroupIds,
      coachIds: _selectedCoachIds,
      isTemplate: widget.isTemplate,
      isRecurring: _isRecurring,
      startDate: _isRecurring ? _startDate : null,
      endDate: _isRecurring ? _endDate : null,
      recurrencePattern: _isRecurring ? _recurrencePattern : null,
      recurrenceDays: _isRecurring && _recurrencePattern == 'weekly' ? _recurrenceDays : null,
      recurrenceInterval: _isRecurring ? _recurrenceInterval : null,
      sessionIds: widget.training?.sessionIds,
      createdAt: widget.training?.createdAt ?? DateTime.now(),
      createdBy: widget.training?.createdBy ?? userID,
      updatedAt: widget.training != null ? DateTime.now() : null,
      updatedBy: widget.training != null ? userID : null,
      content: _content,
    );

    try {
      if (widget.training == null) {
        // Creación
        await trainingService.createTraining(training);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenamiento creado con éxito')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Actualización
        await trainingService.updateTraining(training);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenamiento actualizado con éxito')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.training != null;
    
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
                Text(
                  isEditing 
                      ? 'Editar Entrenamiento' 
                      : widget.isTemplate 
                          ? 'Nueva Plantilla' 
                          : 'Nuevo Entrenamiento',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildForm(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _saveTraining,
                    child: Text(isEditing ? 'Actualizar' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Selector de grupos
          _buildGroupSelector(),
          
          const SizedBox(height: 24),
          
          // Selector de entrenadores
          _buildCoachSelector(),
          
          if (!widget.isTemplate) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            
            // Configuración de recurrencia
            SwitchListTile(
              title: const Text('Entrenamiento recurrente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              
              // Patrón de recurrencia
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Patrón de recurrencia',
                  border: OutlineInputBorder(),
                ),
                value: _recurrencePattern,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Diario')),
                  DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recurrencePattern = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Intervalo de recurrencia
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _recurrenceInterval.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Cada',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final interval = int.tryParse(value);
                        if (interval == null || interval < 1) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final interval = int.tryParse(value);
                        if (interval != null && interval > 0) {
                          _recurrenceInterval = interval;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _recurrencePattern == 'daily'
                          ? 'día(s)'
                          : _recurrencePattern == 'weekly'
                              ? 'semana(s)'
                              : 'mes(es)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              
              // Días de la semana para recurrencia semanal
              if (_recurrencePattern == 'weekly') ...[
                const SizedBox(height: 16),
                const Text('Días de la semana:'),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildWeekdayChip('1', 'Lun'),
                    _buildWeekdayChip('2', 'Mar'),
                    _buildWeekdayChip('3', 'Mié'),
                    _buildWeekdayChip('4', 'Jue'),
                    _buildWeekdayChip('5', 'Vie'),
                    _buildWeekdayChip('6', 'Sáb'),
                    _buildWeekdayChip('7', 'Dom'),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Fechas de inicio y fin
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate == null
                              ? 'Seleccionar'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? (_startDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30))),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de fin',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate == null
                              ? 'Seleccionar'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWeekdayChip(String dayValue, String label) {
    final isSelected = _recurrenceDays.contains(dayValue);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _recurrenceDays.add(dayValue);
          } else {
            _recurrenceDays.remove(dayValue);
          }
        });
      },
    );
  }

  Widget _buildGroupSelector() {
    final groupService = ref.watch(groupServiceProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grupos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Group>>(
          future: groupService.getGroupsByAcademy(widget.academyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            final groups = snapshot.data ?? [];
            
            if (groups.isEmpty) {
              return const Text('No hay grupos disponibles');
            }
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups.map((group) {
                final isSelected = _selectedGroupIds.contains(group.id);
                
                return FilterChip(
                  label: Text(group.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGroupIds.add(group.id);
                      } else {
                        _selectedGroupIds.remove(group.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoachSelector() {
    final userService = ref.watch(userServiceProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entrenadores',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<User>>(
          future: userService.getUsersByRole(UserRole.coach, academyId: widget.academyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            final coaches = snapshot.data ?? [];
            
            if (coaches.isEmpty) {
              return const Text('No hay entrenadores disponibles');
            }
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coaches.map((coach) {
                final isSelected = _selectedCoachIds.contains(coach.id);
                
                return FilterChip(
                  label: Text(coach.name),
                  selected: isSelected,
                  avatar: CircleAvatar(
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    child: Text(
                      coach.name.isNotEmpty ? coach.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCoachIds.add(coach.id);
                      } else {
                        _selectedCoachIds.remove(coach.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
} 