import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/sports/core/models/sport_characteristics.dart';
import 'package:arcinus/features/app/users/athlete/core/models/athlete_profile.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/theme/components/feedback/empty_state.dart';
import 'package:arcinus/features/theme/components/feedback/error_display.dart';
import 'package:arcinus/features/theme/components/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AthleteProfileScreen extends ConsumerStatefulWidget {
  final String athleteId;
  final String? academyId;

  const AthleteProfileScreen({
    super.key,
    required this.athleteId,
    this.academyId,
  });

  @override
  ConsumerState<AthleteProfileScreen> createState() => _AthleteProfileScreenState();
}

class _AthleteProfileScreenState extends ConsumerState<AthleteProfileScreen> {
  User? _user;
  AthleteProfile? _profile;
  Academy? _academy;
  bool _isLoading = true;
  String? _errorMsg;
  SportCharacteristics? _sportCharacteristics;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
  }

  Future<void> _loadAthleteData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = widget.academyId ?? currentAcademy?.id;
      
      if (academyId == null) {
        throw Exception('No se ha seleccionado una academia');
      }
      
      final userService = ref.read(userServiceProvider);
      final result = await userService.getAthleteWithProfile(widget.athleteId, academyId);
      
      _user = result['user'] as User;
      _profile = result['profile'] as AthleteProfile?;
      _academy = currentAcademy;

      if (_user == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // Cargar características específicas del deporte
      if (_academy != null) {
        try {
          _sportCharacteristics = SportCharacteristics.forSport(_academy!.sport);
        } catch (e) {
          // Si el deporte no está soportado, no mostramos características específicas
          developer.log('Deporte no soportado: ${_academy!.sport}');
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al cargar datos: $e';
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

    if (_user == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.person_off,
          message: 'Atleta no encontrado',
          suggestion: 'Verifique el ID del atleta e intente de nuevo',
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: Text(
          'Perfil de ${_user!.name}',
          style: const TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFFFFFFF)),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/athletes/edit',
                arguments: {
                  'userId': _user!.id,
                  'academyId': _academy?.id,
                },
              ).then((_) => _loadAthleteData());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAthleteData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildSportSpecificInfo(),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildMedicalInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF1E1E1E),
            child: Icon(
              Icons.person,
              size: 80,
              color: Color(0xFFa00c30), // Embers
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF), // Magnolia White
            ),
          ),
          Text(
            _user!.email,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8A8A8A), // Light Gray
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    final age = _profile?.birthDate != null
        ? DateTime.now().difference(_profile!.birthDate!).inDays ~/ 365
        : null;

    return Card(
      color: const Color(0xFF1E1E1E), // Dark Gray
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF), // Magnolia White
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Edad',
              age != null ? '$age años' : 'No especificada',
              Icons.cake,
            ),
            _buildInfoRow(
              'Altura',
              _profile?.height != null ? '${_profile!.height} cm' : 'No especificada',
              Icons.height,
            ),
            _buildInfoRow(
              'Peso',
              _profile?.weight != null ? '${_profile!.weight} kg' : 'No especificado',
              Icons.fitness_center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportSpecificInfo() {
    if (_sportCharacteristics == null || _profile == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF1E1E1E), // Dark Gray
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de ${_academy?.sport ?? "Deporte"}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF), // Magnolia White
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Posición',
              _profile?.position ?? 'No especificada',
              Icons.sports,
            ),
            const SizedBox(height: 8),
            const Text(
              'Especializaciones',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8A8A8A), // Light Gray
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_profile?.specializations ?? []).isEmpty
                  ? [
                      const Chip(
                        label: Text('No especificadas'),
                        backgroundColor: Color(0xFF323232), // Medium Gray
                        labelStyle: TextStyle(color: Color(0xFF8A8A8A)),
                      )
                    ]
                  : _profile!.specializations!.map((specialization) {
                      return Chip(
                        label: Text(specialization),
                        backgroundColor: const Color(0xFFa00c30), // Embers
                        labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_sportCharacteristics == null || _profile == null) {
      return const SizedBox.shrink();
    }

    final stats = _profile?.stats ?? {};
    final sportStats = _sportCharacteristics!.athleteStats;
    final statUnits = _sportCharacteristics!.statUnits;

    if (stats.isEmpty && sportStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF1E1E1E), // Dark Gray
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF), // Magnolia White
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFFa00c30), // Embers
                  ),
                  onPressed: () {
                    // Navegar a la pantalla de edición de estadísticas
                    Navigator.pushNamed(
                      context,
                      '/athletes/stats/edit',
                      arguments: {
                        'userId': _user!.id,
                        'academyId': _academy?.id,
                        'sportCharacteristics': _sportCharacteristics,
                      },
                    ).then((_) => _loadAthleteData());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              const Text(
                'No hay estadísticas registradas',
                style: TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                ),
              )
            else
              Column(
                children: sportStats.map((statName) {
                  final value = stats[statName];
                  final unit = statUnits[statName] ?? '';
                  
                  if (value == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatStatName(statName),
                            style: const TextStyle(
                              color: Color(0xFF8A8A8A), // Light Gray
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: _normalizeStatValue(value),
                            backgroundColor: const Color(0xFF323232), // Medium Gray
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFa00c30), // Embers
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$value $unit',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF), // Magnolia White
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfo() {
    final medicalInfo = _profile?.medicalInfo;
    
    if (medicalInfo == null || medicalInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF1E1E1E), // Dark Gray
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Color(0xFFa00c30), // Embers
                ),
                SizedBox(width: 8),
                Text(
                  'Información Médica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF), // Magnolia White
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (medicalInfo.containsKey('notes') && medicalInfo['notes'] != null)
              Text(
                medicalInfo['notes'] as String,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF), // Magnolia White
                ),
              )
            else
              const Text(
                'No hay información médica registrada',
                style: TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFa00c30), // Embers
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF8A8A8A), // Light Gray
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFFFFF), // Magnolia White
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Normalizar valor para la barra de progreso (0-1)
  double _normalizeStatValue(dynamic value) {
    if (value is! num) return 0.0;
    
    // Valor entre 0 y 100
    if (value <= 100) {
      return value / 100;
    }
    
    // Para valores grandes (como altura o peso), usar una escala logarítmica
    return (value / 1000).clamp(0.0, 1.0);
  }

  // Formatear nombre de estadística
  String _formatStatName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }
} 