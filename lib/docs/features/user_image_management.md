# Gestión de Imágenes de Usuario

## Propósito
Este módulo gestiona la toma, procesamiento, almacenamiento y recuperación de imágenes de perfil para los usuarios de la aplicación. Proporciona una interfaz única para manejar todos los aspectos relacionados con las imágenes de usuario.

## Estructura

```
lib/features/app/users/user/
├── core/
│   └── services/
│       └── user_image_service.dart
├── screens/
│   └── camera_screen.dart
└── components/
    └── profile_image_picker.dart
```

## Componentes

### Servicios
- **UserImageService**: Servicio central para gestionar todas las operaciones relacionadas con imágenes de perfil.
  - Subir imágenes a Firebase Storage
  - Preparar y guardar imágenes localmente en el dispositivo
  - Recuperar imágenes desde almacenamiento local o Firebase Storage
  - Eliminar imágenes

### Pantallas
- **CameraScreen**: Pantalla dedicada para la captura de fotos de perfil con diseño circular para mostrar claramente el área que se guardará.

### Componentes UI
- **ProfileImagePicker**: Widget reutilizable que permite seleccionar imágenes ya sea desde la galería o usando la cámara, y muestra una previsualización circular de la imagen actual.

## Integración en Formularios

El componente `ProfileImagePicker` ha sido integrado en los siguientes formularios de usuarios:

- **ManagerFormScreen**: Para la creación y edición de perfiles de gerentes
- **CoachFormScreen**: Para la creación y edición de perfiles de entrenadores
- **AthleteFormScreen**: Para la creación y edición de perfiles de atletas
- **ParentFormScreen**: Para la creación y edición de perfiles de padres/responsables

La integración sigue un patrón común en todos los formularios:

1. Se agrega una variable de estado `_localImagePath` para almacenar la ruta local de la imagen seleccionada
2. Se implementa el método `_handleProfileImageSelected` para actualizar el estado cuando se selecciona una imagen
3. Se coloca el widget `ProfileImagePicker` en la parte superior del formulario
4. Se pasa la URL de la imagen actual (si existe) y el ID del usuario al componente
5. En el método de guardado, se sube la imagen a Firebase Storage (si hay una nueva) y luego se incluye la URL al crear o actualizar el usuario

## Flujo de Trabajo

1. **Captura de Imagen**:
   - El usuario accede a la pantalla de cámara (`CameraScreen`) directamente o a través del `ProfileImagePicker`.
   - Se muestra una interfaz con un recorte circular que define el área de la imagen que se utilizará como foto de perfil.
   - El usuario captura la imagen.

2. **Procesamiento de Imagen**:
   - La imagen capturada se recorta para mantener solo el área circular.
   - Se redimensiona y comprime para optimizar el almacenamiento.
   - Se guarda localmente, sin subir a Firebase Storage.

3. **Almacenamiento Temporal**:
   - La imagen procesada se guarda en el almacenamiento local del dispositivo.
   - La ruta local se proporciona al formulario que utiliza el componente.

4. **Almacenamiento Definitivo**:
   - Al guardar el formulario completo, la imagen se sube a Firebase Storage.
   - Se obtiene la URL de Firebase Storage y se asigna al usuario.
   - Se mantiene una copia en el almacenamiento local para acceso rápido.

5. **Recuperación**:
   - Al mostrar la imagen, primero se busca en el almacenamiento local.
   - Si no está disponible localmente, se descarga desde Firebase Storage y se guarda localmente.

## Implementación Técnica

### Gestión de Caché
- Las imágenes descargadas se almacenan indefinidamente en el almacenamiento local.
- Se implementa un sistema de verificación para detectar si la imagen ya existe localmente.

### Optimización
- Las imágenes se procesan para reducir su tamaño, manteniendo buena calidad.
- El recorte circular permite centrar el contenido relevante (rostro).
- Se evitan subidas innecesarias a Firebase Storage durante el proceso de edición.

### Interfaz de Usuario
- La interfaz de la cámara proporciona retroalimentación visual clara sobre qué parte de la imagen se guardará.
- Se implementa un enfoque "lo que ves es lo que obtienes" para la toma de fotos de perfil.
- El componente `ProfileImagePicker` ofrece una interfaz intuitiva para la selección y visualización de imágenes.

