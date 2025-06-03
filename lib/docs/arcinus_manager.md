# Módulo Arcinus Manager

## Descripción General

El módulo `arcinus_manager` es el panel de control central para los administradores de la plataforma Arcinus. Proporciona una visión integral del sistema y acceso rápido a las funcionalidades críticas de gestión.

## Pantallas Principales

### 1. Arcinus Manager Dashboard (`arcinus_manager_dashboard_screen.dart`)

Esta es la pantalla principal del módulo y ofrece una vista consolidada de la actividad y el estado del sistema.

#### Funcionalidades Clave:

*   **Estadísticas del Sistema:**
    *   Muestra tarjetas con métricas clave como:
        *   Total de Academias
        *   Usuarios Activos
        *   Ingresos Totales
        *   Rendimiento del Sistema (Uptime)
    *   Cada tarjeta de estadística (`_buildStatCard`) visualiza un título, un valor, un subtítulo informativo (ej: cambio respecto al mes anterior) y un icono representativo.

*   **Alertas Críticas (`_buildCriticalAlertsSection`):**
    *   Presenta una sección para mostrar alertas importantes que requieren atención inmediata del administrador. (Los detalles específicos de las alertas se cargarán dinámicamente).

*   **Métricas de Rendimiento (`_buildPerformanceMetricsSection`):**
    *   Muestra gráficos o listados con indicadores clave de rendimiento (KPIs) de la plataforma. (Los detalles específicos de las métricas se cargarán dinámicamente).

*   **Accesos Rápidos (`_buildQuickActionsSection`):**
    *   Proporciona botones o enlaces para acceder directamente a las funciones de gestión más utilizadas. (Los detalles específicos de los accesos rápidos se cargarán dinámicamente).

*   **Resumen de Actividad Reciente (`_buildRecentActivitySection`):**
    *   Muestra un listado o feed de las acciones y eventos más recientes ocurridos en la plataforma. (Los detalles específicos de la actividad se cargarán dinámicamente).

#### Componentes Reutilizables:

*   `_buildStatCard`: Widget para construir las tarjetas de estadísticas individuales.

#### Flujo de Usuario:

1.  El administrador accede a esta pantalla después de iniciar sesión.
2.  Visualiza un resumen del estado del sistema a través de las estadísticas, alertas y métricas.
3.  Puede navegar a otras secciones de administración a través de los accesos rápidos.
4.  Se mantiene informado de las últimas novedades mediante el resumen de actividad reciente.

#### Interacciones:

*   **Actualización por Deslizamiento (Pull-to-Refresh):** La pantalla permite actualizar los datos deslizando hacia abajo (`RefreshIndicator`).
*   La función `_refreshDashboard` se encarga de la lógica de actualización (actualmente es un placeholder).

## Estructura del Módulo

El módulo `arcinus_manager` sigue la siguiente estructura de carpetas:

```
lib/features/arcinus_manager/
└── presentation/
    └── screens/
        └── arcinus_manager_dashboard_screen.dart
```

## Próximos Pasos de Documentación

*   Detallar el contenido y la lógica de las secciones:
    *   `_buildCriticalAlertsSection`
    *   `_buildPerformanceMetricsSection`
    *   `_buildQuickActionsSection`
    *   `_buildRecentActivitySection`
*   Documentar cualquier BLoC o Provider asociado a esta pantalla si existe.
*   Especificar las dependencias y los modelos de datos utilizados. 