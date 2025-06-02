# Módulo de Usuarios de Academia en Arcinus
do
## Descripción General
El módulo de academy_users proporciona un sistema completo para gestionar los diferentes tipos de usuarios dentro de las academias deportivas. Incluye funcionalidades para gestionar atletas, padres, gestores (propietarios y colaboradores), sus permisos, suscripciones y relaciones entre ellos.

## Arquitectura del Módulo

El módulo sigue una arquitectura limpia con las siguientes capas:

### 📁 Estructura de Directorios
```
lib/features/academy_users/
├── data/                     # Capa de datos
│   ├── models/              # Modelos de datos
│   │   ├── manager/         # Modelos específicos de gestores
│   │   └── member/          # Modelos específicos de miembros
│   └── repositories/        # Implementación de repositorios
├── domain/                  # Capa de dominio
│   ├── entities/           # Entidades de negocio
│   └── repositories/       # Interfaces de repositorios
└── presentation/            # Capa de presentación
    ├── screens/            # Pantallas de la aplicación
    ├── widgets/            # Widgets reutilizables
    ├── providers/          # Providers de Riverpod
    └── state/              # Estados de la aplicación
```

## Entidades de Dominio

### 1. AthleteModel (`domain/entities/athlete_model.dart`)
Representa un atleta dentro de la academia:

```dart
@freezed
class AthleteModel with _$AthleteModel {
  const factory AthleteModel({
    String? id,
    required String userId,
    required String academyId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? phoneNumber,
    
    // Información física
    double? heightCm,
    double? weightKg,
    
    // Información de salud
    String? allergies,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    
    // Información deportiva
    String? position,
    
    // Imagen de perfil
    String? profileImageUrl,
    
    // Meta información
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AthleteModel;
}
```

### 2. AcademyMember (`domain/entities/academy_member.dart`)
Entidad genérica que representa cualquier miembro de la academia:

```dart
@freezed
class AcademyMember with _$AcademyMember {
  const factory AcademyMember({
    String? id,
    required String userId,
    required String academyId,
    required AppRole role,
    required String name,
    String email,
    String phone,
    String photoUrl,
    bool isActive,
    
    // Datos específicos según el tipo de miembro
    Map<String, dynamic> sportData,
    Map<String, dynamic> metrics,
    Map<String, dynamic> medicalInfo,
    Map<String, dynamic> contactInfo,
    
    // Relaciones
    List<String> relatedMemberIds,
    List<String> teamIds,
    
    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    
    // Metadatos adicionales
    Map<String, dynamic> metadata,
  }) = _AcademyMember;
}
```

### 3. ManagerUserModel (`data/models/manager/academy_manager_model.dart`)
Modelo específico para usuarios gestores (propietarios y colaboradores):

```dart
@freezed
class ManagerUserModel with _$ManagerUserModel {
  const factory ManagerUserModel({
    String? id,
    required String userId,
    required String academyId,
    required AppRole managerType,
    ManagerStatus status,
    List<ManagerPermission> permissions,
    List<String> managedAcademyIds,
    DateTime? lastLoginDate,
    int academyCount,
    int managedUsersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic> metadata,
  }) = _ManagerUserModel;
}
```

## Enumeraciones

### ManagerStatus (`data/models/manager/academy_manager_status.dart`)
```dart
enum ManagerStatus {
  active,      // Manager activo con permisos completos
  restricted,  // Manager con acceso restringido temporalmente
  inactive,    // Manager inactivo, sin acceso
}
```

### ManagerPermission (`data/models/manager/academy_manager_permission.dart`)
```dart
enum ManagerPermission {
  manageUsers,        // Gestionar usuarios
  managePayments,     // Gestionar pagos
  manageSubscriptions,// Gestionar suscripciones
  viewStats,          // Ver estadísticas
  editAcademy,        // Modificar configuración de academia
  manageSchedule,     // Gestionar horarios
  fullAccess,         // Acceso completo (solo propietarios)
}
```

## Pantallas (Presentation Layer)

### 1. `academy_users_manage_screen.dart`
Pantalla principal para gestionar todos los miembros de la academia:
- Lista de miembros con filtros por tipo
- Búsqueda en tiempo real
- Opciones para añadir nuevos miembros
- Pull-to-refresh para actualización de datos
- Gestión automática del lifecycle de la app

