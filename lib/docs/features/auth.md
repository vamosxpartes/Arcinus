# Feature: Auth

## 1. Nombre del Feature y Resumen
**Nombre:** Auth
**Propósito/Objetivo:** Gestionar la autenticación y autorización de usuarios en la aplicación, permitiendo el registro, inicio de sesión y gestión de credenciales.
**Alcance:** Registro de usuarios, inicio de sesión, restablecimiento de contraseñas, mantenimiento del estado de autenticación y gestión de perfiles.

## 2. Estructura de Archivos Clave
* `lib/features/auth/core/repositories/auth_repository.dart` - Interfaz para el repositorio de autenticación
* `lib/features/auth/core/repositories/firebase_auth_repository.dart` - Implementación de Firebase Auth
* `lib/features/auth/core/providers/auth_providers.dart` - Proveedores de estado de autenticación
* `lib/features/auth/screens/signin_screen.dart` - Pantalla de inicio de sesión
* `lib/features/auth/screens/register_screen.dart` - Pantalla de registro de usuarios
* `lib/features/auth/screens/forgot_password_screen.dart` - Pantalla de recuperación de contraseña
* `lib/features/auth/screens/login_screen.dart` - Pantalla principal de login

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* `SigninScreen` - Pantalla de inicio de sesión con email y contraseña
* `RegisterScreen` - Pantalla de registro de nuevos usuarios
* `ForgotPasswordScreen` - Pantalla para solicitar restablecimiento de contraseña
* `LoginScreen` - Pantalla principal de acceso que gestiona el flujo de autenticación

### Widgets Reutilizables
* Componentes de formulario de autenticación
* Botones y campos de entrada estilizados según el tema de la aplicación

### Proveedores (Providers)
* `authRepositoryProvider` - Proporciona la implementación del repositorio de autenticación
* `authStateChangesProvider` - Stream con los cambios en el estado de autenticación
* `currentUserProvider` - Información del usuario actual autenticado

### Modelos de Datos (Models)
* Utiliza el modelo `User` de la aplicación para la información del usuario autenticado
* Utiliza `UserRole` para definir los roles de usuario (Atleta, Entrenador, Manager, etc.)

### Servicios/Controladores
* Controladores para la validación de formularios de autenticación
* Servicios para la gestión de tokens y sesiones

### Repositorios
* `AuthRepository` - Interfaz abstracta para implementaciones de autenticación
* `FirebaseAuthRepository` - Implementación con Firebase Authentication

## 4. Flujo de Usuario (User Flow)
1. El usuario accede a la pantalla de inicio de sesión/registro
2. Puede registrarse con su correo electrónico y contraseña, definiendo su rol
3. Puede iniciar sesión con sus credenciales existentes
4. Puede solicitar el restablecimiento de contraseña si la olvidó
5. Al autenticarse, se mantiene la sesión y se redirige al dashboard

## 5. Gestión de Estado (State Management)
* Utiliza Riverpod para la gestión del estado de autenticación
* Mantiene el estado global de autenticación a través de providers
* Implementa streams para reaccionar a cambios en el estado de autenticación

## 6. Interacción con Backend/Datos
* Integración con Firebase Authentication para la gestión de credenciales
* Almacenamiento de información de perfil en Firestore
* Subida de imágenes de perfil a Firebase Storage

## 7. Dependencias
**Internas:** 
* Feature de Storage para la persistencia local de información de sesión
* Feature de Usuarios para la gestión de perfiles

**Externas:** 
* Firebase Authentication para la gestión de credenciales
* Firebase Storage para las imágenes de perfil
* Riverpod para la gestión de estado

## 8. Decisiones Arquitectónicas / Notas Importantes
* Patrón Repository para abstraer la implementación de autenticación
* Implementación basada en Firebase pero con capacidad de cambiar el proveedor
* Sistema de roles integrado desde el registro
* Capacidad de almacenamiento local para acceso offline

## 9. Registro de Cambios
* Implementación inicial con Firebase Authentication
* Adición de recuperación de contraseña
* Integración de roles de usuario en el proceso de registro