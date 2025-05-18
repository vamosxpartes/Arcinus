import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:arcinus/core/utils/app_logger.dart';

/// Provider para obtener la caja de Hive para el registro
final registrationBoxProvider = Provider<Box<dynamic>?>((ref) {
  return null; // Se inicializará más adelante
});

/// Inicializa el provider de Hive para el registro
Future<void> initRegistrationBox(ProviderContainer container) async {
  try {
    // Ya se ha inicializado Hive en main.dart, solo abrimos la caja
    final box = await Hive.openBox('registration_data');
    container.updateOverrides([
      registrationBoxProvider.overrideWithValue(box),
    ]);
    AppLogger.logInfo('registration_data box opened successfully');
  } catch (e) {
    AppLogger.logError(
      message: 'Error al abrir la caja de Hive para registro',
      error: e,
    );
  }
}

/// Modelo para los datos del formulario de registro
class RegistrationData {
  /// Email del usuario
  final String email;
  
  /// Contraseña del usuario
  final String password;
  
  /// Nombre del usuario
  final String name;
  
  /// Apellido del usuario
  final String lastName;
  
  /// Teléfono del usuario
  final String phone;
  
  /// Ruta de la imagen de perfil
  final String? profileImagePath;

  /// Constructor
  RegistrationData({
    this.email = '',
    this.password = '',
    this.name = '',
    this.lastName = '',
    this.phone = '',
    this.profileImagePath,
  });

  /// Crea una instancia vacía
  factory RegistrationData.empty() {
    return RegistrationData();
  }

  /// Crea una copia con los valores actualizados
  RegistrationData copyWith({
    String? email,
    String? password,
    String? name,
    String? lastName,
    String? phone,
    String? profileImagePath,
  }) {
    return RegistrationData(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'lastName': lastName,
      'phone': phone,
      'profileImagePath': profileImagePath,
      // No guardar la contraseña en el almacenamiento local
    };
  }

  /// Crea desde JSON
  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String?,
    );
  }
}

/// Provider para los datos del formulario de registro
final registrationFormProvider = 
    StateNotifierProvider<RegistrationFormNotifier, RegistrationData>((ref) {
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

  /// Carga los datos guardados
  Future<void> _loadSavedData() async {
    try {
      if (_box != null && _box.isOpen) {
        final savedData = _box.get(_storageKey);
        if (savedData != null) {
          // Hive puede devolver el valor ya como un mapa o como una cadena JSON
          final Map<String, dynamic> jsonData;
          if (savedData is String) {
            jsonData = jsonDecode(savedData) as Map<String, dynamic>;
          } else if (savedData is Map) {
            jsonData = Map<String, dynamic>.from(savedData);
          } else {
            throw FormatException('Formato de datos no reconocido');
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
    }
  }

  /// Guarda los datos actuales
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
  void updateEmail(String? email) {
    if (email != null) {
      state = state.copyWith(email: email);
      _saveData();
    }
  }

  /// Actualiza la contraseña (solo en memoria, no se persiste)
  void updatePassword(String? password) {
    if (password != null) {
      state = state.copyWith(password: password);
      // No guarda la contraseña en persistencia
    }
  }

  /// Actualiza el nombre
  void updateName(String? name) {
    if (name != null) {
      state = state.copyWith(name: name);
      _saveData();
    }
  }

  /// Actualiza el apellido
  void updateLastName(String? lastName) {
    if (lastName != null) {
      state = state.copyWith(lastName: lastName);
      _saveData();
    }
  }

  /// Actualiza el teléfono
  void updatePhone(String? phone) {
    if (phone != null) {
      state = state.copyWith(phone: phone);
      _saveData();
    }
  }

  /// Actualiza la ruta de la imagen de perfil
  void updateProfileImagePath(String? path) {
    state = state.copyWith(profileImagePath: path);
    _saveData();
  }

  /// Limpia los datos guardados
  Future<void> clearSavedData() async {
    try {
      if (_box != null && _box.isOpen) {
        await _box.delete(_storageKey);
        state = RegistrationData.empty();
        AppLogger.logInfo('Datos de registro eliminados');
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al eliminar datos de registro guardados',
        error: e,
      );
    }
  }
} 