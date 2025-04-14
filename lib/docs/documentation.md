# Documentación General de Arcinus

## Visión General

Arcinus es una aplicación móvil desarrollada en Flutter diseñada para la gestión integral de academias deportivas. La aplicación permite administrar todos los aspectos relacionados con el funcionamiento de clubes y academias deportivas, incluyendo la gestión de usuarios con diferentes roles, equipos, entrenamientos, ejercicios, comunicación entre miembros, y más.

## Arquitectura

La aplicación sigue los principios de Clean Architecture con una estructura modular basada en features. Utiliza el patrón BLoC a través de Riverpod para la gestión de estado, implementa un sistema offline-first para operaciones sin conexión, y se integra con Firebase para backend y autenticación.

## Características Principales

### Infraestructura

#### Auth
Sistema de autenticación que permite registro, inicio de sesión y gestión de credenciales de usuarios. Implementa diferentes métodos de autenticación y mantiene el estado de la sesión.

#### Roles
Sistema flexible de roles de usuario que define diferentes niveles de acceso (Atleta, Entrenador, Manager, Propietario, Padre). Permite la creación de roles personalizados con permisos específicos.

#### Permissions
Sistema granular de permisos que determina las capacidades específicas de cada usuario en la aplicación, proporcionando control preciso sobre las acciones disponibles para cada rol.

#### Navigation
Sistema de navegación coherente que implementa una barra personalizable, gestión de rutas y transiciones entre pantallas. Permite anclar elementos favoritos para acceso rápido.

#### Theme
Sistema de diseño y temas basado en el brand book de Arcinus, proporcionando una apariencia consistente en toda la aplicación con énfasis en el tema oscuro.

#### Storage
Soluciones de almacenamiento local (Hive) y remoto (Firebase) con capacidades de sincronización offline-online y persistencia de datos.

### Funcionalidades de la Aplicación

#### Users
Gestión completa de usuarios con diferenciación de roles y sus funcionalidades específicas por tipo de usuario:

- **User Base**: Funcionalidades comunes para todos los usuarios como gestión de perfil, configuración de cuenta, y preferencias.
  
- **Athlete**: Usuarios deportistas que participan en entrenamientos y competiciones. Tienen acceso a su plan de entrenamiento, seguimiento de progreso, y participación en equipos.
  
- **Coach**: Entrenadores que gestionan atletas y equipos. Pueden crear entrenamientos, evaluar el rendimiento de atletas, y gestionar sesiones.
  
- **Manager**: Administradores de nivel medio que gestionan aspectos organizativos de la academia. Pueden gestionar equipos, coordinar eventos, y supervisar operaciones diarias.
  
- **Owner**: Propietarios de academias con control total sobre la organización. Tienen acceso a todas las funcionalidades administrativas, incluyendo gestión financiera y configuraciones avanzadas.
  
- **Parent**: Padres o tutores de atletas menores. Pueden supervisar el progreso de sus hijos, recibir notificaciones, y comunicarse con entrenadores.

#### Academy
Gestión de academias deportivas dentro de la aplicación, permitiendo crear, visualizar y administrar academias.

#### Sports
Administración de deportes, sus categorías y configuraciones específicas para cada disciplina deportiva soportada en la plataforma.

#### Teams
Gestión de equipos deportivos, incluyendo su creación, asignación de miembros y configuración.

#### Groups
Administración de grupos de usuarios para diferentes propósitos dentro de la aplicación.

#### Trainings
Planificación, ejecución y seguimiento de sesiones de entrenamiento, con asignación a equipos o atletas individuales.

#### Excersice
Biblioteca de ejercicios deportivos que pueden ser utilizados en la creación de entrenamientos.

#### Dashboard
Centro de control personalizado según el rol del usuario, mostrando información relevante y acceso rápido a las funcionalidades principales.

#### Chat
Sistema de comunicación interna entre los diferentes usuarios de la plataforma.

#### Notification
Sistema de notificaciones para mantener a los usuarios informados sobre eventos relevantes.

## Tecnologías Utilizadas

- **Framework**: Flutter para desarrollo multiplataforma
- **Gestión de Estado**: Riverpod y patrón BLoC
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Almacenamiento Local**: Hive
- **Arquitectura**: Clean Architecture con estructura modular basada en features
- **UI/UX**: Material Design 3 con tema personalizado según brand book

## Consideraciones Técnicas

- Implementación de sistema offline-first para operaciones sin conexión
- Sincronización automática cuando se recupera la conexión
- Sistema granular de roles y permisos
- Interfaz adaptable según el rol del usuario
- Almacenamiento local optimizado para rendimiento

1. al tomar la foto, directamente guardarla en el dispositivo indefinidamente. y enviarla a storage. guardar la url en firestore y en caso de no encontrarla en el dispositivo (si se desinstalo la app en caso de que esta accion elimine la foto tambien) o en caso de que un manager tome la foto y un atleta desde su interfaz quiera ver su perfil desde otro dispositvo. se descargue solo 1 vez, y se guarde indefinidamente.
2. compresion de la imagen.  deduplicacio y carga diferida y la versiones por tamaño. 