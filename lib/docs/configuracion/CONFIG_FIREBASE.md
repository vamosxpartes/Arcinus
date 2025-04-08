# Configuración de Firebase para Arcinus

Este documento describe los pasos necesarios para configurar Firebase en el proyecto Arcinus.

## Requisitos previos

1. Tener una cuenta de Google
2. Tener acceso a [Firebase Console](https://console.firebase.google.com/)
3. Tener instalado Flutter y las herramientas de desarrollo para iOS y Android

## Creación del proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Añadir proyecto"
3. Proporciona un nombre para el proyecto (por ejemplo, "Arcinus Dev" para desarrollo)
4. Configura Google Analytics (recomendado activarlo)
5. Haz clic en "Crear proyecto"

## Configuración para Android

1. En la consola de Firebase, haz clic en el ícono de Android para añadir una aplicación
2. Proporciona el ID del paquete de Android: `com.example.arcinus` (o el ID que hayas configurado)
3. Proporciona un apodo para la aplicación (opcional)
4. Registra la aplicación
5. Descarga el archivo `google-services.json`
6. Coloca el archivo en: `android/app/`

### Actualizar la configuración de Gradle

1. Asegúrate de que tu archivo `android/build.gradle` incluye las dependencias de Firebase:

```gradle
buildscript {
    dependencies {
        // Otros plugins
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Asegúrate de que tu archivo `android/app/build.gradle` aplica el plugin:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## Configuración para iOS

1. En la consola de Firebase, haz clic en el ícono de iOS para añadir una aplicación
2. Proporciona el ID del Bundle de iOS: `com.example.arcinus` (o el ID que hayas configurado)
3. Proporciona un apodo para la aplicación (opcional)
4. Registra la aplicación
5. Descarga el archivo `GoogleService-Info.plist`
6. Abre Xcode, selecciona el proyecto Runner y añade el archivo a la carpeta Runner
   (asegúrate de que "Copy items if needed" esté seleccionado)

## Actualizar la configuración en el código

1. Sustituye los valores en `lib/config/firebase/firebase_config.dart` con los valores reales de tu proyecto:

```dart
static FirebaseOptions _getDevelopmentOptions() {
  return const FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID',
    messagingSenderId: 'TU_MESSAGING_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    authDomain: 'TU_AUTH_DOMAIN',
    storageBucket: 'TU_STORAGE_BUCKET',
    iosBundleId: 'TU_IOS_BUNDLE_ID',
  );
}
```

## Configuración para diferentes entornos

Para configurar Firebase para diferentes entornos (desarrollo, staging, producción), sigue estos pasos:

1. Crea proyectos diferentes en Firebase Console para cada entorno
2. Configura cada proyecto con las aplicaciones correspondientes
3. Actualiza `_getDevelopmentOptions()` y `_getProductionOptions()` con los valores correctos

## Verificación

Para verificar que Firebase está correctamente configurado:

1. Ejecuta la aplicación en modo debug
2. Verifica en los logs que Firebase se inicializa correctamente
3. Verifica en Firebase Console que los eventos de Analytics se están registrando

## Seguridad

Recuerda configurar las reglas de seguridad para Firestore y Storage en la consola de Firebase.

Reglas básicas para Firestore:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Reglas más detalladas se implementarán según las necesidades específicas de la aplicación. 