import 'package:flutter_riverpod/flutter_riverpod.dart';
// flutter_riverpod es importado por riverpod_annotation, 
//no es necesario importarlo directamente
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

/// Enumeración que define los diferentes estados posibles después del splash,
/// determinando la navegación inicial del usuario.
enum AppInitialState {
  /// Usuario no está autenticado, debe ir a login.
  notAuthenticated,
  
  /// Usuario autenticado pero necesita completar su perfil.
  needsProfileCompletion,
  /// Usuario completamente autenticado y con perfil listo, puede ir a home.
  authenticated
}

/// Provider que gestiona la lógica 
/// de inicialización durante la pantalla splash.
///
/// Verifica el estado de autenticación y perfil del usuario para determinar
/// el [AppInitialState] y dirigir la navegación inicial.
@riverpod
class SplashController extends _$SplashController {
  @override
  Future<AppInitialState> build() async {
    // Simulamos una carga mínima para mostrar el splash
    await Future<void>.delayed(const Duration(seconds: 2));
    
    // La lógica de redirección real ahora está en AppRouter.
    // Simplemente devolvemos un estado para indicar que el splash terminó.
    return AppInitialState.authenticated; 
  }
}

/// Provider simple para saber si la lógica del splash [SplashController] ha finalizado.
///
/// Devuelve `true` si [splashControllerProvider] ha emitido un estado de datos,
/// `false` en caso contrario (cargando o error).
@riverpod
bool splashCompleted(Ref ref) {
  final splashState = ref.watch(splashControllerProvider);
  return splashState.maybeWhen(
    data: (_) => true,
    orElse: () => false,
  );
} 
