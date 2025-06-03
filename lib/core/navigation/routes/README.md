# Rutas de Navegación - Arcinus

Esta carpeta contiene la estructura modularizada de rutas de la aplicación Arcinus, organizada por shells y funcionalidades.

## Estructura de Archivos

### 📁 `app_routes.dart`
- **Propósito**: Archivo principal que contiene rutas comunes y exporta todos los módulos
- **Contiene**: Rutas de inicialización, shells raíz, y rutas legacy
- **Uso**: `import 'package:arcinus/core/navigation/routes/app_routes.dart'`

### 📁 Archivos Modularizados por Shell

#### `auth_routes.dart`
- Rutas de autenticación y onboarding
- Login, registro, recuperación de contraseña, verificación

#### `super_admin_routes.dart`
- Rutas específicas del SuperAdmin
- Gestión de propietarios, academias, suscripciones, sistema, seguridad

#### `owner_routes.dart`
- Rutas específicas del Propietario
- Dashboard, academias, miembros, pagos, configuración

#### `athlete_routes.dart`
- Rutas específicas del Atleta
- Entrenamientos, progreso, horarios, perfil

#### `collaborator_routes.dart`
- Rutas específicas del Colaborador
- Grupos, asistencia, entrenamientos, configuración

#### `parent_routes.dart`
- Rutas específicas del Padre/Responsable
- Atletas a cargo, pagos, horarios, comunicación

#### `manager_routes.dart`
- Rutas compartidas entre Owner y Collaborator
- Dashboard, creación de academia, gestión unificada

## Convenciones de Uso

### 1. **Importar Rutas**
```dart
// Para acceso a todas las rutas
import 'package:arcinus/core/navigation/routes/app_routes.dart';

// Para rutas específicas de un shell
import 'package:arcinus/core/navigation/routes/super_admin_routes.dart';
```

### 2. **Usar Constantes**
```dart
// ✅ Correcto
Navigator.pushNamed(context, SuperAdminRoutes.owners);
context.go(SuperAdminRoutes.analytics);

// ❌ Incorrecto
Navigator.pushNamed(context, '/superadmin/owners');
```

### 3. **Rutas Relativas vs Absolutas**
- **Absolutas**: Comienzan con `/` - para navegación entre shells
- **Relativas**: Sin `/` inicial - para navegación dentro del mismo shell

```dart
// Absoluta - cambio de shell
static const String owners = '/superadmin/owners';

// Relativa - dentro del shell
static const String dashboard = 'owner_dashboard';
```

## Beneficios de esta Estructura

### 🎯 **Organización**
- Fácil localización de rutas por funcionalidad
- Separación clara de responsabilidades
- Código más legible y mantenible

### 🔧 **Mantenimiento**
- Cambios aislados por shell
- Menor riesgo de conflictos de merge
- Teams independientes por módulo

### 📈 **Escalabilidad**
- Fácil agregar nuevas rutas
- Estructura clara para futuras funcionalidades
- Reutilización de rutas comunes

### 🛡️ **Tipo de Seguridad**
- Constantes tipadas en lugar de strings
- Autocompletado en IDEs
- Detección temprana de errores

## Migración de Rutas Legacy

Para actualizar código existente que use rutas hardcodeadas:

```dart
// Antes
context.go('/superadmin/owners');

// Después
context.go(SuperAdminRoutes.owners);
```

## Agregar Nuevas Rutas

1. **Identificar el shell correcto**
2. **Agregar constante en el archivo del shell**
3. **Usar convención de nombres descriptiva**
4. **Documentar rutas complejas con comentarios**

### Ejemplo:
```dart
// En super_admin_routes.dart
class SuperAdminRoutes {
  // ... rutas existentes ...
  
  // --- Nueva funcionalidad ---
  static const String newFeature = '/superadmin/new-feature';
  static const String newFeatureDetails = '/superadmin/new-feature/:id';
}
```

## Mantenimiento

- **Revisar** rutas unused regularmente
- **Actualizar** documentación cuando se agreguen nuevas rutas
- **Sincronizar** con la configuración de GoRouter
- **Validar** que todas las rutas tengan sus respectivas pantallas implementadas 