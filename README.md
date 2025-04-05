## Estructura de Firestore para Administración de Plataforma

Para el rol de SuperAdmin, se necesita una estructura adicional que permita gestionar la plataforma completa:

```
Collection 'platform'
  |- Document 'settings'
      |- Field: platformName, supportEmail, platformVersion
  |- Document 'statistics'
      |- Field: totalAcademies, totalUsers, activeSubscriptions
  |- Collection 'subscription_plans'
      |- Document '{planId}'
          |- Field: name, price, duration, maxUsers, maxGroups, features
  |- Collection 'platform_users'
      |- Document '{userId}'
          |- Field: email, name, role, permissions, createdAt

Collection 'admin_logs'
  |- Document '{logId}'
      |- Field: userId, action, entityType, entityId, timestamp, details

Collection 'payment_logs'
  |- Document '{paymentId}'
      |- Field: academyId, planId, amount, status, paymentMethod, timestamp
```

### Gestión de Suscripciones

```dart
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required double price,
    required int durationDays,
    required int maxUsers,
    required int maxGroups,
    required Map<String, bool> features,
    required bool isActive,
  }) = _SubscriptionPlan;
  
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);
}

@freezed
class AcademySubscription with _$AcademySubscription {
  const factory AcademySubscription({
    required String id,
    required String academyId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
    required bool autoRenew,
    required List<PaymentRecord> paymentHistory,
  }) = _AcademySubscription;
  
  factory AcademySubscription.fromJson(Map<String, dynamic> json) => _$AcademySubscriptionFromJson(json);
}
```

## Dashboard de SuperAdmin

```dart
class SuperAdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Arcinus Admin Dashboard')),
      body: Column(
        children: [
          // Estadísticas generales
          PlatformStatisticsCard(),
          
          // Listado de academias
          AcademiesManagementList(),
          
          // Gestión de suscripciones
          SubscriptionPlansManager(),
          
          // Logs de sistema
          SystemLogsViewer(),
        ],
      ),
    );
  }
}
```

### Funcionalidades del SuperAdmin

1. **Gestión de Academias**
   - Ver todas las academias registradas
   - Activar/desactivar academias
   - Acceder a los datos de cualquier academia
   - Generar reportes por academia

2. **Gestión de Planes**
   - Crear/modificar planes de suscripción
   - Definir características por plan
   - Establecer precios y duración
   - Configurar promociones y descuentos

3. **Monitoreo de Pagos**
   - Verificar estado de pagos
   - Gestionar renovaciones
   - Procesar reembolsos
   - Generar facturas

4. **Soporte Técnico**
   - Acceder como cualquier usuario para diagnóstico
   - Visualizar logs de errores
   - Resolver problemas técnicos
   - Proporcionar asistencia remota## Estrategia de Gestión de Datos

### Sincronización y Persistencia Local

Para optimizar el rendimiento y reducir las consultas a Firestore, implementaremos una estrategia de sincronización híbrida:

```dart
class SyncStrategy {
  // Tipos de sincronización
  static const int SYNC_FULL = 0;     // Sincronización completa con Firestore
  static const int SYNC_INCREMENTAL = 1; // Sincronización solo de cambios
  static const int SYNC_NONE = 2;     // Sin sincronización (offline)
}
```

#### Carga Inicial y Persistencia Local

1. **Inicialización de la Aplicación**
   ```dart
   Future<void> initializeApp() async {
     // Verificar si existen datos locales
     bool hasLocalData = await _localRepository.hasData();
     
     if (!hasLocalData || _requiresFullSync()) {
       // Primera carga o requiere sincronización completa
       await _performFullSync();
     } else {
       // Cargar datos desde almacenamiento local
       await _localRepository.loadData();
       
       // Sincronizar incremental en segundo plano
       _startIncrementalSync();
     }
   }
   ```

2. **Almacenamiento Local**
   - Utilizaremos Hive para persistencia local de datos
   - Los modelos se adaptarán para ser compatibles con Hive
   - Se implementará capa de caché con TTL (Time-To-Live) configurable

#### Estrategia PULL (Lectura de Datos)

1. **Prioridad Local**
   - Todas las consultas se dirigen primero al almacenamiento local
   - Si los datos no existen o están obsoletos, se consulta Firestore

2. **Sincronización Inteligente**
   - Datos de uso frecuente: sincronización proactiva
   - Datos de uso esporádico: sincronización bajo demanda
   - Datos críticos: siempre verificar actualización

