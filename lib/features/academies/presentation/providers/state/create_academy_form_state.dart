import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_academy_form_state.freezed.dart';

/// Represents the state of the create academy form.
@freezed
class CreateAcademyFormState with _$CreateAcademyFormState {
  const factory CreateAcademyFormState({
    /// Name entered by the user.
    @Default('') String name,
    /// Selected sport code.
    String? sportCode,
    /// Description entered by the user.
    @Default('') String description,
    /// Flag indicating if the form is currently valid.
    /// Could be expanded later for field-specific errors.
    @Default(false) bool isFormValid,
    // TODO: Potentially add field-specific error messages
    // String? nameError,
    // String? sportCodeError,
  }) = _CreateAcademyFormState;

  /// Initial state for the form.
  factory CreateAcademyFormState.initial() => const CreateAcademyFormState();
} 