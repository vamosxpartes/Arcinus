import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/groups/core/models/group_model.dart';
import 'package:arcinus/features/app/groups/core/services/group_service.dart';
import 'package:arcinus/features/app/sports/core/models/sport_characteristics.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/theme/components/feedback/empty_state.dart';
import 'package:arcinus/features/theme/components/feedback/error_display.dart';
import 'package:arcinus/features/theme/components/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamFormationScreen extends ConsumerStatefulWidget {
  final String groupId;
  
  const TeamFormationScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<TeamFormationScreen> createState() => _TeamFormationScreenState();
}

class _TeamFormationScreenState extends ConsumerState<TeamFormationScreen> {
  Group? _group;
  List<User> _athletes = [];
  bool _isLoading = true;
  String? _errorMsg;
  String _selectedFormation = '';
  Map<String, User?> _assignedPositions = {};
  
  SportCharacteristics? _sportCharacteristics;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    
    try {
      final groupService = ref.read(groupServiceProvider);
      final userService = ref.read(userServiceProvider);
      final currentAcademy = ref.read(currentAcademyProvider);
      
      // Cargar el grupo
      _group = await groupService.getGroup(widget.groupId);
      
      if (_group == null) {
        throw Exception('No se pudo cargar el grupo');
      }
      
      // Cargar atletas del grupo
      if (_group!.athleteIds.isNotEmpty) {
        _athletes = await userService.getUsersByIds(_group!.athleteIds);
      }
      
      // Cargar características del deporte
      if (currentAcademy != null) {
        try {
          _sportCharacteristics = SportCharacteristics.forSport(currentAcademy.academySport);
          
          // Inicializar formación seleccionada con la primera disponible
          if (_sportCharacteristics!.formations.isNotEmpty) {
            _selectedFormation = _sportCharacteristics!.formations.keys.first;
            
            // Inicializar posiciones vacías
            final positions = _sportCharacteristics!.formations[_selectedFormation] ?? [];
            for (var position in positions) {
              _assignedPositions[position] = null;
            }
          }
          
          // Cargar formación guardada si existe
          if (_group!.formationData != null && 
              _group!.formationData!.containsKey('currentFormation')) {
            final savedFormation = _group!.formationData!['currentFormation'] as String?;
            final savedAssignments = _group!.formationData!['positionAssignments'] as Map<String, dynamic>?;
            
            if (savedFormation != null && 
                _sportCharacteristics!.formations.containsKey(savedFormation)) {
              _selectedFormation = savedFormation;
              
              // Cargar asignaciones guardadas
              if (savedAssignments != null) {
                _assignedPositions = {};
                final positions = _sportCharacteristics!.formations[_selectedFormation] ?? [];
                
                for (var position in positions) {
                  final athleteId = savedAssignments[position] as String?;
                  if (athleteId != null) {
                    final athlete = _athletes.where((a) => a.id == athleteId).firstOrNull;
                    _assignedPositions[position] = athlete;
                  } else {
                    _assignedPositions[position] = null;
                  }
                }
              }
            }
          }
        } catch (e) {
          developer.log('Error cargando características deportivas: $e');
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error cargando datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveFormation() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    
    try {
      final groupService = ref.read(groupServiceProvider);
      
      // Convertir asignaciones a formato para guardar
      final Map<String, String> positionAssignments = {};
      _assignedPositions.forEach((position, athlete) {
        if (athlete != null) {
          positionAssignments[position] = athlete.id;
        }
      });
      
      // Actualizar formationData
      final formationData = {
        'currentFormation': _selectedFormation,
        'positionAssignments': positionAssignments,
      };
      
      // Guardar en Firestore
      await groupService.updateGroup(
        _group!.id,
        {'formationData': formationData},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formación guardada correctamente')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error guardando formación: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }
    
    if (_errorMsg != null) {
      return Scaffold(body: ErrorDisplay(error: _errorMsg!));
    }
    
    if (_sportCharacteristics == null || _sportCharacteristics!.formations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Formación del Equipo',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const EmptyState(
          icon: Icons.sports_soccer,
          message: 'No hay formaciones disponibles',
          suggestion: 'Este deporte no tiene formaciones configuradas o no se ha seleccionado un deporte.',
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: Text(
          'Formación: ${_group?.name ?? ""}',
          style: const TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFFFFFFFF)),
            onPressed: _saveFormation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de formación
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleccionar Formación',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sportCharacteristics!.formations.keys.map((formation) {
                      final isSelected = _selectedFormation == formation;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(formation),
                          selected: isSelected,
                          selectedColor: const Color(0xFFa00c30), // Embers
                          backgroundColor: const Color(0xFF323232), // Medium Gray
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF8A8A8A),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFormation = formation;
                                
                                // Reiniciar asignaciones al cambiar formación
                                _assignedPositions = {};
                                final positions = _sportCharacteristics!.formations[formation] ?? [];
                                for (var position in positions) {
                                  _assignedPositions[position] = null;
                                }
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Campo de juego
          Expanded(
            child: _buildFormationField(),
          ),
          
          // Lista de atletas disponibles
          Container(
            height: 100,
            color: const Color(0xFF1E1E1E),
            child: _athletes.isEmpty
                ? const Center(
                    child: Text(
                      'No hay atletas en este grupo',
                      style: TextStyle(color: Color(0xFF8A8A8A)),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _athletes.length,
                    itemBuilder: (context, index) {
                      final athlete = _athletes[index];
                      final isAssigned = _assignedPositions.values.contains(athlete);
                      
                      return Draggable<User>(
                        data: athlete,
                        feedback: _buildAthleteBadge(athlete, size: 60, isAssigned: isAssigned),
                        childWhenDragging: _buildAthleteBadge(athlete, isGhost: true, isAssigned: isAssigned),
                        child: _buildAthleteBadge(athlete, isAssigned: isAssigned),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormationField() {
    final formationPositions = _sportCharacteristics!.formations[_selectedFormation] ?? [];
    
    // Determinar el tipo de deporte para diseñar el campo
    final sportCode = ref.read(currentAcademyProvider)?.academySport.toLowerCase() ?? '';
    
    // Elegir fondo según el deporte
    String backgroundImage;
    if (sportCode.contains('futbol') || sportCode.contains('soccer')) {
      backgroundImage = 'assets/images/soccer_field.png';
    } else if (sportCode.contains('baloncesto') || sportCode.contains('basketball')) {
      backgroundImage = 'assets/images/basketball_court.png';
    } else if (sportCode.contains('voleibol') || sportCode.contains('volleyball')) {
      backgroundImage = 'assets/images/volleyball_court.png';
    } else {
      backgroundImage = 'assets/images/generic_field.png';
    }
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF094909), // Verde campo
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          opacity: 0.4, // Semitransparente para ver las posiciones
        ),
      ),
      child: Stack(
        children: [
          // Posiciones basadas en la formación seleccionada
          ...formationPositions.map((position) {
            // Calcular posición basada en el tipo de formación y deporte
            final positionOffset = _calculatePositionOffset(
              position, 
              formationPositions.length, 
              sportCode
            );
            
            return Positioned(
              left: positionOffset.dx,
              top: positionOffset.dy,
              child: DragTarget<User>(
                builder: (context, candidateData, rejectedData) {
                  final hasCandidate = candidateData.isNotEmpty;
                  final assignedAthlete = _assignedPositions[position];
                  
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: hasCandidate
                              ? const Color(0xFFa00c30).withAlpha(200) // Embers cuando hay candidato
                              : assignedAthlete != null
                                  ? const Color(0xFF0C53A0).withAlpha(200) // Azul cuando hay asignado
                                  : const Color(0xFF323232).withAlpha(200), // Medium Gray por defecto
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasCandidate
                                ? const Color(0xFFFF0000) // Borde rojo al arrastrar
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: assignedAthlete != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (assignedAthlete.number != null)
                                      Text(
                                        '#${assignedAthlete.number}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      assignedAthlete.name.split(' ').first,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )
                            : const Icon(
                                Icons.person_add,
                                color: Colors.white54,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          position,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                onAcceptWithDetails: (details) {
                  final athlete = details.data;
                  setState(() {
                    // Eliminar atleta si ya estaba asignado a otra posición
                    _assignedPositions.forEach((pos, user) {
                      if (user?.id == athlete.id) {
                        _assignedPositions[pos] = null;
                      }
                    });
                    
                    // Asignar a nueva posición
                    _assignedPositions[position] = athlete;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildAthleteBadge(User athlete, {double size = 70, bool isGhost = false, bool isAssigned = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isGhost
            ? Colors.grey.withAlpha(90)
            : isAssigned
                ? const Color(0xFF0C53A0).withAlpha(180) // Azul cuando ya está asignado
                : const Color(0xFFa00c30).withAlpha(180), // Embers por defecto
        shape: BoxShape.circle,
        border: Border.all(
          color: isGhost ? Colors.grey.withAlpha(90) : Colors.white,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (athlete.number != null)
            Text(
              '#${athlete.number}',
              style: TextStyle(
                color: isGhost ? Colors.grey.withAlpha(90) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size > 60 ? 16 : 14,
              ),
            ),
          Text(
            athlete.name.split(' ')[0],
            style: TextStyle(
              color: isGhost ? Colors.grey.withAlpha(90) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size > 60 ? 14 : 12,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Offset _calculatePositionOffset(String position, int totalPositions, String sportCode) {
    // Posiciones predefinidas según el deporte y la formación
    
    // Fútbol/Soccer - sistema típico de posiciones
    if (sportCode.contains('futbol') || sportCode.contains('soccer') || sportCode.contains('football')) {
      // Mapa de posiciones comunes en soccer/football
      final Map<String, Offset> soccerPositions = {
        'GK': const Offset(0.5, 0.9), // Portero
        'CB': const Offset(0.5, 0.75), // Defensa central
        'LB': const Offset(0.2, 0.75), // Lateral izquierdo
        'RB': const Offset(0.8, 0.75), // Lateral derecho
        'CDM': const Offset(0.5, 0.6), // Mediocentro defensivo
        'CM': const Offset(0.5, 0.5), // Mediocentro
        'LM': const Offset(0.2, 0.5), // Medio izquierdo
        'RM': const Offset(0.8, 0.5), // Medio derecho
        'CAM': const Offset(0.5, 0.4), // Mediocentro ofensivo
        'LW': const Offset(0.2, 0.25), // Extremo izquierdo
        'RW': const Offset(0.8, 0.25), // Extremo derecho
        'ST': const Offset(0.5, 0.15), // Delantero centro
      };
      
      // Si la posición está en el mapa, usarla
      if (soccerPositions.containsKey(position)) {
        final screenSize = MediaQuery.of(context).size;
        final fieldWidth = screenSize.width - 32; // Restar márgenes
        final fieldHeight = screenSize.height - 250; // Restar header, selector y lista de atletas
        
        final offset = soccerPositions[position]!;
        return Offset(
          offset.dx * fieldWidth - 30, // Centrar en la posición (ancho del círculo = 60)
          offset.dy * fieldHeight - 30, // Centrar en la posición
        );
      }
    }
    
    // Baloncesto/Basketball - sistema típico de posiciones
    if (sportCode.contains('baloncesto') || sportCode.contains('basketball')) {
      final Map<String, Offset> basketballPositions = {
        'PG': const Offset(0.5, 0.8), // Base
        'SG': const Offset(0.8, 0.6), // Escolta
        'SF': const Offset(0.2, 0.6), // Alero
        'PF': const Offset(0.7, 0.3), // Ala-Pívot
        'C': const Offset(0.3, 0.3), // Pívot
      };
      
      if (basketballPositions.containsKey(position)) {
        final screenSize = MediaQuery.of(context).size;
        final fieldWidth = screenSize.width - 32;
        final fieldHeight = screenSize.height - 250;
        
        final offset = basketballPositions[position]!;
        return Offset(
          offset.dx * fieldWidth - 30,
          offset.dy * fieldHeight - 30,
        );
      }
    }
    
    // Voleibol/Volleyball - sistema típico de posiciones
    if (sportCode.contains('voleibol') || sportCode.contains('volleyball')) {
      final Map<String, Offset> volleyballPositions = {
        'S': const Offset(0.5, 0.7), // Armador
        'O': const Offset(0.8, 0.3), // Opuesto
        'MB': const Offset(0.35, 0.3), // Central
        'OH': const Offset(0.2, 0.7), // Receptor
        'L': const Offset(0.65, 0.7), // Líbero
      };
      
      if (volleyballPositions.containsKey(position)) {
        final screenSize = MediaQuery.of(context).size;
        final fieldWidth = screenSize.width - 32;
        final fieldHeight = screenSize.height - 250;
        
        final offset = volleyballPositions[position]!;
        return Offset(
          offset.dx * fieldWidth - 30,
          offset.dy * fieldHeight - 30,
        );
      }
    }
    
    // Futsal - sistema típico de posiciones
    if (sportCode.contains('futsal') || sportCode.contains('sala')) {
      final Map<String, Offset> futsalPositions = {
        'GK': const Offset(0.5, 0.85), // Portero
        'DF': const Offset(0.5, 0.7), // Defensa/Cierre
        'LW': const Offset(0.2, 0.4), // Ala izquierdo
        'RW': const Offset(0.8, 0.4), // Ala derecho
        'PV': const Offset(0.5, 0.2), // Pívot
      };
      
      if (futsalPositions.containsKey(position)) {
        final screenSize = MediaQuery.of(context).size;
        final fieldWidth = screenSize.width - 32;
        final fieldHeight = screenSize.height - 250;
        
        final offset = futsalPositions[position]!;
        return Offset(
          offset.dx * fieldWidth - 30,
          offset.dy * fieldHeight - 30,
        );
      }
    }
    
    // Si no hay posición predefinida, distribuir uniformemente
    final screenSize = MediaQuery.of(context).size;
    final fieldWidth = screenSize.width - 32;
    final fieldHeight = screenSize.height - 250;
    
    final index = _sportCharacteristics!.formations[_selectedFormation]!.indexOf(position);
    final rowCount = totalPositions < 6 ? 2 : 3;
    final colCount = (totalPositions / rowCount).ceil();
    
    final row = index ~/ colCount;
    final col = index % colCount;
    
    final cellWidth = fieldWidth / colCount;
    final cellHeight = fieldHeight / rowCount;
    
    return Offset(
      (col + 0.5) * cellWidth - 30,
      (row + 0.5) * cellHeight - 30,
    );
  }
} 