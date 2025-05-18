import 'package:arcinus/core/sports/models/sport_characteristics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SportCharacteristics', () {
    group('fromJson / toJson', () {
      test('debería deserializar y serializar correctamente', () {
        // Arrange
        final json = {
          'athleteStats': ['stat1', 'stat2'],
          'statUnits': {'stat1': 'unit1'},
          'athleteSpecializations': ['spec1'],
          'positions': ['pos1'],
          'formations': {'form1': ['pos1']},
          'defaultPlayersPerTeam': 5,
          'exerciseCategories': ['cat1'],
          'predefinedExercises': ['ex1'],
          'equipmentNeeded': ['equip1'],
          'matchRules': {'rule1': true},
          'scoreTypes': ['score1'],
          'foulTypes': {'foul1': 'desc1'},
          'additionalParams': {'param1': 'value1'},
        };

        // Act
        final characteristics = SportCharacteristics.fromJson(json);
        final resultJson = characteristics.toJson();

        // Assert
        expect(characteristics.athleteStats, ['stat1', 'stat2']);
        expect(resultJson, json);
      });
    });

    group('forSport', () {
      test('debería devolver las características correctas para baloncesto', () {
        // Act
        final basketball = SportCharacteristics.forSport('basketball');
        final baloncesto = SportCharacteristics.forSport('baloncesto');
        final basketballUpper = SportCharacteristics.forSport('BASKETBALL');

        // Assert
        expect(basketball, isA<SportCharacteristics>());
        expect(basketball.defaultPlayersPerTeam, 5); 
        expect(baloncesto, basketball);
        expect(basketballUpper, basketball);
      });

      test('debería devolver las características correctas para voleibol', () {
        // Act
        final volleyball = SportCharacteristics.forSport('volleyball');
        // Assert
        expect(volleyball, isA<SportCharacteristics>());
        expect(volleyball.defaultPlayersPerTeam, 6);
        expect(volleyball.matchRules['sets'], 5);
      });
      
      test('debería devolver las características correctas para patinaje', () {
        // Act
        final skating = SportCharacteristics.forSport('skating');
        // Assert
        expect(skating, isA<SportCharacteristics>());
        expect(skating.positions, ['No aplica']);
        expect(skating.defaultPlayersPerTeam, 1);
      });

      test('debería devolver las características correctas para fútbol', () {
        // Act
        final soccer = SportCharacteristics.forSport('soccer');
        final futbol = SportCharacteristics.forSport('futbol');
        // Assert
        expect(soccer, isA<SportCharacteristics>());
        expect(soccer.defaultPlayersPerTeam, 11);
        expect(futbol, soccer);
        expect(soccer.matchRules['tiempo_por_mitad'], 45);
      });
      
      test('debería devolver las características correctas para futsal', () {
        // Act
        final futsal = SportCharacteristics.forSport('futsal');
        final futbolSala = SportCharacteristics.forSport('futbol_sala');
        // Assert
        expect(futsal, isA<SportCharacteristics>());
        expect(futsal.defaultPlayersPerTeam, 5);
        expect(futbolSala, futsal);
        expect(futsal.matchRules['tiempo_por_mitad'], 20);
      });

      test('debería lanzar una excepción para un deporte no soportado', () {
        // Assert
        expect(
          () => SportCharacteristics.forSport('unsupported_sport'),
          throwsException,
        );
      });
    });

    group('Constructores de fábrica específicos', () {
      test('basketball() debería crear características correctas', () {
        // Act
        final basketball = SportCharacteristics.basketball();
        // Assert
        expect(basketball.defaultPlayersPerTeam, 5);
        expect(basketball.athleteStats, contains('altura'));
        expect(basketball.matchRules['periodos'], 4);
        expect(basketball.additionalParams['regla_24_segundos'], true);
      });

      test('volleyball() debería crear características correctas', () {
        // Act
        final volleyball = SportCharacteristics.volleyball();
        // Assert
        expect(volleyball.defaultPlayersPerTeam, 6);
        expect(volleyball.athleteStats, contains('alcance_vertical'));
        expect(volleyball.matchRules['sets'], 5);
        expect(volleyball.additionalParams['sistema_rally_point'], true);
      });
      
      test('skating() debería crear características correctas', () {
        // Act
        final skating = SportCharacteristics.skating();
        // Assert
        expect(skating.positions, ['No aplica']);
        expect(skating.athleteSpecializations, contains('velocidad'));
        expect(skating.defaultPlayersPerTeam, 1);
        expect(skating.matchRules['tiempo_programa_corto'], 2.5);
      });
      
      test('soccer() debería crear características correctas', () {
        // Act
        final soccer = SportCharacteristics.soccer();
        // Assert
        expect(soccer.defaultPlayersPerTeam, 11);
        expect(soccer.athleteStats, contains('velocidad'));
        expect(soccer.matchRules['tiempo_por_mitad'], 45);
        expect(soccer.additionalParams['var'], true);
        expect(soccer.positions, contains('Portero (GK)'));
        expect(soccer.formations['4-3-3'], isNotNull);
      });
      
      test('futsala() debería crear características correctas', () {
        // Act
        final futsala = SportCharacteristics.futsala();
        // Assert
        expect(futsala.defaultPlayersPerTeam, 5);
        expect(futsala.athleteStats, contains('agilidad'));
        expect(futsala.matchRules['tiempo_por_mitad'], 20);
        expect(futsala.additionalParams['portero_jugador'], true);
        expect(futsala.positions, contains('Pivote (PV)'));
        expect(futsala.formations['1-2-1'], isNotNull);
        expect(futsala.foulTypes['doble_penalti'], isNotNull);
      });
    });
    
    group('copyWith', () {
      test('debería copiar y actualizar las propiedades correctamente', () {
        // Arrange
        final original = SportCharacteristics.basketball();

        // Act
        final updated = original.copyWith(defaultPlayersPerTeam: 6);

        // Assert
        expect(updated.defaultPlayersPerTeam, 6);
        expect(updated.athleteStats, original.athleteStats); // otras propiedades deben permanecer iguales
      });
    });

  });
} 