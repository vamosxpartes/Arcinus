# Arcinus - Sistema de Gestión para Academias Deportivas

Arcinus es una aplicación móvil desarrollada en Flutter para la gestión integral de academias deportivas. Permite administrar entrenadores, atletas, grupos, entrenamientos, clases, asistencia, pagos y comunicaciones.

## Estado Actual del Desarrollo

El proyecto se encuentra en fase activa de desarrollo con los siguientes componentes implementados:

- ✅ **Autenticación y gestión de usuarios** completa
- ✅ **Sistema de navegación personalizado** sin AppBar, con gestos deslizables y barra inferior configurable
- ✅ **Gestión de academias** con creación, listado y detalles básicos
- ✅ **Dashboards dinámicos basados en permisos** con estadísticas y métricas relevantes
- ✅ **Sistema de permisos granular** para control de acceso a funcionalidades
- ✅ **Sistema de roles personalizados** con interfaz completa de gestión
- ✅ **Optimización de verificación de permisos** mediante sistema de caché
- ✅ **CRUD completo de atletas, entrenadores y gerentes** con pantallas dedicadas
- ✅ **Gestión de grupos/equipos** con asignación de entrenadores y atletas
- ✅ **Sistema de entrenamientos y sesiones** con plantillas, recurrencia y asistencia

Actualmente trabajando en:
- 🔄 Implementación de evaluaciones y seguimiento de atletas
- 🔄 Integración de calendario y programación de actividades
- 🔄 Sistema de comunicación interno y notificaciones

## Características Principales

- **Registro jerárquico de usuarios**: Sólo los propietarios pueden registrarse directamente. Los propietarios gestionan la creación de cuentas para entrenadores, atletas y padres/responsables.
- **Gestión completa de academias deportivas**: Administración de equipos, entrenamientos, clases, asistencia y más.
- **Seguimiento de rendimiento**: Evaluación y seguimiento del progreso de atletas.
- **Sistema de pagos**: Control de mensualidades y pagos.
- **Sistema de comunicación integrado**: Chat interno y notificaciones para mantener a todos los miembros informados.
- **Control de acceso basado en permisos**: Sistema granular que permite control preciso sobre cada funcionalidad.
- **Roles personalizados**: Creación y gestión de roles con combinaciones específicas de permisos.

## Sistema de Entrenamientos y Sesiones

El nuevo sistema de entrenamientos implementado ofrece:

- **Gestión completa de entrenamientos**: Creación, edición y eliminación de entrenamientos.
- **Plantillas reutilizables**: Crear plantillas que pueden utilizarse como base para nuevos entrenamientos.
- **Entrenamientos recurrentes**: Configurar un entrenamiento para repetirse según un patrón (diario, semanal, mensual).
- **Sesiones específicas**: Gestión de sesiones individuales derivadas de un entrenamiento.
- **Registro de asistencia**: Control detallado de asistencia de atletas a cada sesión.
- **Seguimiento de rendimiento**: Registro de datos de desempeño en cada sesión.
- **Flujo de trabajo intuitivo**: Interfaz fácil de usar para la gestión completa del ciclo de entrenamiento.

## Mejoras Planificadas e Implementadas

Como parte de nuestra estrategia de mejora continua, se han identificado e implementado las siguientes mejoras arquitectónicas:

### 1. Optimización de Componentes de Navegación ✅
Se ha centralizado la gestión del BottomNavigationBar en un componente dedicado, reduciendo la duplicación de código en diversas pantallas. Esto ha mejorado la mantenibilidad y asegurado consistencia en la experiencia de navegación.

### 2. Refactorización de Widgets ✅
Se ha implementado una estrategia de modularización rigurosa para externalizar widgets y métodos reutilizables en las diferentes pantallas, permitiendo:
- Reducción significativa de la complejidad de archivos principales
- Mejor capacidad de testing individual de componentes
- Mayor facilidad de colaboración en el desarrollo del proyecto

