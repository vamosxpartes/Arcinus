import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:arcinus/core/utils/app_logger.dart';

/// Variable global para almacenar la referencia al box de registro
Box<dynamic>? _registrationBox;

/// Provider para obtener la caja de Hive para el registro
final registrationBoxProvider = Provider<Box<dynamic>?>((ref) {
  return _registrationBox;
});

/// Inicializa el provider de Hive para el registro
/// Ahora usa una variable global para evitar problemas con overrides dinámicos
Future<void> initRegistrationBox(ProviderContainer container) async {
  try {
    // Verificar si ya está inicializado
    if (_registrationBox != null && _registrationBox!.isOpen) {
      AppLogger.logInfo('registration_data box ya está abierto');
      return;
    }
    
    // Abrir la caja de Hive
    _registrationBox = await Hive.openBox('registration_data');
    AppLogger.logInfo('registration_data box opened successfully');
    
    // No necesitamos hacer override ahora, el provider leerá la variable global
    
  } catch (e) {
    AppLogger.logError(
      message: 'Error al abrir la caja de Hive para registro',
      error: e,
    );
    // En caso de error, asegurar que _registrationBox sea null
    _registrationBox = null;
  }
}

/// Cierra la caja de registro de manera segura
Future<void> closeRegistrationBox() async {
  try {
    if (_registrationBox != null && _registrationBox!.isOpen) {
      await _registrationBox!.close();
      AppLogger.logInfo('registration_data box closed successfully');
    }
    _registrationBox = null;
  } catch (e) {
    AppLogger.logError(
      message: 'Error al cerrar la caja de Hive para registro',
      error: e,
    );
  }
}

/// Modelo para los datos del formulario de registro
class RegistrationData {
  final String email;
  final String displayName;
  final String lastName;
  final String phoneNumber;
  final String academyName;
  final String academySport;
  final String academyLocation;
  final String academyDescription;
  final bool hasCompleteProfile;

  const RegistrationData({
    required this.email,
    required this.displayName,
    required this.lastName,
    required this.phoneNumber,
    required this.academyName,
    required this.academySport,
    required this.academyLocation,
    required this.academyDescription,
    required this.hasCompleteProfile,
  });

  /// Constructor para crear un estado vacío
  factory RegistrationData.empty() {
    return const RegistrationData(
      email: '',
      displayName: '',
      lastName: '',
      phoneNumber: '',
      academyName: '',
      academySport: '',
      academyLocation: '',
      academyDescription: '',
      hasCompleteProfile: false,
    );
  }

  /// Crea una copia con algunos campos modificados
  RegistrationData copyWith({
    String? email,
    String? displayName,
    String? lastName,
    String? phoneNumber,
    String? academyName,
    String? academySport,
    String? academyLocation,
    String? academyDescription,
    bool? hasCompleteProfile,
  }) {
    return RegistrationData(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      academyName: academyName ?? this.academyName,
      academySport: academySport ?? this.academySport,
      academyLocation: academyLocation ?? this.academyLocation,
      academyDescription: academyDescription ?? this.academyDescription,
      hasCompleteProfile: hasCompleteProfile ?? this.hasCompleteProfile,
    );
  }

  /// Convierte a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'academyName': academyName,
      'academySport': academySport,
      'academyLocation': academyLocation,
      'academyDescription': academyDescription,
      'hasCompleteProfile': hasCompleteProfile,
    };
  }

  /// Crea desde JSON
  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      academyName: json['academyName'] as String? ?? '',
      academySport: json['academySport'] as String? ?? '',
      academyLocation: json['academyLocation'] as String? ?? '',
      academyDescription: json['academyDescription'] as String? ?? '',
      hasCompleteProfile: json['hasCompleteProfile'] as bool? ?? false,
    );
  }

  /// Verifica si los datos están completos
  bool get isComplete {
    return email.isNotEmpty &&
        displayName.isNotEmpty &&
        lastName.isNotEmpty &&
        academyName.isNotEmpty &&
        academySport.isNotEmpty;
  }

  @override
  String toString() {
    return 'RegistrationData(email: $email, displayName: $displayName, academyName: $academyName)';
  }
}

