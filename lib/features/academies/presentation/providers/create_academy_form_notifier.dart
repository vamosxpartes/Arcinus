import 'package:arcinus/features/academies/presentation/providers/state/create_academy_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the create academy form state.
final createAcademyFormNotifierProvider =
    StateNotifierProvider<CreateAcademyFormNotifier, CreateAcademyFormState>(
  (ref) => CreateAcademyFormNotifier(),
);

/// Manages the state of the create academy form.
class CreateAcademyFormNotifier extends StateNotifier<CreateAcademyFormState> {
  CreateAcademyFormNotifier() : super(CreateAcademyFormState.initial());

  /// Updates the academy name in the state.
  void setName(String name) {
    state = state.copyWith(name: name);
    _validateForm(); // Re-validate on change
  }

  /// Updates the selected sport code in the state.
  void setSportCode(String? sportCode) {
    state = state.copyWith(sportCode: sportCode);
     _validateForm(); // Re-validate on change
  }

  /// Updates the academy description in the state.
  void setDescription(String description) {
    state = state.copyWith(description: description);
     _validateForm(); // No suele ser obligatorio, pero validamos igual
  }

  /// Basic form validation logic.
  void _validateForm() {
    // Simple validation: name and sportCode must not be empty/null.
    final isValid = state.name.trim().isNotEmpty && state.sportCode != null;
    state = state.copyWith(isFormValid: isValid);
  }

  // Potentially add more complex validation logic here
} 