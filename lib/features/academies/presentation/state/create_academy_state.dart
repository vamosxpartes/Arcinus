import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación

part 'create_academy_state.freezed.dart';

@freezed
sealed class CreateAcademyState with _$CreateAcademyState {
  const factory CreateAcademyState.initial() = _Initial;
  const factory CreateAcademyState.loading() = _Loading;
  // Podríamos pasar el ID de la academia creada en success si es necesario
  const factory CreateAcademyState.success(String academyId) = _Success;
  const factory CreateAcademyState.error(Failure failure) = _Error;
} 