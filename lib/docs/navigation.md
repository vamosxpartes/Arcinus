# Módulo de Navegación

## Descripción General
El módulo de navegación es responsable de gestionar todas las rutas y la lógica de navegación dentro de la aplicación Arcinus. Utiliza `go_router` para una gestión de rutas declarativa y robusta, integrándose con el estado de autenticación para redirigir a los usuarios según sea necesario. También define diferentes "shells" de navegación (estructuras de UI con navegación persistente como `BottomNavigationBar` o `Drawer`) para los distintos roles de usuario.

## Estructura del Módulo

### Tecnologías Principales
- **go_router**: Paquete principal para la gestión de rutas.
- **Riverpod**: Para acceder al estado de autenticación y otros estados relevantes para la lógica de redirección.

### Componentes Clave

#### Router Principal
- **`AppRouter` (`lib/core/navigation/routes/app_router.dart`)**: Contiene la configuración principal de `GoRouter`, incluyendo la lista de rutas, lógica de redirección global y observadores de navegación.

#### Rutas Modularizadas
La estructura de rutas ha sido refactorizada para una mejor organización y mantenimiento:

- **`AppRoutes` (`lib/core/navigation/routes/app_routes.dart`)**: Define constantes para rutas generales y exporta todas las rutas específicas.
- **`AuthRoutes` (`lib/core/navigation/routes/auth_routes.dart`)**: Rutas de autenticación (login, registro, recuperación de contraseña, etc.).
- **`ManagerRoutes` (`lib/core/navigation/routes/manager_routes.dart`)**: Rutas compartidas entre Owner y Collaborator.
- **`OwnerRoutes` (`lib/core/navigation/routes/owner_routes.dart`)**: Rutas específicas del propietario.
- **`CollaboratorRoutes` (`lib/core/navigation/routes/collaborator_routes.dart`)**: Rutas específicas del colaborador.
- **`SuperAdminRoutes` (`lib/core/navigation/routes/super_admin_routes.dart`)**: Rutas del super administrador.
- **`AthleteRoutes` (`lib/core/navigation/routes/athlete_routes.dart`)**: Rutas del atleta.
- **`ParentRoutes` (`lib/core/navigation/routes/parent_routes.dart`)**: Rutas del padre/tutor.

#### Navigation Shells
- **`ManagerShell` (`lib/core/navigation/navigation_shells/manager_shell/manager_shell.dart`)**: UI Shell para usuarios con rol de "Manager" (Owner y Collaborator). Incluye componentes como `ManagerDrawer` y `ManagerAppBar`.
- **`SuperAdminShell` (`lib/core/navigation/navigation_shells/super_admin_shell/super_admin_shell.dart`)**: UI Shell para usuarios con rol de "Super Admin".
- Otros shells para diferentes roles (en desarrollo).

## Estructura de Rutas por Rol

### Rutas de Autenticación (`AuthRoutes`)
```
/auth/login                    - Inicio de sesión
/auth/register                 - Registro de usuario
/auth/forgot-password          - Recuperación de contraseña
/auth/reset-password           - Restablecer contraseña
/auth/verify-email             - Verificación de email
/auth/member-access            - Acceso para miembros
/auth/guest-access             - Acceso para invitados
/auth/2fa                      - Autenticación de dos factores
/auth/phone-verification       - Verificación telefónica
/auth/complete-profile         - Completar perfil
/auth/select-role              - Seleccionar rol
/auth/terms                    - Términos y condiciones
```

### Rutas de Manager (`ManagerRoutes`)
Shell compartido entre Owner y Collaborator:
```
/manager                       - Dashboard principal
/manager/create-academy        - Crear academia
/manager/academy/:academyId    - Vista de academia específica
/manager/academy/:academyId/members - Miembros de academia
/manager/academy/:academyId/payments - Pagos de academia
/manager/profile               - Perfil del usuario
/manager/settings              - Configuración
/manager/dev-tools/use-case-test - Herramientas de desarrollo
```

### Rutas de Owner (`OwnerRoutes`)
Rutas específicas del propietario (relativas a `/owner`):
```
owner_dashboard                - Dashboard del propietario
academy/:academyId             - Academia específica
academy/:academyId/edit        - Editar academia
academy_details                - Detalles de academia
members                        - Gestión de miembros
payments                       - Gestión de pagos
schedule                       - Horarios
stats                          - Estadísticas
more                           - Más opciones
groups                         - Grupos/Equipos
trainings                      - Entrenamientos
settings                       - Configuración
/owner/profile                 - Perfil (ruta completa)
```

### Rutas de Super Admin (`SuperAdminRoutes`)
```
/superadmin                    - Dashboard principal ✅
/superadmin/owners             - Gestión de propietarios ✅
/superadmin/academies          - Gestión de academias ✅
/superadmin/subscriptions      - Gestión de suscripciones ✅
/superadmin/sports             - Deportes globales ✅
/superadmin/system/backups     - Sistema de respaldos ✅
/superadmin/security           - Seguridad y auditoría ✅
/superadmin/analytics          - Análisis y métricas ✅
/superadmin/settings           - Configuración global ✅
```

**Nota**: Todas las rutas del SuperAdmin están correctamente implementadas en el router. Las rutas marcadas con ✅ utilizan `ScreenUnderDevelopment` como placeholder hasta que se implementen las pantallas específicas.

## Flujo de Navegación y Redirección

