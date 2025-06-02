import 'package:arcinus/features/academy_sports/data/repositories/sports_repository.dart';
import 'package:arcinus/features/academy_sports/models/sport_characteristics.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider del repositorio de deportes
final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  return SportsRepository();
});

/// Provider para obtener las características del deporte de una academia
final academySportCharacteristicsProvider = FutureProvider.family<SportCharacteristics?, String>((ref, academyId) async {
  // Primero obtenemos la academia
  final academyAsync = await ref.watch(academyDetailsProvider(academyId).future);
  
  final sportCode = academyAsync.sportCode;
  
  // Intentamos obtener las características del deporte desde Firestore
  final sportsRepository = ref.watch(sportsRepositoryProvider);
  final characteristics = await sportsRepository.getSportCharacteristics(sportCode);
  
  // Si no encontramos las características en Firestore, usamos las predefinidas
  return characteristics ?? SportCharacteristics.forSport(sportCode);
});

/// Provider para obtener las posiciones disponibles para un deporte
final sportPositionsProvider = FutureProvider.family<List<String>, String>((ref, academyId) async {
  final sportCharacteristicsAsync = await ref.watch(academySportCharacteristicsProvider(academyId).future);
  
  if (sportCharacteristicsAsync == null) {
    return [];
  }
  
  return sportCharacteristicsAsync.positions;
}); 