### 3. Migración a Arquitectura Basada en Permisos ✅
Se ha completado la evolución del sistema basado en roles hacia uno fundamentado en permisos específicos, logrando:
- Mayor granularidad en el control de acceso a funcionalidades
- Flexibilidad para personalizar permisos sin alterar roles predefinidos
- Renderización condicional de UI basada en permisos individuales en lugar de roles completos
- Navegación y visualización de contenido adaptada a los permisos específicos de cada usuario

### 4. Optimización de Verificación de Permisos ✅
Se ha implementado un sistema para mejorar el rendimiento de las verificaciones de permisos:
- Caché inteligente de permisos con invalidación automática
- Reducción significativa de operaciones de verificación repetitivas
- Widgets optimizados para mostrar/ocultar contenido basado en permisos
- Mayor fluidez de la interfaz de usuario en pantallas con múltiples comprobaciones

### 5. Sistema de Roles Personalizados ✅
Se ha desarrollado un sistema completo para la creación y gestión de roles personalizados:
- Creación de roles con combinaciones específicas de permisos
- Interfaz para editar y eliminar roles existentes
- Asignación de roles personalizados a múltiples usuarios
- Visualización clara de permisos asociados a cada rol

### Próximas Mejoras Planificadas

1. **Sistema de Auditoría de Permisos**: Implementación de registro y seguimiento de cambios en permisos.
2. **Notificaciones de Cambios de Permisos**: Alertar a usuarios cuando sus permisos son modificados.
3. **Optimización de Consultas a Firestore**: Mejorar la eficiencia en el acceso a datos.

## Esquema de Roles

1. **SuperAdmin**: Administrador de la plataforma (equipo de Arcinus).
2. **Propietario**: Dueño de la academia, con acceso completo a su academia.
3. **Manager**: Gerente administrativo, ayuda en la gestión de la academia.
4. **Entrenador**: Responsable de grupos/equipos y entrenamientos.
5. **Atleta**: Miembro de la academia que participa en las actividades.
6. **Padre/Responsable**: Relacionado con uno o más atletas.
7. **Roles Personalizados**: Combinaciones específicas de permisos definidas por propietarios o managers.

## Estructura de Firestore

```
Collection 'academies'
  |- Document '{academyId}'
      |- Field: name, logo, sport, sportCharacteristics, ownerId, groupIds, coachIds, athleteIds, settings, subscription, createdAt
      |- Collection 'groups'
      |- Collection 'trainings'

Collection 'users'
  |- Document '{userId}'
      |- Field: email, name, role, permissions, academyIds, customRoleIds, createdAt
      |- Collection 'profile'
      |- Collection 'coach_profile' (si el rol es coach)
      |- Collection 'athlete_profile' (si el rol es athlete)
      |- Collection 'parent_profile' (si el rol es parent)

Collection 'custom_roles'
  |- Document '{roleId}'
      |- Field: name, description, academyId, permissions, assignedUserIds, createdBy, createdAt, updatedAt

Collection 'classes'
  |- Document '{classId}'
      |- Collection 'attendance'
      |- Collection 'performance'

Collection 'payments'
  |- Document '{paymentId}'

Collection 'messages'
  |- Document '{messageId}'
      |- Field: senderId, receiverId, content, timestamp, read

Collection 'notifications'
  |- Document '{notificationId}'
      |- Field: userId, title, body, type, read, timestamp, data
```

## Gestión de Cuentas (Sistema Jerárquico)

En Arcinus, implementamos un sistema jerárquico para la gestión de cuentas:

1. **Registro Inicial**: Solo los propietarios de academias pueden registrarse directamente en la aplicación.

2. **Flujo de Inicio para Propietarios**:
   - Después del registro, un propietario debe crear su academia obligatoriamente
   - No podrá acceder al dashboard hasta completar la creación de la academia
   - Si cierra la aplicación durante este proceso, al volver a iniciar sesión continuará en la pantalla de creación

