import 'package:arcinus/features/app/groups/core/services/group_service.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/theme/components/loading/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GroupFormMode { create, edit }

class GroupFormScreen extends ConsumerStatefulWidget {
  final GroupFormMode mode;
  final String? groupId;
  final String academyId;

  const GroupFormScreen({
    super.key,
    required this.mode,
    this.groupId,
    required this.academyId,
  });

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedCoachId;
  List<User> _coaches = [];
  List<User> _allAthletes = [];
  Set<String> _selectedAthleteIds = {};
  
  bool _isLoading = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userService = ref.read(userServiceProvider);
      
      // Cargar entrenadores
      _coaches = await userService.getUsersByRole(
        UserRole.coach, 
        academyId: widget.academyId
      );
      
      // Cargar atletas
      _allAthletes = await userService.getUsersByRole(
        UserRole.athlete, 
        academyId: widget.academyId
      );
      
      // Si estamos en modo edición, cargar datos del grupo
      if (widget.mode == GroupFormMode.edit && widget.groupId != null) {
        await _loadGroupData();
      }
      
      _isInitialized = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadGroupData() async {
    try {
      final groupService = ref.read(groupServiceProvider);
      final group = await groupService.getGroupById(widget.groupId!, widget.academyId);
      
      if (group != null) {
        _nameController.text = group.name;
        if (group.description != null) {
          _descriptionController.text = group.description!;
        }
        
        if (group.coachId != null) {
          _selectedCoachId = group.coachId;
        }
        
        _selectedAthleteIds = Set.from(group.athleteIds);
            }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grupo: $e')),
        );
      }
    }
  }
  
  Future<void> _saveGroup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final groupService = ref.read(groupServiceProvider);
        
        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();
        
        if (widget.mode == GroupFormMode.create) {
          await groupService.createGroup(
            name: name,
            academyId: widget.academyId,
            description: description.isNotEmpty ? description : null,
            coachId: _selectedCoachId,
            athleteIds: _selectedAthleteIds.toList(),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grupo creado correctamente')),
            );
            Navigator.pop(context, true);
          }
        } else if (widget.mode == GroupFormMode.edit && widget.groupId != null) {
          await groupService.updateGroup(
            widget.groupId!,
            {
              'name': name,
              'description': description.isNotEmpty ? description : null,
              'coachId': _selectedCoachId,
              'athleteIds': _selectedAthleteIds.toList(),
            },
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grupo actualizado correctamente')),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar grupo: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mode == GroupFormMode.create 
            ? 'Crear Grupo' 
            : 'Editar Grupo'),
        ),
        body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información básica
                    const Text(
                      'Información del Grupo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    
                    // Entrenador asignado
                    const Text(
                      'Entrenador',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCoachSelector(),
                    const SizedBox(height: 24),
                    
                    // Atletas asignados
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Atletas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedAthleteIds.length} seleccionados',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAthleteList(),
                    const SizedBox(height: 32),
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveGroup,
                        child: Text(
                          widget.mode == GroupFormMode.create 
                            ? 'Crear Grupo' 
                            : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
  
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre del Grupo',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre es obligatorio';
        }
        return null;
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
        hintText: 'Opcional',
      ),
      maxLines: 3,
    );
  }
  
  Widget _buildCoachSelector() {
    if (_coaches.isEmpty) {
      return Card(
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber[700]),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'No hay entrenadores disponibles. Debes crear entrenadores primero.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Seleccionar Entrenador',
        border: OutlineInputBorder(),
        hintText: 'Opcional',
      ),
      value: _selectedCoachId,
      items: [
        const DropdownMenuItem<String>(
          child: Text('Sin entrenador asignado'),
        ),
        ..._coaches.map((coach) {
          return DropdownMenuItem<String>(
            value: coach.id,
            child: Text('${coach.name} (${coach.email})'),
          );
        }),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _selectedCoachId = newValue;
        });
      },
    );
  }
  
  Widget _buildAthleteList() {
    if (_allAthletes.isEmpty) {
      return Card(
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber[700]),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'No hay atletas disponibles. Debes crear atletas primero.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 300,
      child: ListView.builder(
        itemCount: _allAthletes.length,
        itemBuilder: (context, index) {
          final athlete = _allAthletes[index];
          final isSelected = _selectedAthleteIds.contains(athlete.id);
          
          return CheckboxListTile(
            title: Text(athlete.name),
            subtitle: Text(athlete.email),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedAthleteIds.add(athlete.id);
                } else {
                  _selectedAthleteIds.remove(athlete.id);
                }
              });
            },
          );
        },
      ),
    );
  }
} 