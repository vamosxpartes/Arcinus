# Arcinus - Plan de Desarrollo y Depuración

Este documento detalla el proceso de desarrollo de la aplicación Arcinus, con pasos específicos para implementar y depurar cada funcionalidad. El plan está organizado en fases incrementales, permitiendo validar cada componente antes de avanzar.

## Progreso General

**Estado actual**: En desarrollo - Fase 7 (Sistema de Evaluación y Seguimiento)

**Completado**:
- ✅ Configuración inicial del proyecto
- ✅ Autenticación y gestión de usuarios
- ✅ Sistema de navegación y estructura base
- ✅ Implementación parcial de la gestión de academias
- ✅ Migración a arquitectura basada en permisos
- ✅ Optimización del sistema de permisos (caché y rendimiento)
- ✅ Implementación de sistema de roles personalizados
- ✅ Desarrollo de interfaz para administración de permisos
- ✅ Corrección de errores en modelos de datos generados con Freezed
- ✅ Implementación de CRUD completo para atletas, entrenadores y gerentes
- ✅ Implementación de gestión completa de grupos/equipos
- ✅ Implementación de gestión de entrenamientos y sesiones

**En progreso**:
- 🔄 Desarrollo del sistema de evaluación y seguimiento de atletas
- 🔄 Integración de calendario y programación de actividades
- 🔄 Implementación del sistema de comunicación y notificaciones

## Mejoras Arquitectónicas Implementadas

Durante el desarrollo del proyecto, se han implementado las siguientes mejoras arquitectónicas para optimizar la calidad del código y la escalabilidad:

### 1. Centralización de Componentes de Navegación ✅

**Estado**: Completado

**Logros**:
- Se creó un servicio de navegación centralizado (`NavigationService`) que gestiona los estados y configuraciones de la barra
- Se desarrolló un widget abstracto (`CustomNavigationBar`) que consume este servicio
- Se refactorizaron las pantallas existentes para utilizar el nuevo componente
- Se redujo significativamente la duplicación de código

### 2. Modularización de Widgets ✅

**Estado**: Completado

**Logros**:
- Se identificaron y extrajeron componentes utilizados en múltiples lugares
- Se crearon widgets reutilizables con interfaces claras
- Se refactorizaron las pantallas existentes para utilizar los componentes compartidos
- Se redujo la complejidad de los archivos principales

### 3. Evolución a Arquitectura Basada en Permisos ✅

**Estado**: Completado

**Logros**:
- Se definió un catálogo completo de permisos para todas las acciones del sistema
- Se asociaron conjuntos de permisos a los roles existentes
- Se modificó la lógica de renderizado condicional para depender de permisos, no de roles
- Se adaptaron los guardias de navegación para verificar permisos específicos
- Se creó un servicio centralizado (`PermissionService`) para verificar permisos
- Se implementaron métodos de verificación granular (hasPermission, hasAllPermissions, hasAnyPermission)
- Se refactorizó el dashboard para mostrar contenido basado en permisos

**Beneficios obtenidos**:
- Mayor granularidad en el control de acceso
- Flexibilidad para personalizar permisos sin modificar roles predefinidos
- Consistencia en la interfaz de usuario
- Escalabilidad mejorada para añadir nuevas funcionalidades
- Mejor mantenibilidad del código

### 4. Optimización de Verificación de Permisos ✅

**Estado**: Completado

**Logros**:
- Se implementó un sistema de caché de permisos (`PermissionCacheService`) para mejorar el rendimiento
- Se añadió invalidación inteligente de caché con ventana de tiempo configurable
- Se desarrolló un sistema de verificación por lotes para reducir el número de operaciones
- Se crearon widgets optimizados (`PermissionBuilder`, `PermissionGate`, `PermissionSwitch`) para minimizar reconstrucciones innecesarias
- Se implementó un proveedor para obtener lotes de permisos precalculados (`permissionBatchProvider`)

**Beneficios obtenidos**:
- Reducción significativa de operaciones de verificación de permisos
- Mejor rendimiento en interfaces con múltiples componentes basados en permisos
- Menor consumo de recursos en dispositivos
- Experiencia de usuario más fluida

### 5. Sistema de Roles Personalizados ✅

**Estado**: Completado

**Logros**:
- Se desarrolló un modelo completo para roles personalizados (`CustomRole`)
- Se implementó un servicio para gestionar roles personalizados (`CustomRoleService`)
- Se crearon operaciones CRUD para roles personalizados (crear, leer, actualizar, eliminar)
- Se añadió funcionalidad para asignar/quitar roles a usuarios
- Se implementó sistema de recálculo de permisos al modificar roles
- Se construyó una interfaz para crear y editar roles personalizados

**Beneficios obtenidos**:
- Mayor flexibilidad para definir roles según necesidades específicas
- Capacidad de crear plantillas de permisos adaptadas a cada academia
- Simplificación del proceso de asignación de permisos a múltiples usuarios
- Mayor organización jerárquica de permisos

### 6. Interfaz de Administración de Permisos ✅

**Estado**: Completado

