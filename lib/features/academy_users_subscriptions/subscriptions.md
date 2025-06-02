# Módulo de Suscripciones en Arcinus

## Descripción General
El módulo de suscripciones proporciona un sistema completo para gestionar dos tipos de suscripciones:

1. **Suscripciones de Academia**: Maneja los períodos de acceso de una academia específica a la plataforma.
2. **Suscripciones de Software (App)**: Gestiona los planes que los propietarios adquieren para acceder a diferentes características y límites de recursos en la plataforma.
3. **Planes de Suscripción para Atletas**: Gestiona los planes que los atletas pueden contratar dentro de cada academia.

Esta documentación cubre las diferentes facetas del sistema de suscripciones, con énfasis en la gestión de planes para atletas, que es la funcionalidad más reciente.

## Estructura del Módulo

### Modelos de Suscripción de Software
- **AppSubscriptionPlanModel**: Define un plan de suscripción disponible.
  - Tipos (free, basic, pro, enterprise)
  - Precio y moneda
  - Límites (academias, usuarios)
  - Características incluidas
  - Ciclo de facturación

- **AppSubscriptionModel**: Representa una suscripción activa de un propietario.
  - Referencias al propietario y al plan
  - Fechas de inicio, fin y pagos
  - Estado de la suscripción
  - Academias vinculadas
  - Contadores de uso

### Modelos de Planes para Atletas
- **SubscriptionPlanModel**: Define los planes disponibles para atletas dentro de una academia.
  - Nombre y descripción del plan
  - Precio y moneda
  - Ciclo de facturación (mensual, trimestral, semestral, anual)
  - Duración en días
  - Beneficios incluidos
  - Estado de activación (activo/inactivo)

### Enumeraciones
- **AppSubscriptionPlanType**: Define los tipos de planes (free, basic, pro, enterprise).
- **AppFeature**: Define las características disponibles (videoAnalysis, advancedStats, multipleAcademies, apiAccess, customization).
- **BillingCycle**: Define los ciclos de facturación disponibles (monthly, quarterly, biannual, annual).
- **PaymentStatus**: Define el estado de pago de un usuario (active, overdue, inactive).

### Repositorios
- **SubscriptionRepository**: Interfaz para definir las operaciones relacionadas con suscripciones de atletas.
- **SubscriptionRepositoryImpl**: Implementación que utiliza Firestore para:
  - Crear, actualizar y eliminar planes de suscripción
  - Asignar planes a atletas
  - Consultar planes activos y estadísticas

### Providers (Riverpod)
- **subscriptionRepositoryProvider**: Proporciona acceso al repositorio de suscripciones.
- **subscriptionPlansProvider**: Obtiene todos los planes de una academia.
- **activeSubscriptionPlansProvider**: Obtiene los planes activos para mostrar a los atletas.
- **userSubscriptionPlanProvider**: Obtiene el plan asignado a un usuario específico.

## Integración con Atletas

Los atletas ahora incluyen información sobre su plan de suscripción:

1. El modelo `AcademyUserModel` se complementa con `ClientUserModel` que incluye:
   - `subscriptionPlanId`: ID del plan asignado
   - `paymentStatus`: Estado actual del pago
   - `lastPaymentDate`: Fecha del último pago realizado
   - `nextPaymentDate`: Fecha del próximo pago
   - `remainingDays`: Días restantes de la suscripción

2. Las tarjetas de atletas en la pantalla de miembros muestran:
   - Estado del plan con código de colores
   - Nombre del plan asignado
   - Barra de progreso visual que muestra el tiempo restante
   - Fecha del próximo pago

3. Flujo de asignación de planes:
   - Al crear un nuevo atleta (último paso del formulario)
   - Al editar un atleta existente
   - A través de la pantalla de pagos del atleta

## Pantalla de Gestión de Planes

Se ha implementado una pantalla completa para gestionar los planes de suscripción:

1. **Funcionalidades principales**:
   - Listar todos los planes (activos e inactivos)
   - Crear planes nuevos con beneficios personalizables
   - Editar planes existentes
   - Activar/desactivar planes 
   - Filtrar la vista por planes activos/inactivos

2. **Diseño de las tarjetas de plan**:
   - Encabezado colorido con nombre y precio
   - Beneficios incluidos con iconos indicativos
   - Duración y descuento respecto al plan mensual
   - Botones de edición y activación/desactivación

3. **Formulario de creación/edición**:
   - Configuración de nombre, descripción y precio
   - Selección de ciclo de facturación
   - Gestión de beneficios incluidos
   - Activación/desactivación del plan

## Flujos Principales

### 1. Creación de Planes
- El propietario accede a la pantalla de Planes de Suscripción desde el drawer
- Crea planes con diferentes precios y ciclos de facturación
- Configura los beneficios incluidos y activa los planes

### 2. Asignación de Plan a Atleta
- Durante la creación de un nuevo atleta, en el último paso
- Selección del plan y fecha de inicio
- Cálculo automático de la fecha de finalización según el ciclo elegido

### 3. Visualización del Estado de Suscripción
- En la lista de miembros, se muestra el estado de cada atleta
- Indicadores visuales claros mediante colores y barras de progreso
- Información sobre días restantes y próximo pago

### 4. Renovación de Suscripciones
- Registro de pago que actualiza automáticamente las fechas
- Nueva fecha de finalización calculada según el ciclo del plan
- Actualización del estado del atleta (activo, en mora, inactivo)

## Estructura en Firestore

### Colección de Planes para Atletas
```
/academies/{academyId}/subscription_plans/{planId}
    - name: String
    - description: String
    - amount: Number
    - currency: String
    - billingCycle: String
    - extraDays: Number
    - benefits: Array<String>
    - isActive: Boolean
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

### Datos de Suscripción en Perfil de Atleta
```
/academies/{academyId}/users/{userId}
    - clientData:
        - subscriptionPlanId: String
        - paymentStatus: String
        - lastPaymentDate: Timestamp
        - nextPaymentDate: Timestamp
        - remainingDays: Number
```

## Integración con Otros Módulos

1. **Módulo de Atletas**:
   - Paso adicional de selección de plan en el formulario de creación
   - Información de estado de suscripción en las tarjetas de usuario

2. **Módulo de Pagos**:
   - Registro de pagos que actualiza el estado de suscripción
   - Visualización de historial de pagos vinculados al plan

3. **Router**:
   - Nueva ruta para la pantalla de gestión de planes de suscripción
   - Rutas para asignación y gestión de planes por atleta

## Mejores Prácticas
1. Activar solo los planes que están disponibles para nuevos atletas
2. Mantener planes inactivos para atletas que ya los tienen asignados
3. Diseñar planes con diferentes ciclos para ofrecer descuentos en ciclos más largos
4. Monitorear regularmente el estado de las suscripciones
5. Actualizar los beneficios para mantener el valor de los planes