## Uso

### Uso del Componente ProfileImagePicker

Este es el método recomendado para la mayoría de los casos:

```dart
ProfileImagePicker(
  currentImageUrl: user.profileImageUrl,
  userId: user.id,
  onImageSelected: (String localPath) {
    // Guardar la ruta local de la imagen seleccionada
    setState(() {
      _localImagePath = localPath;
    });
  },
),
```

### Subida de Imágenes en Formularios

Al guardar el formulario, se debe subir la imagen a Firebase Storage:

```dart
if (_localImagePath != null) {
  final userImageService = ref.read(userImageServiceProvider);
  final imageUrl = await userImageService.uploadProfileImage(
    imagePath: _localImagePath!,
    userId: userId,
  );
  // Usar la URL al crear/actualizar el usuario
  user = user.copyWith(profileImageUrl: imageUrl);
}
```

### Uso Directo de CameraScreen

Si necesitas una experiencia personalizada para la captura:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CameraScreen(
      userId: 'user123',
      onImageCaptured: (String localPath) {
        // Guardar la ruta local de la imagen capturada
        setState(() {
          _localImagePath = localPath;
        });
      },
    ),
  ),
);
```

### Uso Directo del Servicio

Para operaciones avanzadas o personalizadas:

```dart
final userImageService = ref.read(userImageServiceProvider);

// Preparar una imagen localmente
final String localPath = await userImageService.prepareProfileImage(
  imagePath: selectedImagePath,
);

// Obtener una imagen
final File? imageFile = await userImageService.getProfileImage(imageUrl);

// Eliminar una imagen
await userImageService.deleteProfileImage(imageUrl);
```

## Consideraciones de Seguridad

- Las rutas de Firebase Storage incluyen verificación de seguridad para controlar el acceso a las imágenes.
- El servicio maneja los errores adecuadamente para evitar bloqueos en caso de problemas de red o acceso.

## Solución de Problemas

### Errores de Permisos tras Actualización a v1.1.0

Si después de actualizar a la versión 1.1.0 experimentas errores de permisos en Firebase, especialmente al iniciar sesión, verifica lo siguiente:

1. **Errores en consola**: Busca mensajes como `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation`

2. **Posibles causas**:
   - El repositorio de autenticación (`FirebaseAuthRepository`) podría estar buscando usuarios en ubicaciones incorrectas
   - Las reglas de seguridad de Firestore no se han actualizado para reflejar la nueva estructura de datos

3. **Soluciones**:
   - Actualiza el método `_getUserData` en `FirebaseAuthRepository` para buscar en las ubicaciones correctas
   - Verifica y actualiza las reglas de seguridad de Firestore para permitir acceso a las nuevas ubicaciones
   - Para usuarios existentes, considera migrar sus datos a las nuevas ubicaciones

4. **Ejemplo de reglas de seguridad actualizadas**:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Permitir acceso a las subcolecciones de usuarios en academias
       match /academies/{academyId}/users/{userId} {
         allow read: if request.auth != null && (request.auth.uid == userId || hasAcademyRole(academyId, ['owner', 'manager']));
       }
       
       // Mantener acceso a colecciones anteriores
       match /users/{userId} {
         allow read: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

## Registro de Cambios

- **Versión inicial (0.1.0)**: 
  - Implementación de CameraScreen con recorte circular
  - Implementación de UserImageService para gestión de imágenes
  - Funcionalidad de almacenamiento local y remoto
  - Procesamiento básico de imágenes
  - Componente ProfileImagePicker para integración en formularios
- **Versión 1.0.0**:
  - Integración del componente en todos los formularios de usuario (Manager, Coach, Athlete, Parent)
  - Actualización de los servicios para soportar URLs de imágenes de perfil en la creación y actualización de usuarios
- **Versión 1.1.0**:
  - Se modificó el flujo de trabajo para almacenar imágenes localmente primero
  - Se añadió el método `prepareProfileImage` para guardar imágenes localmente sin subirlas
  - Se cambió `ProfileImagePicker` para devolver rutas locales en lugar de URLs
  - Se actualizó `CameraScreen` para solo procesar y guardar localmente, sin subir a Firebase
  - Se modificaron los formularios para subir imágenes a Firebase solo al guardar el formulario completo 