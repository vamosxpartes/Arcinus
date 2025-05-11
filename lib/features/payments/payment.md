# Módulo de Pagos

## Descripción General
El módulo de pagos permite a los propietarios de academias gestionar todos los pagos realizados por sus atletas, administrar planes de suscripción y monitorear el estado de pago de los usuarios cliente (atletas y padres).

## Estructura del Módulo

### Modelos
- **PaymentModel**: Representa un pago individual con propiedades como monto, moneda, fecha, concepto y más.
- **SubscriptionPlanModel**: Representa un plan de suscripción disponible en la academia.

> **NOTA:** Los modelos `ClientUserModel` y `ManagerUserModel` han sido trasladados al módulo de usuarios y se importan desde allí.

### Enumeraciones
- **PaymentStatus**: Define los posibles estados de pago de un usuario cliente (active, overdue, inactive). Se encuentra ahora en el módulo de usuarios.
- **BillingCycle**: Define los ciclos de facturación disponibles (monthly, quarterly, biannual, annual).

### Repositorios
- **PaymentRepository**: Interfaz para definir las operaciones relacionadas con pagos.
- **PaymentRepositoryImpl**: Implementación que utiliza Firestore para almacenar y recuperar pagos.

### Providers (Riverpod)
- **PaymentsNotifier**: Gestiona los pagos a nivel de academia.
- **AthletePaymentsNotifier**: Gestiona los pagos específicos de un atleta.
- **PaymentFormNotifier**: Gestiona el estado del formulario de registro de pagos.
- **FilteredPaymentsProvider**: Proporciona pagos filtrados según diversos criterios.

### Pantallas
- **PaymentsScreen**: Pantalla principal que muestra todos los pagos de la academia.
- **ManagerPaymentDetailScreen**: Pantalla de detalles de pagos para gestores (propietarios y colaboradores).
- **ClientPaymentDetailScreen**: Pantalla de detalles de pagos para clientes (atletas y padres).
- **RegisterPaymentScreen**: Formulario para registrar nuevos pagos.

## Estructura en Firestore

```
/academies/{academyId}/
    ├── payments/              # Subcolección de pagos
    │   ├── {paymentId}/       # Documento de pago individual
    │   │   ├── amount         # Monto del pago
    │   │   ├── currency       # Moneda (USD, EUR, COP, etc.)
    │   │   ├── paymentDate    # Fecha del pago
    │   │   ├── userId         # ID del usuario que realizó el pago
    │   │   ├── concept        # Concepto o descripción
    │   │   ├── notes          # Notas adicionales
    │   │   └── ...
    │   └── ...
    │
    ├── subscription_plans/    # Subcolección de planes de suscripción
    │   ├── {planId}/          # Documento de plan individual
    │   │   ├── name           # Nombre del plan
    │   │   ├── amount         # Monto del plan
    │   │   ├── currency       # Moneda
    │   │   ├── billingCycle   # Ciclo de facturación
    │   │   ├── benefits       # Lista de beneficios
    │   │   └── ...
    │   └── ...
    │
    └── users/                 # Subcolección de usuarios
        ├── {userId}/          # Documento de usuario
        │   ├── role           # Rol (atleta, padre, etc.)
        │   ├── ...
        │   └── clientData/    # Datos específicos para clientes
        │       ├── paymentStatus          # Estado de pago
        │       ├── subscriptionPlanId     # ID del plan de suscripción
        │       ├── nextPaymentDate        # Fecha del próximo pago
        │       ├── remainingDays          # Días restantes para el pago
        │       └── ...
        └── ...
```

## Integración con Navigation Shells

El módulo de pagos se integra con los nuevos shells de navegación para proporcionar una experiencia de usuario adaptada al rol:

- **ManagerShell**: Los propietarios y colaboradores acceden a todas las funcionalidades de gestión de pagos.
- **ClientShell**: Los atletas y padres acceden a la visualización de sus pagos y estados de suscripción.

## Flujos de Trabajo

1. **Registrar un Pago**:
   - Un usuario gestor ingresa a Pagos > Registrar nuevo
   - Selecciona el atleta/cliente
   - Completa el formulario con monto, concepto, etc.
   - El sistema actualiza el estado del cliente según corresponda

2. **Consultar Pagos**:
   - Gestor: Visualiza todos los pagos, puede filtrar por atleta/fecha/monto
   - Cliente: Visualiza sus propios pagos, puede ver su historial y estado de suscripción

3. **Gestionar Suscripciones**:
   - El propietario puede crear planes de suscripción
   - Asignar planes a los clientes
   - Automatizar recordatorios de pagos

## Características Principales

### Visualización y Gestión de Pagos
- Lista de todos los pagos de la academia
- Vista detallada de pagos por usuario
- Información resumida y estadísticas
- Registro, edición y eliminación de pagos (soft delete)

### Gestión de Planes de Suscripción
- Creación, edición y eliminación de planes
- Asignación de planes a usuarios
- Seguimiento del estado de suscripción

### Estado de Pago de Usuarios
- Monitoreo de usuarios activos, en mora e inactivos
- Cálculo automático de próximas fechas de pago
- Alertas de pagos pendientes

### Adaptación de UI según Rol
- Vista administrativa completa para propietarios y colaboradores
- Vista simplificada para atletas y padres

## Mejoras Futuras

- Implementar filtrado avanzado de pagos
- Añadir reportes y estadísticas financieras
- Exportación de datos a formatos como CSV o PDF
- Implementar recordatorios de pago automáticos
- Añadir métodos de pago online integrados
- Sistema de facturación electrónica
- Notificaciones push para recordatorios de pago 