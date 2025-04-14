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
* `SigninScreen` - Pantalla de inicio de sesión con email y contraseña
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
1. El administrador accede a la pantalla de pre-registro
2. Introduce el correo electrónico, nombre y rol del nuevo usuario
3. El sistema genera un código de activación único
4. El administrador comparte el código con el usuario final

### Flujo de Activación de Cuenta
1. El usuario recibe un código de activación de un administrador
2. Accede a la pantalla de activación y proporciona el código
3. El sistema verifica y muestra la información pre-registrada
4. El usuario establece su contraseña y completa el registro

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
* Almacenamiento de información de perfil en Firestore
* Almacenamiento de pre-registros en colección `preRegisteredUsers` en Firestore
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
* Sistema de códigos de activación con expiración temporal
* Capacidad de almacenamiento local para acceso offline

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