3. **Gestión de Caché**
   ```dart
   Future<T> getData<T>(String id, {bool forceRefresh = false}) async {
     // Verificar si existe en caché y no está obsoleto
     CacheEntry<T>? cachedData = _cacheRepository.get<T>(id);
     
     if (cachedData != null && !cachedData.isExpired() && !forceRefresh) {
       return cachedData.data;
     }
     
     // Si no está en caché o está obsoleto, obtener de Firestore
     T remoteData = await _firebaseRepository.getData<T>(id);
     
     // Actualizar caché
     _cacheRepository.set<T>(id, remoteData);
     
     return remoteData;
   }
   ```

#### Estrategia PUSH (Escritura de Datos)

1. **Escritura Optimista**
   - Actualizar primero el almacenamiento local
   - Luego enviar a Firestore
   - UI responde inmediatamente con datos locales

2. **Cola de Sincronización**
   - Las operaciones de escritura se encolan si no hay conexión
   - Se intenta sincronizar cuando se recupera la conexión
   - Sistema de resolución de conflictos

3. **Transacciones y Consistencia**
   ```dart
   Future<void> updateData<T>(String id, T data) async {
     // Actualizar localmente primero
     await _localRepository.updateData<T>(id, data);
     
     try {
       // Intentar actualizar en Firestore
       await _firebaseRepository.updateData<T>(id, data);
     } catch (e) {
       // Si falla, encolar para sincronización posterior
       _syncQueue.enqueue(SyncOperation(
         type: SyncOperationType.UPDATE,
         collection: _getCollectionForType<T>(),
         id: id,
         data: data,
         timestamp: DateTime.now(),
       ));
       
       // Registrar para reintentar cuando haya conexión
       _connectivityService.onConnected(() {
         _processSyncQueue();
       });
     }
   }
   ```

### Implementación Técnica

#### Repositorios

Cada entidad tendrá dos repositorios:

1. **Repositorio Firebase**: Interactúa directamente con Firestore
   ```dart
   class FirebaseRepository<T> {
     final CollectionReference collection;
     
     Future<T> getData(String id) async {
       DocumentSnapshot doc = await collection.doc(id).get();
       return _convertToModel(doc);
     }
     
     Future<List<T>> queryData(Query query) async {
       QuerySnapshot snapshot = await query.get();
       return snapshot.docs.map((doc) => _convertToModel(doc)).toList();
     }
     
     Future<void> setData(String id, T data) async {
       await collection.doc(id).set(_convertToMap(data));
     }
     
     Stream<T> streamData(String id) {
       return collection.doc(id).snapshots().map((doc) => _convertToModel(doc));
     }
   }
   ```

2. **Repositorio Local**: Gestiona el almacenamiento local con Hive
   ```dart
   class LocalRepository<T> {
     final Box<T> box;
     
     Future<T?> getData(String id) async {
       return box.get(id);
     }
     
     Future<List<T>> getAllData() async {
       return box.values.toList();
     }
     
     Future<void> setData(String id, T data) async {
       await box.put(id, data);
     }
     
     Future<void> removeData(String id) async {
       await box.delete(id);
     }
   }
   ```

3. **Repositorio Unificado**: Combina ambos repositorios con lógica de sincronización
   ```dart
   class Repository<T> {
     final FirebaseRepository<T> _remoteRepo;
     final LocalRepository<T> _localRepo;
     final SyncQueue _syncQueue;
     
     Future<T> getData(String id, {SyncStrategy strategy = SyncStrategy.SYNC_INCREMENTAL}) async {
       // Implementación de la estrategia de lectura
     }
     
     Future<void> setData(String id, T data) async {
       // Implementación de la estrategia de escritura
     }
     
     Future<void> syncData() async {
       // Sincronización manual
     }
   }
   ```

#### Servicio de Sincronización

```dart
class SyncService {
  final Map<String, DateTime> _lastSyncTimestamps = {};
  final SyncQueue _syncQueue;
  
  // Sincronización completa de datos
  Future<void> performFullSync() async {
    // Por cada tipo de entidad
    await _syncAcademies();
    await _syncUsers();
    await _syncGroups();
    // etc.
    
    // Actualizar timestamps
    _lastSyncTimestamps.forEach((entity, _) {
      _lastSyncTimestamps[entity] = DateTime.now();
    });
  }
  
  // Sincronización incremental
  Future<void> performIncrementalSync() async {
    // Para cada entidad, sincronizar solo los cambios desde la última sincronización
    for (var entity in _lastSyncTimestamps.keys) {
      DateTime lastSync = _lastSyncTimestamps[entity]!;
      await _syncEntityChanges(entity, lastSync);
      _lastSyncTimestamps[entity] = DateTime.now();
    }
  }
  
  // Procesamiento de cola de sincronización
  Future<void> processSyncQueue() async {
    while (_syncQueue.isNotEmpty()) {
      SyncOperation operation = _syncQueue.dequeue();
      try {
        await _executeSyncOperation(operation);
      } catch (e) {
        // Si falla, volver a encolar con retraso exponencial
        operation.retryCount++;
        if (operation.retryCount < MAX_RETRY_ATTEMPTS) {
          _syncQueue.enqueue(operation);
        } else {
          // Notificar al usuario de problemas de sincronización
        }
      }
    }
  }
}
```

