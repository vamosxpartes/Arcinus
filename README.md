# Arcinus - Sistema de Gestión para Academias Deportivas

Arcinus es una aplicación móvil desarrollada en Flutter para la gestión integral de academias deportivas. Permite administrar entrenadores, atletas, grupos, entrenamientos, clases, asistencia, pagos y comunicaciones.

##  Indice del Desarrollo

El proyecto se encuentra en fase de planeacion de desarrollo con los siguientes componentes:

**Inicial (Fundamentos y Configuración)**
*   1.  [x] **Tema centralizado** (UI/UX Base: Colores, Tipografía, Modos)
*   2.  [ ] **Wireframes** (Revisión y Aprobación Flujos Principales)
*   3.  [x] **Estructura del Proyecto** (Organización de Carpetas/Módulos)
*   4.  [x] **Configuración de Linting/Estilo de Código** (Análisis Estático)
*   5.  [x] **Estrategia de Manejo de Estado** (Riverpod + Annotations Setup)
*   6.  [x] **Inyección de Dependencias** (Riverpod como estrategia unificada)
*   7.  [x] **Modelos de Datos Inmutables** (Freezed Setup - Listo)
*   8.  [x] **Estrategia de Manejo de Errores** (Definición con Either y Freezed - Lista)
*   9.  [x] **Sistema de roles y permisos** (Enum y Modelo de Datos Inicial - Listo)
*   10. [x] **Autenticación** (Configuración Firebase Auth: Correo/Contraseña, Flujo Básico - Listo)
*   11. [x] **Sistema de navegación** (Configuración GoRouter Básico)
*   12. [x] **Localización** (Configuración Flutter Intl, Idioma Base)
*   13. [x] **Estrategia de Gestión de Assets** (Imágenes, Fuentes)
*   14. [x] **Configuración inicial de Pruebas** (Unit/Widget Setup)

**MVP (Funcionalidad Central)**
*   15. [x] **Sistema de subscripción para las academias** (Modelo y Verificación Básica)
*   16. [x] **Gestión de academias** (CRUD Propietario)
*   17. [x] **Gestión usuarios** (Vinculación Academia, Roles Iniciales)
*   18. [x] **Implementación Roles y Permisos** (Lógica App para MVP)
*   19. [x] **Sistema de pagos interno** (Registro Manual de Pagos Atletas)
*   20. [ ] **Pruebas** (Cobertura Funcionalidades MVP)
*   21. [ ] **Configuración CI/CD** (Builds y Despliegues Automatizados Básicos)
*   22. [ ] **Build Flavors/Environments** (Dev/Prod si es necesario)

**Features a Validar/Post-MVP**
*   [ ] **Inicio de Sesión con Google** (Integración Firebase Auth)
*   [ ] **Inicio de Sesión con Apple** (Integración Firebase Auth)
*   23. [ ] **Gestión de grupos/equipos** (Completo: CRUD, Asignaciones)
*   24. [ ] **Sistema de entrenamientos y sesiones** (Definición, Planificación, Registro)
*   25. [ ] **Implementación de evaluaciones y seguimiento de atletas**
*   26. [ ] **Integración de calendario y programación de actividades**
*   27. [ ] **Sistema de comunicación interno y notificaciones** (Chat/Anuncios, Push FCM)
*   28. [ ] **Control de acceso basado en permisos** (Refinamiento Colaborador)
*   29. [ ] **Integración Pasarela de Pagos** (Suscripciones/Pagos Internos)
*   30. [ ] **Pruebas de Integración** (Flujos Completos)

Detalle de las features:

