import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'sport_characteristics.freezed.dart';
part 'sport_characteristics.g.dart';

@freezed
@HiveType(typeId: 0) // Asignar un ID único para Hive
class SportCharacteristics with _$SportCharacteristics {
  const factory SportCharacteristics({
    // Características del atleta
    @HiveField(0) required List<String> athleteStats,
    @HiveField(1) required Map<String, String> statUnits,
    @HiveField(2) required List<String> athleteSpecializations,
    
    // Características del equipo
    @HiveField(3) required List<String> positions,
    @HiveField(4) required Map<String, List<String>> formations,
    @HiveField(5) required int defaultPlayersPerTeam,
    
    // Características de entrenamiento
    @HiveField(6) required List<String> exerciseCategories,
    @HiveField(7) required List<String> predefinedExercises,
    @HiveField(8) required List<String> equipmentNeeded,
    
    // Características de partidos/competencias
    @HiveField(9) required Map<String, dynamic> matchRules,
    @HiveField(10) required List<String> scoreTypes,
    @HiveField(11) required Map<String, dynamic> foulTypes,
    
    // Otros parámetros específicos del deporte
    @HiveField(12) required Map<String, dynamic> additionalParams,
  }) = _SportCharacteristics;

  factory SportCharacteristics.fromJson(Map<String, dynamic> json) => 
      _$SportCharacteristicsFromJson(json);
  
  /// Método seguro para crear desde JSON con validación de tipos
  factory SportCharacteristics.fromJsonSafe(Map<String, dynamic> json) {
    try {
      AppLogger.logInfo(
        'Creando SportCharacteristics desde JSON',
        className: 'SportCharacteristics',
        functionName: 'fromJsonSafe',
        params: {
          'jsonKeys': json.keys.toList(),
          'hasAthleteStats': json.containsKey('athleteStats'),
          'hasPositions': json.containsKey('positions'),
        },
      );

      // Validar y sanitizar listas
      final athleteStats = _sanitizeStringList(json['athleteStats'], 'athleteStats');
      final athleteSpecializations = _sanitizeStringList(json['athleteSpecializations'], 'athleteSpecializations');
      final positions = _sanitizeStringList(json['positions'], 'positions');
      final exerciseCategories = _sanitizeStringList(json['exerciseCategories'], 'exerciseCategories');
      final predefinedExercises = _sanitizeStringList(json['predefinedExercises'], 'predefinedExercises');
      final equipmentNeeded = _sanitizeStringList(json['equipmentNeeded'], 'equipmentNeeded');
      final scoreTypes = _sanitizeStringList(json['scoreTypes'], 'scoreTypes');

      // Validar y sanitizar maps
      final statUnits = _sanitizeStringMap(json['statUnits'], 'statUnits');
      final formations = _sanitizeFormationsMap(json['formations'], 'formations');
      final matchRules = _sanitizeGenericMap(json['matchRules'], 'matchRules');
      final foulTypes = _sanitizeGenericMap(json['foulTypes'], 'foulTypes');
      final additionalParams = _sanitizeGenericMap(json['additionalParams'], 'additionalParams');

      // Validar entero
      final defaultPlayersPerTeam = _sanitizeInt(json['defaultPlayersPerTeam'], 'defaultPlayersPerTeam', 1);

      return SportCharacteristics(
        athleteStats: athleteStats,
        statUnits: statUnits,
        athleteSpecializations: athleteSpecializations,
        positions: positions,
        formations: formations,
        defaultPlayersPerTeam: defaultPlayersPerTeam,
        exerciseCategories: exerciseCategories,
        predefinedExercises: predefinedExercises,
        equipmentNeeded: equipmentNeeded,
        matchRules: matchRules,
        scoreTypes: scoreTypes,
        foulTypes: foulTypes,
        additionalParams: additionalParams,
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error creando SportCharacteristics desde JSON',
        error: e,
        stackTrace: stackTrace,
        className: 'SportCharacteristics',
        functionName: 'fromJsonSafe',
        params: {'json': json}
      );
      
      // Devolver características básicas como fallback
      return const SportCharacteristics(
        athleteStats: ['altura', 'peso'],
        statUnits: {'altura': 'cm', 'peso': 'kg'},
        athleteSpecializations: ['general'],
        positions: ['Jugador'],
        formations: {'básica': ['Jugador']},
        defaultPlayersPerTeam: 1,
        exerciseCategories: ['técnica', 'físico'],
        predefinedExercises: ['calentamiento', 'ejercicio_básico'],
        equipmentNeeded: ['equipamiento_básico'],
        matchRules: {'tiempo': 60},
        scoreTypes: ['punto'],
        foulTypes: {'falta': 'Infracción general'},
        additionalParams: {},
      );
    }
  }

