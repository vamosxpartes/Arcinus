import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/user_management/models/base_user.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Repositorio base para operaciones CRUD con usuarios del sistema.
/// Maneja la información básica de autenticación y perfil que es común
/// para todos los tipos de usuarios en Arcinus.
abstract class BaseUserRepository {
  
  // ========== CRUD Básico ==========
  
  /// Obtiene un usuario por su ID único (Firebase Auth UID).
  ///
  /// Retorna [Right(BaseUser)] si el usuario existe,
  /// [Right(null)] si no existe,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, BaseUser?>> getUserById(String userId);
  
  /// Obtiene un usuario por su dirección de correo electrónico.
  ///
  /// Retorna [Right(BaseUser)] si el usuario existe,
  /// [Right(null)] si no existe,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, BaseUser?>> getUserByEmail(String email);
  
  /// Crea un nuevo usuario en el sistema.
  ///
  /// Retorna [Right(void)] si se crea exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> createUser(BaseUser user);
  
  /// Actualiza la información de un usuario existente.
  ///
  /// Retorna [Right(void)] si se actualiza exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> updateUser(BaseUser user);
  
  /// Elimina un usuario del sistema (soft delete).
  ///
  /// Retorna [Right(void)] si se elimina exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> deleteUser(String userId);
  
  // ========== Gestión de Roles Globales ==========
  
  /// Actualiza el rol global de un usuario en el sistema.
  ///
  /// [userId] ID del usuario a actualizar
  /// [newRole] Nuevo rol global del usuario
  ///
  /// Retorna [Right(void)] si se actualiza exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> updateGlobalRole(String userId, AppRole newRole);
  
  /// Obtiene todos los usuarios con un rol específico.
  ///
  /// [role] Rol global a filtrar
  ///
  /// Retorna [Right(List<BaseUser>)] con la lista de usuarios,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> getUsersByRole(AppRole role);
  
  // ========== Gestión de Estado ==========
  
  /// Activa o desactiva un usuario en el sistema.
  ///
  /// [userId] ID del usuario
  /// [isActive] true para activar, false para desactivar
  ///
  /// Retorna [Right(void)] si se actualiza exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> setUserActiveStatus(String userId, bool isActive);
  
  /// Marca el perfil de un usuario como completado.
  ///
  /// [userId] ID del usuario
  ///
  /// Retorna [Right(void)] si se actualiza exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> markProfileCompleted(String userId);
  
  // ========== Búsqueda y Filtrado ==========
  
  /// Busca usuarios por nombre o email.
  ///
  /// [query] Término de búsqueda
  /// [limit] Límite de resultados (opcional)
  ///
  /// Retorna [Right(List<BaseUser>)] con los resultados,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> searchUsers(String query, {int? limit});
  
  /// Obtiene todos los usuarios activos del sistema.
  ///
  /// [limit] Límite de resultados (opcional)
  ///
  /// Retorna [Right(List<BaseUser>)] con los usuarios activos,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> getActiveUsers({int? limit});
  
  /// Obtiene usuarios que requieren completar su perfil.
  ///
  /// Retorna [Right(List<BaseUser>)] con los usuarios incompletos,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> getIncompleteProfiles();
  
  // ========== Gestión de Super Administradores ==========
  
  /// Promueve un usuario a super administrador del sistema.
  /// Esta operación solo puede ser realizada por otros super administradores.
  ///
  /// [userId] ID del usuario a promover
  ///
  /// Retorna [Right(void)] si se promueve exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> promoteToSuperAdmin(String userId);
  
  /// Revoca el rol de super administrador de un usuario.
  /// Esta operación solo puede ser realizada por otros super administradores.
  ///
  /// [userId] ID del usuario al que revocar el rol
  ///
  /// Retorna [Right(void)] si se revoca exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> revokeSuperAdmin(String userId);
  
  /// Obtiene todos los super administradores del sistema.
  ///
  /// Retorna [Right(List<BaseUser>)] con los super administradores,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> getSuperAdmins();
  
  // ========== Estadísticas y Métricas ==========
  
  /// Obtiene estadísticas básicas de usuarios del sistema.
  ///
  /// Retorna un mapa con las siguientes claves:
  /// - 'totalUsers': Total de usuarios
  /// - 'activeUsers': Usuarios activos
  /// - 'incompleteProfiles': Perfiles incompletos
  /// - 'usersByRole': Distribución por roles
  ///
  /// Retorna [Right(Map<String, dynamic>)] con las estadísticas,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics();
  
  // ========== Utilidades ==========
  
  /// Verifica si un email ya está registrado en el sistema.
  ///
  /// [email] Email a verificar
  ///
  /// Retorna [Right(bool)] true si existe, false si no existe,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, bool>> emailExists(String email);
  
  /// Actualiza la fecha de última actividad de un usuario.
  ///
  /// [userId] ID del usuario
  ///
  /// Retorna [Right(void)] si se actualiza exitosamente,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, void>> updateLastActivity(String userId);
  
  /// Obtiene usuarios que no han estado activos en un período específico.
  ///
  /// [daysSinceLastActivity] Días desde la última actividad
  ///
  /// Retorna [Right(List<BaseUser>)] con los usuarios inactivos,
  /// [Left(Failure)] en caso de error.
  Future<Either<Failure, List<BaseUser>>> getInactiveUsers(int daysSinceLastActivity);
} 