## 1. Tema centralizado
- **Estrategia:** Se implementará un sistema de tema centralizado y flexible utilizando `ThemeData` de Flutter y las mejores prácticas de Material 3.
- **Base Inicial:** Se comenzará con un tema oscuro (`brightness: Brightness.dark`) inspirado en colores vibrantes sobre fondo oscuro, utilizando `ArcinusColors.primaryBlue` como color semilla (`seedColor`) para `ColorScheme.fromSeed()`. Se planifica añadir soporte para modo claro y otros temas en el futuro.
- **Paleta de Colores:** Definida en `lib/features/theme/ux/arcinus_colors.dart`. Se utilizará `ColorScheme.fromSeed()` para generar la paleta principal, sobreescribiendo colores específicos (como `background`) según sea necesario para el tema oscuro inicial. Los gradientes definidos se usarán consistentemente.
- **Tipografía:** Definida en `lib/features/theme/ux/arcinus_text_styles.dart` usando la fuente 'Roboto' (se incluirá en assets). Los estilos definidos (`h1`, `body`, etc.) se mapearán a las propiedades correspondientes de `ThemeData.textTheme`. Se priorizará el uso de estos estilos predefinidos.
- **Acceso al Tema:** Se crearán extensiones de `BuildContext` (en `lib/features/theme/ux/arcinus_theme.dart` o similar) para un acceso fácil y limpio a las propiedades del tema en los widgets (ej: `context.colorScheme.primary`, `context.textTheme.bodyMedium`).
- **Componentes UI:** Los widgets reutilizables (en `lib/features/theme/ui/`) obtendrán sus estilos y colores principalmente a través del tema (`Theme.of(context)` o las extensiones), asegurando consistencia y adaptabilidad.

## 2. Wireframes
- **Estrategia Actualizada:** Se omitirá la fase formal de wireframing/descripción textual detallada para acelerar el desarrollo del MVP.
- **Enfoque:** Se procederá directamente a implementar la estructura básica de la UI y la navegación para los flujos principales en Flutter, comenzando con el rol `Propietario`.
- **Platzhalter:** Se utilizará la pantalla genérica `lib/features/utils/screens/screen_under_development.dart` como placeholder temporal en la navegación para las secciones o funcionalidades aún no desarrolladas. El diseño y la estructura de la UI se refinarán posteriormente.

## 3. Estructura del Proyecto
- **Estrategia Principal:** Se adoptará una organización **por Feature**. El código fuente dentro de `lib/` se estructurará en una carpeta `features/`, con subcarpetas para cada funcionalidad principal (ej. `auth`, `academies`, `users`, `theme`, etc.).
- **Código Común:** Se utilizará una carpeta `core/` para utilidades, constantes, widgets genéricos, lógica base (como manejo de errores) y la configuración de navegación.
- **Organización Feature:** Cada carpeta de feature (ej. `lib/features/auth/`) contendrá subcarpetas para las distintas capas o tipos de archivos relevantes a esa feature, como:
    - `data/`: Repositorios, fuentes de datos (Firestore, etc.), modelos de datos específicos.
    - `domain/` (Opcional): Entidades de negocio, casos de uso, interfaces de repositorio (si se aplica Clean Architecture estrictamente).
    - `presentation/`: La UI y la lógica de estado.
        - `providers/` o `state/`: Lógica de estado con Riverpod (Providers, Notifiers).
        - `ui/` o `screens_widgets/`: Pantallas y widgets específicos de la feature.
- **Manejo de Estado (Riverpod):** Los Providers/Notifiers de Riverpod se localizarán dentro de la carpeta `presentation/providers/` (o similar) de la feature correspondiente (Opción 2.1).
- **Navegación (GoRouter):** La configuración de GoRouter (definición de rutas, router principal) residirá dentro de la carpeta `core/`, por ejemplo en `lib/core/navigation/` (Opción 3.2).
- **Inyección de Dependencias (GetIt):** La configuración inicial de GetIt se manejará en un archivo dedicado en la raíz de `lib/`, como `dependency_injection.dart`.

## 4. Configuración de Linting/Estilo de Código
- **Reglas de Linting:** Se utilizará el paquete `flutter_lints` (que incluye `lints`) en combinación con el paquete `very_good_analysis` para un análisis estático estricto y la promoción de código de alta calidad. La configuración se realizará en `analysis_options.yaml`.
- **Formateo de Código:** Se utilizará el formateador estándar `dart format` para asegurar un estilo de código consistente en todo el proyecto.
- **Cumplimiento:** Se configurará el IDE (VS Code/Android Studio) para mostrar errores/advertencias de linting en tiempo real y para formatear el código automáticamente al guardar. Adicionalmente, se ejecutarán manualmente los comandos `dart analyze` y `dart format . --fix` antes de realizar commits para asegurar el cumplimiento.

