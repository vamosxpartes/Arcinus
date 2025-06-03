***Features***

**[Diagnóstico General del Proyecto]**
*   [x] Análisis de la estructura de la base de datos (Firestore).
*   [x] Revisión de la organización actual de directorios del proyecto.
*   Listado de pantallas principales y sus funcionalidades.
    *   **arcinus_manager:**
        *   `arcinus_manager_dashboard_screen.dart`
    *   **academy_users:**
        *   `academy_user_details_screen.dart`
        *   `academy_users_manage_screen.dart`
        *   `edit_athlete_screen.dart`
        *   `academy_member_details_screen.dart`
        *   `member_details_screen.dart`
        *   `profile_screen.dart`
        *   `invite_member_screen.dart`
        *   `add_athlete_screen.dart`
        *   `edit_permissions_screen.dart`
    *   **academy_billing:**
        *   `billing_config_screen.dart`
    *   **academies:**
        *   `edit_academy_screen.dart`
    *   **academy_users_payments:**
        *   `register_payment_screen.g.dart`
        *   `payment_config_screen.dart`
        *   `register_payment_screen.dart`
        *   `payment_detail_screen.dart`
        *   `member_payment_detail_screen.dart`
        *   `manager_payment_detail_screen.dart`
        *   `payments_screen.dart`
    *   **academy_sports:**
        *   (No se encontraron pantallas dedicadas en la estructura de directorios inicial. Podrían estar integradas en otras vistas o gestionarse de otra forma.)
    *   **academy_users_subscriptions:**
        *   `subscription_plans_screen.dart`
        *   `app_subscription_plans_screen.dart`
        *   `owner_subscription_screen.dart`
*   Evaluación del estado de la configuración de CI/CD.
    *   No se encontraron archivos de configuración de CI/CD evidentes en el directorio raíz.
*   Análisis de la cobertura de pruebas actual.
    *   No se encontró un archivo de reporte de cobertura (ej. `lcov.info`).
    *   `pubspec.yaml` incluye dependencias para pruebas unitarias y widget tests (`flutter_test`, `fake_cloud_firestore`, `mocktail`), lo que sugiere una infraestructura de pruebas.
    *   No hay scripts de generación de cobertura evidentes en `pubspec.yaml`.

**Gestión del Software (SuperAdmin Shell)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la gestión del software.
        *   Identificar componentes de UI clave para la gestión del software.
        *   Revisar la lógica de negocio de las funcionalidades de SuperAdmin.
        *   Evaluar el estado de las pruebas para el SuperAdmin Shell.
        *   Documentar los modelos de datos utilizados en la gestión del software.

## Infraestructura SuperAdmin Shell
# Implementar SuperAdminDrawer con navegación específica (similar a ManagerDrawer)
# Crear SuperAdminAppBar con funcionalidades específicas del rol
# Configurar rutas anidadas en AppRouter para SuperAdminShell usando ShellRoute
# Implementar provider para gestión del estado global del SuperAdmin
# Crear widgets base reutilizables para pantallas del SuperAdmin

## Dashboard SuperAdmin (Expandir arcinus_manager)
# Adaptar arcinus_manager_dashboard_screen.dart para SuperAdmin con métricas globales:
    # Total de Propietarios de Academias registrados
    # Total de Academias activas/inactivas
    # Total de Usuarios en toda la plataforma
    # Ingresos totales por suscripciones
    # Métricas de uso de la aplicación (sesiones, tiempo promedio)
    # Estado del sistema y uptime
# Implementar alertas críticas específicas para SuperAdmin:
    # Suscripciones vencidas o por vencer
    # Problemas de integridad de datos
    # Academias con actividad sospechosa
    # Errores críticos del sistema
# Añadir accesos rápidos específicos del SuperAdmin:
    # Gestión de propietarios pendientes de aprobación
    # Configuración de planes de suscripción
    # Gestión de deportes globales
    # Herramientas de facturación de la plataforma
