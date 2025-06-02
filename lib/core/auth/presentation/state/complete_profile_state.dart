import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/error/failures.dart'; // Asumiendo que Failure está aquí

part 'complete_profile_state.freezed.dart';

@freezed
sealed class CompleteProfileState with _$CompleteProfileState {
  const factory CompleteProfileState.initial() = _Initial;
  const factory CompleteProfileState.loading() = _Loading;
  const factory CompleteProfileState.success() = _Success;
  const factory CompleteProfileState.error(Failure failure) = _Error;
} 