## 5. Estrategia de Manejo de Estado
- **Framework Principal:** Se utilizará `Riverpod` como solución para el manejo de estado y la inyección de dependencias en toda la aplicación, aprovechando sus características de reactividad y seguridad de tipos en tiempo de compilación.
- **Generación de Código:** Se empleará `riverpod_generator` (Annotations) para simplificar la definición de providers y reducir el código boilerplate. Se ejecutará `build_runner` según sea necesario.
- **Organización de Providers:** Dentro de cada feature (`lib/features/[nombre_feature]/presentation/`), los providers se organizarán en subcarpetas específicas según su tipo o la sub-funcionalidad a la que pertenezcan (ej., `providers/auth/`, `providers/profile/`). Esto mejora la modularidad y la localización del estado.
- **Gestión del Estado de UI y Asíncrono:** Para manejar operaciones asíncronas (llamadas a API, base de datos) y el estado resultante en la UI (carga, éxito, error), se utilizará el patrón de **máquinas de estado** implementado con `Freezed`. Los `AsyncNotifier` expondrán un estado (`state`) definido como una unión Freezed (ej., `AsyncValue<Data>` o un estado personalizado como `sealed class MiEstado with _$MiEstado { const factory MiEstado.initial(); const factory MiEstado.loading(); const factory MiEstado.success(Data data); const factory MiEstado.failure(Error error); }`). Esto permitirá un manejo explícito y seguro de los diferentes estados en la UI mediante `state.when(...)`.

## 6. Inyección de Dependencias
- **Estrategia Unificada con Riverpod:** Se utilizará `Riverpod` no solo para el manejo de estado, sino también como el mecanismo principal para la inyección de dependencias (DI) en toda la aplicación.
- **Registro de Dependencias:** Clases como repositorios, clientes de API, servicios de utilidad, etc., se registrarán como `Provider` simples (o `FutureProvider` si requieren inicialización asíncrona). Por ejemplo: `final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());`.
- **Acceso a Dependencias:** Las dependencias registradas se consumirán dentro de otros providers (ej., `Notifier`) o widgets utilizando `ref.watch` o `ref.read`, según el caso de uso (observar cambios vs. obtener una sola vez).
- **Ventaja:** Esta estrategia mantiene una única herramienta para el estado y la DI, simplificando el conjunto de tecnologías y potencialmente la curva de aprendizaje.

## 7. Modelos de Datos Inmutables
- **Herramienta Principal:** Se utilizará el paquete `freezed` para definir todos los modelos de datos (entidades, DTOs, estados) de la aplicación. Esto asegura la inmutabilidad y proporciona automáticamente métodos útiles como `copyWith`, `==`, y `toString`.
- **Generación de Código:** Se requerirá la ejecución regular de `build_runner` para generar el código asociado a Freezed (`*.freezed.dart`).
- **Serialización JSON:** Para la conversión de objetos desde/hacia JSON (necesario para interactuar con Firestore y otras APIs), se utilizará el paquete `json_serializable` en conjunto con `freezed`. Las clases modelo incluirán las anotaciones `@freezed` y `@JsonSerializable()` (o `@Freezed(toJson: true, fromJson: true)`), y `build_runner` generará los archivos `*.g.dart` con los métodos `fromJson` y `toJson`.
- **Ubicación:** Los modelos de datos específicos de una feature se definirán dentro de la carpeta `data/models/` (o una subcarpeta apropiada como `dto/` si se diferencia) dentro del directorio de esa feature. Por ejemplo: `lib/features/academies/data/models/academy_model.dart`. Los modelos compartidos podrían residir en `lib/core/models/`.

## 8. Estrategia de Manejo de Errores
- **Retorno Funcional con `Either`:** Las operaciones en las capas de datos (repositorios) y dominio (casos de uso, si se implementan) que puedan fallar devolverán un tipo `Either<Failure, SuccessData>` (utilizando el paquete `fpdart`). Esto obliga al llamador a manejar explícitamente tanto el caso de éxito (`Right`) como el de fallo (`Left`).
- **Jerarquía de Fallos (`Failure`):** Se definirá una estructura clara para los errores de la aplicación mediante una clase base abstracta `Failure` y subclases específicas que representen diferentes tipos de errores (ej., `ServerFailure`, `NetworkFailure`, `AuthenticationFailure`, `ValidationFailure`, `CacheFailure`). Se utilizará `Freezed` para definir esta jerarquía de forma concisa y robusta.
    ```dart
    // Ejemplo conceptual (en lib/core/error/failures.dart)
    @freezed
    sealed class Failure with _$Failure {
      const factory Failure.serverError({String? message}) = ServerFailure;
      const factory Failure.networkError() = NetworkFailure;
      const factory Failure.authError(String code) = AuthFailure;
      // ... otros tipos de fallos
    }
    ```
