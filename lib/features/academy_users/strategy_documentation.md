# Estrategia de Gestión de Usuarios - Sistema Arcinus

## 📋 Modelos de Usuario Identificados

### **Modelos Base de Usuario:**
1. **`User`** (`lib/core/auth/user.dart`) - Modelo básico de autenticación
2. **`UserModel`** (`lib/core/models/user_model.dart`) - Modelo básico de perfil  
3. **`UserModel`** (`lib/core/auth/data/models/user_model.dart`) - Modelo extendido de autenticación

### **Modelos de Academia:**
4. **`AcademyUserModel`** - Modelo legacy (necesita migración a Freezed)
5. **`MembershipModel`** - Membresía de usuario a academia
6. **`MemberWithProfile`** - Combinación de membresía y perfil
7. **`AcademyMember`** - Entidad de dominio unificada
8. **`AcademyMemberUserModel`** - Modelo de miembro cliente
9. **`ManagerUserModel`** - Modelo de gestor
10. **`AthleteModel`** - Modelo específico de atleta

## 🏗️ Estrategia de Gestión de Usuarios

### **1. Jerarquía de Usuarios**

```
Sistema Arcinus
├── arcinus_manager (superAdmin)
│   ├── Gestión global del sistema
│   ├── Supervisión de todas las academias
│   └── Administración de propietarios
│
└── academy_users
    ├── academy_admins (administradores)
    │   ├── propietario (owner)
    │   │   ├── Todos los permisos de la academia
    │   │   ├── Gestión de colaboradores
    │   │   └── Configuración de suscripciones
    │   │
    │   └── colaborador (partner/socio)
    │       ├── Permisos restringidos/específicos
    │       ├── Asignados por el propietario
    │       └── Gestión de usuarios según permisos
    │
    └── academy_members (miembros)
        ├── padre
        │   ├── Gestión de atletas hijos
        │   ├── Información de contacto
        │   └── Historial de pagos
        │
        └── atleta
            ├── Información física/deportiva
            ├── Métricas y rendimiento
            └── Historial médico
```

### **2. Arquitectura de Modelos Propuesta**

#### **A. Modelo Base Unificado**

```dart
// Modelo base para todos los usuarios del sistema
@freezed
class BaseUser with _$BaseUser {
  const factory BaseUser({
    required String id,           // Firebase Auth UID
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(AppRole.desconocido) AppRole globalRole,
    @Default(false) bool profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BaseUser;
}
```

#### **B. Modelo de Contexto por Academia**

```dart
// Contexto específico de un usuario en una academia
@freezed
class AcademyUserContext with _$AcademyUserContext {
  const factory AcademyUserContext({
    required String userId,       // Referencia al BaseUser
    required String academyId,
    required AppRole academyRole, // Rol específico en esta academia
    required bool isActive,
    DateTime? joinedAt,
    DateTime? lastActive,
    
    // Información específica según el rol
    Map<String, dynamic>? adminData,    // Para propietarios y colaboradores
    Map<String, dynamic>? memberData,   // Para atletas y padres
    Map<String, dynamic>? metadata,
  }) = _AcademyUserContext;
}
```

#### **C. Modelos Específicos por Rol**

```dart
// Información específica de administradores
@freezed
class AcademyAdminData with _$AcademyAdminData {
  const factory AcademyAdminData({
    required AdminType type,                    // owner | partner
    @Default([]) List<ManagerPermission> permissions,
    @Default([]) List<String> managedAcademyIds,
    ManagerStatus? status,
    DateTime? lastLoginDate,
    Map<String, dynamic>? adminMetadata,
  }) = _AcademyAdminData;
}

// Información específica de miembros
@freezed  
class AcademyMemberData with _$AcademyMemberData {
  const factory AcademyMemberData({
    required MemberType type,                   // athlete | parent
    @Default([]) List<String> relatedMemberIds, // Relaciones padre-atleta
    PaymentStatus? paymentStatus,
    
    // Datos específicos de atletas
    AthleteInfo? athleteInfo,
    
    // Datos específicos de padres
    ParentInfo? parentInfo,
    
    Map<String, dynamic>? memberMetadata,
  }) = _AcademyMemberData;
}

// Información específica de atletas
@freezed
class AthleteInfo with _$AthleteInfo {
  const factory AthleteInfo({
    DateTime? birthDate,
    String? phoneNumber,
    
    // Información física
    double? heightCm,
    double? weightKg,
    
    // Información deportiva
    String? position,
    String? specialization,
    int? experienceYears,
    
    // Información médica
    String? allergies,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    
    // Métricas deportivas
    Map<String, dynamic>? metrics,
    
    // Equipos a los que pertenece
    @Default([]) List<String> teamIds,
  }) = _AthleteInfo;
}

// Información específica de padres
@freezed
class ParentInfo with _$ParentInfo {
  const factory ParentInfo({
    String? phoneNumber,
    String? address,
    String? occupation,
    
    // Información de contacto de emergencia
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    
    // Relación con atletas
    @Default([]) List<String> athleteIds,
  }) = _ParentInfo;
}
```

