# Módulo de Suscripciones en Arcinus

## Descripción General
El módulo de suscripciones proporciona un sistema completo para gestionar dos tipos de suscripciones:

1. **Suscripciones de Academia**: Maneja los períodos de acceso de una academia específica a la plataforma.
2. **Suscripciones de Software (App)**: Gestiona los planes que los propietarios adquieren para acceder a diferentes características y límites de recursos en la plataforma.

Esta documentación se centra en las **Suscripciones de Software**, que determinan cuántas academias puede crear un propietario, cuántos usuarios pueden tener sus academias, y a qué características tienen acceso.

## Estructura del Módulo

### Modelos
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

### Enumeraciones
- **AppSubscriptionPlanType**: Define los tipos de planes (free, basic, pro, enterprise).
- **AppFeature**: Define las características disponibles (videoAnalysis, advancedStats, multipleAcademies, apiAccess, customization).

### Repositorios
- **AppSubscriptionRepository**: Interfaz para definir las operaciones relacionadas con suscripciones.
- **AppSubscriptionRepositoryImpl**: Implementación que utiliza Firestore para almacenar y recuperar suscripciones en colecciones principales:
  - `plans`: Almacena los planes disponibles
  - `subscriptions`: Almacena las suscripciones activas de los propietarios

### Providers (Riverpod)
- **appSubscriptionProvider**: Obtiene la suscripción activa de un propietario.
- **availablePlansProvider**: Obtiene todos los planes de suscripción disponibles.
- **canCreateMoreAcademiesProvider**: Verifica si un propietario puede crear más academias.
- **isFeatureAvailableProvider**: Verifica si una característica está disponible para una academia.

## Integración con Academias

Las academias heredan características de la suscripción de su propietario:

1. El `AcademyModel` incluye:
   - `ownerSubscriptionId`: ID de la suscripción del propietario
   - `inheritedFeatures`: Lista de características heredadas del plan del propietario

2. El `AcademyProvider` se ha actualizado para:
   - Obtener la suscripción del propietario
   - Actualizar la academia con las características heredadas

3. El provider `isFeatureAvailableForAcademy` permite verificar fácilmente si una característica está disponible.

## Flujos Principales

### 1. Suscripción Inicial
- El propietario selecciona un plan
- Se crea una suscripción con fecha de inicio y fin
- La suscripción se vincula al propietario

### 2. Creación de Academia
- Se verifica si el propietario puede crear más academias según su plan
- La academia creada hereda las características del plan del propietario
- Se actualiza el contador de academias en la suscripción

### 3. Verificación de Características
- Al acceder a funcionalidades específicas, se verifica si están disponibles en el plan
- Se muestra u oculta la funcionalidad según corresponda

### 4. Cambio de Plan
- El propietario puede cambiar su plan en cualquier momento
- Se actualizan todas las academias con las nuevas características heredadas

## Estructura en Firestore

### Colección `plans`
```
/plans/{planId}
    - name: String
    - planType: String (free, basic, pro, enterprise)
    - price: Number
    - currency: String
    - billingCycle: String
    - maxAcademies: Number
    - maxUsersPerAcademy: Number
    - features: Array<String>
    - benefits: Array<String>
    - isActive: Boolean
    - metadata: Map
```

### Colección `subscriptions`
```
/subscriptions/{subscriptionId}
    - ownerId: String
    - planId: String
    - status: String
    - startDate: Timestamp
    - endDate: Timestamp
    - lastPaymentDate: Timestamp
    - nextPaymentDate: Timestamp
    - academyIds: Array<String>
    - currentAcademyCount: Number
    - totalUserCount: Number
    - paymentHistory: Map
    - metadata: Map
```

## Pantallas de Usuario
- **AppSubscriptionPlansScreen**: Muestra y permite seleccionar planes de suscripción.
- **OwnerSubscriptionScreen**: Muestra los detalles de la suscripción actual de un propietario.

## Inicialización
Se proporciona un `AppSubscriptionInitializer` para crear planes predeterminados en Firestore si no existen.

## Mejores Prácticas
1. Verificar siempre la disponibilidad de características antes de mostrarlas en la UI
2. Consultar los límites de recursos antes de permitir acciones como crear academias
3. Mantener actualizados los contadores de uso en la suscripción
4. Manejar adecuadamente los casos de suscripción expirada o inactiva