### Monitoreo y Diagnóstico

1. **Estado de Sincronización**
   - Indicador visual del estado de sincronización
   - Historial de operaciones de sincronización
   - Diagnóstico de problemas

2. **Resolución de Conflictos**
   - Estrategias de fusión de datos
   - Registro de conflictos para revisión
   - Opciones de resolución manual

3. **Métricas de Rendimiento**
   - Tamaño de datos sincronizados
   - Tiempo de sincronización
   - Tasa de éxito/fracaso# Arcinus - Sistema de Gestión para Academias Deportivas

## Descripción
Arcinus es una aplicación móvil desarrollada en Flutter para la gestión integral de academias deportivas. Permite administrar entrenadores, atletas, grupos, entrenamientos, clases, asistencia, pagos y comunicaciones.

## Arquitectura

### Estructura de Directorios
La aplicación sigue una arquitectura modular organizada en tres capas principales:

```
lib/
├── main.dart
├── app.dart
├── ui/                  # Capa de Interfaz de Usuario
│   ├── shared/          # Componentes UI compartidos
│   │   ├── widgets/ 
│   │   └── theme/
│   └── features/        # Características organizadas por módulos
│       ├── auth/        # Autenticación
│       │   ├── screens/
│       │   ├── widgets/
│       │   └── providers/
│       ├── dashboard/
│       ├── academy_management/
│       ├── user_management/
│       ├── training/
│       ├── classes/
│       ├── attendance/
│       ├── performance/
│       ├── payments/
│       └── communication/
│
├── ux/                  # Capa de Lógica de Negocio
│   ├── shared/          # Utilidades y servicios compartidos
│   │   ├── services/
│   │   └── utils/
│   └── features/        # Características organizadas por dominio
│       ├── auth/        # Autenticación
│       │   ├── repositories/
│       │   ├── entities/
│       │   └── implementations/
│       ├── academy/
│       ├── user/
│       ├── training/
│       ├── class/
│       ├── attendance/
│       ├── performance/
│       ├── payment/
│       └── communication/
│
└── shared/              # Recursos compartidos entre UI y UX
    ├── models/          # Modelos de datos
    ├── constants/       # Constantes globales
    ├── enums/           # Enumeraciones
    ├── exceptions/      # Excepciones personalizadas
    └── extensions/      # Extensiones
```

### Tecnologías y Patrones

- **Gestión de Estado:** Riverpod + Riverpod Annotation
- **Modelado de Datos:** Freezed para modelos inmutables
- **Base de Datos:** Firestore
- **Autenticación:** Firebase Authentication
- **Navegación:** Go Router con navegación basada en permisos
- **Arquitectura:** MVVM (Model-View-ViewModel) adaptado con Repository Pattern

## Modelos de Datos

Los modelos de datos están diseñados con un enfoque jerárquico donde las entidades heredan características de sus padres y mantienen referencias bidireccionales, optimizados para Firestore:

### Definición de Modelos Principales

#### Academia
```dart
@freezed
class Academy with _$Academy {
  const factory Academy({
    required String id,
    required String name,
    String? logo,
    required String sport,                 // Tipo de deporte (baloncesto, fútbol, etc.)
    required SportCharacteristics sportCharacteristics, // Características específicas del deporte
    required String ownerId,
    required List<String> groupIds,        // Referencias a los grupos de la academia
    required List<String> coachIds,        // Referencias a los entrenadores
    required List<String> athleteIds,      // Referencias a los atletas
    required AcademySettings settings,
    required Subscription subscription,
    required DateTime createdAt,
  }) = _Academy;
  
  factory Academy.fromJson(Map<String, dynamic> json) => _$AcademyFromJson(json);
}

// Características específicas por deporte
@freezed
class SportCharacteristics with _$SportCharacteristics {
  const factory SportCharacteristics({
    required Map<String, dynamic> attributes,  // Atributos específicos del deporte
    required List<String> skillCategories,     // Categorías de habilidades (e.j. tiro, dribbling)
    required List<String> performanceMetrics,  // Métricas de rendimiento específicas
  }) = _SportCharacteristics;
  
  factory SportCharacteristics.fromJson(Map<String, dynamic> json) => _$SportCharacteristicsFromJson(json);
  
  // Métodos de fábrica predefinidos para deportes comunes
  factory SportCharacteristics.basketball() => SportCharacteristics(
    attributes: {'court_type': 'indoor', 'team_size': 5},
    skillCategories: ['shooting', 'dribbling', 'defense', 'passing', 'rebounding'],
    performanceMetrics: ['points', 'assists', 'rebounds', 'steals', 'blocks', 'turnovers']
  );
  
  factory SportCharacteristics.soccer() => SportCharacteristics(
    attributes: {'field_type': 'outdoor', 'team_size': 11},
    skillCategories: ['shooting', 'passing', 'dribbling', 'defense', 'physical'],
    performanceMetrics: ['goals', 'assists', 'passes', 'tackles', 'interceptions']
  );
}
```

