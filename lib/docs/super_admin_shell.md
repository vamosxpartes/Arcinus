# SuperAdmin Shell

## Descripción General

El SuperAdmin Shell es la interfaz de administración de más alto nivel en la plataforma Arcinus, diseñada para gestionar toda la infraestructura, usuarios, academias, suscripciones y configuraciones globales del sistema. Este shell proporciona herramientas comprensivas para la supervisión, moderación y administración de la plataforma completa.

Basado en la arquitectura del `ManagerShell` pero adaptado para las necesidades específicas del SuperAdmin, incluye navegación persistente, dashboard con métricas globales, y acceso a todas las herramientas administrativas de la plataforma.

## Arquitectura y Navegación

### Componentes de Navegación Principales

*   **`SuperAdminShell`**: Componente principal que envuelve todas las rutas del SuperAdmin usando `ShellRoute` de `go_router`.
*   **`SuperAdminDrawer`**: Navegación lateral específica con acceso rápido a todas las secciones administrativas.
*   **`SuperAdminAppBar`**: Barra superior con funcionalidades específicas del rol y acceso a configuraciones globales.

### Estructura de Rutas (Propuesta)

```
/super-admin/
├── dashboard/                    # Dashboard principal con métricas globales
├── owners/                       # Gestión de propietarios de academias
│   ├── list/                     # Lista de todos los propietarios
│   ├── pending-approval/         # Propietarios pendientes de aprobación
│   └── details/:ownerId/         # Detalles específicos del propietario
├── academies/                    # Gestión global de academias
│   ├── list/                     # Lista global de academias
│   └── details/:academyId/       # Detalles y herramientas de moderación
├── subscriptions/                # Gestión de suscripciones globales
│   ├── plans/                    # Configuración de planes de suscripción
│   ├── active/                   # Suscripciones activas
│   └── features/                 # Gestión de features por plan
├── payments/                     # Sistema de pagos y facturación global
│   ├── dashboard/                # Dashboard de pagos globales
│   ├── billing-config/           # Configuración de facturación
│   └── reports/                  # Reportes financieros
├── sports/                       # Gestión de deportes globales
├── system/                       # Herramientas de administración del sistema
│   ├── data-integrity/           # Monitoreo de integridad de datos
│   ├── backups/                  # Sistema de respaldos
│   ├── analytics/                # Análisis de uso
│   └── config/                   # Configuración global
├── communication/                # Herramientas de comunicación
└── security/                     # Auditoría y seguridad
```

## Funcionalidades Principales

### 1. Dashboard SuperAdmin (Expandido de `arcinus_manager`)

Heredando la estructura del `arcinus_manager_dashboard_screen.dart` pero expandido para métricas globales:

#### Estadísticas del Sistema (Expandidas):
*   **Propietarios de Academias**: Total registrados, activos, pendientes de aprobación
*   **Academias**: Total activas/inactivas, distribución por país/región
*   **Usuarios Globales**: Total de usuarios en toda la plataforma
*   **Ingresos**: Totales por suscripciones, métricas de MRR (Monthly Recurring Revenue)
*   **Uso de la Aplicación**: Sesiones activas, tiempo promedio, features más utilizadas
*   **Estado del Sistema**: Uptime, performance, errores críticos

#### Alertas Críticas Específicas:
*   Suscripciones vencidas o próximas a vencer
*   Problemas de integridad de datos detectados
*   Academias con actividad sospechosa
*   Errores críticos del sistema que requieren atención
*   Propietarios pendientes de aprobación por más de X días

#### Accesos Rápidos SuperAdmin:
*   Gestión de propietarios pendientes
*   Configuración de planes de suscripción
*   Herramientas de facturación global
*   Panel de gestión de deportes
*   Herramientas de comunicación masiva

### 2. Gestión de Propietarios (Adaptado de `academy_users`)

Basado en los patrones de `academy_users_manage_screen.dart` pero para propietarios globales:

#### Funcionalidades Clave:
*   **Lista Global de Propietarios**: Similar a `AcademyUserCard` pero para propietarios
*   **Sistema de Filtrado Avanzado**: Por estado, región, tipo de suscripción
*   **Herramientas de Aprobación**: Flujo completo de revisión y aprobación
*   **Comunicación Directa**: Herramientas para contactar propietarios
*   **Historial de Actividad**: Seguimiento de acciones de cada propietario

### 3. Gestión de Academias Global (Expandido de `academies`)

Extendiendo las capacidades de `edit_academy_screen.dart` para administración global:

