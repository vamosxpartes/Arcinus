# Sistema de Features de Arcinus

## Descripción General

El sistema de features de Arcinus proporciona una gestión centralizada y estructurada de todas las funcionalidades de la aplicación. Este sistema permite organizar, categorizar y controlar el acceso a las diferentes características según el estado de desarrollo y los roles de usuario.

## Ubicación del Código

- **Archivo principal**: `lib/core/constants/app_features.dart`
- **Documentación**: `lib/docs/app_features.md` (este archivo)

## Estructura del Sistema

### Estados de Desarrollo (`FeatureStatus`)

El sistema define cinco estados principales para las features:

#### 🟢 `production`
- **Descripción**: Feature completamente funcional y disponible en producción
- **Criterios**: 
  - Funcionalidad 100% implementada
  - Testing completo realizado
  - UI/UX finalizada
  - Documentación completa
- **Visible para**: Todos los usuarios según roles

#### 🟡 `established` 
- **Descripción**: Feature establecida con funcionalidad básica, puede tener mejoras pendientes
- **Criterios**:
  - Funcionalidad core implementada (70-90%)
  - Testing básico realizado
  - UI/UX funcional pero puede mejorar
  - Documentación básica
- **Visible para**: Todos los usuarios según roles
- **Nota**: Pueden tener limitaciones menores o funcionalidades pendientes

#### 🔵 `development`
- **Descripción**: Feature en desarrollo o por validar, no completamente funcional
- **Criterios**:
  - Funcionalidad parcial (30-70%)
  - Testing en progreso
  - UI/UX en desarrollo
- **Visible para**: Solo en modo desarrollo o testing

#### ⚫ `planned`
- **Descripción**: Feature planificada pero no iniciada su desarrollo
- **Criterios**:
  - Especificaciones definidas
  - Sin implementación iniciada
  - Incluida en roadmap
- **Visible para**: No visible para usuarios finales
- **Uso**: Documentación y planificación interna

#### 🟠 `devOnly`
- **Descripción**: Feature solo disponible para desarrollo y testing
- **Criterios**:
  - Herramientas de desarrollo
  - Features experimentales
  - Testing y debugging
- **Visible para**: Solo desarrolladores y testers

### Categorías de Features (`FeatureCategory`)

Las features se organizan en 11 categorías principales:

#### 🎯 `core` - Funciones Principales
Features fundamentales para el funcionamiento básico de la app.

#### 🏫 `academyManagement` - Gestión de Academias  
Funcionalidades relacionadas con la administración de academias.

#### 👥 `userManagement` - Gestión de Usuarios
Gestión de miembros, atletas, padres y colaboradores.

#### 💰 `billing` - Facturación
Sistema de pagos, suscripciones y gestión financiera.

#### 💬 `communication` - Comunicación
Notificaciones, redes sociales y comunicación con usuarios.

#### 🎨 `branding` - Marca y Diseño
Personalización visual y branding de academias.

#### 🏃 `operations` - Operaciones
Gestión operativa: inventario, instalaciones, horarios.

#### 📊 `analytics` - Analytics
Métricas, estadísticas y análisis de datos.

#### ⚙️ `systemAdmin` - Administración del Sistema
Funcionalidades exclusivas para super administradores.

#### 👤 `personal` - Configuración Personal
Ajustes y configuración personal de usuarios.

#### 🛠️ `development` - Herramientas de Desarrollo
Tools para desarrolladores y testing.

### Roles de Usuario (`FeatureRole`)

El sistema define 8 roles diferentes:

- `superAdmin`: Super administrador del sistema
- `owner`: Propietario de academia
- `collaborator`: Colaborador de academia  
- `athlete`: Atleta
- `parent`: Padre/tutor
- `manager`: Cualquier usuario gestor (owner o collaborator)
- `authenticated`: Cualquier usuario autenticado
- `guest`: Usuarios no autenticados

## Catálogo Actual de Features

