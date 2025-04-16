# Feature: Auth

## 1. Nombre del Feature y Resumen
**Nombre:** Auth
**Propósito/Objetivo:** Gestionar la autenticación y autorización de usuarios en la aplicación, permitiendo el registro, inicio de sesión y gestión de credenciales.
**Alcance:** Pre-registro y registro de usuarios, inicio de sesión, restablecimiento de contraseñas, mantenimiento del estado de autenticación y gestión de perfiles.

## 2. Estructura de Archivos Clave
* `lib/features/auth/core/repositories/auth_repository.dart` - Interfaz para el repositorio de autenticación
* `lib/features/auth/core/repositories/firebase_auth_repository.dart` - Implementación de Firebase Auth
* `lib/features/auth/core/providers/auth_providers.dart` - Proveedores de estado de autenticación
* `lib/features/auth/core/models/pre_registered_user.dart` - Modelo para usuarios pre-registrados
* `lib/features/auth/screens/signin_screen.dart` - Pantalla de inicio de sesión
* `lib/features/auth/screens/register_screen.dart` - Pantalla de registro de usuarios
* `lib/features/auth/screens/pre_register_screen.dart` - Pantalla de gestión de pre-registros
* `lib/features/auth/screens/activation_screen.dart` - Pantalla para activación de cuentas pre-registradas
* `lib/features/auth/screens/forgot_password_screen.dart` - Pantalla de recuperación de contraseña
* `lib/features/auth/screens/login_screen.dart` - Pantalla principal de login

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* `SigninScreen` - Pantalla de inicio de sesión con email y contraseña, incluye opción para activar cuenta con código
* `RegisterScreen` - Pantalla de registro de nuevos usuarios
* `PreRegisterScreen` - Pantalla para que administradores creen pre-registros
* `ActivationScreen` - Pantalla para que usuarios pre-registrados activen sus cuentas
* `ForgotPasswordScreen` - Pantalla para solicitar restablecimiento de contraseña
* `LoginScreen` - Pantalla principal de acceso que gestiona el flujo de autenticación

### Widgets Reutilizables
* Componentes de formulario de autenticación
* Botones y campos de entrada estilizados según el tema de la aplicación
* Componentes para la gestión y visualización de códigos de activación

### Proveedores (Providers)
* `authRepositoryProvider` - Proporciona la implementación del repositorio de autenticación
* `authStateChangesProvider` - Stream con los cambios en el estado de autenticación
* `currentUserProvider` - Información del usuario actual autenticado
* `preRegisteredUsersProvider` - Lista de usuarios pre-registrados

### Modelos de Datos (Models)
* Utiliza el modelo `User` de la aplicación para la información del usuario autenticado
* Utiliza `UserRole` para definir los roles de usuario (Atleta, Entrenador, Manager, etc.)
* `PreRegisteredUser` - Modelo para almacenar información de pre-registros pendientes

### Servicios/Controladores
* Controladores para la validación de formularios de autenticación
* Servicios para la gestión de tokens y sesiones
* Controladores para la gestión de códigos de activación

### Repositorios
* `AuthRepository` - Interfaz abstracta para implementaciones de autenticación
* `FirebaseAuthRepository` - Implementación con Firebase Authentication

## 4. Flujo de Usuario (User Flow)

### Flujo de Pre-registro
1. El administrador accede a la pantalla de pre-registro o utiliza los formularios de creación de usuarios en el módulo de gestión de usuarios.
2. Introduce el **nombre y rol** del nuevo usuario. **Importante: No se solicita ni guarda el correo electrónico en este paso.**
3. El sistema (usando `createPreRegisteredUserProvider` o similar):
   - Genera un código de activación único (`activationCode`).
   - Crea un **nuevo documento** en la subcolección de la academia correspondiente: `academies/{academyId}/pendingActivations/{activationCode}`. El ID del documento es el propio código.
   - **Contenido del Documento:** Guarda la información temporal necesaria: `{ name: '...', role: '...', createdBy: '...', createdAt: ... }`.
   - **Nota:** Este paso NO crea un usuario en `academies/{academyId}/users` ni en Firebase Auth.
4. El administrador comparte el `activationCode` con el usuario final.

