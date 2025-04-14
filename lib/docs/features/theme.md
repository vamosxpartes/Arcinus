# Feature: Theme

## 1. Nombre del Feature y Resumen
**Nombre:** Theme
**Propósito/Objetivo:** Implementar el sistema de diseño y temas de Arcinus, proporcionando una apariencia consistente en toda la aplicación basada en el brand book.
**Alcance:** Gestión de colores, tipografía, espaciados, estilos de componentes y tema general de la aplicación.

## 2. Estructura de Archivos Clave
* `lib/features/theme/core/app_theme.dart` - Implementación base del tema con todos los colores y estilos
* `lib/features/theme/core/arcinus_theme.dart` - Clase principal que proporciona acceso centralizado a todos los componentes del tema
* `lib/features/theme/core/arcinus_colors.dart` - Sistema de colores de la aplicación
* `lib/features/theme/core/arcinus_text_styles.dart` - Estilos de tipografía
* `lib/features/theme/core/arcinus_theme_data.dart` - Configuración detallada del ThemeData
* `lib/features/theme/components/` - Componentes de UI personalizados (inputs, feedback, loading)

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* No tiene pantallas específicas, ya que es un feature transversal

### Widgets Reutilizables
* Componentes de inputs, feedback y loading que implementan el diseño de Arcinus

### Proveedores (Providers)
* No implementa providers específicos

### Modelos de Datos (Models)
* No implementa modelos de datos específicos

### Servicios/Controladores
* `ArcinusTheme` - Clase estática que centraliza el acceso a los componentes del tema

### Repositorios
* No implementa repositorios específicos

## 4. Flujo de Usuario (User Flow)
1. El tema se aplica automáticamente a todos los componentes de la aplicación
2. Se utiliza principalmente el tema oscuro según el brand book
3. Los componentes estilizados se utilizan en toda la aplicación para mantener consistencia

## 5. Gestión de Estado (State Management)
* El tema es estático y no cambia durante la ejecución de la aplicación
* Utiliza constantes para colores y estilos

## 6. Interacción con Backend/Datos
* No interactúa con el backend
* Los componentes de tema se cargan localmente

## 7. Dependencias
**Internas:** 
* Flutter Material
* SystemChrome para la configuración de la UI del sistema

**Externas:** 
* No tiene dependencias externas específicas

## 8. Decisiones Arquitectónicas / Notas Importantes
* Se utiliza principalmente el tema oscuro según el brand book
* Implementa un sistema de tokens de diseño (colores, espaciados, tipografía)
* Proporciona helpers para crear gradientes y decoraciones consistentes
* Usa Material 3 como base pero con estilos personalizados

## 9. Registro de Cambios
* Implementación inicial del sistema de temas basado en el brand book
* Adición de componentes estilizados para inputs, feedback y loading