# Implementar resumen de actividad reciente a nivel de plataforma

## Gestión de Propietarios de Academias (Adaptado de academy_users)
# Crear pantalla de listado de todos los propietarios (owners_manage_screen.dart)
    # Lista con tarjetas de propietarios (similar a AcademyUserCard)
    # Filtrado por estado: Activo, Pendiente, Suspendido, Rechazado
    # Búsqueda por nombre, email o academia
    # Acciones: Ver detalles, Aprobar/Rechazar, Suspender/Activar
# Implementar pantalla de detalles del propietario (owner_details_screen.dart)
    # Información personal del propietario
    # Detalles de la academia asociada
    # Historial de suscripciones y pagos
    # Actividad reciente del propietario
    # Herramientas de moderación
# Crear pantalla de aprobación/rechazo de propietarios (owner_approval_screen.dart)
    # Formulario de revisión de solicitudes
    # Documentos subidos por el propietario
    # Comentarios internos para el equipo
    # Historial de decisiones
# Implementar notificaciones automáticas para propietarios
# Crear herramientas de comunicación directa con propietarios

## Gestión de Academias a Nivel Global (Adaptado de academies)
# Crear pantalla de listado global de academias (global_academies_screen.dart)
    # Vista de todas las academias de la plataforma
    # Filtrado por estado, país, deporte, plan de suscripción
    # Métricas por academia: usuarios, actividad, ingresos
    # Acciones administrativas: Ver detalles, Suspender, Editar configuración
# Implementar herramientas de moderación de academias
    # Suspensión temporal o permanente
    # Modificación de configuraciones críticas
    # Acceso de emergencia a datos de la academia
# Añadir funcionalidad de análisis de actividad por academia
# Crear herramientas de respaldo y restauración de datos de academias

## Gestión de Planes de Suscripción Global (Expandir academy_users_subscriptions)
# Crear pantalla de gestión de planes globales (global_subscription_plans_screen.dart)
    # CRUD completo de planes de suscripción de la plataforma
    # Configuración de precios por región/país
    # Gestión de features incluidas en cada plan
    # Definición de límites por plan (usuarios, almacenamiento, etc.)
# Implementar pantalla de configuración de features (platform_features_screen.dart)
    # Lista de todas las funcionalidades de la plataforma
    # Asignación de features a planes específicos
    # Activación/desactivación temporal de features
    # Configuración de límites y restricciones
# Crear herramientas de migración entre planes
# Implementar sistema de cupones y descuentos globales
# Añadir métricas de conversión y retención por plan

## Gestión de Pagos y Facturación Global (Expandir academy_users_payments y academy_billing)
# Crear dashboard de pagos globales (global_payments_dashboard_screen.dart)
    # Vista consolidada de todos los pagos de la plataforma
    # Métricas de ingresos por período, plan, región
    # Seguimiento de pagos fallidos y recuperación de ingresos
    # Herramientas de reconciliación contable
# Implementar gestión de suscripciones activas (platform_subscriptions_screen.dart)
    # Lista de todas las suscripciones activas
    # Herramientas para modificar estados de suscripción
    # Gestión de renovaciones y cancelaciones
    # Sistema de reactivación de suscripciones vencidas
# Crear pantalla de configuración de facturación global (global_billing_config_screen.dart)
    # Configuración de datos fiscales de la empresa
    # Plantillas de facturas para diferentes regiones
    # Configuración de métodos de pago aceptados
    # Integración con pasarelas de pago
# Implementar herramientas de reportes financieros
    # Informes de ingresos por período
    # Análisis de churn y retención
    # Métricas de LTV (Lifetime Value)
    # Proyecciones financieras
# Añadir sistema de notificaciones para suscripciones por vencer
# Crear herramientas de recuperación de pagos fallidos

## Gestión de Deportes Global (Expandir academy_sports)
# Crear pantalla de gestión de deportes (global_sports_screen.dart)
    # CRUD completo de deportes disponibles en la plataforma
    # Gestión de SportCharacteristics para cada deporte
    # Configuración de atributos específicos por deporte
    # Herramientas de validación de configuraciones deportivas
