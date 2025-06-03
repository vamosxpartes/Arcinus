# Módulo Academy Users Subscriptions

## Descripción General

El módulo `academy_users_subscriptions` gestiona todo lo relacionado con los planes de suscripción que una academia puede ofrecer a sus usuarios. Esto incluye la creación, visualización, edición y gestión del estado (activo/inactivo) de dichos planes.

## Pantallas Principales

### 1. Gestión de Planes de Suscripción (`subscription_plans_screen.dart`)

Nombre de la clase: `SubscriptionPlansScreen`

Esta pantalla es la interfaz principal para que los administradores de una academia gestionen los planes de suscripción.

#### Funcionalidades Clave:

*   **Visualización de Planes:** Muestra una lista de planes de suscripción (`ListView.builder`) utilizando tarjetas individuales (`_buildPlanCard`) para cada plan.
*   **Información por Plan:** Cada tarjeta muestra:
    *   Nombre del plan.
    *   Precio formateado (`plan.formattedPrice`).
    *   Estado (activo/inactivo) visualmente diferenciado (ej. color del encabezado).
    *   (Se esperan más detalles como descripción, duración, etc., dentro del cuerpo de la tarjeta, no completamente visibles en las primeras 200 líneas).
*   **Creación de Nuevos Planes:**
    *   Un botón "nuevo" (`ElevatedButton.icon`) permite abrir un formulario (`_showPlanForm`) para crear un nuevo plan de suscripción. Los detalles de este formulario no son visibles en el fragmento inicial.
*   **Filtrado de Planes:**
    *   Un `Switch` permite al usuario alternar entre mostrar todos los planes o solo los planes activos (`_showInactivePlans`).
*   **Estado Vacío:** Muestra un mensaje y un botón para "Crear primer plan" si no hay planes (o planes activos) disponibles.
*   **Gestión del Título de la Pantalla:** Actualiza el título de la pantalla a "Planes de Suscripción" usando `titleManagerProvider`.
*   **Manejo de Carga y Errores:** Muestra un indicador de carga (`CircularProgressIndicator`) mientras se obtienen los datos y un mensaje de error en caso de fallo.

#### Parámetros Requeridos:

*   `academyId` (String): El identificador de la academia para la cual se están gestionando los planes de suscripción.

#### Proveedores (Providers) Relevantes (según imports y uso):

*   `subscriptionPlansProvider(academyId)`: Provider principal para obtener y gestionar la lista de planes de suscripción para una academia específica.
*   `titleManagerProvider` (de `core/navigation`): Para actualizar el título de la pantalla en el shell principal.

#### Interacciones y Lógica Adicional:

*   La función `_showPlanForm(context, [SubscriptionPlanModel? plan])` (no completamente visible, pero inferida por su uso para crear y editar) se encarga de mostrar el diálogo o pantalla para ingresar/modificar los detalles del plan.
*   Los planes inactivos se diferencian visualmente (ej. color del encabezado de la tarjeta).

#### Modelos de Datos:

*   `SubscriptionPlanModel`: Encapsula la información de un plan de suscripción (nombre, precio, estado, etc.).

## Estructura del Módulo (Parcial)

```
lib/features/academy_users_subscriptions/
├── data/
│   └── models/
│       └── subscription_plan_model.dart // Inferido por imports
├── domain/
│   └── repositories/
│       └── subscription_repository_impl.dart // Inferido por imports
├── presentation/
│   ├── providers/
│   │   └── subscription_plans_provider.dart // Contiene subscriptionPlansProvider
│   ├── screens/
│   │   ├── subscription_plans_screen.dart
│   │   ├── app_subscription_plans_screen.dart
│   │   └── owner_subscription_screen.dart
│   └── utils/ // (Contenido específico no explorado aún)
└── subscriptions.md (documentación interna)
```

## Próximos Pasos de Documentación

*   Detallar el contenido y la lógica del formulario `_showPlanForm` para la creación y edición de planes.
*   Documentar las otras pantallas identificadas:
    *   `app_subscription_plans_screen.dart`
    *   `owner_subscription_screen.dart`
*   Explorar y documentar el contenido de las carpetas `domain` (incluyendo `SubscriptionRepositoryImpl`), `data`, y `utils`.
*   Describir con más detalle el `SubscriptionPlanModel`.
*   Revisar el archivo Markdown interno (`subscriptions.md`) para información complementaria. 