import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that holds the ID of the currently selected academy.
///
/// This is typically set after the user selects an academy to manage.
/// It will be null initially or if no academy is selected.
final currentAcademyIdProvider = StateProvider<String?>((ref) => null); 