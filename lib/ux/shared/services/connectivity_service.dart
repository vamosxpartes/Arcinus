import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor para el servicio de conectividad
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Servicio para verificar la conectividad a Internet
class ConnectivityService {
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  /// Stream que emite cambios de conectividad
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;
  
  ConnectivityService() {
    // Verificar conectividad inicial
    _checkConnectivity();
    
    // Programar verificaciones periódicas
    Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectivity();
    });
  }
  
  /// Verifica si hay conectividad a Internet
  Future<bool> hasConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return hasConnection;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Error al verificar conectividad: $e');
      return false;
    }
  }
  
  /// Verifica la conectividad y notifica a los oyentes
  Future<void> _checkConnectivity() async {
    try {
      final hasConnection = await hasConnectivity();
      _connectivityController.add(hasConnection);
    } catch (e) {
      debugPrint('Error al verificar conectividad: $e');
      _connectivityController.add(false);
    }
  }
  
  /// Libera recursos
  void dispose() {
    _connectivityController.close();
  }
} 