#### Grupo
```dart
@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String academyId,        // Referencia a la academia padre
    required String sport,            // Hereda el deporte de la academia
    required String coachId,          // Entrenador principal
    required List<String> athleteIds, // Referencias a los atletas del grupo
    required AgeCategory ageCategory, // Categoría de edad
    required SkillLevel skillLevel,   // Nivel de habilidad
    required DateTime createdAt,
  }) = _Group;
  
  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

enum AgeCategory { kids, youth, junior, senior, adult }
enum SkillLevel { beginner, intermediate, advanced, elite }
```

#### Usuario
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required Map<String, bool> permissions,  // Permisos como mapa de booleanos
    required List<String> academyIds,        // Academias a las que pertenece
    required DateTime createdAt,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Coach with _$Coach {
  const factory Coach({
    required String userId,          // Referencia al usuario
    required List<String> academyIds, // Academias donde entrena
    required List<String> groupIds,   // Grupos que entrena
    required String specialization,   // Especialización (técnica, física, etc.)
    required Map<String, bool> permissions,  // Permisos específicos de entrenador
    required List<String> certifications,    // Certificaciones
    required DateTime createdAt,
  }) = _Coach;
  
  factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
}
```

#### Atleta
```dart
@freezed
class Athlete with _$Athlete {
  const factory Athlete({
    required String userId,           // Referencia al usuario
    required String academyId,        // Academia a la que pertenece
    required List<String> groupIds,   // Grupos a los que pertenece
    required String primaryCoachId,   // Entrenador principal
    required List<String> parentIds,  // Referencias a los padres/responsables
    required String sport,            // Deporte (heredado de la academia)
    required AgeCategory ageCategory, // Categoría de edad
    required SkillLevel skillLevel,   // Nivel de habilidad
    required Map<String, Performance> performances, // Registro de rendimiento
    required AttendanceRecord attendance,          // Registro de asistencia
    required DateTime birthDate,
    required DateTime createdAt,
  }) = _Athlete;
  
  factory Athlete.fromJson(Map<String, dynamic> json) => _$AthleteFromJson(json);
}

@freezed
class Parent with _$Parent {
  const factory Parent({
    required String userId,           // Referencia al usuario
    required List<String> childrenIds, // Referencias a sus hijos atletas
    required List<String> academyIds,  // Academias de sus hijos
    required Map<String, bool> permissions, // Permisos específicos de padre
    required DateTime createdAt,
  }) = _Parent;
  
  factory Parent.fromJson(Map<String, dynamic> json) => _$ParentFromJson(json);
}
```

### Estructura en Firestore

```
Collection 'academies'
  |- Document '{academyId}'
      |- Field: name, logo, sport, sportCharacteristics, ownerId, groupIds, coachIds, athleteIds, settings, subscription, createdAt
      |- Collection 'groups'
          |- Document '{groupId}'
              |- Field: name, academyId, sport, coachId, athleteIds, ageCategory, skillLevel, createdAt
      |- Collection 'trainings'
          |- Document '{trainingId}'
              |- Field: name, description, sport, type, exercises, difficulty, createdBy, createdAt

Collection 'users'
  |- Document '{userId}'
      |- Field: email, name, role, permissions, academyIds, createdAt
      |- Collection 'profile'
          |- Document 'userProfile'
              |- Field: phone, address, birthDate, emergencyContact
      |- Collection 'coach_profile' (si el rol es coach)
          |- Document 'details'
              |- Field: academyIds, groupIds, specialization, permissions, certifications
      |- Collection 'athlete_profile' (si el rol es athlete)
          |- Document 'details'
              |- Field: academyId, groupIds, primaryCoachId, parentIds, sport, ageCategory, skillLevel, birthDate
      |- Collection 'parent_profile' (si el rol es parent)
          |- Document 'details'
              |- Field: childrenIds, academyIds, permissions

