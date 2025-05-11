# Módulo de Autenticación

## Descripción General
El módulo de autenticación gestiona todos los procesos relacionados con la identidad de los usuarios en la aplicación Arcinus, incluyendo registro, inicio de sesión, cierre de sesión y gestión de perfiles. Este módulo se integra con Firebase Authentication y Firestore para proporcionar una solución de autenticación robusta y escalable.

## Estructura del Módulo

### Arquitectura
El módulo sigue la arquitectura de capas, separando claramente:
- **Data**: Modelos y repositorios
- **Presentation**: Providers, estado y UI

### Modelo Principal
- `UserModel`: Representa la información básica de cualquier usuario en el sistema, independientemente de su rol.

### Repositorio de Autenticación
- `AuthRepository`: Define las operaciones de autenticación
- `FirebaseAuthRepository`: Implementación concreta que utiliza Firebase Authentication

## Flujos Principales

### 1. Registro de Usuario
1. Usuario completa formulario de registro básico (email/contraseña)
2. Se crea cuenta en Firebase Authentication
3. Se crea documento inicial en colección `users` de Firestore
4. Usuario es redirigido a la pantalla de completar perfil
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

## Pantallas Principales

- **WelcomeScreen**: Pantalla inicial de la aplicación
- **LoginScreen**: Formulario de inicio de sesión
- **RegisterScreen**: Formulario de registro de cuenta
- **CompleteProfileScreen**: Formulario para completar perfil de usuario
- **MemberAccessScreen**: Acceso para miembros invitados

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