- **Manejo en la Capa de Presentación:** Los `Notifier` / `AsyncNotifier` de Riverpod serán responsables de llamar a los métodos que devuelven `Either`. Utilizarán `.fold()` (o un `switch` sobre el `Either`) para manejar el resultado:
    - En caso de `Right(SuccessData)`, actualizarán el estado a `MiEstado.success(data)` (o similar).
    - En caso de `Left(Failure)`, capturarán el objeto `Failure` específico y actualizarán el estado a `MiEstado.failure(failure)`. 
- **Presentación en la UI:** La UI (Widgets) observará el estado del provider (`state.when(...)`) y reaccionará a los diferentes estados definidos por la máquina de estados Freezed, mostrando la información, indicadores de carga o mensajes/widgets de error apropiados basados en el tipo de `Failure` recibido en el estado `failure`.

## 9. Almacenamiento Local y Sincronización (Offline First)
- **Tecnología:** Se utilizará `Hive` como base de datos local NoSQL para almacenar datos esenciales y permitir el acceso offline y mejorar el rendimiento percibido.
- **Datos a Cachear:** Inicialmente, se priorizará el cacheo de:
    - Información del perfil del usuario actual.
    - Lista de academias a las que pertenece el usuario (si aplica).
    - Detalles de la academia activa actualmente (información básica, miembros, grupos).
    - Datos de referencia que cambian poco (ej. características de deportes).
- **Fuente de Verdad:** `Firestore` seguirá siendo la fuente única y autoritativa de los datos.
- **Estrategia de Sincronización:**
    - **Lectura:** Al iniciar la aplicación o al acceder a una sección, se intentará cargar los datos desde Hive primero para una respuesta rápida. En paralelo (o inmediatamente después), se establecerá un listener de Firestore para obtener los datos frescos y actualizados. Cuando lleguen los datos de Firestore, se actualizará la caché de Hive y la UI.
    - **Escritura:** Las operaciones de escritura (Crear, Actualizar, Eliminar) se enviarán directamente a Firestore. Si la operación en Firestore es exitosa, la respuesta (o el listener de Firestore) actualizará la caché local en Hive.
    - **Manejo de Conflictos:** Dado que Firestore es la fuente de verdad y las escrituras van primero allí, el riesgo de conflictos complejos se minimiza. Se manejarán errores de escritura en Firestore adecuadamente.
    - **Trabajo Offline:** La aplicación permitirá visualizar los datos cacheados en Hive mientras no haya conexión. Las operaciones de escritura estarán deshabilitadas o se encolarán (estrategia a definir post-MVP si se requiere soporte completo offline para escrituras).
- **Implementación:** Se crearán adaptadores (`TypeAdapter`) para los modelos de datos que se almacenen en Hive. Se utilizarán `Repositories` que abstraigan el acceso a datos, consultando primero Hive y luego/paralelamente Firestore.

## 10. Sistema de roles y permisos
- **Definición de Roles Base:** Se utilizarán los roles definidos previamente: `SuperAdmin`, `Propietario`, `Colaborador`, `Atleta`, `Padre/Responsable`.
- **Representación en Código:** Los roles se representarán en el código Dart mediante un `enum AppRole` para garantizar la seguridad de tipos y la claridad.
    ```dart
    // Ejemplo (en lib/core/auth/roles.dart o similar)
    enum AppRole { superAdmin, propietario, colaborador, atleta, padre, desconocido }
    ```