# Implementar editor visual de características deportivas
    # Interfaz para modificar positions, formations, exerciseCategories
    # Gestión de equipamiento necesario por deporte
    # Configuración de reglas y tipos de puntuación
# Añadir sistema de solicitudes de nuevos deportes por parte de academias
# Crear herramientas de migración y sincronización de datos deportivos
# Implementar validación automática de integridad en configuraciones deportivas

## Herramientas de Administración del Sistema
# Crear panel de monitoreo de integridad de datos (data_integrity_screen.dart)
    # Herramientas de diagnóstico de inconsistencias
    # Reportes automáticos de problemas detectados
    # Herramientas de limpieza y corrección de datos
    # Logs de auditoría de cambios críticos
# Implementar sistema de respaldo y restauración (backup_management_screen.dart)
    # Configuración de respaldos automáticos
    # Gestión de respaldos manuales
    # Herramientas de restauración selectiva
    # Verificación de integridad de respaldos
# Crear herramientas de análisis de uso (usage_analytics_screen.dart)
    # Métricas detalladas de uso por feature
    # Análisis de patrones de comportamiento
    # Identificación de funcionalidades menos utilizadas
    # Reportes de rendimiento de la aplicación
# Implementar sistema de configuración global de la aplicación
    # Parámetros de configuración del sistema
    # Límites globales y restricciones
    # Configuración de funcionalidades experimentales
    # Gestión de mantenimientos programados

## Comunicación y Notificaciones SuperAdmin
# Crear sistema de anuncios globales para todos los usuarios
# Implementar herramientas de comunicación masiva
# Añadir sistema de notificaciones de emergencia
# Crear canal de comunicación directo con propietarios de academias
# Implementar sistema de tickets de soporte técnico

## Seguridad y Auditoría
# Crear logs de auditoría para todas las acciones del SuperAdmin
# Implementar sistema de permisos granulares para el equipo SuperAdmin
# Añadir herramientas de monitoreo de seguridad
# Crear alertas automáticas para actividades sospechosas
# Implementar sistema de acceso de emergencia con trazabilidad completa

**Gestión Academia (Manager Shell)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la gestión de academia.
        *   Identificar componentes de UI clave para la gestión de academia.
        *   Revisar la lógica de negocio de las funcionalidades del Manager Shell para academias.
        *   Evaluar el estado de las pruebas para la gestión de academias.
        *   Documentar los modelos de datos utilizados en la gestión de academias.
# Estadísticas de la academia (Desarrollar vista de estadísticas básicas de la academia)
# Añadir funcionalidad para gestionar configuración y preferencias de la academia
# Revisar y optimizar la carga de academias con índices adecuados en Firestore
# Gestión de grupos/equipos (Completo: CRUD, Asignaciones)
# Integración de calendario y programación de actividades

**Gestión de Usuarios (Manager Shell)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la gestión de usuarios.
        *   Identificar componentes de UI clave para la gestión de usuarios.
        *   Revisar la lógica de negocio de las funcionalidades de gestión de usuarios.
        *   Evaluar el estado de las pruebas para la gestión de usuarios.
        *   Documentar los modelos de datos utilizados en la gestión de usuarios.
# Gestión específica de Entrenadores
# Gestión específica de Padres/Responsables
# Añadir filtrado y búsqueda de miembros por categoría/rol
# Implementar la visualización de perfiles completos de usuarios y acciones específicas para cada rol
# Control de acceso basado en permisos (Refinamiento Colaborador)

**Gestión de Atletas (Manager Shell)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la gestión de atletas.
        *   Identificar componentes de UI clave para la gestión de atletas.
        *   Revisar la lógica de negocio de las funcionalidades de gestión de atletas.
        *   Evaluar el estado de las pruebas para la gestión de atletas.
        *   Documentar los modelos de datos utilizados en la gestión de atletas.