### 🎯 Funciones Principales (Establecidas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Dashboard** | 🟡 Establecida | Manager, SuperAdmin | Panel de control principal |
| **Academia** | 🟡 Establecida | Manager | Gestión de información de academias |
| **Miembros** | 🟡 Establecida | Manager | Gestión de atletas y usuarios |

### 💰 Facturación (Mixto)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Planes de Suscripción** | 🟡 Establecida | Manager | Gestión de planes de la academia |
| **Pagos** | 🟡 Establecida | Manager | Gestión de pagos y suscripciones |
| **Facturación** | 🟡 Establecida | Manager | Configuración de facturación de la academia |

### 🏃 Operaciones (Planificadas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Inventario** | ⚫ Planificada | Manager | Gestión de equipamiento y materiales |
| **Instalaciones** | ⚫ Planificada | Manager | Gestión de espacios físicos |
| **Horarios** | ⚫ Planificada | Manager | Planificación de entrenamientos |
| **Grupos** | ⚫ Planificada | Manager | Organización de atletas |
| **Entrenamientos** | ⚫ Planificada | Manager | Planificación y seguimiento |

### 💬 Comunicación (Planificadas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Notificaciones** | ⚫ Planificada | Manager | Sistema de notificaciones |
| **Redes Sociales** | ⚫ Planificada | Manager | Integración con redes sociales |
| **Normas y Documentos** | ⚫ Planificada | Manager | Gestión de documentos oficiales |

### 🎨 Personalización (Planificadas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Marca y Personalización** | ⚫ Planificada | Owner | Personalización visual |

### 📊 Analytics (Planificadas/En Desarrollo)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Estadísticas** | ⚫ Planificada | Owner | Métricas de rendimiento |
| **Análisis del Sistema** | 🔵 En Desarrollo | SuperAdmin | Métricas globales |

### ⚙️ Administración del Sistema (Establecidas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Gestión de Planes Globales** | 🟡 Establecida | SuperAdmin | Administración de planes |
| **Gestión de Propietarios** | 🟡 Establecida | SuperAdmin | CRUD de propietarios |

### 👤 Configuración Personal (Establecidas)

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Mi Perfil** | 🟡 Establecida | Authenticated | Gestión de perfil personal |
| **Configuración** | 🟡 Establecida | Authenticated | Ajustes personales |

### 🛠️ Herramientas de Desarrollo

| Feature | Estado | Rol | Descripción |
|---------|--------|-----|-------------|
| **Test de Casos de Uso** | 🟠 Solo Dev | Manager | Testing de funcionalidades |

## Uso del Sistema

### Métodos Principales

```dart
// Obtener todas las features
List<AppFeature> allFeatures = AppFeatures.all;

// Obtener features por estado
List<AppFeature> productionFeatures = AppFeatures.getByStatus(FeatureStatus.production);

// Obtener features por rol  
List<AppFeature> managerFeatures = AppFeatures.getByRole(FeatureRole.manager);

// Obtener features disponibles (production + established)
List<AppFeature> availableFeatures = AppFeatures.available;

// Obtener features para mostrar en drawer
List<AppFeature> drawerFeatures = AppFeatures.getDrawerFeatures(FeatureRole.manager);

// Obtener feature específica
AppFeature? feature = AppFeatures.getById('dashboard');

// Obtener estadísticas
Map<FeatureStatus, int> statusCount = AppFeatures.statusCount;
Map<FeatureCategory, int> categoryCount = AppFeatures.categoryCount;
```

### Integración con UI

#### En el Manager Drawer

El sistema de features se puede integrar con el drawer para generar dinámicamente los elementos de navegación:

```dart
// Ejemplo de uso en ManagerDrawer
final userRole = getUserRole(); // owner, collaborator, etc.
final availableFeatures = AppFeatures.getDrawerFeatures(
  userRole == AppRole.propietario ? FeatureRole.owner : FeatureRole.collaborator
);

// Generar elementos del drawer basados en features
for (final feature in availableFeatures) {
  if (feature.status.isAvailable) {
    _buildDrawerItem(
      context,
      feature.route ?? '',
      getIconFromName(feature.iconName),
      feature.displayName,
      isActive: true,
    );
  }
}
```