#### Características Principales:
*   **Vista Global de Academias**: Lista de todas las academias con métricas clave
*   **Herramientas de Moderación**: Suspensión, modificación de configuraciones
*   **Análisis de Actividad**: Métricas de uso por academia
*   **Gestión de Emergencia**: Acceso administrativo a datos de academias

### 4. Gestión de Suscripciones Global (Expandido de `academy_users_subscriptions`)

Basado en `subscription_plans_screen.dart` pero para gestión de la plataforma:

#### Funcionalidades Avanzadas:
*   **Planes Globales**: CRUD de planes de suscripción de la plataforma
*   **Gestión de Features**: Asignación de funcionalidades por plan
*   **Precios Regionales**: Configuración de precios por región/país
*   **Métricas de Conversión**: Análisis de efectividad de planes

### 5. Sistema de Pagos y Facturación Global (Expandido de `academy_users_payments` y `academy_billing`)

Combinando y expandiendo las capacidades de pagos y facturación:

#### Herramientas Financieras:
*   **Dashboard de Pagos Globales**: Vista consolidada de todos los pagos
*   **Gestión de Suscripciones Activas**: Control total sobre suscripciones
*   **Configuración de Facturación**: Plantillas y configuraciones globales
*   **Reportes Financieros**: Análisis de ingresos, churn, LTV

### 6. Gestión de Deportes Global (Expandido de `academy_sports`)

Extendiendo las capacidades de `SportCharacteristics`:

#### Funcionalidades Deportivas:
*   **CRUD de Deportes**: Gestión completa de deportes disponibles
*   **Editor Visual**: Interfaz para configurar características deportivas
*   **Validación Automática**: Verificación de integridad de configuraciones
*   **Solicitudes de Academias**: Sistema para nuevos deportes solicitados

## Providers y Estado

### Providers Principales (Propuestos):

*   **`superAdminDashboardProvider`**: Métricas y estadísticas globales
*   **`globalOwnersProvider`**: Gestión de propietarios de academias
*   **`globalAcademiesProvider`**: Administración de academias globales
*   **`platformSubscriptionsProvider`**: Suscripciones y planes globales
*   **`globalPaymentsProvider`**: Pagos y facturación de la plataforma
*   **`globalSportsProvider`**: Gestión de deportes globales
*   **`systemAdminProvider`**: Herramientas de administración del sistema

### Modelos de Datos (Propuestos):

*   **`PlatformMetricsModel`**: Métricas y estadísticas globales
*   **`OwnerManagementModel`**: Gestión de propietarios
*   **`GlobalAcademyModel`**: Academia con datos administrativos adicionales
*   **`PlatformSubscriptionPlanModel`**: Planes de suscripción globales
*   **`GlobalPaymentModel`**: Pagos con datos de plataforma
*   **`SystemConfigModel`**: Configuraciones globales del sistema

## Seguridad y Auditoría

### Características de Seguridad:

*   **Logs de Auditoría**: Registro completo de todas las acciones del SuperAdmin
*   **Permisos Granulares**: Sistema de permisos específicos para el equipo
*   **Monitoreo de Seguridad**: Alertas automáticas para actividades sospechosas
*   **Acceso de Emergencia**: Herramientas de acceso crítico con trazabilidad completa

### Trazabilidad:

*   Registro de todos los cambios realizados
*   Identificación del usuario que realizó cada acción
*   Timestamps precisos de todas las operaciones
*   Capacidad de rollback para cambios críticos

## Próximos Pasos de Implementación

1. **Fase 1**: Implementar la infraestructura base del SuperAdminShell
2. **Fase 2**: Desarrollar el dashboard con métricas globales
3. **Fase 3**: Implementar gestión de propietarios y academias
4. **Fase 4**: Crear herramientas de suscripciones y pagos globales
5. **Fase 5**: Añadir gestión de deportes y herramientas del sistema
6. **Fase 6**: Implementar seguridad, auditoría y comunicación

## Integración con Módulos Existentes

El SuperAdmin Shell reutilizará y extenderá los patrones y componentes de:

*   **`arcinus_manager`**: Base para el dashboard y métricas
*   **`academy_users`**: Patrones para gestión de propietarios
*   **`academies`**: Base para administración de academias
*   **`academy_users_subscriptions`**: Fundamento para planes globales
*   **`academy_users_payments`**: Base para sistema de pagos global
*   **`academy_billing`**: Fundamento para facturación de plataforma
*   **`academy_sports`**: Base para gestión de deportes global

Esta arquitectura garantiza consistencia en la experiencia de usuario mientras proporciona las herramientas específicas que el SuperAdmin necesita para gestionar efectivamente toda la plataforma Arcinus. 