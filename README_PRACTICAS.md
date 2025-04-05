# Arcinus - Buenas Prácticas

Este documento recopila las mejores prácticas recomendadas para el desarrollo de la aplicación Arcinus. Seguir estas prácticas ayudará a mantener un código limpio, mantenible y escalable.

## Arquitectura y Organización del Código

### Estructura de Carpetas

Mantenemos una estructura clara dividida en tres secciones principales:

```
lib/
├── ui/      # Interfaz de usuario (pantallas, widgets, providers)
├── ux/      # Lógica de negocio (repositorios, implementaciones, entidades)
└── shared/  # Recursos compartidos (modelos, constantes, utilidades)
```

**Buenas prácticas:**
- Mantener la separación de responsabilidades entre las tres capas
- Organizar por características (auth, dashboard, etc.) dentro de cada capa
- Evitar dependencias circulares entre módulos

### Convenciones de Nomenclatura

**Archivos:**
- Usar `snake_case` para nombres de archivos: `auth_repository.dart`
- Usar sufijos descriptivos: `_screen.dart`, `_widget.dart`, `_provider.dart`

**Clases:**
- Usar `PascalCase` para nombres de clases: `AuthRepository`
- Nombres claros y descriptivos: `UserProfileScreen` en lugar de `Profile`

**Variables y métodos:**
- Usar `camelCase` para variables y métodos: `userRepository`, `fetchUserData()`
- Evitar abreviaturas oscuras y nombres de una sola letra

### Clean Architecture

- **Entities**: Modelos de dominio core (en `shared/models/`)
- **Use Cases**: Lógica de negocio (en `ux/features/{feature}/implementations/`)
- **Repositories**: Abstracción de fuentes de datos (en `ux/features/{feature}/repositories/`)
- **UI**: Presentación (en `ui/features/{feature}/`)

## Gestión de Estado con Riverpod

### Diseño de Providers

**Providers Granulares:**
```dart
// Incorrecto: Provider demasiado grande
@riverpod
class AcademyState extends _$AcademyState {
  @override
  Future<Academy> build(String academyId) async {
    // Mucha lógica, múltiples responsabilidades
  }
  
  // Muchos métodos diferentes...
}

// Correcto: Providers específicos
@riverpod
class Academy extends _$Academy {
  @override
  Future<Academy> build(String academyId) async {
    return ref.watch(academyRepositoryProvider).getAcademy(academyId);
  }
}

@riverpod
class AcademyGroups extends _$AcademyGroups {
  @override
  Future<List<Group>> build(String academyId) async {
    return ref.watch(groupRepositoryProvider).getGroupsByAcademy(academyId);
  }
}
```

**Separación de Estado y Lógica:**
```dart
// Estado
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<User?> build() => const AsyncValue.data(null);
}

// Lógica
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<void> build() async {
    // Inicialización
  }
  
  Future<void> signIn(String email, String password) async {
    final authState = ref.read(authStateProvider.notifier);
    authState.state = const AsyncValue.loading();
    
    try {
      final user = await ref.read(authRepositoryProvider).signIn(email, password);
      authState.state = AsyncValue.data(user);
    } catch (e, st) {
      authState.state = AsyncValue.error(e, st);
    }
  }
}
```

### Optimización de Rebuilds

**Selección de Estado:**
```dart
// Eficiente: reconstruye solo cuando cambia el nombre
final userName = ref.watch(userProvider.select((user) => user.name));

// Ineficiente: reconstruye con cualquier cambio en el usuario
final user = ref.watch(userProvider);
final name = user.name;
```

**Cacheo Inteligente:**
```dart
@Riverpod(keepAlive: true)
class ActiveAcademy extends _$ActiveAcademy {
  // Este estado se mantiene vivo durante toda la sesión
}
```

## Modelos de Datos y Serializaciones

### Inmutabilidad con Freezed

**Define modelos claros:**
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required Map<String, bool> permissions,
    @Default([]) List<String> academyIds,
    required DateTime createdAt,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**Usa patrones de copia para actualizaciones:**
```dart
// Incorrecto: modificación directa
user.name = 'Nuevo nombre';  // ¡Error! Los objetos Freezed son inmutables

// Correcto: creación de copia con cambios
final updatedUser = user.copyWith(name: 'Nuevo nombre');
```

### Validación

Implementa validación en los modelos cuando sea posible:

