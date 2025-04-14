# Feature: Navigation

## 1. Nombre del Feature y Resumen
**Nombre:** Navigation
**Propósito/Objetivo:** Proporcionar un sistema de navegación coherente y personalizable en toda la aplicación, que permita al usuario moverse de forma intuitiva entre las diferentes secciones.
**Alcance:** Implementación de la barra de navegación, gestión de rutas, transiciones entre pantallas y definición de la estructura general de navegación.

## 2. Estructura de Archivos Clave
* `lib/features/navigation/main_screen.dart` - Pantalla principal que gestiona la navegación entre tabs
* `lib/features/navigation/core/services/navigation_service.dart` - Servicio central para la navegación
* `lib/features/navigation/core/models/navigation_item.dart` - Modelo para representar elementos de navegación
* `lib/features/navigation/components/custom_navigation_bar.dart` - Barra de navegación personalizada
* `lib/features/navigation/components/navigation_items.dart` - Definición de elementos de navegación disponibles

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* `MainScreen` - Pantalla principal que contiene la barra de navegación y gestiona las tabs

### Widgets Reutilizables
* `CustomNavigationBar` - Barra de navegación personalizada con soporte para anclar elementos
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
* Mantiene el estado de la tab actual dentro de MainScreen
* Utiliza Riverpod para la gestión de estado global de navegación
* Mantiene un registro de los elementos anclados por el usuario

## 6. Interacción con Backend/Datos
* Almacenamiento local de preferencias de navegación del usuario (elementos anclados)
* No realiza peticiones al backend directamente

## 7. Dependencias
**Internas:** 
* Utiliza las pantallas de las diferentes secciones de la aplicación
* Integración con el sistema de permisos para la disponibilidad de rutas

**Externas:** 
* Flutter Riverpod para la gestión de estado

## 8. Decisiones Arquitectónicas / Notas Importantes
* Implementación de navegación basada en tabs para las secciones principales
* Sistema de anclaje de elementos para personalización
* Acciones contextuales según la sección activa
* Compatibilidad con navegación anidada dentro de cada sección

## 9. Registro de Cambios
* Implementación inicial del sistema de navegación por tabs
* Adición del sistema de elementos anclados
* Implementación de acciones contextuales por sección