import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

/// Servicio para gestionar Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final Logger _logger = Logger();
  FirebaseAnalytics? _analytics;

  /// Constructor factory que devuelve la instancia singleton
  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  /// Inicializa el servicio de Analytics
  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _logger.i('Analytics inicializado correctamente');
    } catch (e) {
      _logger.e('Error al inicializar Analytics: $e');
    }
  }

  /// Obtiene la instancia de FirebaseAnalytics
  FirebaseAnalytics? get analytics => _analytics;

  /// Crea el observer para la navegación
  FirebaseAnalyticsObserver? getAnalyticsObserver() {
    if (_analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  /// Registra un evento personalizado
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.d('Evento Analytics registrado: $name');
    } catch (e) {
      _logger.e('Error al registrar evento Analytics: $e');
    }
  }

  /// Registra un evento de login
  Future<void> logLogin({String? method}) async {
    try {
      await _analytics?.logLogin(loginMethod: method ?? 'email');
      _logger.d('Evento de login registrado');
    } catch (e) {
      _logger.e('Error al registrar evento de login: $e');
    }
  }

  /// Registra un evento de registro de usuario
  Future<void> logSignUp({String? method}) async {
    try {
      await _analytics?.logSignUp(signUpMethod: method ?? 'email');
      _logger.d('Evento de registro registrado');
    } catch (e) {
      _logger.e('Error al registrar evento de registro: $e');
    }
  }

  /// Establece el usuario actual para Analytics
  Future<void> setUserId(String userId) async {
    try {
      await _analytics?.setUserId(id: userId);
      _logger.d('ID de usuario establecido: $userId');
    } catch (e) {
      _logger.e('Error al establecer ID de usuario: $e');
    }
  }

  /// Establece una propiedad de usuario
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
      _logger.d('Propiedad de usuario establecida: $name=$value');
    } catch (e) {
      _logger.e('Error al establecer propiedad de usuario: $e');
    }
  }
} 