### **3. Enumeraciones de Soporte**

```dart
enum AdminType {
  owner,      // Propietario
  partner,    // Socio/Colaborador
}

enum MemberType {
  athlete,    // Atleta
  parent,     // Padre/Responsable
}

enum ManagerPermission {
  // Gestión de usuarios
  manageUsers,
  inviteUsers,
  removeUsers,
  
  // Gestión financiera
  managePayments,
  viewPayments,
  manageSubscriptions,
  
  // Gestión de academia
  editAcademyInfo,
  manageSchedule,
  manageTeams,
  
  // Análisis y reportes
  viewStatistics,
  exportData,
  generateReports,
  
  // Configuración
  managePermissions,  // Solo para owners
  fullAccess,        // Acceso completo (solo owners)
}

enum ManagerStatus {
  active,      // Manager activo
  restricted,  // Acceso restringido temporalmente
  inactive,    // Manager inactivo
  suspended,   // Suspendido por el propietario
}
```

### **4. Estructura de Repositorios**

#### **A. Repositorio Base de Usuarios**

```dart
abstract class BaseUserRepository {
  // CRUD básico de usuarios
  Future<Either<Failure, BaseUser?>> getUserById(String userId);
  Future<Either<Failure, BaseUser?>> getUserByEmail(String email);
  Future<Either<Failure, void>> createUser(BaseUser user);
  Future<Either<Failure, void>> updateUser(BaseUser user);
  
  // Gestión de roles globales
  Future<Either<Failure, void>> updateGlobalRole(String userId, AppRole role);
}
```

#### **B. Repositorio de Contextos de Academia**

```dart
abstract class AcademyUserContextRepository {
  // CRUD de contextos
  Future<Either<Failure, AcademyUserContext?>> getUserContext(
    String userId, 
    String academyId
  );
  
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyUsers(
    String academyId,
    {AppRole? roleFilter}
  );
  
  Future<Either<Failure, void>> createUserContext(AcademyUserContext context);
  Future<Either<Failure, void>> updateUserContext(AcademyUserContext context);
  Future<Either<Failure, void>> removeUserFromAcademy(
    String userId, 
    String academyId
  );
  
  // Gestión de permisos para administradores
  Future<Either<Failure, void>> updateAdminPermissions(
    String userId, 
    String academyId, 
    List<ManagerPermission> permissions
  );
  
  // Gestión de relaciones padre-atleta
  Future<Either<Failure, void>> linkParentToAthlete(
    String parentId, 
    String athleteId, 
    String academyId
  );
}
```

#### **C. Repositorio de Administradores de Sistema**

```dart
abstract class ArcinusManagerRepository {
  // Gestión de super administradores
  Future<Either<Failure, List<BaseUser>>> getSuperAdmins();
  Future<Either<Failure, void>> promoteToSuperAdmin(String userId);
  Future<Either<Failure, void>> revokeSuperAdmin(String userId);
  
  // Supervisión global
  Future<Either<Failure, List<AcademyModel>>> getAllAcademies();
  Future<Either<Failure, Map<String, dynamic>>> getSystemStatistics();
  
  // Gestión de propietarios
  Future<Either<Failure, List<BaseUser>>> getAllOwners();
  Future<Either<Failure, void>> suspendAcademy(String academyId, String reason);
}
```

### **5. Casos de Uso Principales**

#### **A. Gestión de Administradores**

```dart
class ManageAcademyAdminsUseCase {
  // Promover usuario a administrador
  Future<Either<Failure, void>> promoteToAdmin(
    String userId,
    String academyId,
    AdminType type,
    List<ManagerPermission> permissions,
  );
  
  // Actualizar permisos de colaborador
  Future<Either<Failure, void>> updatePartnerPermissions(
    String partnerId,
    String academyId,
    List<ManagerPermission> newPermissions,
  );
  
  // Remover administrador
  Future<Either<Failure, void>> removeAdmin(
    String adminId,
    String academyId,
  );
}
```