**Logros**:
- Se desarrolló una interfaz completa para gestionar permisos (`PermissionsManagementScreen`)
- Se implementó un sistema de pestañas para diferentes modos de gestión (individual, por rol, por lotes)
- Se añadió funcionalidad de búsqueda y filtrado de usuarios
- Se creó una interfaz de edición de permisos con soporte para estado tri-estado (activar, desactivar, sin cambios)
- Se implementó un sistema visual para gestionar permisos predeterminados por rol

**Beneficios obtenidos**:
- Interfaz intuitiva para gestionar permisos sin necesidad de conocimientos técnicos
- Mayor control para propietarios y managers sobre los permisos de su equipo
- Capacidad de realizar cambios masivos de permisos de forma eficiente
- Visualización clara del estado actual de permisos

### 7. Depuración de Errores en Modelos con Freezed ✅

**Estado**: Completado

**Logros**:
- Se identificaron y corrigieron errores de null safety en el modelo `CustomRole`
- Se implementó el manejo adecuado de campos potencialmente nulos en la interfaz de usuario
- Se actualizaron las operaciones de conversión de datos en `CustomRoleService` para manejar diversos tipos de datos
- Se ejecutó correctamente el generador de código para asegurar la integridad de los modelos
- Se realizaron pruebas exhaustivas de la pantalla de gestión de roles para validar las correcciones

**Beneficios obtenidos**:
- Mayor estabilidad en la gestión de roles personalizados
- Eliminación de errores en tiempo de ejecución relacionados con valores nulos
- Mejora en la robustez del código frente a datos inconsistentes
- Mejor experiencia de usuario al eliminar errores visuales
- Documentación de buenas prácticas para el uso de Freezed en el proyecto

• Verificar mejora de rendimiento en verificación de permisos ✓
• Comprobar funcionamiento correcto de la caché con invalidación automática ✓
• Validar flujo completo de creación y asignación de roles personalizados ✓
• Probar la interfaz de gestión de permisos con diferentes tipos de usuarios ✓
• Verificar que las operaciones por lotes funcionan correctamente ✓
• Notas de problemas encontrados:
  - Se encontraron errores con la generación de código Freezed para CustomRole que requirieron ejecutar build_runner
  - Se detectaron problemas de tipo en las conversiones de listas en el servicio CustomRoleService que fueron corregidos
  - La pantalla CustomRolesScreen presentaba errores de null safety que se resolvieron con comprobaciones adicionales
  - Se actualizó el manejo de operadores de acceso nulo (?) en la interfaz para cumplir con las reglas de linting
  - Se recomendó actualizar los comandos de generación de código a 'dart run build_runner' en lugar de 'flutter pub run'

### 8. Sistema de Gestión de Grupos ✅

**Estado**: Completado

**Logros**:
- Se desarrolló un modelo completo para grupos (`Group`) con soporte para relaciones
- Se implementó un servicio completo para la gestión de grupos (`GroupService`)
- Se crearon pantallas para listar, crear, editar y eliminar grupos
- Se desarrolló una interfaz para asignar entrenadores y atletas a grupos
- Se integró la gestión de grupos en la navegación principal
- Se implementó un widget de carga compartido para mejorar la UX durante operaciones
- Se diseñó una interfaz intuitiva con búsqueda y filtrado de grupos
- Se creó una estructura de navegación basada en pestañas con acceso directo a grupos

**Beneficios obtenidos**:
- Gestión completa de grupos deportivos dentro de cada academia
- Capacidad para organizar atletas en equipos específicos
- Asignación eficiente de entrenadores a grupos
- Interfaz amigable para la gestión de relaciones
- Mayor organización y claridad en la estructura deportiva
- Base sólida para implementar entrenamientos y evaluaciones

### 9. Implementación de Almacenamiento Local con Hive ✅

**Estado**: Completado

**Logros**:
- Se implementó un sistema completo de almacenamiento local utilizando Hive
- Se crearon modelos específicos para persistencia local (ej. `UserHiveModel`)
- Se desarrolló el servicio de conectividad (`ConnectivityService`) para monitoreo de red
- Se implementó un sistema de operaciones offline con cola de sincronización
- Se desarrolló el servicio de sincronización (`SyncService`) para reconciliar datos
- Se integraron repositorios locales en los servicios existentes
- Se creó documentación detallada del sistema en README-offline-sync.md

**Beneficios obtenidos**:
- Funcionalidad completa offline con sincronización automática
- Reducción significativa de consultas a Firestore
- Mejor experiencia de usuario en condiciones de conectividad limitada
- Sistema transparente que no requiere intervención del usuario
- Estructura extensible para añadir soporte offline a nuevas entidades
- Base sólida para implementar caché de datos frecuentemente accedidos

**Pruebas y depuración**:
• Verificar funcionamiento del servicio de conectividad ✓
• Comprobar almacenamiento local de usuarios ✓

### 10. Optimización de la Persistencia de Autenticación ✅

**Estado**: Completado