/// Provider para el notificador del formulario de registro
final registrationFormProvider = StateNotifierProvider<RegistrationFormNotifier, RegistrationData>((ref) {
  final box = ref.watch(registrationBoxProvider);
  return RegistrationFormNotifier(box);
});

/// Notificador para gestionar el estado del formulario de registro
class RegistrationFormNotifier extends StateNotifier<RegistrationData> {
  /// Box de Hive para persistencia
  final Box<dynamic>? _box;
  
  /// Clave para almacenar los datos en Hive
  static const _storageKey = 'form_data';

  /// Constructor
  RegistrationFormNotifier(this._box) : super(RegistrationData.empty()) {
    _loadSavedData();
  }

  /// Carga los datos guardados de manera segura
  Future<void> _loadSavedData() async {
    try {
      if (_box != null && _box.isOpen) {
        final savedData = _box.get(_storageKey);
        if (savedData != null) {
          final Map<String, dynamic> jsonData;
          
          if (savedData is String) {
            try {
              jsonData = jsonDecode(savedData) as Map<String, dynamic>;
            } catch (e) {
              AppLogger.logWarning('Error decodificando JSON de registro: $e');
              return;
            }
          } else if (savedData is Map) {
            jsonData = Map<String, dynamic>.from(savedData);
          } else {
            AppLogger.logWarning('Formato de datos de registro no reconocido: ${savedData.runtimeType}');
            return;
          }
          
          state = RegistrationData.fromJson(jsonData);
          AppLogger.logInfo('Datos de registro cargados: ${state.email}');
        }
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al cargar datos de registro guardados',
        error: e,
      );
      // En caso de error, mantener el estado vacío
    }
  }

  /// Guarda los datos actuales de manera segura
  Future<void> _saveData() async {
    try {
      if (_box != null && _box.isOpen) {
        final jsonData = jsonEncode(state.toJson());
        await _box.put(_storageKey, jsonData);
        AppLogger.logInfo('Datos de registro guardados');
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al guardar datos de registro',
        error: e,
      );
    }
  }

  /// Actualiza el email
  void updateEmail(String email) {
    state = state.copyWith(email: email);
    _saveData();
  }

  /// Actualiza el nombre
  void updateDisplayName(String displayName) {
    state = state.copyWith(displayName: displayName);
    _saveData();
  }

  /// Actualiza el apellido
  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
    _saveData();
  }

  /// Actualiza el teléfono
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
    _saveData();
  }

  /// Actualiza el nombre de la academia
  void updateAcademyName(String academyName) {
    state = state.copyWith(academyName: academyName);
    _saveData();
  }

  /// Actualiza el deporte de la academia
  void updateAcademySport(String academySport) {
    state = state.copyWith(academySport: academySport);
    _saveData();
  }

  /// Actualiza la ubicación de la academia
  void updateAcademyLocation(String academyLocation) {
    state = state.copyWith(academyLocation: academyLocation);
    _saveData();
  }

  /// Actualiza la descripción de la academia
  void updateAcademyDescription(String academyDescription) {
    state = state.copyWith(academyDescription: academyDescription);
    _saveData();
  }

  /// Marca el perfil como completo
  void markProfileComplete() {
    state = state.copyWith(hasCompleteProfile: true);
    _saveData();
  }

  /// Limpia todos los datos
  Future<void> clearData() async {
    state = RegistrationData.empty();
    try {
      if (_box != null && _box.isOpen) {
        await _box.delete(_storageKey);
        AppLogger.logInfo('Datos de registro eliminados');
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al eliminar datos de registro',
        error: e,
      );
    }
  }
} 