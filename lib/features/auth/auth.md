# Módulo de Autenticación

## Descripción General
El módulo de autenticación gestiona todos los procesos relacionados con la identidad de los usuarios en la aplicación Arcinus, incluyendo registro, inicio de sesión, cierre de sesión y gestión de perfiles. Este módulo se integra con Firebase Authentication y Firestore para proporcionar una solución de autenticación robusta y escalable.

## Estructura del Módulo

### Arquitectura
El módulo sigue la arquitectura de capas, separando claramente:
- **Data**: Modelos y repositorios
- **Presentation**: Providers, estado y UI
- **Domain**: Lógica de negocio y entidades

### Modelo Principal
- `UserModel`: Representa la información básica de cualquier usuario en el sistema, independientemente de su rol.
- `AuthState`: Define el estado de autenticación (autenticado, no autenticado, error, etc.)

### Repositorio de Autenticación
- `AuthRepository`: Define las operaciones de autenticación
- `FirebaseAuthRepository`: Implementación concreta que utiliza Firebase Authentication

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
- `authStateNotifierProvider`: Maneja el estado global de autenticación
- `completeProfileProvider`: Gestiona el estado del formulario de perfil
- `userProfileProvider`: Proporciona información del perfil del usuario actual
- `registrationFormProvider`: Gestiona el estado y persistencia del formulario de registro

### Persistencia de Datos
- Utiliza Hive para almacenamiento local de datos de registro
- Implementa persistencia para permitir completar el registro en sesiones múltiples
- Protege datos sensibles evitando almacenar contraseñas

## Pantallas Principales

- **WelcomeScreen**: Pantalla inicial de la aplicación
- **LoginScreen**: Formulario de inicio de sesión
- **RegisterScreen**: Formulario de registro por pasos con UX mejorada
- **CompleteProfileScreen**: Formulario para completar perfil de usuario
- **MemberAccessScreen**: Acceso para miembros invitados

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

```
/users/               # Colección principal de usuarios
  ├── {userId}/       # Documento por cada usuario
      ├── email       # Correo del usuario
      ├── displayName # Nombre completo
      ├── photoUrl    # URL de la foto de perfil
      ├── appRole     # Rol principal (propietario, colaborador, atleta, etc.)
      ├── profileCompleted # Indica si completó su perfil inicial
      ├── createdAt   # Fecha de creación
      ├── updatedAt   # Última actualización
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