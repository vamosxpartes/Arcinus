# Módulo de Autenticación

## Descripción General
El módulo de autenticación gestiona todos los procesos relacionados con la identidad de los usuarios en la aplicación Arcinus, incluyendo registro, inicio de sesión, cierre de sesión y gestión de perfiles. Este módulo se integra con Firebase Authentication y Firestore para proporcionar una solución de autenticación robusta y escalable.

## Estructura del Módulo

### Arquitectura
El módulo sigue la arquitectura de capas, separando claramente:
- **Data**: Modelos (`user_model.dart`) y Repositorios (`auth_repository.dart`, `user_repository_impl.dart`)
- **Presentation**: Providers (`auth_providers.dart`, `user_profile_provider.dart`, etc.), Estado (`auth_state.dart`, `complete_profile_state.dart`) y UI (Screens y Widgets)
- **Domain**: Lógica de negocio (Casos de Uso como `arcinus_manager_usecase.dart`) y Entidades/Interfaces de Repositorio (`base_user_repository.dart`, `user_repository.dart`).

### Modelo Principal
- `BaseUser`: Ubicado en `lib/core/auth/models/base_user.dart`, representa la información básica común a cualquier usuario en el sistema.
- `User` (Entidad de Dominio): Definido en `lib/core/auth/user.dart`, utilizado frecuentemente en la capa de dominio y presentación.
- `UserModel`: Ubicado en `lib/core/auth/data/models/user_model.dart`, es la implementación concreta del modelo de usuario utilizado para la persistencia en Firestore.
- `AcademySpecificModels`: En `lib/core/auth/models/academy_specific_models.dart`, contiene modelos para contextos específicos de academias.
- `AcademyUserContext`: En `lib/core/auth/models/academy_user_context.dart`, define el contexto de un usuario dentro de una academia.
- `AuthState`: Definido en `lib/core/auth/presentation/providers/auth_state.dart` (usando `freezed`), representa los diferentes estados del proceso de autenticación (inicial, cargando, autenticado, no autenticado, error). También existe una definición en `lib/core/auth/presentation/state/auth_state.dart` que incluye `AuthStatus` enum.

### Repositorio de Autenticación
- `AuthRepository`: Interfaz y su implementación concreta se encuentran en `lib/core/auth/data/repositories/auth_repository.dart`. Utiliza Firebase Authentication directamente para las operaciones de autenticación.
- `UserRepository`: Interfaz en `lib/core/auth/domain/repositories/user_repository.dart`.
- `UserRepositoryImpl`: Implementación en `lib/core/auth/data/repositories/user_repository_impl.dart`, maneja la lógica de Firestore para los datos del usuario.
- `BaseUserRepository`: Interfaz en `lib/core/auth/domain/repositories/base_user_repository.dart`.
- `ArcinusManagerRepository`: Interfaz en `lib/core/auth/domain/repositories/arcinus_manager_repository.dart`.
- `AcademyUserContextRepository`: Interfaz en `lib/core/auth/domain/repositories/academy_user_context_repository.dart`.

### Domain
#### Casos de Uso (Use Cases)
- `ArcinusManagerUsecase`: Ubicado en `lib/core/auth/domain/usecases/arcinus_manager_usecase.dart`, maneja la lógica relacionada con la gestión de Arcinus.
- `ManageAcademyMembersUsecase`: En `lib/core/auth/domain/usecases/manage_academy_members_usecase.dart`, para la gestión de miembros de una academia.
- `ManageAcademyAdminsUsecase`: En `lib/core/auth/domain/usecases/manage_academy_admins_usecase.dart`, para la gestión de administradores de una academia.

## Flujos Principales

### 1. Registro de Usuario Mejorado
1. Usuario accede al formulario de registro por pasos:
   - **Paso 1**: Credenciales (email/contraseña) con validación en tiempo real
   - **Paso 2**: Información de perfil (nombre, apellido, foto)
   - **Paso 3**: Confirmación y términos de servicio
2. Se crea cuenta en Firebase Authentication
3. Se crea documento inicial en colección `users` de Firestore
4. Usuario completa su perfil con foto de perfil opcional
5. Al completar perfil, se actualiza el documento en Firestore
6. Se redirecciona al usuario según su rol

### 2. Inicio de Sesión
1. Usuario ingresa credenciales
2. Sistema valida contra Firebase Authentication
3. Se obtiene información básica del usuario
4. Se redirecciona según el rol y estado del usuario

### 3. Completar Perfil
1. Usuario nuevo o existente accede a la pantalla de perfil
2. Puede actualizar información personal y foto de perfil
3. Los cambios se guardan en Firestore
4. Se actualizan los proveedores de estado

### 4. Invitación de Usuarios
1. Un usuario gestor puede invitar a otros usuarios
2. Se especifica email y rol del invitado
3. Se crea cuenta y documento en Firestore
4. El invitado recibe notificación para completar registro

## Providers y Estado (Riverpod)