**Logros**:
- Se implementó un sistema robusto de persistencia de autenticación en Firebase Auth
- Se añadió configuración automática de persistencia según la plataforma (LOCAL para móvil, SESSION para web)
- Se agregaron logs extensivos para monitoreo y depuración del sistema de autenticación
- Se mejoró la gestión de estados de autenticación en el autoLoadAcademyProvider
- Se corrigió el problema de pérdida de sesión al reiniciar la aplicación
- Se optimizó el proceso de recuperación de datos de usuario cuando cambia el estado de autenticación

**Beneficios obtenidos**:
- Experiencia de usuario más fluida sin necesidad de iniciar sesión repetidamente
- Mayor robustez en la gestión de sesiones de usuario
- Mejor compatibilidad entre diferentes plataformas
- Sistema de logs que facilita el diagnóstico de problemas relacionados con autenticación
- Transiciones más suaves entre estados de la aplicación (autenticado/no autenticado)
- Carga más confiable de datos relacionados con el usuario al iniciar la aplicación

**Pruebas y depuración**:
• Verificar persistencia de sesión entre reinicios de aplicación ✓
• Comprobar correcta carga de datos de usuario después de reiniciar ✓
• Validar funcionamiento adecuado del autoLoadAcademyProvider con usuario autenticado ✓
• Verificar correcto manejo de timestamps en modelos de datos ✓
• Notas de problemas encontrados:
  - Se detectó un error "setPersistence() is only supported on web based platforms" que fue corregido implementando verificación de plataforma
  - Se observó que los objetos Timestamp de Firestore no se convertían correctamente a DateTime en ciertos modelos
  - Se encontraron casos donde el usuario aparecía como "no autenticado" brevemente al iniciar la aplicación

### 11. Corrección de la Navegación del Dashboard ✅

**Estado**: Completado

**Logros**:
- Se optimizó el comportamiento del icono de Dashboard en la barra de navegación personalizada
- Se eliminó la navegación redundante que causaba la creación de nuevas instancias del Dashboard
- Se implementó una lógica mejorada para volver a la raíz de la navegación cuando se selecciona el Dashboard
- Se refactorizó la gestión de estados en el componente CustomNavigationBar
- Se añadieron verificaciones para prevenir múltiples recreaciones de pantallas

**Beneficios obtenidos**:
- Mejor conservación del estado entre navegaciones
- Experiencia de usuario más consistente y predecible
- Menor consumo de memoria al evitar instancias duplicadas de pantallas
- Transiciones más fluidas entre secciones de la aplicación
- Estructura de navegación más robusta y mantenible

**Pruebas y depuración**:
• Verificar comportamiento del Dashboard al hacer tap en su icono ✓
• Comprobar conservación de estado entre navegaciones ✓
• Validar comportamiento cuando existen múltiples niveles de navegación ✓
• Notas de problemas encontrados:
  - Se identificó que el uso de pushReplacementNamed causaba la pérdida de estado y duplicación de instancias
  - Se observó que la pila de navegación no se limpiaba correctamente al regresar al Dashboard
  - Se resolvió la redundancia en el manejo de rutas de navegación

## Fase 6: Sistema de Entrenamientos y Sesiones

**Estado**: Completado ✅

**Logros**:
- Se desarrolló el modelo `Training` con soporte para plantillas y recurrencia
- Se implementó el servicio completo para gestión de entrenamientos (`TrainingService`)
- Se creó el modelo `Session` para instancias específicas de entrenamientos
- Se implementó un sistema flexible de recurrencia (diaria, semanal, mensual)
- Se desarrolló la interfaz para crear y gestionar entrenamientos y plantillas
- Se implementó la pantalla para gestionar sesiones de un entrenamiento
- Se creó el sistema de registro de asistencia para sesiones
- Se integró con el sistema de grupos existente
- Se añadió soporte para evaluación de rendimiento

**Beneficios obtenidos**:
- Gestión completa del ciclo de entrenamientos
- Planificación eficiente mediante el sistema de plantillas y recurrencia
- Seguimiento detallado de asistencia
- Base sólida para implementar el sistema de evaluación y seguimiento de atletas

**Pruebas y depuración**:
```
• Verificar creación de entrenamientos y plantillas ✓
• Comprobar generación de sesiones recurrentes ✓
• Validar registro y guardado de asistencia ✓
• Probar integración con los grupos existentes ✓
• Verificar creación de sesiones individuales ✓
• Notas de problemas encontrados:
  - Se requirió la generación de código Freezed para los nuevos modelos
  - Se ajustó la interfaz para mejorar la experiencia en tablets
```

## Fase 7: Sistema de Evaluación y Seguimiento

**Objetivo**: Crear un sistema para evaluar y hacer seguimiento del progreso de los atletas.

**Tareas planificadas**:
- Desarrollar modelo `Evaluation` con métricas configurables
- Implementar servicio para gestionar evaluaciones de atletas
- Crear interfaz para registrar y visualizar evaluaciones
- Diseñar gráficos y estadísticas de progreso
- Implementar sistema de objetivos personalizados
- Desarrollar comparativas entre atletas del mismo grupo
- Implementar exportación de datos para análisis externos

