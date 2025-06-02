import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Repositorio base para la gestión de usuarios del sistema Arcinus.
/// Maneja la información global de usuarios independiente del contexto de academia.
abstract class BaseUserRepository {
  // === CRUD básico de usuarios ===
  
  /// Obtiene un usuario por su ID
  Future<Either<Failure, BaseUser?>> getUserById(String userId);
  
  /// Obtiene un usuario por su email
  Future<Either<Failure, BaseUser?>> getUserByEmail(String email);
  
  /// Crea un nuevo usuario en el sistema
  Future<Either<Failure, void>> createUser(BaseUser user);
  
  /// Actualiza la información de un usuario existente
  Future<Either<Failure, void>> updateUser(BaseUser user);
  
  /// Elimina un usuario del sistema (soft delete)
  Future<Either<Failure, void>> deleteUser(String userId);
  
  // === Gestión de roles globales ===
  
  /// Actualiza el rol global de un usuario
  Future<Either<Failure, void>> updateGlobalRole(String userId, AppRole role);
  
  /// Obtiene todos los usuarios con un rol específico
  Future<Either<Failure, List<BaseUser>>> getUsersByRole(AppRole role);
  
  /// Obtiene todos los super administradores del sistema
  Future<Either<Failure, List<BaseUser>>> getSuperAdmins();
  
  // === Gestión de perfil ===
  
  /// Marca el perfil de un usuario como completado
  Future<Either<Failure, void>> markProfileCompleted(String userId);
  
  /// Actualiza la foto de perfil de un usuario
  Future<Either<Failure, void>> updateProfilePhoto(String userId, String photoUrl);
  
  /// Actualiza las configuraciones del usuario
  Future<Either<Failure, void>> updateUserSettings(
    String userId, 
    Map<String, dynamic> settings
  );
  
  // === Búsqueda y filtrado ===
  
  /// Busca usuarios por término de búsqueda (nombre, email)
  Future<Either<Failure, List<BaseUser>>> searchUsers(
    String searchTerm, {
    AppRole? roleFilter,
    int? limit,
  });
  
  /// Obtiene usuarios paginados
  Future<Either<Failure, List<BaseUser>>> getUsersPaginated({
    int page = 1,
    int pageSize = 20,
    AppRole? roleFilter,
    String? searchTerm,
  });
  
  // === Estadísticas y métricas ===
  
  /// Obtiene el número total de usuarios por rol
  Future<Either<Failure, Map<AppRole, int>>> getUserCountByRole();
  
  /// Obtiene estadísticas generales de usuarios
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics();
  
  // === Validaciones ===
  
  /// Verifica si un email ya está registrado
  Future<Either<Failure, bool>> isEmailRegistered(String email);
  
  /// Verifica si un usuario existe
  Future<Either<Failure, bool>> userExists(String userId);
  
  // === Auditoría ===
  
  /// Registra una acción de auditoría para un usuario
  Future<Either<Failure, void>> logUserAudit({
    required String userId,
    required String action,
    required String details,
    Map<String, dynamic>? metadata,
  });
  
  /// Obtiene el historial de auditoría de un usuario
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserAuditHistory(
    String userId, {
    int? limit,
    DateTime? since,
  });
}

/// Implementación por defecto del repositorio base de usuarios
/// que combina múltiples fuentes de datos
abstract class BaseUserRepositoryImpl implements BaseUserRepository {
  // Esta clase puede ser extendida por implementaciones específicas
  // que utilicen diferentes fuentes de datos (Firestore, API REST, etc.)
  
  /// Valida los datos de un usuario antes de guardar
  Either<Failure, void> validateUserData(BaseUser user) {
    // Validaciones básicas
    if (user.email.isEmpty) {
      return left(const Failure.validationError(message: 'Email es requerido'));
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(user.email)) {
      return left(const Failure.validationError(message: 'Email no tiene formato válido'));
    }
    
    if (user.id.isEmpty) {
      return left(const Failure.validationError(message: 'ID de usuario es requerido'));
    }
    
    return right(null);
  }
  
  /// Crea metadatos de auditoría para operaciones
  Map<String, dynamic> createAuditMetadata({
    required String action,
    String? performedBy,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'performedBy': performedBy,
      'additionalData': additionalData,
    };
  }
} 