Collection 'classes'
  |- Document '{classId}'
      |- Field: academyId, groupId, trainingId, coachId, date, status
      |- Collection 'attendance'
          |- Document '{date}'
              |- Field: presentAthletes, absentAthletes, notes
      |- Collection 'performance'
          |- Document '{athleteId}'
              |- Field: metrics, notes, improvement

Collection 'payments'
  |- Document '{paymentId}'
      |- Field: academyId, userId, amount, date, status, paymentMethod, description, concept
```

## Sistema de Navegación y Permisos

### Estructura de Navegación
La navegación está basada en Go Router y utiliza guardianes (guards) para controlar el acceso según roles y permisos:

```dart
final router = GoRouter(
  routes: [
    // Rutas públicas
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    
    // Rutas protegidas por autenticación
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardScreen(),
      redirect: (context, state) => authGuard(context),
    ),
    
    // Rutas específicas por rol
    GoRoute(
      path: '/academy/settings',
      builder: (_, __) => const AcademySettingsScreen(),
      redirect: (context, state) => roleGuard(context, [UserRole.owner, UserRole.manager]),
    ),
  ],
);
```

### Permisos y Roles
El sistema de permisos está basado en roles con permisos máximos predeterminados, pero permite personalización mediante booleanos:

```dart
enum UserRole {
  superAdmin, // Supervisor de la aplicación (equipo de Arcinus)
  owner,      // Propietario de la academia
  manager,    // Gerente administrativo
  coach,      // Entrenador
  athlete,    // Atleta
  parent,     // Padre/responsable
  guest       // Usuario no registrado
}

// Definición de permisos como mapa de booleanos
class Permissions {
  // Permisos de superAdmin
  static const String managePlatform = 'managePlatform';   // Gestionar plataforma completa
  static const String viewAllAcademies = 'viewAllAcademies'; // Ver todas las academias
  static const String manageSubscriptions = 'manageSubscriptions'; // Gestionar suscripciones
  static const String managePaymentPlans = 'managePaymentPlans'; // Gestionar planes de pago
  
  // Permisos administrativos
  static const String createAcademy = 'createAcademy';  // Solo para propietarios nuevos
  static const String manageAcademy = 'manageAcademy';  // Configurar academia
  static const String manageUsers = 'manageUsers';      // Gestionar usuarios
  static const String manageCoaches = 'manageCoaches';  // Gestionar entrenadores
  static const String manageGroups = 'manageGroups';    // Gestionar grupos
  static const String assignPermissions = 'assignPermissions';  // Asignar permisos
  
  // Permisos financieros
  static const String managePayments = 'managePayments';  // Gestionar pagos
  static const String viewFinancials = 'viewFinancials';  // Ver finanzas
  
  // Permisos de entrenamiento
  static const String createTraining = 'createTraining';   // Crear entrenamientos
  static const String viewAllTrainings = 'viewAllTrainings'; // Ver todos los entrenamientos
  static const String editTraining = 'editTraining';       // Editar entrenamientos
  
  // Permisos de clases
  static const String scheduleClass = 'scheduleClass';     // Programar clases
  static const String takeAttendance = 'takeAttendance';   // Tomar asistencia
  static const String viewAllAttendance = 'viewAllAttendance'; // Ver toda la asistencia
  
  // Permisos de evaluación
  static const String evaluateAthletes = 'evaluateAthletes'; // Evaluar atletas
  static const String viewAllEvaluations = 'viewAllEvaluations'; // Ver todas las evaluaciones
  
  // Permisos de comunicación
  static const String sendNotifications = 'sendNotifications'; // Enviar notificaciones
  static const String useChat = 'useChat';                   // Usar el chat
  
  // Función para obtener permisos predeterminados por rol
  static Map<String, bool> getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return {
          // Permisos de nivel plataforma
          managePlatform: true,
          viewAllAcademies: true,
          manageSubscriptions: true,
          managePaymentPlans: true,
          
          // Todos los demás permisos
          createAcademy: true,
          manageAcademy: true,
          manageUsers: true,
          manageCoaches: true,
          manageGroups: true,
          assignPermissions: true,
          managePayments: true,
          viewFinancials: true,
          createTraining: true,
          viewAllTrainings: true,
          editTraining: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: true,
          evaluateAthletes: true,
          viewAllEvaluations: true,
          sendNotifications: true,
          useChat: true,
        };
      