  /// Métodos auxiliares de sanitización
  static List<String> _sanitizeStringList(dynamic value, String fieldName) {
    if (value == null) {
      AppLogger.logWarning(
        'Campo $fieldName es null, usando lista vacía',
        className: 'SportCharacteristics',
        functionName: '_sanitizeStringList'
      );
      return [];
    }
    
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    
    AppLogger.logWarning(
      'Campo $fieldName no es una lista válida: ${value.runtimeType}',
      className: 'SportCharacteristics',
      functionName: '_sanitizeStringList'
    );
    return [];
  }

  static Map<String, String> _sanitizeStringMap(dynamic value, String fieldName) {
    if (value == null) return {};
    
    if (value is Map) {
      final result = <String, String>{};
      value.forEach((key, val) {
        if (key != null && val != null) {
          result[key.toString()] = val.toString();
        }
      });
      return result;
    }
    
    AppLogger.logWarning(
      'Campo $fieldName no es un Map válido: ${value.runtimeType}',
      className: 'SportCharacteristics',
      functionName: '_sanitizeStringMap'
    );
    return {};
  }

  static Map<String, List<String>> _sanitizeFormationsMap(dynamic value, String fieldName) {
    if (value == null) return {};
    
    if (value is Map) {
      final result = <String, List<String>>{};
      value.forEach((key, val) {
        if (key != null) {
          result[key.toString()] = _sanitizeStringList(val, '$fieldName.$key');
        }
      });
      return result;
    }
    
    return {};
  }

