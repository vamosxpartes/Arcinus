# Feature: Navigation

## 1. Nombre del Feature y Resumen
**Nombre:** Navigation
**Propósito/Objetivo:** Proporcionar un sistema de navegación coherente y personalizable en toda la aplicación, que permita al usuario moverse de forma intuitiva entre las diferentes secciones.
**Alcance:** Implementación de la barra de navegación, gestión de rutas, transiciones entre pantallas y definición de la estructura general de navegación.

## 2. Estructura de Archivos Clave
* `lib/app.dart` - Widget principal de la aplicación, configuración inicial.
* `lib/features/navigation/main_screen.dart` - Pantalla principal que gestiona la navegación entre tabs.
* `lib/features/navigation/core/app_router.dart` - Define las rutas nombradas y la lógica de generación de rutas.
* `lib/features/navigation/core/services/navigation_service.dart` - Servicio central para la navegación (si aplica).
* `lib/features/navigation/core/models/navigation_item.dart` - Modelo para representar elementos de navegación (si aplica).
* `lib/features/navigation/components/custom_navigation_bar.dart` - Barra de navegación personalizada.
* `lib/features/navigation/components/navigation_items.dart` - Definición de elementos de navegación disponibles.
* `lib/features/navigation/components/base_scaffold.dart` - Scaffold base reutilizable.
* `lib/features/navigation/screens/loading_screen.dart` - Pantalla de carga genérica.
* `lib/features/navigation/screens/splash_screen.dart` - Pantalla de bienvenida inicial.
* `lib/features/navigation/screens/under_development_screen.dart` - Placeholder para funcionalidades no implementadas.
* `lib/features/navigation/screens/chat_list_screen.dart` - Pantalla de lista de chats (ejemplo).
* `lib/features/navigation/screens/notifications_screen.dart` - Pantalla de notificaciones (ejemplo).
* `lib/features/navigation/utils/exit_confirmation.dart` - Lógica para confirmar la salida de la app.

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* `MainScreen` - Pantalla principal que contiene la barra de navegación y gestiona las tabs

### Widgets Reutilizables
* `CustomNavigationBar` - Barra de navegación personalizada con soporte para anclar elementos
* `BaseScaffold` - Scaffold personalizado que encapsula la lógica de navegación común
* Componentes de transición entre pantallas

### Proveedores (Providers)
* Proveedores para gestionar el estado de navegación actual
* Integración con Riverpod para la gestión de estado

### Modelos de Datos (Models)
* `NavigationItem` - Modelo que representa un elemento de navegación con ícono, etiqueta y destino

### Servicios/Controladores
* `NavigationService` - Servicio que centraliza la lógica de navegación y gestiona elementos anclados

### Repositorios
* No implementa repositorios específicos

## 4. Flujo de Usuario (User Flow)
1. El usuario accede a las principales secciones mediante la barra de navegación inferior
2. Puede anclar elementos favoritos para acceso rápido
3. El botón "+" proporciona acciones contextuales según la sección actual
4. La navegación respeta el historial para facilitar el retorno a pantallas anteriores

## 5. Gestión de Estado (State Management)
* **Ruta Activa:** Se utiliza `Riverpod` con un `StateProvider` (`currentRouteProvider`) para mantener el nombre de la ruta actual visible. Un `NavigatorObserver` (`AppRouteObserver`) actualiza este provider en cada evento de navegación (`push`, `pop`, `replace`).
* **Ítems Fijados:** Se utiliza `Riverpod` con un `StateNotifierProvider` (`pinnedItemsProvider`) que gestiona la lista de `NavigationItem` fijados por el usuario. `NavigationService` interactúa con este provider y con `SharedPreferences` para persistir la selección.
* **Estado Interno (`MainScreen`):** Mantiene el estado del `_currentTab` para saber qué widget mostrar en el `body`.
* **Estado Interno (`CustomNavigationBar`):** Gestiona animaciones internas para el panel expandible y la posición del botón 'Agregar'.

## 6. Interacción con Backend/Datos
* Almacenamiento local (`SharedPreferences`) de las preferencias de navegación del usuario (destinos de los ítems anclados) a través de `NavigationService`.
* No realiza peticiones al backend directamente.

## 7. Dependencias
**Internas:** 
* Utiliza las pantallas de las diferentes secciones de la aplicación.
* `features/navigation/core/providers` para el estado global.
* `features/navigation/core/services/route_observer.dart`.

