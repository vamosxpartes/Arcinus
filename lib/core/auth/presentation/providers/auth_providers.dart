import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/auth/data/repositories/auth_repository.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Provider para observar el estado de autenticación en tiempo real.
/// Este es el principal provider que se usará
/// para verificar si el usuario está autenticado.
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Provider para el usuario actual.
/// Usa el estado de Firebase Auth directamente.
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
}

/// Notifier para manejar las acciones de autenticación y su estado.
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() {
    // El método build debe ser un getter sincrónico,
    // así que usamos un listener separado para actualizar el estado
    // basado en el stream de authStateChanges.
    _setupAuthListener();
    return const AuthState.initial();
  }

  /// Configura un listener para el stream de cambios de autenticación.
  void _setupAuthListener() {
    // Marcar como cargando inmediatamente
    state = const AuthState.loading();
    
    // Escuchar cambios futuros
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AuthState.authenticated(user: user);
          } else {
            state = const AuthState.unauthenticated();
          }
        },
        loading: () {
          // Mantener estado de carga si estamos esperando
          if (!state.isLoading) {
            state = const AuthState.loading();
          }
        },
        error: (error, stackTrace) {
          state = AuthState.error(message: error.toString());
        },
      );
    });

    // También verificar el estado actual inmediatamente
    final currentAuthState = ref.read(authStateChangesProvider);
    currentAuthState.whenData((user) {
      if (user != null) {
        state = AuthState.authenticated(user: user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  /// Inicia sesión con email y contraseña.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signInWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) => state = AuthState.error(message: failure.message),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Crea un nuevo usuario con email y contraseña.
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.createUserWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) => state = AuthState.error(message: failure.message),
      (user) => state = AuthState.authenticated(user: user),
    );
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    state = const AuthState.loading();

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signOut();

    result.fold(
      (failure) => state = AuthState.error(message: failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }
}