```dart
@freezed
class Email with _$Email {
  const Email._();
  
  const factory Email(String value) = _Email;
  
  factory Email.parse(String input) {
    if (!input.contains('@')) {
      throw FormatException('Email inválido');
    }
    return Email(input);
  }
  
  bool get isValid => value.contains('@');
}
```

## Rendimiento

### Optimizaciones de Firestore

**Consultas Eficientes:**
```dart
// Incorrecto: Traer toda la colección y filtrar
final allGroups = await firestore.collection('groups').get();
final academyGroups = allGroups.docs
    .where((doc) => doc.data()['academyId'] == academyId)
    .map((doc) => Group.fromJson(doc.data()))
    .toList();

// Correcto: Filtrar en la consulta
final academyGroups = await firestore
    .collection('groups')
    .where('academyId', isEqualTo: academyId)
    .get()
    .then((snapshot) => snapshot.docs.map((doc) => Group.fromJson(doc.data())).toList());
```

**Transacciones para Operaciones Relacionadas:**
```dart
Future<void> createGroupWithAthletes(Group group, List<Athlete> athletes) async {
  return firestore.runTransaction((transaction) async {
    // Crear grupo
    final groupRef = firestore.collection('groups').doc(group.id);
    transaction.set(groupRef, group.toJson());
    
    // Actualizar atletas
    for (final athlete in athletes) {
      final updatedAthlete = athlete.copyWith(
        groupIds: [...athlete.groupIds, group.id],
      );
      
      final athleteRef = firestore.collection('athletes').doc(athlete.id);
      transaction.update(athleteRef, updatedAthlete.toJson());
    }
  });
}
```

### Listas Virtualizadas

Siempre usa widgets con carga perezosa para listas:

```dart
// Incorrecto: carga toda la lista en memoria
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)

// Correcto: carga solo los elementos visibles
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

### Carga Paginada

Implementa paginación para colecciones grandes:

```dart
Future<List<Athlete>> getAthletesForAcademy(String academyId, {
  DocumentSnapshot? lastDocument,
  int pageSize = 20,
}) async {
  Query query = firestore
    .collection('athletes')
    .where('academyId', isEqualTo: academyId)
    .orderBy('name')
    .limit(pageSize);
    
  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => Athlete.fromJson(doc.data())).toList();
}
```

## Testing

### Mocks y Fakes

Utiliza mocks para facilitar el testing:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

test('sign in succeeds with valid credentials', () async {
  final mockRepo = MockAuthRepository();
  when(mockRepo.signIn('test@example.com', 'password'))
      .thenAnswer((_) async => User(...));
      
  final result = await mockRepo.signIn('test@example.com', 'password');
  expect(result, isA<User>());
});
```

### Integración con Riverpod

Prueba providers con contenedores de prueba:

```dart
test('AuthStateNotifier updates state correctly', () async {
  final mockRepo = MockAuthRepository();
  when(mockRepo.signIn('test@example.com', 'password'))
      .thenAnswer((_) async => User(...));
      
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
  
  // Verificar estado inicial
  expect(container.read(authStateProvider), const AsyncValue<User?>.data(null));
  
  // Ejecutar acción
  await container.read(authControllerProvider.notifier).signIn('test@example.com', 'password');
  
  // Verificar estado actualizado
  expect(container.read(authStateProvider).value, isA<User>());
});
```

## Gestión de Errores

### Estrategia Centralizada

Implementa un manejador de errores central:

```dart
class ErrorHandler {
  static void handleError(Object error, StackTrace? stackTrace) {
    // Logging del error
    logger.error('Error: $error', stackTrace: stackTrace);
    
    // Reporting a servicio de monitoreo
    crashlytics.recordError(error, stackTrace);
    
    // Clasificación del error
    if (error is FirebaseException) {
      _handleFirebaseError(error);
    } else if (error is NetworkException) {
      _handleNetworkError(error);
    }
  }
  
  // Métodos específicos por tipo de error...
}
```

### Propagación de Errores con AsyncValue