### Fase 8: Integración de Calendario

**Objetivo**: Implementar un sistema de calendario para visualizar y programar actividades.

**Tareas planificadas**:
- Desarrollar vista de calendario con diferentes modos (mes, semana, día)
- Implementar integración con entrenamientos y sesiones
- Crear sistema de eventos personalizados
- Implementar recordatorios y notificaciones
- Desarrollar sincronización con calendarios externos (Google, Apple)
- Diseñar interfaz para gestionar disponibilidad de entrenadores
- Implementar reserva de instalaciones y recursos

## Fase 1: Configuración del Proyecto e Infraestructura Base

### 1.1 Configuración del Proyecto Flutter

- [x] Crear proyecto Flutter con las dependencias iniciales
- [x] Configurar estructura de carpetas (ui, ux, shared)
- [x] Configurar análisis estático y linting
- [x] Inicializar control de versiones

**Pruebas y depuración:**
```
• Validar que la aplicación se ejecute correctamente en dispositivos iOS y Android ✓
• Confirmar que la estructura de carpetas sea accesible correctamente ✓
• Verificar que el linting funcione según las reglas establecidas ✓
• Notas de problemas encontrados: 
  - Se resolvieron problemas iniciales con las dependencias de Firebase
```

### 1.2 Configuración de Firebase

- [x] Crear proyecto Firebase
- [x] Configurar Firebase para ambientes (desarrollo, staging, producción)
- [x] Configurar Firebase Authentication
- [x] Configurar Firestore Database
- [x] Implementar Firebase Analytics

**Pruebas y depuración:**
```
• Verificar conexión correcta con Firebase desde la aplicación ✓
• Validar que las credenciales estén configuradas para cada ambiente ✓
• Comprobar permisos y reglas de seguridad ✓
• Verificar inicialización correcta de servicios Firebase ✓
• Notas de problemas encontrados:
  - Se ajustaron las reglas de seguridad de Firestore para permitir el acceso adecuado
```

### 1.3 Implementación de Gestión de Estado Base

- [x] Configurar Riverpod y generadores
- [x] Implementar AuthRepository base
- [x] Implementar modelo User con Freezed
- [x] Crear providers base de autenticación

**Pruebas y depuración:**
```
• Verificar generación correcta de código con build_runner ✓
• Validar construcción de modelos Freezed ✓
• Comprobar funcionamiento de providers y su ciclo de vida ✓
• Notas de problemas encontrados:
  - Se tuvo que resolver un problema con la inicialización de Ref
```

## Fase 2: Autenticación y Gestión de Usuarios

### 2.1 Implementación de Autenticación

- [x] Diseñar pantalla de login con logo adaptable según tema claro/oscuro
- [x] Implementar inicio de sesión con email/password
- [x] Implementar pantalla de splash animada con logo
- [x] Diseñar pantalla de registro que permita solo crear cuentas de propietarios
- [x] Implementar recuperación de contraseña
- [x] Manejar correctamente la navegación basada en el estado de autenticación

**Pruebas y depuración:**
```
• Probar flujo completo de login con credenciales válidas e inválidas ✓
• Verificar que el splash se muestra correctamente y tiene la duración adecuada ✓
• Verificar que el logo se muestra correctamente según el tema (blanco/negro) ✓
• Verificar que solo se pueden registrar propietarios de academias ✓
• Comprobar persistencia de sesión entre reinicios de la app ✓
• Validar flujo de recuperación de contraseña ✓
• Notas de problemas encontrados:
  - Se corrigió un problema con la redirección después del registro
```

### 2.2 Gestión de Perfiles de Usuario

- [x] Implementar pantalla de perfil de usuario
- [x] Implementar edición de perfil
- [x] Implementar subida de imagen de perfil
- [x] Crear provider para gestión de perfil

**Pruebas y depuración:**
```
• Verificar carga correcta de datos de perfil ✓
• Comprobar actualización de datos en Firestore ✓
• Validar restricciones y validaciones de datos ✓
• Comprobar que se muestra correctamente el avatar según la inicial del nombre ✓
• Verificar que el propietario puede ver la opción de crear academia ✓
• Notas de problemas encontrados:
  - Se resolvió un problema con el manejo de la imagen de perfil en Firebase Storage
```

### 2.3 Sistema de Roles y Permisos Jerárquico

- [x] Implementar modelo de permisos según jerarquía
- [x] Asegurar que solo propietarios pueden registrarse directamente
- [x] Crear pantalla para que propietarios inviten a nuevos usuarios
- [x] Implementar verificación de permisos en UI
- [x] Crear pantalla de gestión de permisos para propietarios y managers

**Pruebas y depuración:**
```
• Validar que solo se pueden crear propietarios en el registro directo ✓
• Comprobar restricciones de UI basadas en permisos ✓
• Verificar persistencia de permisos en Firestore ✓
• Validar sistema de invitación de usuarios y roles asignados ✓
• Notas de problemas encontrados:
  - Se implementaron mejoras adicionales para la verificación de permisos
```

