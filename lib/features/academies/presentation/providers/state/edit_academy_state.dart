import 'package:arcinus/core/error/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_academy_state.freezed.dart';

@freezed
sealed class EditAcademyState with _$EditAcademyState {
  /// Estado inicial, antes de intentar guardar.
  const factory EditAcademyState.initial() = _Initial;

  /// Estado mientras se guardan los cambios.
  const factory EditAcademyState.loading() = _Loading;

  /// Estado cuando los cambios se guardaron exitosamente.
  const factory EditAcademyState.success() = _Success;

  /// Estado cuando ocurrió un error al guardar.
  const factory EditAcademyState.error(Failure failure) = _Error;
} 