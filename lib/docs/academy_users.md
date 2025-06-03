# Módulo Academy Users

## Descripción General

El módulo `academy_users` se encarga de la gestión de todos los usuarios asociados a una academia, incluyendo atletas, padres/tutores y colaboradores. Proporciona las herramientas para visualizar, añadir, editar y administrar los perfiles y roles de los miembros de la academia.

Este módulo también maneja la lógica de actualización de datos de los usuarios, especialmente en respuesta a eventos como pagos de suscripciones, asegurando que la información mostrada sea siempre la más reciente.

## Pantallas Principales

### 1. Gestión de Miembros de la Academia (`academy_users_manage_screen.dart`)

Nombre de la clase: `AcademyMembersScreen`

Esta pantalla es el punto central para la administración de los miembros de una academia específica. Permite a los administradores ver una lista de todos los miembros, buscarlos, y realizar acciones como añadir nuevos miembros.

#### Funcionalidades Clave:

*   **Visualización de Miembros:** Muestra una lista de los usuarios (atletas, etc.) asociados a la academia. Se espera que utilice el widget `AcademyUserCard` para mostrar la información de cada usuario.
*   **Búsqueda de Miembros:** Incluye un campo de búsqueda (`_searchController`) para filtrar la lista de miembros por nombre u otro criterio.
*   **Añadir Nuevos Miembros (`_showAddOptionsDialog`):**
    *   Proporciona opciones para añadir diferentes tipos de miembros:
        *   **Añadir Atleta:** Navega a la pantalla `AddAthleteScreen`.
        *   **Añadir Padre/Tutor:** (Funcionalidad futura) Actualmente muestra una pantalla de "En desarrollo".
        *   **Añadir Colaborador:** (Funcionalidad futura) Actualmente muestra una pantalla de "En desarrollo".
*   **Actualización Automática de Datos:**
    *   Implementa `WidgetsBindingObserver` y el método `didChangeAppLifecycleState` para detectar cuándo la aplicación vuelve al primer plano (estado `resumed`).
    *   Si ha pasado un tiempo determinado (actualmente > 5 segundos) desde la última actualización, se dispara un refresh de datos (`_refreshDataAfterPaymentUpdate`) para asegurar que la información esté actualizada, especialmente después de procesos externos como pagos.
    *   Incluye `AppLogger` para el seguimiento detallado del ciclo de vida y los procesos de actualización.
*   **Actualización Manual (Pull-to-Refresh):** Se asume que la interfaz de usuario permitirá la actualización manual de la lista de miembros (aunque el widget `RefreshIndicator` no es visible en las primeras 200 líneas, es una práctica común junto con la lógica de refresh existente).
*   **Gestión del Título de la Pantalla:** Utiliza un `titleManagerProvider` para actualizar dinámicamente el título de la pantalla a "Miembros".

#### Parámetros Requeridos:

*   `academyId` (String): El identificador de la academia cuyos miembros se van a gestionar. Este parámetro es esencial para cargar los datos correctos.

#### Interacciones y Lógica Adicional:

*   **Timestamps para Evitar Refreshes Excesivos (`_lastRefreshTime`):** Mantiene un registro de la última vez que se actualizaron los datos para evitar llamadas redundantes a la API o procesos de recarga.
*   **Notificación de Pagos (`_shouldRefreshAfterPayment`):** Aunque no se detalla su uso en el `initState` o `didChangeAppLifecycleState` inicial, la variable sugiere un mecanismo para forzar la actualización después de que se complete un pago en otra parte de la aplicación.

#### Proveedores (Providers) Relevantes (según imports):

*   `academy_member_provider.dart`: Probablemente contiene la lógica principal para obtener y gestionar los datos de los miembros de la academia.
*   `academy_users_providers.dart`: Otros providers relacionados con los usuarios de la academia.
*   `athlete_periods_info_provider.dart` y `period_providers.dart` (del feature `academy_users_subscriptions`): Sugieren una integración para mostrar información de suscripciones o periodos de los atletas.
*   `titleManagerProvider` (de `core/navigation`): Para gestionar el título de la pantalla en la barra de navegación o appBar.

#### Widgets Reutilizables (según imports):

*   `AvatarHorizontalScrollSection`: Podría usarse para mostrar una selección rápida o un filtro de usuarios destacados.
*   `AcademyUserCard`: Widget para mostrar la información individual de cada miembro de la academia.

## Estructura del Módulo (Parcial)

```
lib/features/academy_users/
├── data/
│   └── models/
│       └── academy_user_model.dart
├── domain/ 
├── presentation/
│   ├── providers/
│   │   ├── academy_member_provider.dart
│   │   └── academy_users_providers.dart
│   ├── screens/
│   │   ├── academy_users_manage_screen.dart
│   │   ├── add_athlete_screen.dart
│   │   ├── ... (otras pantallas)
│   └── widgets/
│       ├── avatar_horizontal_scroll_section.dart
│       └── academy_user_card.dart
├── academy_users.md (documentación interna)
├── implementation_recommendations.md (documentación interna)
└── strategy_documentation.md (documentación interna)
```

## Próximos Pasos de Documentación

*   Documentar las otras pantallas identificadas en `lib/features/academy_users/presentation/screens/`:
    *   `academy_user_details_screen.dart`
    *   `edit_athlete_screen.dart`
    *   `academy_member_details_screen.dart`
    *   `member_details_screen.dart`
    *   `profile_screen.dart`
    *   `invite_member_screen.dart`
    *   `add_athlete_screen.dart` (ya referenciada)
    *   `edit_permissions_screen.dart`
*   Detallar la funcionalidad de los `providers` clave.
*   Describir la estructura y el propósito de las carpetas `domain` y `data`, incluyendo los modelos como `academy_user_model.dart`.
*   Revisar los archivos Markdown existentes (`academy_users.md`, `implementation_recommendations.md`, `strategy_documentation.md`) en `lib/features/academy_users/` para extraer información relevante que pueda complementar esta documentación oficial. 