### 2. `add_athlete_screen.dart`
Formulario completo para registrar nuevos atletas:
- Información personal básica
- Datos físicos (altura, peso)
- Información médica y de emergencia
- Datos deportivos (posición, experiencia)
- Subida de foto de perfil
- Validación en tiempo real

### 3. `academy_user_details_screen.dart`
Pantalla de detalles de un usuario específico:
- Información completa del usuario
- Historial de pagos y suscripciones
- Opciones de edición
- Gestión de relaciones (padre-atleta)

### 4. `academy_member_details_screen.dart`
Similar a la anterior pero enfocada en la entidad AcademyMember:
- Vista detallada de miembros
- Métricas deportivas
- Información de contacto de emergencia

### 5. `invite_member_screen.dart`
Pantalla para invitar nuevos miembros vía email:
- Formulario de invitación
- Selección del rol del nuevo miembro
- Gestión de invitaciones pendientes

### 6. `edit_permissions_screen.dart`
Pantalla para gestionar permisos de colaboradores:
- Lista de permisos disponibles
- Asignación/revocación de permisos
- Vista previa de permisos efectivos

### 7. `edit_athlete_screen.dart`
Formulario de edición para atletas existentes:
- Actualización de información personal
- Modificación de datos deportivos
- Actualización de foto de perfil

### 8. `member_details_screen.dart`
Vista general de detalles de cualquier tipo de miembro.

### 9. `profile_screen.dart`
Pantalla de perfil del usuario actual.

## Widgets Reutilizables

### 1. `academy_user_card.dart`
Tarjeta que muestra información resumida de un usuario:
- Foto de perfil
- Información básica
- Estado de pagos
- Acciones rápidas

### 2. `academy_payment_avatars_section.dart`
Sección que muestra avatares de usuarios con estado de pagos:
- Agrupación por estado de pago
- Indicadores visuales de estado
- Navegación a detalles

### 3. `payment_progress_bar.dart`
Barra de progreso para mostrar estado de pagos:
- Progreso visual del ciclo de facturación
- Fechas importantes
- Estados de pago

### 4. `payment_status_badge.dart`
Badge que indica el estado de pago de un usuario:
- Códigos de color por estado
- Textos descriptivos
- Íconos representativos

## Providers (Riverpod)

### Providers de Estado de UI
- `invite_member_provider.dart`: Gestiona el estado de invitación de miembros
- `edit_permissions_provider.dart`: Gestiona el estado de edición de permisos
- `add_athlete_providers.dart`: Gestiona el estado del formulario de añadir atleta
- `academy_member_provider.dart`: Gestiona el estado de los miembros de la academia

### Providers de Datos
- `academy_users_providers.dart`: Provee acceso a los datos de usuarios de la academia
- `membership_providers.dart`: Gestiona los datos de membresías
- `permission_provider.dart`: Gestiona los permisos de usuarios

### Providers Principales
- `academy_providers.dart`: Providers generales para la funcionalidad de academias

## Estados de la Aplicación

### 1. `invite_member_state.dart`
```dart
@freezed
class InviteMemberState with _$InviteMemberState {
  const factory InviteMemberState({
    @Default(false) bool isLoading,
    @Default('') String email,
    AppRole? selectedRole,
    String? errorMessage,
    @Default(false) bool isSuccess,
  }) = _InviteMemberState;
}
```

### 2. `add_athlete_state.dart`
```dart
@freezed
class AddAthleteState with _$AddAthleteState {
  const factory AddAthleteState({
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? errorMessage,
    // Campos del formulario
    @Default('') String firstName,
    @Default('') String lastName,
    DateTime? birthDate,
    @Default('') String phoneNumber,
    // ... más campos
  }) = _AddAthleteState;
}
```

## Repositorios

### 1. `academy_users_repository.dart`
Repositorio principal para operaciones con usuarios de academia:
- CRUD de usuarios
- Búsqueda y filtrado
- Gestión de relaciones usuario-academia

### 2. `academy_members_repository.dart`
Repositorio específico para miembros de academia:
- Operaciones con la entidad AcademyMember
- Gestión de datos específicos por rol

### 3. `membership_repository_impl.dart`
Implementación del repositorio de membresías:
- Gestión de suscripciones
- Estados de pago
- Ciclos de facturación