3. **Creación de Cuentas**:
   - Los **Propietarios** pueden crear cuentas para:
     - Managers
     - Entrenadores
     - Atletas
     - Padres/Responsables
   
   - Los **Managers** pueden crear cuentas para:
     - Entrenadores
     - Atletas
     - Padres/Responsables

   - Los **Entrenadores** pueden solicitar la creación de:
     - Atletas
     - Padres/Responsables

4. **Vinculación de Cuentas**:
   - Los atletas pueden ser vinculados a múltiples entrenadores y grupos
   - Los padres/responsables pueden ser vinculados a múltiples atletas

## Sistema de Gestión de Usuarios

La gestión de usuarios se organiza por categorías:

- **Tabbed Interface**: La pantalla de gestión de usuarios presenta pestañas para diferentes tipos de usuarios:
  - Managers
  - Entrenadores
  - Atletas
  - Grupos

- **Visibility Control**: Las pestañas se muestran u ocultan según los permisos del usuario.

- **User Search**: Cada categoría incluye un buscador y etiquetas para filtrar usuarios.

## Sistema de Permisos y Roles Personalizados

- **Administración de Permisos**: Interfaz completa para gestionar permisos de usuarios:
  - Gestión individual por usuario
  - Gestión por roles
  - Operaciones por lotes para múltiples usuarios

- **Roles Personalizados**: Sistema para crear y gestionar roles a medida:
  - Creación de roles con nombres y descripciones personalizadas
  - Asignación granular de permisos específicos
  - Visualización de permisos activos en cada rol
  - Gestión de usuarios asignados a cada rol

## Sistema de Comunicación

- **Chat Interno**: Permite la comunicación directa entre miembros de la academia.
  - Chats individuales y grupales
  - Accesible desde la barra de navegación superior y mediante deslizamiento lateral desde el dashboard

- **Notificaciones**: Sistema de alertas para eventos importantes.
  - Notificaciones de clases, pagos, mensajes y eventos
  - Accesible desde el icono en la barra de navegación y mediante deslizamiento lateral desde el dashboard

## Sistema de Navegación Mejorado

- **Navegación Deslizable**: Inspirada en Instagram y los sistemas de notificaciones de Android.
  - Deslizar de izquierda a derecha desde el dashboard para acceder a la pantalla de chat
  - Deslizar de derecha a izquierda desde el dashboard para acceder a las notificaciones
  - Experiencia fluida con transiciones animadas entre páginas

- **Interfaz Sin AppBar**: 
  - Diseño limpio sin barra superior tradicional
  - Mayor espacio para el contenido principal
  - Navegación completa basada en el BottomNavigationBar y gestos

- **Bottom Navigation Bar Personalizable**: 
  - Barra de navegación inferior con 5 elementos visibles fijados por el usuario
  - Panel expandible con accesos adicionales en formato wrap al deslizar hacia arriba
  - Personalización de elementos favoritos mediante pulsación larga sobre cualquier icono
  - Acceso rápido a funciones clave: Perfil, Chat y Notificaciones
  - Indicador visual de iconos fijados y elemento activo

- **Panel Expandible Interactivo**:
  - Deslizamiento suave con animaciones fluidas
  - Detección inteligente de gestos para expandir o contraer el panel
  - Organización automática de elementos no fijados
  - Ajuste dinámico de contenido con desplazamiento adaptable

## Instalación y Configuración

### Requisitos

- Flutter 3.0 o superior
- Firebase CLI
- Cuenta de Firebase

### Configuración

1. Clone el repositorio
   ```
   git clone https://github.com/tu-usuario/arcinus.git
   cd arcinus
   ```

2. Instale las dependencias
   ```
   flutter pub get
   ```