```dart
@riverpod
class AcademyState extends _$AcademyState {
  @override
  Future<Academy> build(String academyId) async {
    try {
      return await ref.watch(academyRepositoryProvider).getAcademy(academyId);
    } catch (e, st) {
      ref.read(errorHandlerProvider).handleError(e, st);
      rethrow; // Propagar para que AsyncValue capture el error
    }
  }
}

// En la UI
Consumer(
  builder: (context, ref, child) {
    final academyState = ref.watch(academyStateProvider(academyId));
    
    return academyState.when(
      data: (academy) => AcademyDetailsScreen(academy: academy),
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => ErrorDisplay(
        message: 'Error cargando academia',
        onRetry: () => ref.refresh(academyStateProvider(academyId)),
      ),
    );
  },
)
```

## Seguridad

### Validación en Cliente y Servidor

**Cliente (para UX):**
```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa un email';
  }
  if (!value.contains('@')) {
    return 'Por favor ingresa un email válido';
  }
  return null;
}
```

**Servidor (reglas de Firestore):**
```javascript
match /users/{userId} {
  allow create: if request.auth != null 
    && request.resource.data.email is string
    && request.resource.data.email.matches('^[^@]+@[^@]+\\.[^@]+$');
}
```

### Permisos y Acceso

**Verifica permisos antes de operaciones:**
```dart
Future<void> updateGroup(Group group) async {
  final user = await ref.read(authStateProvider.future);
  
  if (user == null) {
    throw NotAuthenticatedException();
  }
  
  final hasPermission = user.permissions['manageGroups'] == true;
  
  if (!hasPermission) {
    throw PermissionDeniedException('No tienes permiso para gestionar grupos');
  }
  
  return ref.read(groupRepositoryProvider).updateGroup(group);
}
```

## UI/UX

### Componentes Reutilizables

```dart
class AcademyCard extends StatelessWidget {
  final Academy academy;
  final VoidCallback? onTap;
  
  const AcademyCard({
    Key? key,
    required this.academy,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      // Implementación consistente de tarjeta de academia
    );
  }
}
```

### Sistema de Diseño

Mantén un tema coherente:

```dart
final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3E7BFA),
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(...),
    headlineMedium: TextStyle(...),
    // Definir todos los estilos de texto
  ),
  // Componentes personalizados
  extensions: [
    AcademyThemeExtension(
      cardBackground: Colors.white,
      statusColors: StatusColors(...),
    ),
  ],
);
```

## Documentación del Código

### Documentación de Clases y Métodos

```dart
/// Repositorio que maneja las operaciones CRUD para academias.
///
/// Proporciona métodos para crear, leer, actualizar y eliminar academias,
/// así como para gestionar sus relaciones con entrenadores y atletas.
class AcademyRepository {
  /// Obtiene una academia por su ID.
  ///
  /// Retorna la academia completa con todos sus datos.
  /// Lanza [NotFoundException] si la academia no existe.
  /// 
  /// Parámetros:
  /// - [id]: Identificador único de la academia
  Future<Academy> getAcademy(String id) async {
    // Implementación
  }
  
  // Otros métodos...
}
```

### Convenciones para TODOs

```dart
// TODO(username): Implementar cache de academias para reducir consultas
// FIXME(username): Resolver problema de sincronización cuando se actualizan múltiples atletas
// OPTIMIZE(username): Mejorar rendimiento de esta consulta
```

## Herramientas de Desarrollo

### Linting y Análisis Estático

Archivo `analysis_options.yaml` riguroso:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - avoid_empty_else
    - avoid_redundant_argument_values
    - avoid_type_to_string
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - directives_ordering
    - package_api_docs
    - prefer_const_constructors
    - prefer_final_fields
    - test_types_in_equals
    - throw_in_finally
    - unawaited_futures
    - unnecessary_null_checks
    - use_key_in_widget_constructors
```

### VSCode/IDE Setup

Configuraciones recomendadas para VSCode (`.vscode/settings.json`):

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.lineLength": 80,
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "[dart]": {
    "editor.rulers": [80],
    "editor.tabSize": 2,
    "editor.detectIndentation": false,
    "editor.suggest.insertMode": "replace",
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

## Consejos Finales

1. **Revisión de código**: Establece un proceso de revisión de código entre pares.
2. **Documentación actualizada**: Mantén este documento de mejores prácticas actualizado.
3. **Retrospectivas**: Realiza retrospectivas frecuentes para identificar áreas de mejora.
4. **Benchmarking**: Mide el rendimiento de la aplicación regularmente.
5. **Conoce tu stack**: Mantente actualizado con las mejores prácticas de Flutter, Riverpod y Firebase.