1. **Inicialización**: `AppRouter` configura `GoRouter` con todas las rutas definidas.
2. **Escucha de Estado de Autenticación**: `AppRouter` utiliza un `refreshListenable` conectado al estado de autenticación para reaccionar a cambios.
3. **Lógica de Redirección (`redirect`)**:
   - Usuario no autenticado → `/welcome`
   - Usuario autenticado sin academia (propietario) → `/create-academy`
   - Usuario autenticado → Ruta específica del rol
   - Manejo de rutas públicas y protegidas
4. **Navegación entre Rutas**: Se utiliza `context.go()`, `context.push()` con las constantes definidas.
5. **Navigation Shells**: Dependiendo del rol, se muestra el shell apropiado con navegación persistente.

## Beneficios de la Modularización

### Organización
- **Separación por responsabilidad**: Cada archivo de rutas maneja un dominio específico
- **Facilidad de mantenimiento**: Cambios en rutas de un rol no afectan otros
- **Escalabilidad**: Fácil agregar nuevas rutas sin saturar un archivo único

### Desarrollo en Equipo
- **Menos conflictos**: Diferentes desarrolladores pueden trabajar en rutas de diferentes roles
- **Revisiones más focalizadas**: PRs más pequeños y específicos
- **Responsabilidades claras**: Cada módulo tiene un propósito bien definido

### Mantenimiento
- **Búsqueda eficiente**: Fácil encontrar rutas específicas
- **Refactoring seguro**: Cambios aislados por dominio
- **Testing granular**: Pruebas específicas por módulo de rutas

## Integración con Módulos

- **Módulo de Autenticación**: El estado de autenticación determina la lógica de redirección
- **Módulos de Features**: Cada feature registra sus rutas en el archivo correspondiente
- **Providers de Estado**: Integración con Riverpod para estado reactivo

## Mejores Prácticas

1. **Modularización**: Mantener rutas organizadas por dominio/rol
2. **Constantes Tipadas**: Usar clases estáticas para evitar strings mágicos
3. **Rutas Relativas vs Absolutas**: Usar rutas relativas dentro de shells, absolutas para navegación entre shells
4. **Redirección Robusta**: Lógica clara basada en estado de autenticación y permisos
5. **Uso de ShellRoute**: Aprovechar shells para experiencias consistentes
6. **Documentación**: Mantener documentadas las rutas y su propósito

## Convenciones de Nomenclatura

### Archivos de Rutas
- `{role}_routes.dart` para rutas específicas de rol
- `auth_routes.dart` para autenticación
- `app_routes.dart` como punto de entrada principal

### Constantes de Rutas
- `root` para ruta base del shell
- Nombres descriptivos en camelCase
- Rutas con parámetros usando `:paramName`

### Nombres de Rutas
- Usar el mismo nombre que la constante para consistencia
- Prefijos por rol cuando sea necesario para evitar colisiones

## Mejoras Futuras

- **Generación de Código**: Para rutas tipadas automáticas
- **Deep Linking Avanzado**: Manejo de URLs complejas
- **Transiciones Personalizadas**: Animaciones específicas por ruta
- **Middleware de Rutas**: Para validaciones y transformaciones
- **Rutas Dinámicas**: Basadas en configuración remota
- **Testing Automatizado**: Pruebas de navegación y redirección

## Resolución de Problemas Comunes

### Error: "no routes for location: /ruta"

**Problema**: GoRouter no encuentra una ruta específica y muestra un error como:
```
GoException: no routes for location: /superadmin/analytics
```

**Causas comunes**:
1. La ruta está definida en las constantes (`SuperAdminRoutes`) pero no está registrada en el router (`app_router.dart`)
2. La ruta está mal escrita o tiene un path incorrecto
3. Falta el shell o la estructura de rutas padre

**Solución**:
1. Verificar que la ruta esté definida en el archivo de rutas correspondiente (ej: `super_admin_routes.dart`)
2. Asegurar que la ruta esté registrada en el router principal (`app_router.dart`)
3. Verificar que el path coincida exactamente con la constante definida
4. Si es necesario, usar `ScreenUnderDevelopment` como placeholder temporal

**Ejemplo de solución**:
```dart
// En app_router.dart, dentro del ShellRoute correspondiente:
GoRoute(
  path: 'analytics', // path relativo al shell
  name: 'superAdminAnalytics',
  builder: (context, state) => ScreenUnderDevelopment(
    message: 'Analytics y Métricas',
    icon: Icons.analytics_outlined,
    primaryColor: Colors.deepPurple,
    description: 'Análisis de uso, rendimiento y métricas del sistema',
  ),
),
```

### Inconsistencias entre Drawer y Router

**Problema**: Los elementos del drawer navegan a rutas que no existen en el router.

**Prevención**:
1. Siempre verificar que todas las rutas usadas en navegación shells estén implementadas
2. Usar análisis estático (`flutter analyze`) regularmente
3. Documentar nuevas rutas agregadas
4. Implementar tests de navegación para rutas críticas

## Migración y Refactoring

La refactorización de `app_routes.dart` a múltiples archivos específicos requiere:

1. **Actualizar Imports**: Cambiar referencias de `AppRoutes.x` a `XRoutes.y`
2. **Verificar Consistencia**: Asegurar que todas las rutas estén correctamente referenciadas
3. **Testing**: Validar que la navegación funciona correctamente
4. **Documentación**: Actualizar documentación y ejemplos

Esta estructura modular facilita el mantenimiento a largo plazo y mejora la experiencia de desarrollo del equipo.