      case UserRole.owner:
        return {
          // Permisos de nivel plataforma (ninguno)
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          
          createAcademy: false,  // Se revoca después del primer uso
          manageAcademy: true,
          manageUsers: true,
          manageCoaches: true,
          manageGroups: true,
          assignPermissions: true,
          managePayments: true,
          viewFinancials: true,
          createTraining: true,
          viewAllTrainings: true,
          editTraining: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: true,
          evaluateAthletes: true,
          viewAllEvaluations: true,
          sendNotifications: true,
          useChat: true,
        };
        
      // Otros roles como antes...
      default:
        return {
          // Permisos básicos para otros roles
          useChat: true,
        };
    }
  }
}
```

## Implementación de Providers

Utilizaremos Riverpod con anotaciones para gestionar el estado de la aplicación:

```dart
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    return _authRepository.currentUser();
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signIn(email, password));
  }
}

@riverpod
class AcademyProvider extends _$AcademyProvider {
  @override
  Future<Academy> build(String academyId) async {
    return _academyRepository.getAcademy(academyId);
  }
}
```

## Procesos Específicos

### Registro y Onboarding
1. **Registro de Propietario**
   - El usuario se registra como propietario de academia
   - Se le asigna el rol `owner` con el permiso `createAcademy` activo
   - Accede a un wizard de configuración inicial

2. **Creación de Academia**
   - El propietario crea su academia seleccionando deporte
   - Se genera estructura base según el deporte seleccionado
   - Se revoca automáticamente el permiso `createAcademy`
   - Se redirige al dashboard de propietario

3. **Configuración Inicial**
   - Configuración de suscripción (período de prueba gratuito)
   - Personalización básica (logo, información de contacto)
   - Selección de características específicas del deporte

### Gestión de Usuarios
1. **Inscripción de Usuarios**
   - El propietario/manager puede registrar nuevos usuarios
   - Asigna roles: manager, coach, athlete, parent
   - Configura permisos iniciales según el rol

2. **Vinculación de Usuarios**
   - Enlazar atletas con sus padres/responsables
   - Asignar entrenadores a grupos específicos
   - Asociar atletas a uno o más grupos

### Gestión de Entrenamiento
1. **Creación de Entrenamientos**
   - Definir plantillas de entrenamientos por deporte/categoría
   - Establecer ejercicios, series, repeticiones, objetivos
   - Clasificar por nivel de dificultad y tipo (físico, técnico, táctico)

2. **Programación de Clases**
   - Asignar entrenamiento a un grupo específico
   - Fijar fecha, hora y duración
   - Designar entrenador responsable
   - Establecer objetivos específicos de la clase

3. **Seguimiento de Clases**
   - Registrar asistencia
   - Evaluar desempeño (individual y grupal)
   - Documentar observaciones y áreas de mejora

### Monitoreo de Rendimiento
1. **Evaluación de Atletas**
   - Registrar métricas específicas del deporte
   - Seguimiento de progresión
   - Comparativa con objetivos establecidos

2. **Reportes y Análisis**
   - Generar informes de rendimiento
   - Identificar tendencias y patrones
   - Visualización de datos para entrenadores y padres

### Gestión Financiera
1. **Registro de Pagos**
   - Registrar mensualidades, cuotas o pagos puntuales
   - Establecer recordatorios y notificaciones
   - Generar comprobantes

2. **Seguimiento Financiero**
   - Dashboard de ingresos/gastos
   - Reportes por período
   - Estado de pagos por atleta/familia

### Comunicación
1. **Notificaciones**
   - Envío de avisos según rol y grupo
   - Alertas automáticas (clases, pagos, evaluaciones)
   - Confirmaciones de asistencia

2. **Chat Interno**
   - Comunicación directa entre usuarios
   - Grupos de chat por equipo/categoría
   - Intercambio de información relevante

## Flujo de Desarrollo

1. **Configuración del Proyecto**
   - Configurar Firebase
   - Instalar dependencias
   - Configurar estructura inicial

2. **Implementación de Modelos Base**
   - Definir modelos con Freezed
   - Implementar conversión a/desde JSON

3. **Implementación de Autenticación**
   - Configurar Firebase Auth
   - Implementar repositorio de autenticación
   - Crear providers de autenticación
   - Desarrollar UI de autenticación y onboarding

4. **Implementación de Academia**
   - Configurar Firestore
   - Implementar repositorio de academia
   - Crear providers de academia
   - Desarrollar wizard de creación de academia
   - Crear dashboard de propietario

5. **Implementación de Usuarios y Permisos**
   - Implementar sistema de roles y permisos
   - Crear flujo de registro de usuarios
   - Desarrollar gestión de permisos
   - Implementar guardias de navegación

6. **Implementación de Funcionalidades Core**
   - Gestión de grupos y equipos
   - Sistema de entrenamientos
   - Programación de clases
   - Registro de asistencia

7. **Implementación de Funcionalidades Avanzadas**
   - Seguimiento de rendimiento
   - Gestión de pagos
   - Sistema de notificaciones
   - Chat interno

## Estrategia de Testing

Para asegurar la calidad y estabilidad de la aplicación, implementaremos una estrategia de testing completa:

### Tipos de Tests

1. **Tests Unitarios**
   - Tests para modelos y DTOs
   - Tests para repositorios (con mocks de Firebase)
   - Tests para providers y servicios
   ```dart
   void main() {
     group('AuthRepository Tests', () {
       late MockFirebaseAuth mockFirebaseAuth;
       late AuthRepository authRepository;
       
       setUp(() {
         mockFirebaseAuth = MockFirebaseAuth();
         authRepository = AuthRepository(mockFirebaseAuth);
       });
       
       test('signIn should return User on successful authentication', () async {
         // Arrange
         when(mockFirebaseAuth.signInWithEmailAndPassword(
           email: anyNamed('email'),
           password: anyNamed('password')
         )).thenAnswer((_) async => MockUserCredential());
         
         // Act
         final result = await authRepository.signIn('test@example.com', 'password');
         
         // Assert
         expect(result, isA<User>());
       });
     });
   }
   ```

2. **Tests de Integración**
   - Tests para flujos completos de negocio
   - Tests de integración repositorio-provider
   - Tests de integración provider-UI
   ```dart
   void main() {
     group('Academy Creation Flow', () {
       late MockAuthRepository mockAuthRepository;
       late MockAcademyRepository mockAcademyRepository;
       
       setUp(() {
         mockAuthRepository = MockAuthRepository();
         mockAcademyRepository = MockAcademyRepository();
         
         // Initialize providers for testing
         container = ProviderContainer(
           overrides: [
             authRepositoryProvider.overrideWithValue(mockAuthRepository),
             academyRepositoryProvider.overrideWithValue(mockAcademyRepository),
           ],
         );
       });
       
       test('createAcademy flow works correctly', () async {
         // Test the complete flow from auth to academy creation
       });
     });
   }
   ```

3. **Tests de Widget**
   - Tests para componentes UI aislados
   - Tests para pantallas completas
   - Tests para navegación
   ```dart
   void main() {
     group('LoginScreen Widget Tests', () {
       testWidgets('shows error message on invalid credentials', (WidgetTester tester) async {
         // Build our widget
         await tester.pumpWidget(
           ProviderScope(
             overrides: [
               authStateProvider.overrideWith((_) => const AsyncValue.data(null)),
             ],
             child: MaterialApp(
               home: LoginScreen(),
             ),
           ),
         );
         
         // Enter invalid credentials
         await tester.enterText(find.byKey(const Key('emailField')), 'invalid@email.com');
         await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
         await tester.tap(find.byType(ElevatedButton));
         await tester.pump();
         
         // Verify error message appears
         expect(find.text('Invalid credentials'), findsOneWidget);
       });
     });
   }
   ```

4. **Tests End-to-End**
   - Tests para flujos críticos completos
   - Tests de integración con Firebase Emulator
   - Tests de rendimiento

### Herramientas y Frameworks

- **Mockito**: Para mocks y stubs
- **Fake Firebase**: Para emular Firebase localmente
- **Integration Test**: Para tests de integración en dispositivos reales
- **Golden Tests**: Para comparación visual automatizada

### Automatización de Tests

- Configuración de GitHub Actions/GitLab CI para ejecución automática
- Tests ejecutados en cada PR y antes de cada release
- Cobertura de código mínima requerida (80%)
- Integración con dashboards de calidad

## CI/CD y Gestión de Versiones

### Estructura de Ramas

```
main          # Versión en producción
├── staging   # Versión para pruebas pre-release
│   ├── dev   # Desarrollo continuo
│   │   ├── feature/XXX  # Funcionalidades específicas
│   │   ├── bugfix/XXX   # Correcciones de errores
│   │   └── refactor/XXX # Refactorizaciones
```

### Pipeline de CI/CD

1. **Fase de Build y Tests**
   ```yaml
   build_and_test:
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v3
       - uses: subosito/flutter-action@v2
         with:
           flutter-version: '3.7.x'
           channel: 'stable'
       - run: flutter pub get
       - run: flutter analyze
       - run: flutter test
   ```

2. **Fase de Integración**
   - Construcción de artefactos
   - Tests de integración
   - Análisis de calidad

3. **Fase de Despliegue**
   - Despliegue automático a Firebase App Distribution para staging
   - Despliegue a Google Play/App Store para producción
   - Generación de notas de versión

### Gestión de Versiones

Utilizaremos versionamiento semántico (SemVer):

```
MAJOR.MINOR.PATCH+BUILD
```

- **MAJOR**: Cambios incompatibles con versiones anteriores
- **MINOR**: Funcionalidades nuevas compatibles con versiones anteriores
- **PATCH**: Correcciones de errores compatibles con versiones anteriores
- **BUILD**: Identificador de compilación

Ejemplo de automatización:
```dart
// Archivo version.dart generado automáticamente por CI/CD
class AppVersion {
  static const String version = '1.2.3';
  static const int buildNumber = 42;
  static const String buildDate = '2025-04-04';
  static const String commitHash = 'a1b2c3d';
}
```

### Despliegue Multi-ambiente

- **Development**: Para pruebas internas
  - Firebase proyecto de desarrollo
  - Sufijo .dev en el nombre
  - Base de datos aislada

- **Staging**: Para pruebas pre-lanzamiento
  - Firebase proyecto de staging
  - Sufijo .staging en el nombre
  - Datos simulados realistas

- **Production**: Para usuarios finales
  - Firebase proyecto de producción
  - Sin sufijo
  - Datos reales protegidos

## Internacionalización y Localización

### Estructura

Utilizaremos el paquete `flutter_localizations` y `intl` para manejar la internacionalización:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class ArcInusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // Inglés
        const Locale('es', ''), // Español
        const Locale('fr', ''), // Francés
        const Locale('pt', ''), // Portugués
        // Más idiomas según necesidad
      ],
      // ...
    );
  }
}
```