# Implementación de evaluaciones y seguimiento de atletas

**Pagos (Manager Shell / Sistema)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual del sistema de pagos.
        *   Identificar componentes de UI clave para el sistema de pagos.
        *   Revisar la lógica de negocio de las funcionalidades de pagos.
        *   Evaluar el estado de las pruebas para el sistema de pagos.
        *   Documentar los modelos de datos utilizados en el sistema de pagos.
# Autenticación al registrar pago
# Factura automática al registrar pago
# Desarrollar pantalla de registro de pagos de atletas
# Implementar sistema de seguimiento de pagos pendientes y completados
# Crear informes básicos de pagos recibidos por período
# Integración Pasarela de Pagos (Suscripciones/Pagos Internos)

**Entrenamientos (Manager Shell)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la gestión de entrenamientos.
        *   Identificar componentes de UI clave para la gestión de entrenamientos.
        *   Revisar la lógica de negocio de las funcionalidades de entrenamientos.
        *   Evaluar el estado de las pruebas para la gestión de entrenamientos.
        *   Documentar los modelos de datos utilizados en la gestión de entrenamientos.
# Gestión de Inventario
# Gestión de Sitios de entrenamiento
# Gestión de Ejercicios
# Gestión de Grupos de entrenamiento
# Sistema de entrenamientos y sesiones (Definición, Planificación, Registro)

**Rendimiento Atletas**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual del seguimiento de rendimiento de atletas.
        *   Identificar componentes de UI clave para el rendimiento de atletas.
        *   Revisar la lógica de negocio de las funcionalidades de rendimiento.
        *   Evaluar el estado de las pruebas para el seguimiento de rendimiento.
        *   Documentar los modelos de datos utilizados en el rendimiento de atletas.
# Estadísticas de rendimiento
# Gestión de Pruebas de rendimiento
# Seguimiento de progreso de atletas

**Autenticación y Perfil de Usuario**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de la autenticación y perfil.
        *   Identificar componentes de UI clave para autenticación y perfil.
        *   Revisar la lógica de negocio de las funcionalidades de autenticación y perfil.
        *   Evaluar el estado de las pruebas para autenticación y perfil.
        *   Documentar los modelos de datos utilizados en autenticación y perfil.
# Inicio de Sesión con Apple (Integración Firebase Auth)
# Implementar pantalla de visualización y edición de perfil propio (Owner)
# Añadir funcionalidad para cambiar contraseña y datos de contacto (Owner)
# Incluir sección de preferencias de notificaciones (Owner)

**Comunicación**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual del sistema de comunicación.
        *   Identificar componentes de UI clave para la comunicación.
        *   Revisar la lógica de negocio de las funcionalidades de comunicación.
        *   Evaluar el estado de las pruebas para el sistema de comunicación.
        *   Documentar los modelos de datos utilizados en el sistema de comunicación.
# Sistema de comunicación interno y notificaciones (Chat/Anuncios, Push FCM)

**Desarrollo y Operaciones (DevOps)**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual de las herramientas de DevOps.
        *   Identificar componentes o scripts clave para DevOps.
        *   Revisar la lógica de los flujos de CI/CD.
        *   Evaluar el estado de las pruebas de integración y despliegue.
        *   Documentar la configuración y modelos de datos (si aplica) para DevOps.
# Configuración CI/CD (Builds y Despliegues Automatizados Básicos)
# Build Flavors/Environments (Dev/Prod si es necesario)
# Pruebas de Integración (Flujos Completos)

**Members Shell**
    *   Diagnóstico Específico:
        *   Verificar la implementación actual del Members Shell.
        *   Identificar componentes de UI clave para el Members Shell.
        *   Revisar la lógica de negocio de las funcionalidades del Members Shell.
        *   Evaluar el estado de las pruebas para el Members Shell.
        *   Documentar los modelos de datos utilizados en el Members Shell.
# (Definir tareas específicas para el shell de miembros/atletas/padres)
