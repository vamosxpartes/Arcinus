import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';

/// Provider que mantiene la academia actualmente seleccionada.
///
/// Contiene el objeto AcademyModel completo en lugar de solo el ID.
/// Se establece típicamente después de que el usuario selecciona una academia para gestionar.
/// Será null inicialmente o si no hay academia seleccionada.
final currentAcademyProvider = StateProvider<AcademyModel?>((ref) => null); 