- **Almacenamiento del Rol Principal:** El rol principal de cada usuario (Propietario, Atleta, Padre, etc.) se almacenará como **Custom Claim** en Firebase Authentication. Esto permite un acceso rápido y eficiente al rol del usuario autenticado, tanto en el backend (Firestore Rules) como en el frontend.
- **Permisos Específicos para Colaboradores:** Para el rol `Colaborador`, se implementará un sistema de permisos granulares. Un `Propietario` podrá asignar permisos específicos a un `Colaborador` marcando/desmarcando acciones permitidas (ej., `manage_groups`, `record_attendance`, `manage_payments`). Esta **lista explícita de permisos** (`List<String>`) se almacenará probablemente en el documento de Firestore que representa la membresía o relación del colaborador con la academia, debido a los límites de tamaño de los Custom Claims.
- **Modelo de Datos:** Se necesitará un modelo de datos para representar la relación usuario-academia-rol-permisos, especialmente para `Colaborador` y `Padre/Responsable` (que puede estar vinculado a varios atletas).
- **Cumplimiento y Seguridad:**
    - **Firestore Security Rules:** Serán la principal línea de defensa. Las reglas verificarán el rol del usuario (obtenido del Custom Claim del token de autenticación) y, para operaciones específicas de Colaborador, podrán verificar la presencia del permiso requerido (leyendo el documento de membresía/relación correspondiente).
    - **Lógica en la Aplicación (Frontend):** La UI se adaptará dinámicamente según el rol y los permisos del usuario actual (obtenidos a través de un provider que lea los Custom Claims y/o datos de Firestore). Se utilizará un enfoque de **ShellRoute por rol** (ver sección Sistema de Navegación) donde cada Shell (Scaffold específico del rol) puede contener lógica para mostrar/ocultar opciones o renderizar contenido condicionalmente según los permisos y otros estados (como suscripción).

## 11 Sistema de navegacion y Estructura UI por Rol
- **Framework:** Se utilizará `GoRouter` como solución de navegación declarativa para la aplicación.
- **Configuración:** La configuración principal de `GoRouter` residirá en `lib/core/navigation/` (como se definió en la estructura del proyecto).
- **Estrategia de Shell por Rol:** Se adoptará un enfoque basado en `ShellRoute` (o un patrón similar) para estructurar la interfaz de usuario según el rol principal del usuario (`Propietario`, `Atleta`, `Colaborador`, `SuperAdmin`).
    - **Switcher Inicial:** Un widget raíz o la lógica de `GoRouter.redirect` observará el estado global `AuthState`.
        - Si `unauthenticated`, dirigirá a las rutas de autenticación (`/login`, `/welcome`).
        - Si `authenticated`, leerá el rol principal del `User` (probablemente desde los Custom Claims).
        - Según el rol, redirigirá a la ruta raíz correspondiente a ese rol (ej. `context.go('/owner')`, `context.go('/athlete')`).
    - **ShellRoutes por Rol:** Se definirán `ShellRoute` distintas para cada rol principal. El constructor (`shellBuilder` o similar) de cada `ShellRoute` creará un `Scaffold` específico para ese rol (ej., `OwnerScaffold`, `AthleteScaffold`) que contendrá la estructura base de la UI (AppBar, Drawer, BottomNavigationBar, etc.).
    - **Rutas Anidadas:** Las rutas específicas para las funcionalidades de cada rol (ej., `/owner/dashboard`, `/owner/groups`, `/athlete/trainings`) se definirán como rutas hijas anidadas dentro de su `ShellRoute` correspondiente. GoRouter se encargará de renderizar la pantalla de la ruta hija activa dentro del `body` del `Scaffold` del rol.
- **Definición de Rutas:**
    - Se emplearán **clases o constantes estáticas** para definir los nombres y paths de las rutas (ej., `AppRoutes.ownerDashboard = '/owner/dashboard';`).
- **Renderizado Condicional dentro del Shell:** Los Scaffolds específicos de cada rol (`OwnerScaffold`, `AthleteScaffold`, etc.) serán responsables de:
    - Mostrar la UI base común para ese rol.
    - Renderizar el widget `child` (la pantalla de la ruta hija actual proporcionada por GoRouter) en su `body`.
    - **Implementar Diseño Responsivo:** Adaptar la estructura base (ej., usar `Drawer` en móvil/tablet, `BottomNavigationBar` en móvil, o paneles laterales permanentes en web/escritorio) según el tamaño de la pantalla o plataforma, utilizando `LayoutBuilder` o `MediaQuery`.
    - Observar estados adicionales relevantes para ese rol (ej., estado de la suscripción de la academia para el `Propietario`, permisos específicos para el `Colaborador`).
    - **Renderizar condicionalmente** contenido alternativo en el `body` (ej., mostrar una pantalla de "Suscripción requerida" en lugar del dashboard si la suscripción no está activa) o adaptar la UI base (mostrar/ocultar acciones en el `AppBar` según los permisos) basándose en estos estados.