### 2.4 Implementación del Sistema de Gestión de Usuarios Mejorado

- [x] Rediseñar la pantalla de gestión de usuarios con un TabBar categorizado por tipo de usuario
- [x] Implementar pestañas para Managers, Entrenadores, Atletas y Grupos
- [x] Crear sistema de búsqueda de usuarios por nombre/email
- [x] Implementar filtrado de usuarios mediante etiquetas
- [x] Añadir control de visibilidad basado en permisos del usuario
- [x] Crear sistema de invitación integrado en cada categoría

**Pruebas y depuración:**
```
• Verificar que las pestañas se muestran correctamente según el rol del usuario ✓
• Comprobar funcionamiento de la búsqueda y filtros ✓
• Validar que los permisos de visualización se respetan correctamente ✓
• Probar el proceso de invitación desde cada categoría ✓
• Notas de problemas encontrados:
  - Se identificaron problemas con el AppBar que han sido resueltos con la implementación del nuevo diseño sin barras superiores
  - Se ha mejorado la experiencia de usuario siguiendo el diseño del sistema de navegación actualizado
```

### 2.5 Optimización del Sistema de Permisos e Implementación de Roles Personalizados

- [x] Implementar sistema de caché para verificación de permisos
- [x] Desarrollar modelo y servicio para roles personalizados
- [x] Crear componentes UI optimizados para permisos
- [x] Implementar pantalla de gestión de roles personalizados
- [x] Desarrollar interfaz de administración de permisos
- [x] Corregir errores de null safety en modelos Freezed

**Pruebas y depuración:**
```
• Verificar mejora de rendimiento en verificación de permisos ✓
• Comprobar funcionamiento correcto de la caché con invalidación automática ✓
• Validar flujo completo de creación y asignación de roles personalizados ✓
• Probar la interfaz de gestión de permisos con diferentes tipos de usuarios ✓
• Verificar que las operaciones por lotes funcionan correctamente ✓
• Notas de problemas encontrados:
  - Se encontraron errores con la generación de código Freezed para CustomRole que requirieron ejecutar build_runner
  - Se detectaron problemas de tipo en las conversiones de listas en el servicio CustomRoleService que fueron corregidos
  - La pantalla CustomRolesScreen presentaba errores de null safety que se resolvieron con comprobaciones adicionales
  - Se actualizó el manejo de operadores de acceso nulo (?) en la interfaz para cumplir con las reglas de linting
  - Se recomendó actualizar los comandos de generación de código a 'dart run build_runner' en lugar de 'flutter pub run'
```

## Fase 3: Navegación y Estructura Base de la App

### 3.1 Configuración de Router

- [x] Implementar navegación básica
- [x] Definir rutas principales
- [x] Implementar guardias de navegación por rol/permiso
- [x] Crear scaffold base para diferentes layouts

**Pruebas y depuración:**
```
• Verificar funcionamiento de navegación entre pantallas ✓
• Comprobar bloqueo de rutas sin permisos adecuados ✓
• Validar persistencia de ruta actual en reinicios ✓
• Notas de problemas encontrados:
  - Se decidió utilizar navegación manual hasta completar la implementación de GoRouter
```

### 3.2 Pantallas Base por Rol

- [x] Implementar dashboard para propietario
- [x] Implementar dashboard para manager
- [x] Implementar dashboard para coach
- [x] Implementar dashboard para atleta
- [x] Implementar dashboard para padre/responsable

**Pruebas y depuración:**
```
• Verificar carga correcta de dashboard según rol ✓
• Comprobar visualización adecuada de métricas relevantes por rol ✓
• Validar navegación desde dashboard a secciones específicas ✓
• Verificar carga de datos en cada dashboard ✓
• Notas de problemas encontrados:
  - Se mejoró la lógica de cambio de dashboard según el rol del usuario
```

### 3.3 Sistema de Sincronización Offline

- [ ] Implementar repositorio local con Hive
- [ ] Crear estrategia de sincronización
- [ ] Implementar cola de operaciones offline
- [ ] Añadir indicadores de sincronización en UI

**Pruebas y depuración:**
```
• Esta funcionalidad se ha pospuesto para una fase posterior
```

### 3.4 Simplificación de la Interfaz de Usuario 

- [x] Eliminar completamente el AppBar de todas las pantallas
- [x] Adaptar el diseño para aprovechar el espacio adicional
- [x] Asegurar que la navegación funcione correctamente sin AppBar
- [x] Ajustar el diseño de las pantallas individuales para mayor coherencia

**Pruebas y depuración:**
```
• Verificar que todas las pantallas mantienen su funcionalidad sin AppBar ✓
• Comprobar que el diseño se ajusta correctamente en diferentes tamaños de pantalla ✓
• Validar que los usuarios pueden navegar intuitivamente sin la barra superior ✓
• Probar la experiencia en dispositivos de diferentes tamaños ✓
• Notas de problemas encontrados:
  - Se necesitó ajustar algunos elementos de navegación para compensar la ausencia del AppBar
```

### 3.5 Rediseño del Sistema de Navegación

