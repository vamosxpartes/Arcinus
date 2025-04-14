# Feature: Permissions

## 1. Nombre del Feature y Resumen
**Nombre:** Permissions
**Propósito/Objetivo:** Implementar un sistema granular de permisos que determine las capacidades específicas de cada usuario en la aplicación, proporcionando control preciso sobre las acciones disponibles.
**Alcance:** Definición, verificación y aplicación de permisos en toda la aplicación, integración con el sistema de roles.

## 2. Estructura de Archivos Clave
* `lib/features/permissions/core/models/permissions.dart` - Definición de todos los permisos disponibles
* `lib/features/permissions/providers/permission_providers.dart` - Proveedores para verificación de permisos
* `lib/features/permissions/core/services/` - Servicios para la gestión de permisos

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* No tiene pantallas propias, se integra con otras interfaces de gestión

### Widgets Reutilizables
* No implementa widgets específicos, aunque se utiliza en widgets condicionales basados en permisos

### Proveedores (Providers)
* `userPermissionsProvider` - Acceso a los permisos del usuario actual
* Proveedores para verificación de permisos específicos

### Modelos de Datos (Models)
* Clase `Permissions` con constantes para todos los permisos disponibles
* Maps de permisos que asocian nombres de permisos con valores booleanos

### Servicios/Controladores
* Servicios para la verificación y aplicación de permisos
* Helpers para determinar si un usuario tiene permisos específicos

### Repositorios
* No implementa repositorios específicos, se integra con el repositorio de usuarios

## 4. Flujo de Usuario (User Flow)
1. Los permisos se asignan a usuarios según su rol (predefinido o personalizado)
2. El sistema verifica los permisos antes de mostrar opciones o permitir acciones
3. Las interfaces se adaptan dinámicamente según los permisos disponibles
4. Los administradores pueden modificar permisos a través de la gestión de roles

## 5. Gestión de Estado (State Management)
* Utiliza Riverpod para proporcionar acceso a los permisos del usuario actual
* Permisos consultables mediante proveedores específicos
* Implementación de proveedores de familia para consultas parametrizadas

## 6. Interacción con Backend/Datos
* Los permisos se obtienen del perfil de usuario y de los roles asignados
* Se sincronizan junto con la información del usuario

## 7. Dependencias
**Internas:** 
* Feature de Roles para la asignación de permisos según roles
* Feature de Usuarios para obtener permisos del usuario actual

**Externas:** 
* Riverpod para la gestión de estado y proveedores

## 8. Decisiones Arquitectónicas / Notas Importantes
* Estructura de permisos granular con más de 25 permisos específicos
* Permisos organizados por categorías funcionales (administración, entrenamientos, etc.)
* Permisos predeterminados según el rol del usuario
* Sistema extensible para añadir nuevos permisos según crezca la aplicación

## 9. Registro de Cambios
* Implementación inicial del sistema de permisos básicos
* Expansión de permisos para nuevas funcionalidades
* Integración con sistema de roles personalizados