### Flujo de Activación de Cuenta
1. El usuario recibe un código de activación de un administrador.
2. Accede a la pantalla de inicio de sesión y selecciona "Activar cuenta con código".
3. Introduce el `activationCode`.
4. El sistema intenta leer el documento `academies/{relevantAcademyId}/pendingActivations/{activationCode}`.
   - Si existe, recupera `name` y `role`.
   - Si no existe, el código es inválido o ya fue usado.
5. **El usuario proporciona su propio correo electrónico y establece su contraseña en esta pantalla.**
6. El sistema (usando `completeRegistrationProvider` o similar):
   - Llama a `AuthRepository.signUpWithEmailAndPassword(...)` para crear la cuenta en Firebase Authentication, obteniendo el `authUid`.
   - Llama a `UserService.createUser(...)` (o una función similar interna) para crear el registro de usuario final en `academies/{academyId}/users/{authUid}`, usando el `authUid` como ID del documento y guardando `name`, `role`, `email` y otros datos.
   - **Elimina** el documento temporal `academies/{academyId}/pendingActivations/{activationCode}`.
   - Inicia sesión al usuario.

### Flujo Normal de Autenticación
1. El usuario accede a la pantalla de inicio de sesión
2. Inicia sesión con sus credenciales existentes
3. Puede solicitar el restablecimiento de contraseña si la olvidó
4. Al autenticarse, se mantiene la sesión y se redirige al dashboard

## 5. Gestión de Estado (State Management)
* Utiliza Riverpod para la gestión del estado de autenticación
* Mantiene el estado global de autenticación a través de providers
* Implementa streams para reaccionar a cambios en el estado de autenticación
* Gestiona el estado de pre-registros y activaciones

## 6. Interacción con Backend/Datos
* Integración con Firebase Authentication para la gestión de credenciales
* Almacenamiento de información de perfil en Firestore (en la colección `users` dentro de cada academia).
* Almacenamiento de pre-registros temporales en la subcolección `pendingActivations` dentro de cada documento de academia (`academies/{id}/pendingActivations/{code}`).
* Subida de imágenes de perfil a Firebase Storage

## 7. Dependencias
**Internas:** 
* Feature de Storage para la persistencia local de información de sesión
* Feature de Usuarios para la gestión de perfiles

**Externas:** 
* Firebase Authentication para la gestión de credenciales
* Firebase Firestore para almacenamiento de datos de usuario y pre-registros
* Firebase Storage para las imágenes de perfil
* Riverpod para la gestión de estado

## 8. Decisiones Arquitectónicas / Notas Importantes
* Patrón Repository para abstraer la implementación de autenticación
* Implementación basada en Firebase pero con capacidad de cambiar el proveedor
* Sistema de roles integrado desde el pre-registro
* Sistema de códigos de activación con expiración temporal (almacenados como documentos en `pendingActivations` dentro de la academia).
* Capacidad de almacenamiento local para acceso offline
* **Desacoplamiento:** La gestión de datos de usuario en Firestore (`UserService`) está separada de la gestión de cuentas de autenticación (`AuthRepository`). `UserService` no crea/modifica directamente cuentas de Auth.
* **Almacenamiento de Pre-registro:** Se utiliza una subcolección `pendingActivations` dentro de cada academia para los registros temporales, en lugar de una colección raíz.

## 9. Registro de Cambios
* Implementación inicial con Firebase Authentication
* Adición de recuperación de contraseña
* Integración de roles de usuario en el proceso de registro
* Implementación del sistema de pre-registro y activación de cuentas
  * Creación del modelo `PreRegisteredUser` para gestionar usuarios pre-registrados
  * Implementación de generación y verificación de códigos de activación
  * Adición de pantallas para la gestión de pre-registros y activación de cuentas
  * Integración de flujo de completar registro para usuarios pre-registrados
  * Implementación de controles de permisos para acceso al sistema de pre-registro
* Mejora en el flujo de redirección automática después de autenticación
  * Implementación de verificación y escucha del estado de autenticación en LoginScreen
  * Redirección automática al dashboard cuando el usuario ya está autenticado
* Mejora en el flujo de cierre de sesión
  * Implementación de redirección automática a login cuando el usuario cierra sesión desde el perfil
  * Corrección de comportamiento para no mostrar vista estática cuando no hay sesión
