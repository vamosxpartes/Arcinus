import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para gestionar el estado global de la pantalla de usuarios
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier();
});

/// Estado para la pantalla de gestión de usuarios
class UserManagementState {
  final int currentTabIndex;
  final bool showInviteForm;
  final String searchQuery;
  final UserRole selectedRole;

  UserManagementState({
    this.currentTabIndex = 0,
    this.showInviteForm = false,
    this.searchQuery = '',
    this.selectedRole = UserRole.coach,
  });

  UserManagementState copyWith({
    int? currentTabIndex,
    bool? showInviteForm,
    String? searchQuery,
    UserRole? selectedRole,
  }) {
    return UserManagementState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      showInviteForm: showInviteForm ?? this.showInviteForm,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

/// Notifier para manejar los cambios de estado
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(UserManagementState());

  void setCurrentTabIndex(int index) {
    // Actualiza el rol seleccionado basado en la pestaña
    UserRole role;
    switch (index) {
      case 0:
        role = UserRole.manager;
        break;
      case 1:
        role = UserRole.coach;
        break;
      case 2:
        role = UserRole.athlete;
        break;
      case 3:
        // Grupos - no tiene rol asociado
        role = state.selectedRole;
        break;
      case 4:
        role = UserRole.parent;
        break;
      case 5:
        role = UserRole.owner;
        break;
      default:
        role = state.selectedRole;
        break;
    }

    state = state.copyWith(
      currentTabIndex: index,
      selectedRole: role,
      // Si estamos mostrando el formulario y cambiamos de tab, lo ocultamos
      showInviteForm: false,
    );
  }

  void toggleInviteForm() {
    state = state.copyWith(showInviteForm: !state.showInviteForm);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSelectedRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }
} 