import 'dart:developer' as developer;

class AppLogger {
  // Identificador base para los logs de esta app, puede ser el nombre de la app.
  static const String _appIdentifier = 'ArcinusApp'; // Puedes cambiar esto por el nombre de tu app

  static void logInfo(
    String message, {
    String? className,
    String? functionName,
    Map<String, dynamic>? params,
  }) {
    final loggerName = _buildLoggerName(className, functionName);
    String logMessage = message;
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
    String logMessage = message;
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
    String logMessage = message;
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
} 