### Auth State Management
- `authStateChangesProvider`: En `lib/core/auth/presentation/providers/auth_providers.dart`, provee un stream de los cambios en el estado de autenticación de Firebase.
- `currentUserProvider`: En `lib/core/auth/presentation/providers/auth_providers.dart`, provee el usuario de Firebase actual.
- `authStateNotifierProvider`: En `lib/core/auth/presentation/providers/auth_providers.dart`, un `NotifierProvider` que gestiona `AuthState` (definido con `freezed`) y expone métodos para iniciar sesión, registrar, cerrar sesión, etc., actualizando el estado correspondientemente.
- `completeProfileProvider`: Aunque no hay un provider con este nombre exacto, la lógica para completar el perfil se maneja a través de `CompleteProfileState` en `lib/core/auth/presentation/state/complete_profile_state.dart` y los providers relacionados con la actualización del perfil de usuario.
- `userProfileProvider`: Se encuentra en `lib/core/auth/presentation/providers/user_profile_provider.dart`, proporciona información del perfil del usuario actual y permite su actualización.
- `registrationFormProvider`: Ubicado en `lib/core/auth/presentation/providers/registration_form_provider.dart`, gestiona el estado y la persistencia del formulario de registro multi-paso.
- `AcademyMembersProviders`: Colección de providers en `lib/core/auth/presentation/providers/academy_members_providers.dart` para gestionar miembros de academias.
- `ArcinusManagerProviders`: Colección de providers en `lib/core/auth/presentation/providers/arcinus_manager_providers.dart` para la gestión de Arcinus.
- `AcademyAdminProviders`: Colección de providers en `lib/core/auth/presentation/providers/academy_admin_providers.dart` para la gestión de administradores de academias.

### Persistencia de Datos
- Utiliza Hive para almacenamiento local de datos de registro
- Implementa persistencia para permitir completar el registro en sesiones múltiples
- Protege datos sensibles evitando almacenar contraseñas

## Pantallas Principales

- **WelcomeScreen**: Pantalla inicial de la aplicación
- **LoginScreen**: Formulario de inicio de sesión
- **RegisterScreen**: Formulario de registro por pasos (`lib/core/auth/presentation/ui/screens/register_screen.dart`)
- **CompleteProfileScreen**: No existe como pantalla separada con ese nombre exacto, pero la funcionalidad de completar/editar perfil está integrada, probablemente dentro de una pantalla de perfil general que utiliza `userProfileProvider`.
- **MemberAccessScreen**: Pantalla para el acceso de miembros (`lib/core/auth/presentation/ui/screens/member_access_screen.dart`)

## Características de UX Mejoradas

- **Indicador de fortaleza de contraseña**: Retroalimentación visual en tiempo real
- **Validación instantánea**: Mensajes de error contextuales y específicos
- **Persistencia de progreso**: Recuperación automática del avance en el registro
- **Gestión de imágenes de perfil**: Selección desde galería o cámara con previsualización
- **Detección de conectividad**: Soporte para modo offline durante el registro
- **Diseño adaptativo**: Optimizado para diferentes tamaños de pantalla

## Integración con Navigation Shell

El módulo define comportamientos de redirección en función del estado de autenticación:
- Usuarios no autenticados: Redirigidos a pantallas de autenticación
- Usuarios autenticados con perfil incompleto: Redirigidos a completar perfil
- Usuarios autenticados según rol:
  - Propietarios: Panel de academia (o creación si no tiene)
  - Colaboradores: Panel de academia asignada
  - Atletas/Padres: Panel de cliente
  - Superadministradores: Panel administrativo

## Estructura en Firestore

La estructura principal sigue en `/users/{userId}`. Los campos exactos deben ser consistentes con `UserModel` (`lib/core/auth/data/models/user_model.dart`) y `BaseUser` (`lib/core/auth/models/base_user.dart`).
```
/users/               # Colección principal de usuarios
  ├── {userId}/       # Documento por cada usuario
      ├── email       # Correo del usuario (de BaseUser, UserModel)
      ├── displayName # Nombre completo (de BaseUser, UserModel)
      ├── photoUrl    # URL de la foto de perfil (de BaseUser, UserModel)
      ├── appRole     # Rol principal (e.g., propietario, colaborador, atleta) (de UserModel, referenciado por AppRole en `lib/core/auth/app_role.dart`)
      ├── profileCompleted # Booleano, indica si completó su perfil inicial (de UserModel)
      ├── createdAt   # Fecha de creación (Timestap de Firestore, gestionado por BaseUser, UserModel)
      ├── updatedAt   # Última actualización (Timestamp de Firestore, gestionado por BaseUser, UserModel)
      ├── # Otros campos específicos del rol o adicionales según BaseUser/UserModel
```

## Mejores Prácticas

1. **Seguridad**: Implementar reglas de Firestore y Storage para proteger datos
2. **Validación**: Validar entradas en cliente y servidor
3. **Manejo de errores**: Mostrar mensajes amigables para problemas de autenticación
4. **Persistencia**: Manejar adecuadamente la persistencia de sesión
5. **Desacoplamiento**: Separar lógica de UI y mantener repositorios independientes
6. **Almacenamiento local**: Utilizar Hive para persistencia segura y eficiente

## Casos de Error Comunes

- Correo electrónico ya en uso
- Contraseña débil
- Problemas de conexión con Firebase
- Cuenta deshabilitada
- Credenciales inválidas

## Interacción con Otros Módulos

- **Módulo de Usuarios**: Utiliza la información básica de auth para extender con datos específicos
- **Módulo de Academias**: Verifica permisos y roles para operaciones administrativas
- **Módulo de Pagos**: Consulta identificación de usuarios para asociar pagos

## Mejoras Futuras

- Implementar autenticación con redes sociales (Google, Apple)
- Añadir autenticación por número de teléfono
- Implementar recuperación de cuenta con validación adicional
- Añadir autenticación de dos factores para mayor seguridad 