#### Control de Acceso por Feature

```dart
// Verificar si el usuario tiene acceso a una feature
bool hasAccess(String featureId, FeatureRole userRole) {
  final feature = AppFeatures.getById(featureId);
  return feature != null && 
         feature.allowedRoles.contains(userRole) &&
         feature.status.isAvailable;
}
```

## Estadísticas Actuales

### Por Estado
- �� **Establecidas**: 9 features (37%)
- ⚫ **Planificadas**: 11 features (46%)  
- 🔵 **En Desarrollo**: 1 feature (4%)
- 🟠 **Solo Dev**: 1 feature (4%)
- 🟢 **Producción**: 0 features (0%)

### Por Categoría
- 🎯 **Core**: 3 features
- 🏫 **Academy Management**: 2 features
- 👥 **User Management**: 2 features
- 💰 **Billing**: 3 features
- 🏃 **Operations**: 5 features
- 💬 **Communication**: 3 features
- 🎨 **Branding**: 1 feature
- 📊 **Analytics**: 2 features
- ⚙️ **System Admin**: 3 features
- 👤 **Personal**: 2 features
- 🛠️ **Development**: 1 feature

## Roadmap de Desarrollo

### Fase 1 (Q1 2024) - Completar Base ✅
- ✅ Dashboard básico
- ✅ Gestión de academias
- ✅ Gestión de miembros
- ✅ Sistema de suscripciones
- ✅ Sistema de pagos

### Fase 2 (Q2 2024) - Operaciones
- 🔄 Inventario
- 🔄 Instalaciones  
- 🔄 Horarios
- 🔄 Grupos
- 🔄 Facturación avanzada

### Fase 3 (Q3 2024) - Entrenamiento y Comunicación
- 🔄 Entrenamientos
- 🔄 Notificaciones
- 🔄 Estadísticas para owners
- 🔄 Documentos y normas

### Fase 4 (Q4 2024) - Personalización y Social
- 🔄 Marca y personalización
- 🔄 Redes sociales
- 🔄 Analytics del sistema

## Mejores Prácticas

### Para Desarrolladores

1. **Siempre consultar el catálogo**: Antes de implementar una nueva feature, verificar si ya está definida
2. **Actualizar estado**: Mantener actualizado el estado de las features durante el desarrollo
3. **Respetar dependencias**: Verificar que las dependencias estén implementadas antes de desarrollar una feature
4. **Documentar cambios**: Actualizar notas cuando se modifique el comportamiento

### Para Product Managers

1. **Planificación basada en features**: Usar el catálogo para planning y roadmaps
2. **Control de acceso**: Definir claramente qué roles pueden acceder a cada feature
3. **Comunicación clara**: Usar los estados para comunicar el progreso a stakeholders

### Para QA

1. **Testing por estado**: Enfocar testing según el estado de la feature
2. **Verificación de roles**: Asegurar que solo los roles autorizados accedan a las features
3. **Regresión**: Verificar que las dependencias funcionen correctamente

## Mantenimiento

### Actualizaciones Regulares
- Revisar estados mensualmente
- Actualizar roadmap trimestralmente
- Documentar cambios en release notes

### Métricas a Monitorear
- Tiempo promedio de desarrollo por estado
- Porcentaje de features en cada estado
- Adopción de features por rol de usuario

## Consideraciones Futuras

### Funcionalidades Planeadas del Sistema
- Configuración remota de features
- A/B testing basado en features
- Analytics de uso por feature
- Sistema de permisos granular
- Feature flags dinámicos

### Escalabilidad
- Separación por módulos
- Versionado de features
- Migración de estados
- Deprecación controlada 