- [x] Implementar navegación deslizable tipo Instagram
- [x] Crear sistema de deslizamiento de izquierda a derecha para acceder al chat
- [x] Implementar deslizamiento de derecha a izquierda para acceder a notificaciones
- [x] Sustituir el Drawer por animaciones de deslizamiento
- [x] Agregar botones de Perfil, Chat y Notificaciones al BottomNavigationBar

**Pruebas y depuración:**
```
• Verificar fluidez de las animaciones de deslizamiento ✓
• Comprobar transiciones entre dashboard, chat y notificaciones ✓
• Validar respuesta táctil y comportamiento en distintos dispositivos ✓
• Probar comportamiento con gestos de navegación del sistema ✓
• Verificar acceso rápido a Perfil, Chat y Notificaciones desde el BottomNavigationBar ✓
• Notas de problemas encontrados:
  - Se detectó un problema inicial de desbordamiento (overflow) en la columna del panel de navegación.
  - Solución: Reemplazar SizedBox con altura fija por Expanded y SingleChildScrollView para permitir desplazamiento.
```

### 3.6 Implementación de Bottom Navigation Bar Personalizable

- [x] Crear sistema de BottomNavigationBar con botones tipo wrap
- [x] Implementar visualización de solo 5 iconos principales
- [x] Desarrollar panel expandible para mostrar botones adicionales
- [x] Añadir sistema para fijar/personalizar botones favoritos
- [x] Implementar persistencia de configuración de botones
- [x] Añadir animaciones fluidas al expandir/contraer el panel

**Pruebas y depuración:**
```
• Verificar funcionamiento del sistema wrap para los botones ✓
• Comprobar expansión/contracción del panel de navegación ✓
• Validar personalización y fijación de botones favoritos ✓
• Probar persistencia de la configuración entre sesiones ✓
• Verificar accesibilidad y facilidad de uso ✓
• Notas de problemas encontrados:
  - Al expandir el panel completamente, inicialmente se presentaba desbordamiento de la UI.
  - Solución: Implementar un sistema de ScrollView con altura dinámica y eliminar restricciones de altura fija.
```

## Fase 4: Gestión de Academias

### 4.1 Creación y Configuración de Academia

- [x] Implementar pantalla de creación de academia
- [x] Crear formulario de configuración de deporte
- [x] Añadir configuración de detalles de la academia
- [x] Implementar flujo obligatorio de creación de academia para propietarios

**Pruebas y depuración:**
```
• Validar flujo completo de creación de academia ✓
• Comprobar que un propietario recién registrado sea redirigido a crear su academia ✓
• Verificar que no se pueda omitir la creación de academia para propietarios ✓
• Comprobar persistencia correcta en Firestore ✓
• Verificar selección de deporte y configuración específica ✓
• Validar limitación de una academia por propietario ✓
• Notas de problemas encontrados:
  - Se corrigió un problema con el proceso de subida del logo de la academia
  - Se implementó una validación para evitar que un propietario cree múltiples academias
```

### 4.2 CRUD Completo de Usuarios por Tipo

- [ ] Implementar pantallas de creación y edición para managers
- [ ] Implementar pantallas de creación y edición para coaches
- [ ] Implementar pantallas de creación y edición para atletas
- [ ] Implementar pantallas de creación y edición para padres/responsables
- [ ] Crear flujos de edición de perfiles específicos por rol
- [ ] Implementar eliminación segura de usuarios con confirmación

**Pruebas y depuración:**
```
• Esta funcionalidad está en implementación prioritaria
```

### 4.3 Gestión de Grupos/Equipos

- [ ] Implementar pantalla de listado de grupos
- [ ] Crear pantalla de detalle de grupo
- [ ] Implementar creación/edición de grupos
- [ ] Añadir asignación de coach a grupo

**Pruebas y depuración:**
```
• Esta funcionalidad está en la lista de próximas implementaciones
```

### 4.4 Gestión de Atletas

- [ ] Implementar registro de atletas
- [ ] Crear pantalla de perfil de atleta
- [ ] Implementar asignación de atletas a grupos
- [ ] Añadir vinculación de padres/responsables

**Pruebas y depuración:**
```
• Esta funcionalidad está en implementación prioritaria
```

## Fase 5: Sistema de Entrenamientos y Clases

### 5.1 Gestión de Entrenamientos

- [ ] Implementar modelo de entrenamiento
- [ ] Crear plantillas de entrenamiento por deporte
- [ ] Implementar creación/edición de entrenamientos
- [ ] Añadir biblioteca de ejercicios

**Pruebas y depuración:**
```
• Verificar creación de entrenamientos
• Comprobar especialización por deporte
• Validar biblioteca de ejercicios
• Probar edición y actualización de entrenamientos
• Notas de problemas encontrados:

```

### 5.2 Programación de Clases

- [ ] Implementar calendario de clases
- [ ] Crear pantalla de programación de clase
- [ ] Implementar asignación de entrenamiento a clase
- [ ] Añadir notificaciones de clases programadas

