import 'package:arcinus/core/error/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_academy_state.freezed.dart';

@freezed
sealed class CreateAcademyState with _$CreateAcademyState {
  /// Estado inicial o inactivo.
  const factory CreateAcademyState.initial() = _Initial;

  /// Estado mientras se guarda la academia.
  const factory CreateAcademyState.loading() = _Loading;

  /// Estado de éxito tras guardar la academia.
  const factory CreateAcademyState.success(String academyId) = _Success;

  /// Estado de error al guardar.
  const factory CreateAcademyState.error(Failure failure) = _Error;
} 