### Archivos de Traducción

Los textos se organizarán en archivos ARB:

```json
// lib/l10n/app_en.arb
{
  "appTitle": "Arcinus - Sports Academy Manager",
  "loginTitle": "Welcome Back",
  "emailLabel": "Email",
  "passwordLabel": "Password",
  "loginButton": "Sign In",
  "@loginButton": {
    "description": "Text shown on the login button"
  },
  "coachDashboardTitle": "Coach Dashboard",
  "@coachDashboardTitle": {
    "description": "Title for the coach's dashboard screen"
  }
}
```

```json
// lib/l10n/app_es.arb
{
  "appTitle": "Arcinus - Gestor de Academias Deportivas",
  "loginTitle": "Bienvenido de Nuevo",
  "emailLabel": "Correo electrónico",
  "passwordLabel": "Contraseña",
  "loginButton": "Iniciar Sesión",
  "coachDashboardTitle": "Panel del Entrenador"
}
```

### Uso en el Código

```dart
// Acceso simple a textos traducidos
Text(AppLocalizations.of(context).loginTitle),

// Textos con parámetros
Text(AppLocalizations.of(context).welcomeUser(userName)),

// Pluralización
Text(AppLocalizations.of(context).athleteCount(count)),
```

### Adaptación Regional

1. **Formatos de Fecha/Hora**
   ```dart
   String formattedDate = DateFormat.yMMMd(locale).format(dateTime);
   ```

