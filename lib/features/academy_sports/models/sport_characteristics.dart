import 'package:freezed_annotation/freezed_annotation.dart';

part 'sport_characteristics.freezed.dart';
part 'sport_characteristics.g.dart';

@freezed
class SportCharacteristics with _$SportCharacteristics {
  const factory SportCharacteristics({
    // Características del atleta
    required List<String> athleteStats,
    required Map<String, String> statUnits,
    required List<String> athleteSpecializations,
    
    // Características del equipo
    required List<String> positions,
    required Map<String, List<String>> formations,
    required int defaultPlayersPerTeam,
    
    // Características de entrenamiento
    required List<String> exerciseCategories,
    required List<String> predefinedExercises,
    required List<String> equipmentNeeded,
    
    // Características de partidos/competencias
    required Map<String, dynamic> matchRules,
    required List<String> scoreTypes,
    required Map<String, dynamic> foulTypes,
    
    // Otros parámetros específicos del deporte
    required Map<String, dynamic> additionalParams,
  }) = _SportCharacteristics;

  factory SportCharacteristics.fromJson(Map<String, dynamic> json) => 
      _$SportCharacteristicsFromJson(json);
  
  /// Obtiene las características para un deporte específico basado en su código
  static SportCharacteristics forSport(String sportCode) {
    switch (sportCode.toLowerCase()) {
      case 'baloncesto':
      case 'basketball':
        return SportCharacteristics.basketball();
      case 'voleibol':
      case 'volleyball':
        return SportCharacteristics.volleyball();
      case 'patinaje':
      case 'skating':
        return SportCharacteristics.skating();
      case 'futbol':
      case 'football':
      case 'soccer':
        return SportCharacteristics.soccer();
      case 'futsal':
      case 'futbol_sala':
      case 'futbol_salon':
        return SportCharacteristics.futsala();
      default:
        throw Exception('Deporte no soportado: $sportCode');
    }
  }
      
