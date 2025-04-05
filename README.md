# Arcinus - Sistema de Gestión para Academias Deportivas

Arcinus es una aplicación móvil desarrollada en Flutter para la gestión integral de academias deportivas. Permite administrar entrenadores, atletas, grupos, entrenamientos, clases, asistencia, pagos y comunicaciones.

## Características Principales

- **Registro jerárquico de usuarios**: Sólo los propietarios pueden registrarse directamente. Los propietarios gestionan la creación de cuentas para entrenadores, atletas y padres/responsables.
- **Gestión completa de academias deportivas**: Administración de equipos, entrenamientos, clases, asistencia y más.
- **Seguimiento de rendimiento**: Evaluación y seguimiento del progreso de atletas.
- **Sistema de pagos**: Control de mensualidades y pagos.
- **Sistema de comunicación integrado**: Chat interno y notificaciones para mantener a todos los miembros informados.

## Esquema de Roles

1. **SuperAdmin**: Administrador de la plataforma (equipo de Arcinus).
2. **Propietario**: Dueño de la academia, con acceso completo a su academia.
3. **Manager**: Gerente administrativo, ayuda en la gestión de la academia.
4. **Entrenador**: Responsable de grupos/equipos y entrenamientos.
5. **Atleta**: Miembro de la academia que participa en las actividades.
6. **Padre/Responsable**: Relacionado con uno o más atletas.

## Estructura de Firestore

```
Collection 'academies'
  |- Document '{academyId}'
      |- Field: name, logo, sport, sportCharacteristics, ownerId, groupIds, coachIds, athleteIds, settings, subscription, createdAt
      |- Collection 'groups'
      |- Collection 'trainings'

Collection 'users'
  |- Document '{userId}'
      |- Field: email, name, role, permissions, academyIds, createdAt
      |- Collection 'profile'
      |- Collection 'coach_profile' (si el rol es coach)
      |- Collection 'athlete_profile' (si el rol es athlete)
      |- Collection 'parent_profile' (si el rol es parent)

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

2. **Creación de Cuentas**:
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

3. **Vinculación de Cuentas**:
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

3. Configure Firebase siguiendo las instrucciones en `README_FIREBASE.md`

4. Ejecute la aplicación
   ```
   flutter run
   ```

## Estructura del Proyecto

```
lib/
├── main.dart
├── app.dart
├── ui/                  # Capa de Interfaz de Usuario
│   ├── shared/          # Componentes UI compartidos
│   └── features/        # Características organizadas por módulos
│       ├── auth/        # Autenticación
│       ├── dashboard/
│       ├── chat/        # Sistema de chat interno
│       ├── notifications/ # Gestión de notificaciones
│       ├── academy_management/
│       └── ...
├── ux/                  # Capa de Lógica de Negocio
│   ├── shared/          # Utilidades y servicios compartidos
│   └── features/        # Características organizadas por dominio
└── shared/              # Recursos compartidos entre UI y UX
```

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