3. Genere el código necesario para los modelos
   ```
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Configure Firebase siguiendo las instrucciones en `README_FIREBASE.md`

5. Ejecute la aplicación
   ```
   flutter run
   ```

## Estructura del Proyecto

La aplicación utiliza una arquitectura de módulos funcionales donde cada funcionalidad importante está organizada en su propio directorio con una estructura consistente:

```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── state.md
└── features/            # Características organizadas por módulos
    ├── academy/         # Gestión de academias
    │
    ├── auth/            # Autenticación
    │   ├── core/        # Componentes principales de autenticación
    │   │   ├── models/  # Modelos de datos
    │   │   ├── providers/# Proveedores 
    │   │   └── repositories/# Repositorios
    │   ├── login/       # Flujo de inicio de sesión
    │   │   ├── screens/ # Pantallas de login
    │   │   └── controllers/# Controladores
    │   ├── register/    # Flujo de registro
    │   │   └── screens/ # Pantallas de registro
    │   ├── recovery/    # Recuperación de contraseña
    │   │   └── screens/ # Pantallas de recuperación
    │   └── auth.dart    # Archivo barril para exportaciones
    │
    ├── navigation/      # Sistema de navegación
    │   ├── core/        # Componentes principales
    │   │   ├── models/  # Modelos para navegación 
    │   │   └── services/# Servicios de navegación
    │   ├── components/  # Componentes de UI para navegación
    │   ├── main/        # Pantalla principal
    │   │   └── screens/ # Pantallas de navegación principal
    │   └── splash/      # Pantalla de inicio
    │       └── screens/ # Pantalla de splash
    │
    ├── permissions/     # Administración de permisos
    │   ├── core/        # Componentes principales
    │   │   ├── models/  # Definiciones de permisos
    │   │   └── services/# Servicios para permisos
    │   ├── providers/   # Proveedores de permisos
    │   └── ui/          # Interfaz para gestión de permisos
    │       ├── screens/ # Pantallas de gestión
    │       └── widgets/ # Widgets para permisos
    │
    ├── roles/           # Gestión de roles
    │   ├── core/        # Componentes principales
    │   │   ├── models/  # Modelos de roles
    │   │   └── services/# Servicios para roles
    │   ├── management/  # Gestión de roles
    │   │   ├── screens/ # Pantallas de gestión
    │   │   ├── widgets/ # Widgets específicos
    │   │   └── controllers/# Controladores
    │   └── assignment/  # Asignación de roles
    │       ├── screens/ # Pantallas de asignación
    │       └── controllers/# Controladores
    │
    ├── storage/         # Gestión de almacenamiento
    │   ├── core/        # Configuración principal
    │   ├── firebase/    # Integración con Firebase
    │   │   ├── auth/    # Autenticación Firebase
    │   │   ├── firestore/# Firestore
    │   │   └── storage/ # Storage
    │   ├── hive/        # Almacenamiento local
    │   │   ├── models/  # Modelos para persistencia
    │   │   └── services/# Servicios de almacenamiento
    │   └── sync/        # Sincronización de datos
    │       └── strategies/# Estrategias de sincronización
    │
    └── theme/           # Temas y estilos
        ├── core/        # Definiciones principales
        └── components/  # Componentes de UI temáticos
            ├── loading/ # Indicadores de carga
            ├── feedback/# Componentes de feedback
            └── inputs/  # Componentes de entrada
```

Esta arquitectura de módulos funcionales proporciona:

1. **Mayor cohesión** - Los componentes relacionados están agrupados juntos
2. **Menor acoplamiento** - Cada módulo funcional puede evolucionar con menos dependencias
3. **Mejor mantenibilidad** - Estructura predecible que facilita encontrar y modificar código
4. **Escalabilidad** - Nuevos módulos pueden ser añadidos siguiendo el mismo patrón

## Tecnologías Utilizadas

- **Estado**: Riverpod con anotaciones
- **Modelos**: Freezed para inmutabilidad
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Navegación**: Go Router
- **Localización**: Flutter Intl

## Contribución

Por favor, lea nuestra guía de contribución en `CONTRIBUTING.md` antes de enviar pull requests.

## Licencia

Este proyecto está licenciado bajo [LICENCIA]. Consulte el archivo `LICENSE` para más detalles.