  // Valores predefinidos por deporte
  factory SportCharacteristics.basketball() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'envergadura', 'salto_vertical', 'resistencia',
      'puntos_por_partido', 'rebotes', 
      'asistencias', 'robos', 'tapones', 'eficiencia_tiro'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'envergadura': 'cm',
      'salto_vertical': 'cm',
      'resistencia': 'nivel',
      'puntos_por_partido': 'pts',
      'eficiencia_tiro': '%'
    },
    athleteSpecializations: [
      'tirador', 'defensa', 'juego_interior', 'playmaker', 'reboteador'
    ],
    positions: [
      'Base (PG)', 'Escolta (SG)', 'Alero (SF)', 'Ala-Pívot (PF)', 'Pívot (C)'
    ],
    formations: {
      '2-3': ['PG', 'SG', 'SF', 'PF', 'C'],
      '3-2': ['PG', 'SG', 'SF', 'PF', 'C'],
      '1-3-1': ['PG', 'SG', 'SF', 'PF', 'C']
    },
    defaultPlayersPerTeam: 5,
    exerciseCategories: [
      'tiro', 'pase', 'bote', 'defensa', 'rebote', 'acondicionamiento', 'táctica'
    ],
    predefinedExercises: [
      'tiros_libres', 'tiro_de_3', 'dribling', 'ejercicio_pase_pecho', 
      'defensa_individual', 'rebote_ofensivo', 'contraataque'
    ],
    equipmentNeeded: [
      'balón', 'canasta', 'conos', 'silbato', 'cronómetro', 'pizarra'
    ],
    matchRules: {
      'periodos': 4,
      'minutos_por_periodo': 10,
      'tiempo_extra': 5,
      'tiempos_muertos': 2,
      'bonus_faltas': 5
    },
    scoreTypes: [
      'tiro_libre (1pt)', 'tiro_de_campo (2pts)', 'triple (3pts)'
    ],
    foulTypes: {
      'personal': 'Contacto ilegal con un oponente',
      'técnica': 'Conducta antideportiva',
      'antideportiva': 'Contacto excesivo sin intención de jugar el balón',
      'descalificante': 'Falta grave que lleva a expulsión'
    },
    additionalParams: {
      'regla_24_segundos': true,
      'regla_8_segundos': true,
      'regla_3_segundos': true
    }
  );
  
  factory SportCharacteristics.volleyball() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'alcance_vertical', 'resistencia', 
      'aces', 'bloqueos', 'ataques_exitosos', 'recepciones', 'defensa'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'alcance_vertical': 'cm',
      'resistencia': 'nivel',
      'eficiencia_saque': '%'
    },
    athleteSpecializations: [
      'armador', 'opuesto', 'central', 'receptor', 'líbero'
    ],
    positions: [
      'Armador (S)', 'Opuesto (O)', 'Central (MB)', 'Receptor (OH)', 'Líbero (L)'
    ],
    formations: {
      '5-1': ['S', 'O', 'MB', 'MB', 'OH', 'OH'],
      '4-2': ['S', 'O', 'MB', 'MB', 'OH', 'OH'],
      '6-2': ['S', 'O', 'MB', 'MB', 'OH', 'OH']
    },
    defaultPlayersPerTeam: 6,
    exerciseCategories: [
      'saque', 'recepción', 'colocación', 'ataque', 'bloqueo', 'defensa', 'acondicionamiento'
    ],
    predefinedExercises: [
      'saque_flotante', 'saque_potencia', 'recepción_antebrazo', 
      'colocación_dedos', 'remate_diagonal', 'bloqueo_individual', 'defensa_libero'
    ],
    equipmentNeeded: [
      'balón', 'red', 'postes', 'silbato', 'cronómetro', 'pizarra'
    ],
    matchRules: {
      'sets': 5,
      'puntos_por_set': 25,
      'puntos_último_set': 15,
      'diferencia_para_ganar': 2,
      'tiempos_muertos': 2,
      'cambios_por_set': 6
    },
    scoreTypes: [
      'punto_directo', 'punto_error_rival'
    ],
    foulTypes: {
      'rotación': 'Error en el orden de rotación',
      'doble_golpe': 'Contacto consecutivo por el mismo jugador',
      'toque_red': 'Contacto con la red',
      'invasión': 'Pisar la línea central bajo la red'
    },
    additionalParams: {
      'sistema_rally_point': true,
      'líbero_permitido': true,
      'regla_back_row_attack': true
    }
  );
  
  factory SportCharacteristics.skating() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'flexibilidad', 'equilibrio', 'resistencia', 
      'velocidad', 'técnica', 'expresión_artística'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'flexibilidad': 'grados',
      'equilibrio': 'nivel',
      'resistencia': 'nivel',
      'velocidad': 'km/h'
    },
    athleteSpecializations: [
      'velocidad', 'artístico', 'freestyle', 'slalom', 'saltos'
    ],
    positions: [
      'No aplica'
    ],
    formations: {
      'individual': ['patinador'],
      'pareja': ['patinador 1', 'patinador 2'],
      'grupo': ['patinador 1', 'patinador 2', 'patinador 3', 'patinador 4']
    },
    defaultPlayersPerTeam: 1,
    exerciseCategories: [
      'técnica_básica', 'equilibrio', 'velocidad', 'giros', 'saltos', 'coreografía', 'resistencia'
    ],
    predefinedExercises: [
      'postura_básica', 'cruce_adelante', 'cruce_atrás', 'frenado', 
      'giro_dos_pies', 'giro_un_pie', 'salto_básico', 'ángel', 'línea_recta'
    ],
    equipmentNeeded: [
      'patines', 'protecciones', 'conos', 'cronómetro', 'música', 'pista'
    ],
    matchRules: {
      'tiempo_programa_corto': 2.5,
      'tiempo_programa_largo': 4,
      'elementos_técnicos_requeridos': 8,
      'calentamiento_minutos': 6
    },
    scoreTypes: [
      'puntuación_técnica', 'puntuación_componentes', 'deducciones'
    ],
    foulTypes: {
      'caída': 'Deducción por caída durante la ejecución',
      'tiempo_excedido': 'Programa más largo del permitido',
      'vestuario_inapropiado': 'Vestuario no acorde a las reglas',
      'música_inapropiada': 'Música con letra cuando no está permitida'
    },
    additionalParams: {
      'sistema_calificación_isu': true,
      'niveles_dificultad': 4,
      'factor_programa_largo': 2.0
    }
  );
  
  factory SportCharacteristics.soccer() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'velocidad', 'resistencia', 'fuerza', 
      'goles', 'asistencias', 'pases_completados', 'recuperaciones', 'intercepciones'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'velocidad': 'km/h',
      'resistencia': 'nivel',
      'precisión_pase': '%',
      'precisión_tiro': '%'
    },
    athleteSpecializations: [
      'finalizador', 'pasador', 'regateador', 'defensor', 'portero'
    ],
    positions: [
      'Portero (GK)', 'Defensa Central (CB)', 'Lateral Derecho (RB)', 'Lateral Izquierdo (LB)',
      'Mediocentro Defensivo (CDM)', 'Mediocentro (CM)', 'Mediocentro Ofensivo (CAM)',
      'Extremo Derecho (RW)', 'Extremo Izquierdo (LW)', 'Delantero Centro (ST)'
    ],
    formations: {
      '4-3-3': ['GK', 'RB', 'CB', 'CB', 'LB', 'CDM', 'CM', 'CM', 'RW', 'ST', 'LW'],
      '4-4-2': ['GK', 'RB', 'CB', 'CB', 'LB', 'RM', 'CM', 'CM', 'LM', 'ST', 'ST'],
      '3-5-2': ['GK', 'CB', 'CB', 'CB', 'RM', 'CDM', 'CM', 'CM', 'LM', 'ST', 'ST']
    },
    defaultPlayersPerTeam: 11,
    exerciseCategories: [
      'técnica', 'táctico', 'físico', 'psicológico', 'set_pieces'
    ],
    predefinedExercises: [
      'pases_cortos', 'pases_largos', 'control', 'conducción', 'finalizaciones', 
      'centros', 'rondos', 'posesión', 'pressing', 'contraataque', 'defensa_en_zona'
    ],
    equipmentNeeded: [
      'balón', 'conos', 'petos', 'portería', 'escaleras_agilidad', 'vallas', 'silbato'
    ],
    matchRules: {
      'tiempo_por_mitad': 45,
      'descanso': 15,
      'tiempo_extra': 30,
      'sustituciones': 5
    },
    scoreTypes: [
      'gol'
    ],
    foulTypes: {
      'falta': 'Infracción de las reglas del juego',
      'tarjeta_amarilla': 'Advertencia formal',
      'tarjeta_roja': 'Expulsión del partido',
      'fuera_de_juego': 'Posición adelantada ilegal'
    },
    additionalParams: {
      'fuera_de_juego': true,
      'var': true,
      'gol_visitante': false,
      'regla_cesión': true
    }
  );
  
  factory SportCharacteristics.futsala() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'velocidad', 'resistencia', 'agilidad', 
      'goles', 'asistencias', 'pases_completados', 'recuperaciones', 'técnica'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'velocidad': 'km/h',
      'resistencia': 'nivel',
      'precisión_pase': '%',
      'precisión_tiro': '%'
    },
    athleteSpecializations: [
      'finalizador', 'pasador', 'regateador', 'defensor', 'portero', 'pivote'
    ],
    positions: [
      'Portero (GK)', 'Cierre (DF)', 'Ala Derecho (RW)', 'Ala Izquierdo (LW)', 'Pivote (PV)'
    ],
    formations: {
      '1-2-1': ['GK', 'DF', 'RW', 'LW', 'PV'],
      '2-2': ['GK', 'DF', 'DF', 'RW', 'LW'],
      '3-1': ['GK', 'DF', 'RW', 'LW', 'PV']
    },
    defaultPlayersPerTeam: 5,
    exerciseCategories: [
      'técnica', 'táctico', 'físico', 'psicológico', 'set_pieces'
    ],
    predefinedExercises: [
      'pases_rápidos', 'control_rápido', 'finalizaciones', 'transiciones', 
      'pressing', 'contraataque', 'defensa_en_zona', 'juego_de_pivote'
    ],
    equipmentNeeded: [
      'balón_futsal', 'conos', 'petos', 'portería_futsal', 'silbato', 'cronómetro'
    ],
    matchRules: {
      'tiempo_por_mitad': 20,
      'descanso': 10,
      'tiempo_extra': 10,
      'tiempos_muertos': 1,
      'faltas_acumulativas': 5
    },
    scoreTypes: [
      'gol'
    ],
    foulTypes: {
      'falta': 'Infracción de las reglas del juego',
      'tarjeta_amarilla': 'Advertencia formal',
      'tarjeta_roja': 'Expulsión del partido',
      'falta_acumulativa': 'Falta que suma al conteo por periodo',
      'doble_penalti': 'Tiro desde 10 metros tras 5 faltas acumulativas'
    },
    additionalParams: {
      'portero_jugador': true,
      'saque_banda_pie': true,
      'tiempo_parado': true,
      'regla_4_segundos': true
    }
  );
} 