**Externas:** 
* `flutter_riverpod` para la gestión de estado.
* `shared_preferences` para persistir los ítems fijados.

## 8. Decisiones Arquitectónicas / Notas Importantes
* Implementación de navegación basada en tabs para las secciones principales
* Sistema de anclaje de elementos para personalización
* Acciones contextuales según la sección activa
* Compatibilidad con navegación anidada dentro de cada sección
* `BaseScaffold` que encapsula la lógica de navegación común para reducir duplicación y garantizar consistencia

## 9. Registro de Cambios
* Implementación inicial del sistema de navegación por tabs
* Adición del sistema de elementos anclados
* Implementación de acciones contextuales por sección
* Creación del BaseScaffold para estandarizar la estructura de pantallas
* Actualización de pantallas para usar BaseScaffold en módulos de chat y notificaciones
* Refactorización de pantallas para adaptar el uso correcto de BaseScaffold en lugar de Scaffold
* Implementación del sistema de middleware de autenticación:
  * Creación de AuthRoutingMiddleware para centralizar la lógica de navegación basada en autenticación
  * Implementación de AuthScaffold que integra BaseScaffold con el middleware de autenticación
  * Actualización de pantallas clave para usar AuthScaffold y obtener redirección automática
* **Modularización de `app.dart`**:
  * Extracción de pantallas (`LoadingScreen`, `ChatListScreen`, `NotificationsScreen`, `UnderDevelopmentScreen`) a `lib/features/navigation/screens/`.
  * Extracción de la lógica de rutas (`routes`, `onGenerateRoute`, `onUnknownRoute`) a `lib/features/navigation/core/app_router.dart`.
  * Extracción de la lógica de confirmación de salida a `lib/features/navigation/utils/exit_confirmation.dart`.
* **Gestión de Estado de Navegación con Riverpod:**
  * Se introdujo `currentRouteProvider` (StateProvider) y `AppRouteObserver` para rastrear la ruta activa globalmente.
  * Se introdujo `pinnedItemsProvider` (StateNotifierProvider) para gestionar centralizadamente los ítems fijados.
  * `NavigationService` se refactorizó para usar `Ref` y actualizar los providers, además de `SharedPreferences`.
  * `BaseScaffold` y `MainScreen` fueron actualizados para consumir estos providers y obtener el estado de navegación.

## 10. Pantallas que Deben Usar BaseScaffold o AuthScaffold

Las siguientes pantallas deben actualizarse:

### Pantallas que requieren autenticación (usar AuthScaffold)
* `lib/features/app/users/user/screens/profile_screen.dart` ✓
* `lib/features/app/users/user/screens/user_management_screen.dart` <--- **Pendiente (usa BaseScaffold)**
* `lib/features/app/academy/screens/*.dart`
* `lib/features/app/excersice/screens/*.dart`
* `lib/features/app/trainings/screens/*.dart`

### Pantallas sin requisito de autenticación (usar BaseScaffold)
* `lib/features/navigation/screens/loading_screen.dart` ✓
* `lib/features/navigation/screens/under_development_screen.dart` ✓
* `lib/features/navigation/screens/chat_list_screen.dart` ✓
* `lib/features/navigation/screens/notifications_screen.dart` ✓
* `lib/features/auth/screens/login_screen.dart` ✓
* `lib/features/auth/screens/signin_screen.dart`
* `lib/features/auth/screens/register_screen.dart`

### Notas sobre el uso de AuthScaffold y BaseScaffold
* AuthScaffold: Usar para pantallas que requieren autenticación
  * Proporciona redirección automática al login cuando no hay sesión activa
  * Maneja automáticamente los cambios en el estado de autenticación
* BaseScaffold: Usar para pantallas básicas sin requisitos de autenticación
  * Más ligero, sin verificación de autenticación
  * Adecuado para pantallas de login, registro, etc.
* Pantallas de formularios: Usar con `showNavigation: false`
* **Pantallas dentro de MainScreen**: Cuando una pantalla será mostrada dentro de MainScreen, debe establecer `showNavigation: false` para evitar duplicación de barras de navegación
  * MainScreen ya proporciona su propia CustomNavigationBar
  * Ejemplos: DashboardScreen, ProfileScreen cuando se accede desde el tab de perfil