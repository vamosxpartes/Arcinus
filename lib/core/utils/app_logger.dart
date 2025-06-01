import 'dart:developer' as developer;

class AppLogger {
  // Identificador base para los logs de esta app, puede ser el nombre de la app.
  static const String _appIdentifier = 'ArcinusApp'; // Puedes cambiar esto por el nombre de tu app
  
  // Timestamp de inicio de sesión para rastrear procesos relacionados
  static final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  static final DateTime _sessionStartTime = DateTime.now();

  static void logInfo(
    String message, {
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
  }) {
    final loggerName = _buildLoggerName(className, functionName);
    final timestamp = _formatTimestamp(DateTime.now());
    final sessionDuration = _getSessionDuration();
    
    String logMessage = '[$timestamp] [Sesión: $_sessionId] [+${sessionDuration}ms] $message';
    if (params != null) {
      logMessage += ' ${params.toString()}';
    }

    developer.log(
      logMessage,
      name: loggerName,
      level: 700, // Nivel INFO
      time: DateTime.now(),
    );
  }

  static void logWarning(
    String message, {
    Object? error,
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
  }) {
    final loggerName = _buildLoggerName(className, functionName);
    final timestamp = _formatTimestamp(DateTime.now());
    final sessionDuration = _getSessionDuration();
    
    String logMessage = '[$timestamp] [Sesión: $_sessionId] [+${sessionDuration}ms] ⚠️ $message';
    if (params != null) {
      logMessage += ' ${params.toString()}';
    }
    
    developer.log(
      logMessage,
      name: loggerName,
      error: error,
      level: 900, // Nivel WARNING
      time: DateTime.now(),
    );
  }

  static void logError({
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
  }) {
    final loggerName = _buildLoggerName(className, functionName);
    final timestamp = _formatTimestamp(DateTime.now());
    final sessionDuration = _getSessionDuration();
    
    String logMessage = '[$timestamp] [Sesión: $_sessionId] [+${sessionDuration}ms] ❌ $message';
    if (params != null) {
      logMessage += ' ${params.toString()}';
    }

    developer.log(
      logMessage,
      name: loggerName,
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Nivel SEVERE
      time: DateTime.now(),
    );
  }

  /// Método para registrar el inicio de un proceso específico
  static void logProcessStart(
    String processName, {
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
  }) {
    logInfo(
      '🚀 INICIO: $processName',
      className: className,
      functionName: functionName,
      params: params,
    );
  }

  /// Método para registrar el fin de un proceso específico
  static void logProcessEnd(
    String processName, {
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
    int? durationMs,
  }) {
    String message = '✅ FIN: $processName';
    if (durationMs != null) {
      message += ' (duración: ${durationMs}ms)';
    }
    
    logInfo(
      message,
      className: className,
      functionName: functionName,
      params: params,
    );
  }

  static String _buildLoggerName(String? className, String? functionName) {
    final stringBuffer = StringBuffer();
    stringBuffer.write(_appIdentifier);
    if (className != null && className.isNotEmpty) {
      stringBuffer.write('.$className');
    }
    if (functionName != null && functionName.isNotEmpty) {
      stringBuffer.write('.$functionName');
    }
    return stringBuffer.toString();
  }

  /// Formatea el timestamp en un formato legible
  static String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}.'
           '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }

  /// Calcula la duración desde el inicio de la sesión en milisegundos
  static int _getSessionDuration() {
    return DateTime.now().difference(_sessionStartTime).inMilliseconds;
  }

  /// Obtiene el ID de sesión actual para rastreo
  static String get sessionId => _sessionId;

  /// Obtiene el tiempo de inicio de sesión
  static DateTime get sessionStartTime => _sessionStartTime;
} 