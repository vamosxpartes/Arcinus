# Feature: Roles

## 1. Nombre del Feature y Resumen
**Nombre:** Roles
**Propósito/Objetivo:** Implementar un sistema flexible de roles de usuario que permita definir y gestionar diferentes niveles de acceso dentro de la aplicación, tanto roles predefinidos como personalizables.
**Alcance:** Definición de roles, creación de roles personalizados, asignación de usuarios a roles y gestión de la relación entre roles y permisos.

## 2. Estructura de Archivos Clave
* `lib/features/roles/models/custom_role.dart` - Modelo principal para roles personalizados
* `lib/features/roles/models/custom_role.freezed.dart` - Código generado para el modelo
* `lib/features/roles/models/custom_role.g.dart` - Serializadores generados para JSON
* `lib/features/roles/services/custom_role_service.dart` - Servicio para la gestión de roles personalizados

## 3. Componentes Principales (Código)
### Pantallas (Screens)
* No tiene pantallas propias, se integra con otras interfaces de gestión

### Widgets Reutilizables
* No implementa widgets específicos

### Proveedores (Providers)
* Proveedores para acceder a los servicios de roles

### Modelos de Datos (Models)
* `CustomRole` - Modelo para roles personalizados con nombre, descripción y permisos asociados
* Se integra con el modelo general de `UserRole` para los roles predeterminados

### Servicios/Controladores
* `CustomRoleService` - Servicio para CRUD de roles personalizados y asignación a usuarios

### Repositorios
* Implementa funcionalidad de persistencia dentro del servicio de roles

## 4. Flujo de Usuario (User Flow)
1. Los usuarios administradores crean roles personalizados 
2. Asignan permisos específicos a cada rol personalizado
3. Asignan usuarios a roles personalizados o predefinidos
4. El sistema aplica los permisos correspondientes según el rol

## 5. Gestión de Estado (State Management)
* Utiliza Riverpod para proporcionar acceso a los roles disponibles
* Integración con Freezed para inmutabilidad y gestión segura de estado

## 6. Interacción con Backend/Datos
* Persistencia de roles personalizados en Firestore
* Sincronización de roles entre dispositivos
* Almacenamiento de asignaciones de usuarios a roles

## 7. Dependencias
**Internas:** 
* Feature de Permisos para la definición de capacidades de cada rol
* Feature de Usuarios para la asignación de roles

**Externas:** 
* Freezed para generación de código relacionado con inmutabilidad
* Firestore para persistencia

## 8. Decisiones Arquitectónicas / Notas Importantes
* Separación entre roles predefinidos (enum) y roles personalizados
* Los roles personalizados son específicos por academia
* Sistema flexible que permite crear jerarquías de permisos personalizadas
* Los roles incluyen metadatos sobre creación y actualización para auditoría

## 9. Registro de Cambios
* Implementación inicial de roles predefinidos
* Adición de sistema de roles personalizados
* Integración con el sistema de permisos