- **Ventajas:** Esta estructura centraliza la UI base por rol, simplifica las definiciones de rutas hijas y permite un control granular sobre lo que se muestra al usuario basándose en múltiples factores (autenticación, rol, permisos, estado de suscripción, etc.) dentro del contexto de cada rol.

## 12 Localización
- **Framework Base:** Se utilizará el soporte incorporado de Flutter a través de los paquetes `flutter_localizations` y `intl`.
- **Gestión Manual:** La configuración inicial se realizará manualmente, definiendo las clases `LocalizationsDelegate` y `AppLocalizations` necesarias sin depender de herramientas de generación de código como `intl_utils` en la fase inicial.
- **Estructura de Archivos:** Los archivos de traducción (probablemente en formato `.arb` para compatibilidad con `intl`) se organizarán de forma distribuida:
    - Un conjunto global de traducciones en `lib/l10n/` (ej., `app_es.arb`) para textos comunes.
    - Archivos de traducción específicos para cada feature dentro de su propia carpeta `l10n/` (ej., `lib/features/auth/l10n/auth_es.arb`).
    - **Nota:** Esto requerirá configurar múltiples `LocalizationsDelegates` (uno global y uno por feature o un delegado compuesto) en `MaterialApp`.
- **Idiomas Soportados:** Se comenzará con el **Español (`es`)** como idioma base y por defecto. La estructura y configuración se realizarán de manera que sea sencillo añadir soporte para otros idiomas (como Inglés - `en`) en el futuro, simplemente añadiendo los archivos `.arb` correspondientes y actualizando los delegados.
- **Acceso a Traducciones:** Las cadenas traducidas se accederán en el código (principalmente en widgets) utilizando el método estándar `AppLocalizations.of(context)!.nombreClave`. Será necesario asegurarse de que las claves de traducción sean únicas globalmente o estén correctamente prefijadas/gestionadas si se cargan desde múltiples archivos/delegados.

## 13 Estrategia de Gestión de Assets
- **Estrategia:** Se implementará una estrategia para gestionar y organizar los assets (imágenes, fuentes, etc.) de manera eficiente y coherente en la aplicación.
- **Organización:** Los assets se organizarán en carpetas específicas según su tipo (ej., `images/`, `fonts/`, `icons/`, etc.) dentro del directorio `assets/`, tal como se declara en `pubspec.yaml`.
- **Uso:** Para acceder a los assets de forma segura y evitar errores tipográficos, se utilizará la clase `lib/core/constants/app_assets.dart`. Esta clase contendrá constantes `static const String` para las rutas de los assets. Se añadirán nuevas constantes a esta clase a medida que se agreguen assets específicos.

## 14 Configuración inicial de Pruebas
- **Estrategia:** Se adoptará un **Enfoque Equilibrado Inicial** para las pruebas del MVP.
- **Alcance Inicial:** Se implementará un conjunto básico tanto de **pruebas unitarias** (utilizando `package:test`) como de **pruebas de widgets** (utilizando `package:flutter_test`). Se ha creado una estructura de carpetas base en `test/unit_tests/` y `test/widget_tests/` con archivos de ejemplo (`calculator_test.dart` y `simple_widget_test.dart`).
- **Foco Pruebas Unitarias:** Se priorizará la lógica de negocio crítica seleccionada (ej., funciones clave en `Notifier`/`Provider`, utilidades complejas, manejo de errores) para validar su corrección independientemente de la UI.
- **Foco Pruebas de Widgets:** Se priorizarán las pantallas y componentes fundamentales de los flujos de usuario más importantes (ej., flujo de autenticación, pantallas principales) para asegurar que la interacción básica y la renderización funcionen correctamente.
- **Objetivo:** Lograr una cobertura inicial mínima pero representativa en ambas capas (lógica y UI) para aumentar la confianza en la estabilidad del MVP.
- **Herramientas:** Se utilizarán los paquetes estándar `test` y `flutter_test`, junto con `mocktail` para la creación de mocks. Las pruebas se pueden ejecutar con `flutter test`.

