import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';

/// Provider para la actualización de academias
final updateAcademyProvider = StateNotifierProvider<UpdateAcademyNotifier, AsyncValue<void>>(
  (ref) => UpdateAcademyNotifier(ref.watch(academyRepositoryProvider)),
);

/// Notifier para gestionar la actualización de academias
class UpdateAcademyNotifier extends StateNotifier<AsyncValue<void>> {
  final AcademyRepository _repository;

  UpdateAcademyNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Método para actualizar una academia
  Future<void> updateAcademy(AcademyModel academy) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.updateAcademy(academy);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = const AsyncValue.data(null),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
} 