* Integración con sistema centralizado de middleware de autenticación:
  * Reemplazo de lógica de redirección manual por sistema centralizado mediante AuthScaffold
  * Implementación de redirección automática basada en estado de autenticación
  * Estandarización del manejo de sesiones en toda la aplicación
* Integración de pre-registro en el flujo principal de autenticación:
  * Adición de botón "Activar cuenta con código" en la pantalla de inicio de sesión
  * Mejora del flujo de activación de cuentas para mejor experiencia de usuario
  * Vinculación con el sistema de gestión de usuarios para facilitar el pre-registro desde múltiples puntos de la aplicación
* Mejora del flujo de activación de cuentas para mejor experiencia de usuario
  * Vinculación con el sistema de gestión de usuarios para facilitar el pre-registro desde múltiples puntos de la aplicación
* Simplificación del proceso de creación de usuarios (v1.5.0)
  * Eliminación de la opción de creación directa, estableciendo el pre-registro como único método de creación de usuarios
  * Modificación del formulario de creación para eliminar la solicitud de correo electrónico
  * Actualización del proceso de activación para permitir al usuario proporcionar su propio correo electrónico
  * Mejora de la seguridad y privacidad al permitir que los usuarios proporcionen sus propias credenciales
* **Modificación del flujo de pre-registro y desacoplamiento de UserService (v1.6.0 o posterior):**
  * **El correo electrónico ya no se solicita ni se guarda durante la creación del pre-registro.**
  * **El usuario proporciona su correo electrónico directamente en la pantalla de activación junto con su contraseña.**
  * Actualización de `AuthRepository`, `FirebaseAuthRepository` y providers (`createPreRegisteredUserProvider`, `completeRegistrationProvider`) para reflejar este cambio.
  * Modificación de `UserService` para que sus métodos CRUD (crear, actualizar) operen únicamente sobre Firestore, sin interactuar con Firebase Auth.
  * **Cambio en almacenamiento de pre-registro:** Los datos temporales de pre-registro se guardan ahora en la subcolección `academies/{id}/pendingActivations/{code}` en lugar de una colección raíz `preRegisteredUsers`.

## 10. Puntos por Completar (Nuevo Flujo de Activación)

Para finalizar la implementación del flujo de activación mediante `pendingActivations`:

1.  **Implementar `_getCurrentAcademyId()`:**
    *   Reemplazar la lógica placeholder en `ParentFormScreen`, `CoachFormScreen` (y los demás formularios) para obtener correctamente el ID de la academia activa en el contexto del administrador que está creando el usuario.
    *   Considerar usar un provider global como `currentAcademyProvider` o similar.

2.  **Actualizar Formularios Restantes:**
    *   Aplicar los cambios del flujo de pre-registro (eliminar email, llamar a `createPendingActivationProvider`, mostrar código) a:
        *   `ManagerFormScreen.dart`
        *   `AthleteFormScreen.dart`

3.  **Implementar/Actualizar Pantalla de Activación (Usuario Final):**
    *   Crear o modificar la pantalla donde el usuario final introduce el `activationCode`, su `email` y su `password`.
    *   Esta pantalla debe obtener el `academyId` correspondiente (¿cómo lo sabrá el usuario o la app? ¿Quizás se puede inferir o requerir?).
    *   Debe llamar al provider `completeActivationWithCodeProvider` con los datos necesarios.
    *   Manejar estados de carga, éxito (login/redirección) y error (código inválido, email en uso, etc.).
    *   Revisar `SigninScreen` y `LoginScreen` para integrar el botón/enlace "Activar cuenta con código" de forma clara.

4.  **Verificar `UserService` (Opcional pero recomendado):**
    *   Aunque `AuthRepository` ahora crea el usuario directamente en Firestore, revisar si `UserService` tiene métodos (`updateUser`, `updateParent`, etc.) que necesiten ser conscientes de la nueva estructura o si su lógica sigue siendo válida.

5.  **Ejecutar `build_runner`:**
    *   Asegurarse de ejecutar `flutter pub run build_runner build --delete-conflicting-outputs` después de modificar los providers para generar los archivos `.g.dart` actualizados y evitar errores.

6.  **Pruebas:**
    *   Probar exhaustivamente todo el flujo: creación del código por admin, activación por usuario final (casos éxito y error), inicio de sesión posterior.