import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_user_model.freezed.dart';
part 'academy_user_model.g.dart';

/// Modelo modernizado de usuario de academia con Freezed
/// Reemplaza el modelo legacy sin Freezed que estaba en academy_users_repository.dart
@freezed
class AcademyUserModel with _$AcademyUserModel {
  const factory AcademyUserModel({
    /// ID único del usuario en la academia
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    /// Nombre del usuario
    required String firstName,
    
    /// Apellido del usuario
    required String lastName,
    
    /// Fecha de nacimiento
    @NullableTimestampConverter() DateTime? birthDate,
    
    /// Número de teléfono
    String? phoneNumber,
    
    /// Altura en centímetros
    double? heightCm,
    
    /// Peso en kilogramos
    double? weightKg,
    
    /// URL de imagen de perfil
    String? profileImageUrl,
    
    /// Alergias conocidas
    String? allergies,
    
    /// Condiciones médicas
    String? medicalConditions,
    
    /// Información de contacto de emergencia
    @Default({}) Map<String, dynamic> emergencyContact,
    
    /// Posición deportiva (para atletas)
    String? position,
    
    /// Rol del usuario en la academia
    String? role,
    
    /// ID del usuario que creó este registro
    required String createdBy,
    
    /// Fecha de creación
    @NullableTimestampConverter() required DateTime createdAt,
    
    /// Fecha de última actualización
    @NullableTimestampConverter() required DateTime updatedAt,
    
    /// Metadatos adicionales
    @Default({}) Map<String, dynamic> metadata,
  }) = _AcademyUserModel;

  /// Factory estándar de Freezed para generar toJson automáticamente
  factory AcademyUserModel.fromJson(Map<String, dynamic> json) => _$AcademyUserModelFromJson(json);

  /// Factory seguro para crear desde JSON con validación de campos requeridos
  factory AcademyUserModel.fromJsonSafe(Map<String, dynamic> json) {
    try {
      // Validar campos requeridos antes de la deserialización
      _validateRequiredFields(json);
      
      // Sanitizar datos antes de la deserialización
      final sanitizedJson = _sanitizeJsonData(json);
      
      return _$AcademyUserModelFromJson(sanitizedJson);
    } catch (e) {
      throw FormatException('Error al crear AcademyUserModel desde JSON: $e\nJSON recibido: $json');
    }
  }
  
  /// Valida que los campos requeridos estén presentes y no sean null
  static void _validateRequiredFields(Map<String, dynamic> json) {
    final requiredFields = ['firstName', 'lastName', 'createdBy', 'createdAt', 'updatedAt'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        throw ArgumentError('Campo requerido faltante o null: $field');
      }
    }
    
    // Validar que firstName y lastName sean strings no vacíos
    final firstName = json['firstName'];
    final lastName = json['lastName'];
    final createdBy = json['createdBy'];
    
    if (firstName is! String || firstName.trim().isEmpty) {
      throw ArgumentError('firstName debe ser un string no vacío');
    }
    
    if (lastName is! String || lastName.trim().isEmpty) {
      throw ArgumentError('lastName debe ser un string no vacío');
    }
    
    if (createdBy is! String || createdBy.trim().isEmpty) {
      throw ArgumentError('createdBy debe ser un string no vacío');
    }
  }
  
  /// Sanitiza los datos JSON para evitar errores de casting
  static Map<String, dynamic> _sanitizeJsonData(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    
    // Sanitizar campos de string
    for (final field in ['firstName', 'lastName', 'phoneNumber', 'profileImageUrl', 
                        'allergies', 'medicalConditions', 'position', 'role', 'createdBy']) {
      if (sanitized.containsKey(field) && sanitized[field] != null) {
        sanitized[field] = sanitized[field].toString().trim();
      }
    }
    
    // Sanitizar campos numéricos
    if (sanitized.containsKey('heightCm') && sanitized['heightCm'] != null) {
      try {
        sanitized['heightCm'] = double.parse(sanitized['heightCm'].toString());
      } catch (e) {
        sanitized['heightCm'] = null; // Si no se puede convertir, asignar null
      }
    }
    
    if (sanitized.containsKey('weightKg') && sanitized['weightKg'] != null) {
      try {
        sanitized['weightKg'] = double.parse(sanitized['weightKg'].toString());
      } catch (e) {
        sanitized['weightKg'] = null; // Si no se puede convertir, asignar null
      }
    }
    
    // Sanitizar maps para evitar que sean null
    if (sanitized.containsKey('emergencyContact') && sanitized['emergencyContact'] == null) {
      sanitized['emergencyContact'] = <String, dynamic>{};
    }
    
    if (sanitized.containsKey('metadata') && sanitized['metadata'] == null) {
      sanitized['metadata'] = <String, dynamic>{};
    }
    
    // Sanitizar fechas - el NullableTimestampConverter se encargará del resto
    // Solo nos aseguramos de que las fechas requeridas estén presentes
    if (!sanitized.containsKey('createdAt') || sanitized['createdAt'] == null) {
      sanitized['createdAt'] = Timestamp.now();
    }
    
    if (!sanitized.containsKey('updatedAt') || sanitized['updatedAt'] == null) {
      sanitized['updatedAt'] = Timestamp.now();
    }
    
    return sanitized;
  }
}

/// Extensión con métodos de utilidad para AcademyUserModel
extension AcademyUserModelExtension on AcademyUserModel {
  /// Obtiene el nombre completo del usuario
  String get fullName => '$firstName $lastName';
  
  /// Verifica si el usuario es un atleta
  bool get isAthlete => role?.toLowerCase() == 'atleta' || role?.toLowerCase() == 'athlete';
  
  /// Verifica si el usuario es un padre/responsable
  bool get isParent => role?.toLowerCase() == 'padre' || role?.toLowerCase() == 'parent';
  
  /// Verifica si tiene información médica completa
  bool get hasMedicalInfo => allergies?.isNotEmpty == true || medicalConditions?.isNotEmpty == true;
  
  /// Verifica si tiene información de contacto de emergencia
  bool get hasEmergencyContact => emergencyContact.isNotEmpty;
  
  /// Obtiene la edad si la fecha de nacimiento está disponible
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      return age - 1;
    }
    return age;
  }
  
  /// Convierte a AppRole enum
  AppRole get appRole {
    if (role == null) return AppRole.desconocido;
    switch (role!.toLowerCase()) {
      case 'atleta':
      case 'athlete':
        return AppRole.atleta;
      case 'padre':
      case 'parent':
        return AppRole.padre;
      case 'propietario':
      case 'owner':
        return AppRole.propietario;
      case 'colaborador':
      case 'collaborator':
        return AppRole.colaborador;
      default:
        return AppRole.desconocido;
    }
  }
  
  /// Valida que el modelo sea consistente
  bool get isValid {
    return firstName.trim().isNotEmpty && 
           lastName.trim().isNotEmpty && 
           createdBy.trim().isNotEmpty;
  }
  
  /// Obtiene una versión segura del modelo que garantiza consistencia
  AcademyUserModel get validated {
    if (isValid) return this;
    
    return copyWith(
      firstName: firstName.trim().isEmpty ? 'Sin nombre' : firstName.trim(),
      lastName: lastName.trim().isEmpty ? 'Sin apellido' : lastName.trim(),
      createdBy: createdBy.trim().isEmpty ? 'sistema' : createdBy.trim(),
    );
  }
} 