# Arcinus - Plan de Desarrollo y Depuración

Este documento detalla el proceso de desarrollo de la aplicación Arcinus, con pasos específicos para implementar y depurar cada funcionalidad. El plan está organizado en fases incrementales, permitiendo validar cada componente antes de avanzar.

## Progreso General

**Estado actual**: En desarrollo - Fase 4 (Gestión de Academias)

**Completado**:
- ✅ Configuración inicial del proyecto
- ✅ Autenticación y gestión de usuarios
- ✅ Sistema de navegación y estructura base
- ✅ Implementación parcial de la gestión de academias
- ✅ Migración a arquitectura basada en permisos

**En progreso**:
- 🔄 Completar gestión de academias
- 🔄 Implementación de gestión de grupos/equipos

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

## Próximas Mejoras Arquitectónicas

Para continuar mejorando la arquitectura del proyecto, se han identificado las siguientes oportunidades:

### 1. Interfaz de Administración de Permisos

**Objetivo**: Crear una interfaz visual para que propietarios y managers puedan gestionar los permisos de los usuarios.

**Implementación planificada**:
- Diseñar una pantalla de administración de permisos con matriz de usuarios/permisos
- Implementar funcionalidad de edición de permisos con actualización en tiempo real
- Crear sistema de previsualización de cambios antes de confirmar

### 2. Sistema de Roles Personalizados

**Objetivo**: Permitir la creación y gestión de roles personalizados con combinaciones específicas de permisos.

**Implementación planificada**:
- Desarrollar modelo para roles personalizados
- Implementar interfaz para crear y editar roles
- Adaptar el sistema de asignación de permisos para trabajar con roles personalizados

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
- [ ] Implementar selección de plan de suscripción
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

### 4.2 Gestión de Grupos/Equipos

- [ ] Implementar pantalla de listado de grupos
- [ ] Crear pantalla de detalle de grupo
- [ ] Implementar creación/edición de grupos
- [ ] Añadir asignación de coach a grupo

**Pruebas y depuración:**
```
• Esta funcionalidad está en la lista de próximas implementaciones
```

### 4.3 Gestión de Atletas

- [ ] Implementar registro de atletas
- [ ] Crear pantalla de perfil de atleta
- [ ] Implementar asignación de atletas a grupos
- [ ] Añadir vinculación de padres/responsables

**Pruebas y depuración:**
```
• Esta funcionalidad está en la lista de próximas implementaciones
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

## Fase 6: Seguimiento de Rendimiento

### 6.1 Evaluación de Atletas

- [ ] Implementar modelo de rendimiento por deporte
- [ ] Crear pantalla de evaluación
- [ ] Implementar registro de métricas específicas
- [ ] Añadir notas y comentarios

**Pruebas y depuración:**
```
• Verificar registro de métricas de rendimiento
• Comprobar adaptación según deporte seleccionado
• Validar persistencia de evaluaciones en Firestore
• Probar visualización de historial de evaluaciones
• Notas de problemas encontrados:




```

### 6.2 Visualización de Progreso

- [ ] Implementar gráficos de progreso
- [ ] Crear dashboard de rendimiento para atletas
- [ ] Implementar comparativas entre atletas (para coaches)
- [ ] Añadir informes descargables

**Pruebas y depuración:**
```
• Verificar visualización correcta de datos en gráficos
• Comprobar cálculo de tendencias y progresos
• Validar comparativas entre periodos
• Probar generación y descarga de informes
• Notas de problemas encontrados:




```

### 6.3 Sistema de Objetivos

- [ ] Implementar definición de objetivos
- [ ] Crear seguimiento de objetivos
- [ ] Implementar notificaciones de logros
- [ ] Añadir celebración de hitos alcanzados

**Pruebas y depuración:**
```
• Verificar creación de objetivos personalizados
• Comprobar seguimiento automático de progreso
• Validar notificaciones al alcanzar objetivos
• Probar visualización de objetivos por rol
• Notas de problemas encontrados:




```

## Fase 7: Gestión Financiera

### 7.1 Sistema de Pagos

- [ ] Implementar registro de pagos
- [ ] Crear pantalla de historial de pagos
- [ ] Implementar recordatorios de pago
- [ ] Añadir generación de comprobantes

**Pruebas y depuración:**
```
• Verificar registro correcto de pagos
• Comprobar cálculo de saldos pendientes
• Validar envío de recordatorios
• Probar generación de comprobantes
• Notas de problemas encontrados:




```

### 7.2 Gestión de Suscripciones

- [ ] Implementar modelos de planes de suscripción
- [ ] Crear pantalla de gestión de suscripción
- [ ] Implementar cambio de plan
- [ ] Añadir renovación automática

**Pruebas y depuración:**
```
• Verificar visualización de detalles de suscripción actual
• Comprobar proceso de cambio de plan
• Validar limitaciones según plan seleccionado
• Probar proceso de renovación
• Notas de problemas encontrados:




```

### 7.3 Reportes Financieros

- [ ] Implementar cálculo de ingresos
- [ ] Crear dashboard financiero
- [ ] Implementar reportes por período
- [ ] Añadir exportación de datos

**Pruebas y depuración:**
```
• Verificar cálculos correctos de ingresos
• Comprobar generación de reportes por periodo
• Validar filtros y agrupaciones
• Probar exportación en diferentes formatos
• Notas de problemas encontrados:




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

## Fase 10: Pulido Final e Internacionalización

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

### 10.3 Pruebas Finales

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

- Sprint actual: 4
- Fecha de inicio: 05/04/2023
- Fecha de finalización prevista: 20/04/2023
- Funcionalidades prioritarias:
  1. Completar la gestión de academias
  2. Implementar mejoras arquitectónicas
  3. Comenzar con la gestión de grupos
- Impedimentos actuales:
  - Necesidad de refactorización para manejar el crecimiento de la complejidad

### Registro de Decisiones Técnicas

```
Fecha | Decisión | Motivación | Alternativas Consideradas | Estado
----- | -------- | ---------- | ------------------------- | ------
05/04/2023 | Migrar a sistema basado en permisos | Mayor flexibilidad y granularidad | Mantener sistema basado en roles con verificaciones específicas | ✅ Completado
05/04/2023 | Centralizar componentes de navegación | Reducir duplicación de código | Mantener implementación actual con duplicación controlada | ✅ Completado
05/04/2023 | Externalizar widgets reutilizables | Mejorar mantenibilidad y testabilidad | Continuar con enfoque monolítico por pantalla | ✅ Completado
06/04/2023 | Implementar interfaz de administración de permisos | Facilitar gestión de permisos por propietarios | Limitar la administración de permisos solo a código | 🔄 En progreso
06/04/2023 | Desarrollar sistema de roles personalizados | Permitir flexibilidad en organización de equipos | Mantener roles predefinidos únicamente | 📅 Planificado
```

## Apéndice: Comandos y Scripts Útiles

### Comandos para Desarrollo
```bash
# Generación de código
flutter pub run build_runner build --delete-conflicting-outputs

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