**Pruebas y depuración:**
```
• Verificar visualización correcta del calendario
• Comprobar creación de clases en fechas específicas
• Validar asignación de entrenamiento, grupo y coach
• Probar envío de notificaciones a participantes
• Notas de problemas encontrados:

```

### 5.3 Registro de Asistencia

- [ ] Implementar pantalla de asistencia
- [ ] Crear sistema de registro de presentes/ausentes
- [ ] Implementar historial de asistencia
- [ ] Añadir estadísticas de asistencia

**Pruebas y depuración:**
```
• Verificar registro de asistencia para una clase
• Comprobar actualización en tiempo real
• Validar historial de asistencia por atleta
• Probar generación de estadísticas de asistencia
• Notas de problemas encontrados:

```

## Fase 6: Análisis y Métricas (Trasladado de fases anteriores)

### 6.1 Dashboard de Métricas

- [ ] Implementar métricas específicas por rol
- [ ] Crear visualizaciones de datos en el dashboard
- [ ] Implementar filtros temporales para métricas
- [ ] Añadir gráficos interactivos

**Pruebas y depuración:**
```
• Esta funcionalidad ha sido pospuesta para una fase posterior
```

### 6.2 Reportes Analíticos

- [ ] Implementar sistema de reportes personalizados
- [ ] Crear exportación de datos estadísticos
- [ ] Implementar comparativas de rendimiento
- [ ] Añadir proyecciones y tendencias

**Pruebas y depuración:**
```
• Esta funcionalidad ha sido pospuesta para una fase posterior
```

## Fase 7: Análisis y Métricas (Trasladado de fases anteriores)

### 7.1 Dashboard de Métricas

- [ ] Implementar métricas específicas por rol
- [ ] Crear visualizaciones de datos en el dashboard
- [ ] Implementar filtros temporales para métricas
- [ ] Añadir gráficos interactivos

**Pruebas y depuración:**
```
• Esta funcionalidad ha sido pospuesta para una fase posterior
```

### 7.2 Reportes Analíticos

- [ ] Implementar sistema de reportes personalizados
- [ ] Crear exportación de datos estadísticos
- [ ] Implementar comparativas de rendimiento
- [ ] Añadir proyecciones y tendencias

**Pruebas y depuración:**
```
• Esta funcionalidad ha sido pospuesta para una fase posterior
```

## Fase 8: Comunicación y Notificaciones

### 8.1 Sistema de Notificaciones

- [ ] Implementar Firebase Cloud Messaging
- [ ] Crear gestor de notificaciones
- [ ] Implementar notificaciones personalizadas
- [ ] Añadir preferencias de notificación
- [ ] Implementar pantalla de centro de notificaciones
- [ ] Añadir indicador de notificaciones no leídas en la AppBar

**Pruebas y depuración:**
```
• Verificar recepción de notificaciones push
• Comprobar visualización en primer y segundo plano
• Validar acciones al interactuar con notificaciones
• Probar configuración de preferencias
• Verificar funcionamiento del indicador de notificaciones no leídas
• Comprobar marcado de notificaciones como leídas
• Notas de problemas encontrados:

```

### 8.2 Chat Interno

- [ ] Implementar modelo de mensajes
- [ ] Crear pantalla de chat individual
- [ ] Implementar chats grupales
- [ ] Añadir envío de archivos/imágenes
- [ ] Implementar acceso al chat desde icono en AppBar
- [ ] Añadir indicador de mensajes no leídos
- [ ] Crear pantalla de listado de conversaciones

**Pruebas y depuración:**
```
• Verificar envío y recepción de mensajes
• Comprobar actualización en tiempo real
• Validar chats grupales
• Probar envío de archivos multimedia
• Verificar notificaciones de nuevos mensajes
• Comprobar funcionamiento del icono e indicador en AppBar
• Verificar sistema de marcado de mensajes como leídos
• Notas de problemas encontrados:

```

### 8.3 Anuncios y Eventos

- [ ] Implementar sistema de anuncios
- [ ] Crear calendario de eventos
- [ ] Implementar confirmación de asistencia a eventos
- [ ] Añadir recordatorios de eventos

**Pruebas y depuración:**
```
• Verificar publicación de anuncios
• Comprobar visualización en calendario
• Validar proceso de confirmación de asistencia
• Probar envío de recordatorios
• Notas de problemas encontrados:

```

## Fase 9: Panel de SuperAdmin

### 9.1 Gestión de Academias

- [ ] Implementar listado de todas las academias
- [ ] Crear pantalla de detalle de academia
- [ ] Implementar acciones administrativas
- [ ] Añadir estadísticas globales

**Pruebas y depuración:**
```
• Verificar listado completo de academias
• Comprobar acceso a detalles de cualquier academia
• Validar acciones administrativas (activar/desactivar)
• Probar filtros y búsquedas
• Notas de problemas encontrados:

```

### 9.2 Gestión de Planes

- [ ] Implementar creación/edición de planes
- [ ] Crear pantalla de gestión de características
- [ ] Implementar asignación de precios
- [ ] Añadir activación/desactivación de planes