2. **Formatos Numéricos**
   ```dart
   String formattedCurrency = NumberFormat.currency(
     locale: locale,
     symbol: currencySymbol,
   ).format(amount);
   ```

3. **Adaptación de Diseño**
   - Ajuste de longitudes de texto según idioma
   - Soporte para dirección RTL (árabe, hebreo)
   - Adaptación de layouts para textos extensos

### Detección de Idioma

```dart
Future<void> setLocale() async {
  // Intentar obtener el idioma del dispositivo
  final deviceLocale = WidgetsBinding.instance.window.locale;
  
  // Verificar si el idioma es soportado
  if (supportedLocales.contains(deviceLocale)) {
    await _settingsRepository.setLocale(deviceLocale.toString());
  } else {
    // Idioma predeterminado
    await _settingsRepository.setLocale('en');
  }
}
```

## Consideraciones Técnicas

- **Rendimiento**: Optimización de consultas Firestore
- **Escalabilidad**: Estructura de datos diseñada para crecimiento
- **Offline First**: Soporte para funcionamiento sin conexión
- **Seguridad**: Reglas de Firestore para proteger datos
- **Accesibilidad**: Soporte para lectores de pantalla y navegación alternativa

## Recursos Adicionales

- Documentación de Riverpod: [link]
- Documentación de Freezed: [link]
- Documentación de Firebase: [link]
- Documentación de Go Router: [link]
- Documentación de Internacionalización Flutter: [link]