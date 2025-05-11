# Módulo de Pagos

## Descripción General
El módulo de pagos permite a los propietarios de academias gestionar todos los pagos realizados por sus atletas, administrar planes de suscripción y monitorear el estado de pago de los usuarios cliente (atletas y padres).

## Nueva Experiencia de Usuario (UX)

La interfaz de pagos ha sido rediseñada para ofrecer una experiencia más contextual e integrada:

1. **Acceso contextual desde lista de miembros**:
   - Se eliminó la opción "Pagos" del drawer de navegación principal
   - La gestión de pagos se realiza directamente desde el contexto de cada atleta

2. **Tarjetas de usuario mejoradas**:
   - Muestran el estado de pago (activo, en mora, inactivo) con códigos de color intuitivos:
     - Verde para atletas con pagos al día
     - Naranja para atletas en mora
     - Gris para atletas inactivos
   - Incluyen información sobre el plan de suscripción
   - Visualizan la fecha del próximo pago
   - Incluyen barra de progreso que muestra el tiempo restante de la suscripción

3. **Gestos deslizantes (Dismissible)**:
   - **Deslizar izquierda → derecha**: Acceso rápido a gestión de pagos del atleta
   - **Deslizar derecha → izquierda**: Acceso rápido a edición de datos del atleta

4. **Navegación simplificada**:
   - Tap en la tarjeta: Acceso a detalles completos del usuario
   - Menos clics y navegaciones para realizar tareas comunes

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
- **SubscriptionRepository**: Interfaz para operaciones relacionadas con planes de suscripción.
- **SubscriptionRepositoryImpl**: Implementación que gestiona planes y asignaciones a usuarios.

### Providers (Riverpod)
- **PaymentsNotifier**: Gestiona los pagos a nivel de academia.
- **AthletePaymentsNotifier**: Gestiona los pagos específicos de un atleta.
- **PaymentFormNotifier**: Gestiona el estado del formulario de registro de pagos.
- **FilteredPaymentsProvider**: Proporciona pagos filtrados según diversos criterios.
- **clientUserProvider**: Nuevo provider que obtiene información de pago para atletas.
- **activeSubscriptionPlansProvider**: Proporciona planes de suscripción activos.
- **subscriptionPlansProvider**: Proporciona todos los planes de suscripción disponibles.

### Pantallas
- **PaymentsScreen**: Pantalla principal que muestra todos los pagos de la academia.
- **ManagerPaymentDetailScreen**: Pantalla de detalles de pagos para gestores (propietarios y colaboradores).
- **ClientPaymentDetailScreen**: Pantalla de detalles de pagos para clientes (atletas y padres).
- **RegisterPaymentScreen**: Formulario para registrar nuevos pagos.
- **AthletePaymentsScreen**: Gestión específica de pagos para un atleta (accesible vía gesto deslizante).
- **SubscriptionPlansScreen**: Gestión de planes de suscripción disponibles.

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
    │   │   ├── isActive       # Estado de activación del plan
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
        │       ├── lastPaymentDate        # Fecha del último pago
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
   - Un usuario gestor accede a un atleta desde la lista de miembros
   - Desliza la tarjeta del atleta de izquierda a derecha
   - Accede a la pantalla de pagos del atleta
   - Registra el nuevo pago completando el formulario
   - El sistema actualiza el estado del cliente según corresponda

2. **Consultar Pagos**:
   - Gestor: Visualiza todos los pagos, puede acceder directamente desde las tarjetas de atletas
   - Cliente: Visualiza sus propios pagos, puede ver su historial y estado de suscripción

3. **Gestionar Planes de Suscripción**:
   - El propietario accede a la pantalla de Planes de Suscripción desde el drawer
   - Puede crear, editar y activar/desactivar planes
   - Cada plan define precio, duración y beneficios

4. **Asignar Plan a un Atleta**:
   - Durante la creación de un nuevo atleta, en el último paso
   - Al editar un atleta existente desde su perfil
   - Directamente desde la pantalla de pagos del atleta

## Características Principales

### Visualización y Gestión de Pagos
- Información de pago visible directamente en las tarjetas de usuario
- Acceso rápido mediante gestos deslizantes
- Indicadores visuales claros del estado de pago
- Registro, edición y eliminación de pagos (soft delete)

### Gestión de Planes de Suscripción
- Creación, edición y activación/desactivación de planes
- Asignación de planes a usuarios
- Seguimiento del estado de suscripción
- Visualización de tiempo restante mediante barras de progreso

### Estado de Pago de Usuarios
- Monitoreo de usuarios activos, en mora e inactivos
- Cálculo automático de próximas fechas de pago
- Alertas visuales para pagos pendientes o próximos a vencer

### Adaptación de UI según Rol
- Vista administrativa completa para propietarios y colaboradores
- Vista simplificada para atletas y padres
- Interfaces contextuales que reducen la complejidad de navegación

## Mejoras Futuras

- Implementar filtrado por estado de pago en la lista de miembros
- Añadir notificaciones para pagos próximos a vencer
- Mejorar las estadísticas agregadas por grupos o categorías
- Exportación de datos a formatos como CSV o PDF
- Implementar recordatorios de pago automáticos
- Añadir métodos de pago online integrados
- Sistema de facturación electrónica
- Notificaciones push para recordatorios de pago 