  static Map<String, dynamic> _sanitizeGenericMap(dynamic value, String fieldName) {
    if (value == null) return {};
    
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    } else if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((key, val) {
        if (key != null) {
          result[key.toString()] = val;
        }
      });
      return result;
    }
    
    return {};
  }

  static int _sanitizeInt(dynamic value, String fieldName, int defaultValue) {
    if (value == null) return defaultValue;
    
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    
    AppLogger.logWarning(
      'Campo $fieldName no es un entero válido: ${value.runtimeType}, usando $defaultValue',
      className: 'SportCharacteristics',
      functionName: '_sanitizeInt'
    );
    return defaultValue;
  }
      
  /// Obtiene las características para un deporte específico basado en su código
  static SportCharacteristics forSport(String sportCode) {
    try {
      AppLogger.logInfo(
        'Creando características para deporte',
        className: 'SportCharacteristics',
        functionName: 'forSport',
        params: {'sportCode': sportCode}
      );

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
        case 'weightlifting':
        case 'levantamiento_pesas':
        case 'pesas':
        case 'gimnasio':
          return SportCharacteristics.weightlifting();
        default:
          AppLogger.logWarning(
            'Deporte no reconocido, usando configuración básica',
            className: 'SportCharacteristics',
            functionName: 'forSport',
            params: {'sportCode': sportCode}
          );
          return SportCharacteristics.basic(sportCode);
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error creando características para deporte',
        error: e,
        stackTrace: stackTrace,
        className: 'SportCharacteristics',
        functionName: 'forSport',
        params: {'sportCode': sportCode}
      );
      return SportCharacteristics.basic(sportCode);
    }
  }

  /// Características básicas para deportes no reconocidos
  factory SportCharacteristics.basic(String sportCode) => SportCharacteristics(
    athleteStats: ['altura', 'peso', 'resistencia'],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'resistencia': 'nivel',
    },
    athleteSpecializations: ['general'],
    positions: ['Deportista'],
    formations: {'individual': ['Deportista']},
    defaultPlayersPerTeam: 1,
    exerciseCategories: ['técnica', 'físico', 'táctico'],
    predefinedExercises: ['calentamiento', 'acondicionamiento', 'técnica_básica'],
    equipmentNeeded: ['equipamiento_básico'],
    matchRules: {
      'tiempo_total': 60,
      'descansos': 1,
    },
    scoreTypes: ['punto'],
    foulTypes: {
      'falta': 'Infracción de las reglas',
    },
    additionalParams: {
      'deporte_codigo': sportCode,
      'configuracion': 'basica',
    },
  );
      
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

  factory SportCharacteristics.weightlifting() => const SportCharacteristics(
    athleteStats: [
      'altura', 'peso', 'fuerza_maxima', 'potencia', 'resistencia_muscular',
      'porcentaje_grasa_corporal', 'masa_muscular', 'flexibilidad',
      'peso_maximo_sentadilla', 'peso_maximo_press_banca', 'peso_maximo_peso_muerto',
      'peso_maximo_arranque', 'peso_maximo_envion'
    ],
    statUnits: {
      'altura': 'cm',
      'peso': 'kg',
      'fuerza_maxima': 'kg',
      'potencia': 'watts',
      'resistencia_muscular': 'repeticiones',
      'porcentaje_grasa_corporal': '%',
      'masa_muscular': 'kg',
      'flexibilidad': 'cm',
      'peso_maximo_sentadilla': 'kg',
      'peso_maximo_press_banca': 'kg',
      'peso_maximo_peso_muerto': 'kg',
      'peso_maximo_arranque': 'kg',
      'peso_maximo_envion': 'kg'
    },
    athleteSpecializations: [
      'powerlifting', 'halterofilia', 'culturismo', 'fuerza_general', 'crossfit'
    ],
    positions: [
      'No aplica'
    ],
    formations: {
      'individual': ['atleta']
    },
    defaultPlayersPerTeam: 1,
    exerciseCategories: [
      'fuerza_basica', 'powerlifting', 'halterofilia', 'accesorios', 'cardio', 'flexibilidad', 'tecnica'
    ],
    predefinedExercises: [
      'sentadilla', 'press_banca', 'peso_muerto', 'arranque', 'envion', 'cargada',
      'press_militar', 'dominadas', 'fondos', 'remo_con_barra', 'curl_biceps', 'extensiones_triceps'
    ],
    equipmentNeeded: [
      'barra_olimpica', 'discos', 'rack_sentadillas', 'banco_press', 'mancuernas',
      'bandas_elasticas', 'chaleco_lastrado', 'cinturon_pesas', 'muñequeras', 'rodilleras'
    ],
    matchRules: {
      'intentos_por_ejercicio': 3,
      'tiempo_entre_intentos': 2,
      'calentamiento_minutos': 15,
      'peso_inicial_minimo': 'peso_corporal_x_0.5'
    },
    scoreTypes: [
      'peso_levantado', 'total_powerlifting', 'total_halterofilia', 'wilks_score'
    ],
    foulTypes: {
      'tecnica_incorrecta': 'Ejecución que no cumple estándares técnicos',
      'comando_no_seguido': 'No seguir las indicaciones del juez',
      'tiempo_excedido': 'Tomar más tiempo del permitido',
      'equipamiento_no_reglamentario': 'Usar equipamiento no autorizado'
    },
    additionalParams: {
      'categorias_peso': [
        '59kg', '66kg', '74kg', '83kg', '93kg', '105kg', '120kg', '120kg+'
      ],
      'ejercicios_powerlifting': ['sentadilla', 'press_banca', 'peso_muerto'],
      'ejercicios_halterofilia': ['arranque', 'envion'],
      'sistemas_puntuacion': ['wilks', 'dots', 'ipf_points']
    }
  );
} 