#### **B. Gestión de Miembros**

```dart
class ManageAcademyMembersUseCase {
  // Añadir atleta
  Future<Either<Failure, void>> addAthlete(
    String userId,
    String academyId,
    AthleteInfo athleteInfo,
  );
  
  // Añadir padre y vincular con atletas
  Future<Either<Failure, void>> addParentWithAthletes(
    String userId,
    String academyId,
    ParentInfo parentInfo,
    List<String> athleteIds,
  );
  
  // Actualizar información de atleta
  Future<Either<Failure, void>> updateAthleteInfo(
    String athleteId,
    String academyId,
    AthleteInfo newInfo,
  );
}
```

#### **C. Gestión de Sistema (Arcinus Manager)**

```dart
class ArcinusManagerUseCase {
  // Supervisión global
  Future<Either<Failure, SystemOverview>> getSystemOverview();
  
  // Gestión de academias
  Future<Either<Failure, void>> suspendAcademy(
    String academyId,
    String reason,
    DateTime? until,
  );
  
  // Gestión de propietarios
  Future<Either<Failure, void>> transferAcademyOwnership(
    String academyId,
    String currentOwnerId,
    String newOwnerId,
  );
}
```

### **6. Estructura de Base de Datos**

#### **Firestore Collections Structure:**

```
/users/{userId}                           // BaseUser data
  - email, displayName, photoUrl, globalRole, etc.

/academy_contexts/{userId}_{academyId}     // AcademyUserContext
  - userId, academyId, academyRole, isActive, etc.
  - adminData: {...}  // Si es admin
  - memberData: {...} // Si es member

/academies/{academyId}
  - Basic academy info
  
  /users/{userId}                         // Usuario específico en esta academia
    - Referencia al context + datos específicos cached
    
  /admins/{userId}                        // Solo administradores
    - Datos específicos de administración
    
  /members/{userId}                       // Solo miembros (atletas/padres)
    - Datos específicos de membresía

/system/                                  // Para Arcinus Managers
  /statistics/                            // Estadísticas globales
  /audit_logs/                           // Logs de auditoría
```

### **7. Migración Gradual**

#### **Fase 1: Unificación de Modelos Base**
1. Migrar `AcademyUserModel` a Freezed
2. Consolidar modelos duplicados de `UserModel`
3. Implementar `BaseUser` como modelo principal

#### **Fase 2: Implementación de Contextos**
1. Crear `AcademyUserContext` 
2. Actualizar repositorios para usar contextos

#### **Fase 3: Especialización por Roles**
1. Implementar modelos específicos (`AthleteInfo`, `ParentInfo`, etc.)
2. Migrar datos específicos de cada rol
3. Actualizar UI para usar nuevos modelos

#### **Fase 4: Sistema de Arcinus Manager**
1. Implementar funcionalidades de super administrador
2. Crear dashboard de supervisión global
3. Implementar herramientas de auditoría

### **8. Beneficios de la Estrategia**

#### **✅ Ventajas:**
- **Separación clara de responsabilidades** entre roles
- **Escalabilidad** para múltiples academias por usuario
- **Flexibilidad** en permisos granulares
- **Mantenibilidad** con arquitectura limpia
- **Consistencia** en el manejo de datos
- **Auditoría** completa de acciones del sistema

#### **🔒 Seguridad:**
- Validación de permisos en múltiples capas
- Roles específicos por academia
- Sistema de auditoría integral
- Gestión centralizada de accesos

#### **📈 Escalabilidad:**
- Soporte para múltiples academias por usuario
- Permisos granulares configurables
- Sistema preparado para crecimiento futuro
- Arquitectura modular y extensible

### **9. Implementación Recomendada**

1. **Comenzar con la unificación** de modelos existentes
2. **Implementar repositorios** siguiendo el patrón establecido
3. **Migrar gradualmente** las funcionalidades existentes
4. **Añadir nuevas funcionalidades** de Arcinus Manager
5. **Optimizar rendimiento** según métricas de uso

Esta estrategia proporciona una base sólida para el crecimiento futuro del sistema mientras mantiene la compatibilidad con el código existente. 