**Pruebas y depuración:**
```
• Verificar creación de nuevos planes
• Comprobar edición de planes existentes
• Validar asignación de características por plan
• Probar impacto en academias existentes
• Notas de problemas encontrados:

```

### 9.3 Monitoreo de Sistema

- [ ] Implementar dashboard de rendimiento
- [ ] Crear log de actividades críticas
- [ ] Implementar alertas de sistema
- [ ] Añadir herramientas de diagnóstico

**Pruebas y depuración:**
```
• Verificar monitoreo de métricas clave
• Comprobar registro de actividades importantes
• Validar sistema de alertas
• Probar herramientas de diagnóstico y solución
• Notas de problemas encontrados:

```

## Fase 10: Pulido Final, Internacionalización y Monetización

### 10.1 Internacionalización

- [ ] Implementar sistema i18n
- [ ] Crear archivos de traducción
- [ ] Implementar detección de idioma
- [ ] Añadir soporte para RTL (si aplica)

**Pruebas y depuración:**
```
• Verificar cambio de idioma en la aplicación
• Comprobar traducción de todos los textos
• Validar formatos regionales (fechas, números)
• Probar soporte RTL en idiomas que lo requieran
• Notas de problemas encontrados:

```

### 10.2 Optimización de Rendimiento

- [ ] Realizar auditoría de rendimiento
- [ ] Optimizar consultas a Firestore
- [ ] Implementar carga perezosa
- [ ] Reducir tamaño de aplicación

**Pruebas y depuración:**
```
• Verificar tiempos de carga de pantallas principales
• Comprobar uso de memoria
• Validar rendimiento en dispositivos de gama baja
• Probar comportamiento con grandes volúmenes de datos
• Notas de problemas encontrados:

```

### 10.3 Sistema de Pagos y Suscripciones

- [ ] Implementar modelos de planes de suscripción
- [ ] Crear pantalla de gestión de suscripción para propietarios
- [ ] Implementar integración con pasarela de pagos
- [ ] Añadir sistema de facturación y comprobantes
- [ ] Implementar gestión de pagos de usuarios a academias

**Pruebas y depuración:**
```
• Esta funcionalidad ha sido pospuesta para la fase final
```

### 10.4 Pruebas Finales

- [ ] Realizar pruebas de aceptación de usuario
- [ ] Ejecutar pruebas de regresión
- [ ] Implementar pruebas de seguridad
- [ ] Validar en múltiples dispositivos

**Pruebas y depuración:**
```
• Verificar todos los flujos críticos
• Comprobar compatibilidad con diversos dispositivos
• Validar experiencia de usuario final
• Documentar cualquier problema pendiente
• Notas finales:

```

## Administración del Proyecto

### Seguimiento de Progreso

- Sprint actual: 5
- Fecha de inicio: 06/04/2023
- Fecha de finalización prevista: 27/04/2023
- Funcionalidades prioritarias:
  1. Completar la gestión de academias
  2. Implementar mejoras en el sistema de permisos
  3. Comenzar con la gestión de grupos
- Impedimentos actuales:
  - Necesidad de ejecutar build_runner para generar archivos Freezed faltantes

### Registro de Decisiones Técnicas

```
Fecha | Decisión | Motivación | Alternativas Consideradas | Estado
----- | -------- | ---------- | ------------------------- | ------
05/04/2023 | Migrar a sistema basado en permisos | Mayor flexibilidad y granularidad | Mantener sistema basado en roles con verificaciones específicas | ✅ Completado
05/04/2023 | Centralizar componentes de navegación | Reducir duplicación de código | Mantener implementación actual con duplicación controlada | ✅ Completado
05/04/2023 | Externalizar widgets reutilizables | Mejorar mantenibilidad y testabilidad | Continuar con enfoque monolítico por pantalla | ✅ Completado
06/04/2023 | Implementar sistema de caché para permisos | Mejorar rendimiento de verificaciones | Mantener verificación directa sin caché | ✅ Completado
06/04/2023 | Desarrollar sistema de roles personalizados | Permitir flexibilidad en organización de equipos | Mantener roles predefinidos únicamente | ✅ Completado
06/04/2023 | Crear interfaz de administración de permisos | Facilitar gestión visual de permisos | Limitar modificación de permisos a nivel de código | ✅ Completado
06/04/2023 | Actualizar comandos de generación de código | Seguir recomendaciones de Dart 3.0 | Mantener comandos antiguos | ✅ Completado
```

## Apéndice: Comandos y Scripts Útiles

### Comandos para Desarrollo
```bash
# Generación de código
dart run build_runner build --delete-conflicting-outputs

# Análisis estático
flutter analyze

# Ejecución de tests
flutter test

# Limpieza de caché
flutter clean

# Ejecución en modo profile
flutter run --profile
```

### Comandos para CI/CD
```bash
# Construcción para Android
flutter build apk --release

# Construcción para iOS
flutter build ios --release

# Firebase deployment
firebase deploy --only functions,firestore:rules

# Ejecución de tests de integración
flutter test integration_test
```