## 15 Sistema de subscripción para las academias
- **Modelo de Datos:** Se creará una nueva colección de nivel superior en Firestore llamada `subscriptions` para almacenar la información de las suscripciones de las academias.
- **Estructura del Documento:** Cada documento en la colección `subscriptions` representará una suscripción y contendrá como mínimo los siguientes campos:
    - `academyId`: El ID del documento de la academia a la que pertenece la suscripción (referencia o string).
    - `status`: El estado actual de la suscripción (ej. `'active'`, `'inactive'`, `'trial'`, `'expired'`). Para el MVP, un valor simple como `'active'` podría ser suficiente inicialmente.
    - `endDate`: La fecha (Timestamp) en la que expira la suscripción actual.
    - (Opcional/Futuro): `planId`, `startDate`, etc.
- **Verificación Básica en el MVP:**
    - **Lógica:** La verificación de si una academia tiene una suscripción activa se realizará consultando la colección `subscriptions`.
    - **Implementación:** Se buscará un documento en `subscriptions` donde `academyId` coincida con el ID de la academia actual y el `status` sea `'active'` (y opcionalmente, `endDate` sea posterior a la fecha actual).
    - **Propósito MVP:** Esta verificación básica se utilizará principalmente para habilitar/deshabilitar el acceso a la funcionalidad principal de la academia para el `Propietario` y `Colaborador`. No se implementarán restricciones complejas en este punto.
- **Consideraciones:** Este enfoque separa la lógica de suscripción de la entidad `Academy`, facilitando la gestión futura de historiales de suscripción, diferentes planes, etc.

## 16 Gestión de academias
- **Alcance:** Operaciones que un `Propietario` realiza sobre sus academias.
- **Arquitectura Multi-Academia:** Aunque el MVP se centrará en el flujo de *una* academia por propietario, la arquitectura (modelos, providers, acceso a datos Firestore) se diseñará para soportar la gestión de **múltiples academias** por propietario en el futuro. Se usará un provider (`currentAcademyIdProvider`) para gestionar el ID de la academia activa.
- **Operaciones CRUD para el Propietario (MVP):**
    - **Crear (Create):** El Propietario podrá crear su **primera academia** desde un dashboard inicial. Se guardará el `AcademyModel` en Firestore, incluyendo un campo `sportCode` (ej., 'basketball', 'soccer') para identificar el deporte.
    - **Leer (Read):** El Propietario podrá ver la información de la academia *seleccionada actualmente*.
    - **Actualizar (Update):** El Propietario podrá modificar la información de la academia *seleccionada actualmente*.
    - **Eliminar (Delete):** NO se implementará en el MVP.
- **Modelo de Datos:** Se definirá `AcademyModel` (con `ownerId`, `sportCode`, etc.).
- **Características por Deporte:** Se usará un modelo `SportCharacteristics` (ubicado en `lib/core/sports/models/`) que define atributos específicos por deporte (posiciones, estadísticas, etc.). Un provider (`sportCharacteristicsProvider`) expondrá las características correspondientes a la academia *seleccionada actualmente*, basándose en su `sportCode`.

## To Do
1. **Agregar todas las rutas para owner al GoRouter**: Completar la implementación de todas las rutas necesarias para el rol de propietario en el sistema de navegación GoRouter.

2. **Control de "completar perfil" para creación de academia**: Mejorar el flujo de usuario para que si un usuario completa su perfil pero experimenta un error al crear la academia, al volver a la aplicación no se le solicite completar el perfil nuevamente, sino que sea redirigido directamente a la pantalla de creación de academia.

## Tareas Pendientes - Owner UX/UI
1.  **Retirar el buscador del AppBar:** Eliminar el campo o icono de búsqueda de la barra de aplicación principal para el rol de Propietario.
2.  **Conectar pantalla de perfil al icono del AppBar:** Hacer que el icono de perfil en el AppBar navegue a la pantalla de perfil del usuario Propietario.
3.  **Dividir Drawer en secciones:** Reorganizar el menú lateral (Drawer) para el Propietario en dos secciones:
    *   **Implementadas:** Incluirá las opciones principales actualmente en desarrollo o listas (Academia, Miembros, Pagos).
    *   **Por Implementar:** Incluirá el resto de las opciones que aún no están desarrolladas o son futuras.