### 4. `academy_member_repository_impl.dart`
Implementación específica para miembros de academia:
- Operaciones complejas con miembros
- Gestión de relaciones padre-atleta
- Actualización de métricas

## Modelos de Datos

### Modelos Principales
- `membership_model.dart`: Modelo de membresía y suscripción
- `member_with_profile.dart`: Modelo combinado de miembro con perfil
- `academy_member_model.dart`: Modelo específico de miembro de academia
- `academy_manager_model.dart`: Modelo de gestor de academia

### Extensiones y Utilidades
- `academy_manager_extensions.dart`: Extensiones para el modelo de manager
- Archivos `.freezed.dart` y `.g.dart`: Generados automáticamente por code generation

## Flujos Principales

### 1. Gestión de Atletas
1. **Añadir Atleta**: `add_athlete_screen.dart` → `add_athlete_providers.dart` → `academy_users_repository.dart`
2. **Editar Atleta**: `edit_athlete_screen.dart` → providers → repositorio
3. **Ver Detalles**: `academy_user_details_screen.dart` → providers específicos

### 2. Gestión de Permisos
1. **Editar Permisos**: `edit_permissions_screen.dart` → `edit_permissions_provider.dart`
2. **Validar Permisos**: Extensiones de `ManagerUserModel`

### 3. Invitación de Miembros
1. **Invitar**: `invite_member_screen.dart` → `invite_member_provider.dart`
2. **Gestionar Invitaciones**: Provider de estado → repositorio

### 4. Gestión de Pagos
1. **Visualizar Estados**: `academy_payment_avatars_section.dart`
2. **Actualizar Información**: Lifecycle management en pantallas principales
3. **Progreso de Pagos**: `payment_progress_bar.dart`

## Integración con Otros Módulos

### Módulo de Autenticación
- Obtención del usuario actual
- Validación de roles y permisos
- Gestión de sesiones

### Módulo de Pagos
- Estados de pago de usuarios
- Información de suscripciones
- Ciclos de facturación

### Módulo de Academias
- Relación usuario-academia
- Configuración específica por academia
- Jerarquías de permisos

## Características Técnicas

### Gestión de Estado
- **Riverpod** para gestión reactiva del estado
- **Freezed** para inmutabilidad de modelos
- **Code Generation** para serialización JSON

### Persistence
- **Cloud Firestore** como base de datos principal
- **Repositorio Pattern** para abstracción de datos
- **Timestamps automáticos** para auditoría

### UI/UX
- **Material 3** design system
- **Pull-to-refresh** para actualización de datos
- **Búsqueda en tiempo real** con debouncing
- **Lifecycle management** para optimización de rendimiento

### Validación
- **Validación en tiempo real** en formularios
- **Validación de permisos** antes de operaciones
- **Validación de datos** en modelos

## Mejores Prácticas Implementadas

1. **Arquitectura Limpia**: Separación clara entre capas
2. **Immutabilidad**: Uso de Freezed para modelos inmutables
3. **Type Safety**: Uso extensivo de tipos fuertes
4. **Error Handling**: Manejo consistente de errores
5. **Performance**: Optimizaciones de rendimiento y memory management
6. **Testing**: Estructura preparada para testing
7. **Accessibility**: Consideraciones de accesibilidad en widgets
8. **Logging**: Sistema de logging integrado con AppLogger

## Próximas Mejoras

### Funcionalidades Pendientes
- [ ] Sistema completo de invitaciones por email
- [ ] Gestión avanzada de equipos
- [ ] Dashboard de métricas deportivas
- [ ] Sistema de notificaciones push
- [ ] Integración con sistemas de pago externos
- [ ] API REST para integraciones externas
- [ ] Sistema de reportes avanzados

### Mejoras Técnicas
- [ ] Testing completo (unit, widget, integration)
- [ ] Optimizaciones de performance adicionales
- [ ] Implementación de caché offline
- [ ] Mejoras en la gestión de imágenes
- [ ] Internacionalización completa
- [ ] Mejoras en accesibilidad

## Consideraciones de Seguridad

1. **Validación de Permisos**: Verificación constante de permisos en operaciones sensibles
2. **Sanitización de Datos**: Validación y sanitización en formularios
3. **Auditoría**: Timestamps y logging de operaciones importantes
4. **Acceso Granular**: Sistema de permisos específicos por funcionalidad
5. **Protección de Datos**: Manejo seguro de información personal y médica 