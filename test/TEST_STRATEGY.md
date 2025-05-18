# Estrategia de Pruebas - Arcinus

## Índice
1. [Objetivos](#objetivos)
2. [Tipos de Pruebas](#tipos-de-pruebas)
3. [Herramientas](#herramientas)
4. [Estructura de Carpetas](#estructura-de-carpetas)
5. [Checklist de Implementación](#checklist-de-implementación)

## Objetivos

- Validar la correcta implementación de las funcionalidades del MVP
- Asegurar el comportamiento esperado de la lógica de negocio
- Verificar la UI y experiencia de usuario según el rol
- Facilitar refactorizaciones futuras con pruebas automatizadas
- Lograr una cobertura mínima del 70% en código crítico

## Tipos de Pruebas

### Pruebas Unitarias
Enfocadas en verificar el comportamiento aislado de componentes individuales:
- Providers/Notifiers de Riverpod
- Repositorios
- Modelos
- Utilidades y helpers

### Pruebas de Widgets
Enfocadas en verificar el comportamiento y apariencia de la UI:
- Componentes reutilizables
- Pantallas completas
- Navegación
- Comportamiento según rol/permisos

### Pruebas de Integración
Enfocadas en verificar el comportamiento de flujos completos:
- Autenticación
- Gestión de academias
- Gestión de usuarios
- Sistema de pagos

## Herramientas

- **Test Framework**: `package:test` y `package:flutter_test`
- **Mocks**: `package:mocktail`
- **Cobertura**: `package:coverage`
- **Golden Tests**: `package:golden_toolkit` (para pruebas visuales)

## Estructura de Carpetas

```
test/
  ├── unit_tests/
  │   ├── features/
  │   │   ├── auth/
  │   │   ├── academies/
  │   │   ├── users/
  │   │   └── payments/
  │   └── core/
  │       ├── utils/
  │       └── models/
  ├── widget_tests/
  │   ├── features/
  │   │   ├── auth/
  │   │   ├── academies/
  │   │   ├── users/
  │   │   └── payments/
  │   └── common/
  │       ├── components/
  │       └── navigation/
  └── integration_tests/
      └── flows/
          ├── auth_flow/
          ├── academy_management_flow/
          └── user_management_flow/
```

## Checklist de Implementación

### Configuración Inicial ✅
- [x] Verificar dependencias de pruebas en `pubspec.yaml`
- [ ] Configurar runner de pruebas en CI/CD
- [ ] Configurar análisis de cobertura

### Pruebas Unitarias (Prioridad Alta)

#### Core
- [x] Test de modelos base (`User`, `Academy`, etc.)
- [x] Test de utilidades de formato y validación
- [x] Test de manejadores de errores (Either)

#### Auth
- [x] Test de AuthRepository
- [x] Test de AuthNotifier
- [ ] Test de validaciones de login/registro

#### Usuarios
- [x] Test de UserRepository
- [x] Test de ClientUserProvider
- [ ] Test de RolePermissions

#### Academias
- [x] Test de AcademyRepository
- [x] Test de AcademyNotifier
- [ ] Test de SportCharacteristics

#### Pagos
- [ ] Test de PaymentRepository
- [ ] Test de PaymentNotifier

### Pruebas de Widgets (Prioridad Media)

#### Componentes Comunes
- [ ] Test de formularios reutilizables
- [ ] Test de cards y listados
- [ ] Test de diálogos y modales
- [ ] Test de navegación (GoRouter)

#### Auth UI
- [ ] Test de pantalla de login
- [ ] Test de pantalla de registro
- [ ] Test de recuperación de contraseña

#### UI de Propietario
- [ ] Test de dashboard
- [ ] Test de listado de academias
- [ ] Test de edición de academia
- [ ] Test de gestión de usuarios

#### UI de Pagos
- [ ] Test de registro de pagos
- [ ] Test de visualización de historial

### Pruebas de Integración (Prioridad Baja - Post MVP)
- [ ] Flujo completo de registro y configuración inicial
- [ ] Flujo de creación y gestión de academia
- [ ] Flujo de gestión de usuarios y permisos
- [ ] Flujo de registro y seguimiento de pagos

### Documentación y Calidad
- [x] Documentar convenciones de pruebas
- [ ] Configurar análisis de cobertura en PR
- [ ] Crear plantillas para nuevas pruebas

## Métricas de Éxito
- Cobertura mínima del 70% en código crítico
- Todos los flujos principales con pruebas de integración
- Componentes UI principales con golden tests
- Tiempo de ejecución de pruebas < 5 minutos

## Notas
- Priorizar pruebas de funcionalidades críticas del MVP
- Usar mocks para Firestore y servicios externos
- Mantener pruebas independientes (no dependientes entre sí)
- Cada PR debe incluir pruebas para nuevas funcionalidades 

## Pruebas Implementadas

### Core
1. **TimestampConverter** (`test/unit_tests/core/utils/timestamp_converter_test.dart`) ✅
   - Prueba la conversión correcta entre DateTime y Timestamp de Firestore.
   - Verifica el manejo adecuado de valores nulos.

2. **Failure** (`test/unit_tests/core/error/failures_test.dart`) ✅
   - Prueba los diferentes tipos de fallos y sus propiedades.
   - Verifica la creación correcta de cada tipo de Failure.
   - Implementa un enfoque de prueba que verifica directamente las propiedades en lugar del getter message.

3. **AppRole** (`test/unit_tests/core/auth/roles_test.dart`) ✅
   - Prueba la conversión entre roles y sus representaciones como string.
   - Verifica el manejo de strings inválidos o nulos.

4. **User Model** (`test/unit_tests/core/models/user_model_test.dart`) ✅
   - Prueba la creación del modelo con valores requeridos y opcionales.
   - Verifica la correcta serialización/deserialización a/desde JSON.
   - Prueba el funcionamiento de copyWith para modificar propiedades.

### Features
1. **AuthRepository** (`test/unit_tests/features/auth/repositories/auth_repository_test.dart`) ✅
   - Prueba la interacción con Firebase Auth y Firestore para operaciones de autenticación.
   - Verifica el manejo de casos de éxito y error en login, registro y cierre de sesión.
   - Utiliza mocktail para simular las dependencias externas.
   - Implementa el patrón AAA (Arrange-Act-Assert) para estructurar cada prueba.

2. **AuthNotifier** (`test/unit_tests/features/auth/providers/auth_notifier_test.dart`) ✅
   - Prueba la gestión del estado de autenticación con Riverpod.
   - Verifica la correcta interacción con el AuthRepository.
   - Comprueba que el estado cambie correctamente en respuesta a acciones de autenticación.
   - Verifica el manejo de errores y estados de carga/autenticado/no-autenticado.

3. **UserRepository** (`test/unit_tests/features/users/data/repositories/user_repository_test.dart`) ✅
   - Prueba operaciones CRUD de usuarios en Firestore.
   - Verifica la correcta obtención de usuarios por email e ID.
   - Comprueba la creación y actualización de usuarios manager y cliente.
   - Utiliza fake_cloud_firestore para simular la base de datos.
   - Verifica manejo de errores de validación y cuando no se encuentra un usuario.

4. **ClientUserProvider** (`test/unit_tests/features/users/presentation/providers/client_user_provider_test.dart`) ✅
   - Prueba los tres providers asociados: clientUserProvider, clientUsersByRoleProvider y clientUsersByPaymentStatusProvider.
   - Verifica la correcta interacción con el ClientUserRepository.
   - Comprueba el manejo de casos de éxito y error al obtener usuarios.
   - Verifica el comportamiento cuando no hay academia seleccionada.
   - Utiliza mocktail para simular las dependencias.

5. **AcademyRepository** (`test/unit_tests/features/academies/data/repositories/academy_repository_test.dart`) ✅
   - Prueba operaciones CRUD de academias en Firestore.
   - Verifica la correcta creación, obtención y actualización de academias.
   - Simula Firebase Storage para evitar dependencias externas.
   - Comprueba el manejo de errores de validación y cuando no se encuentra una academia.
   - Verifica el formateo correcto de datos como números de teléfono.

6. **AcademyNotifier** (`test/unit_tests/features/academies/presentation/providers/academy_notifier_test.dart`) ✅
   - Prueba la gestión del estado de academias con Riverpod utilizando el AsyncNotifier.
   - Verifica la obtención correcta de datos de academia y sus suscripciones.
   - Comprueba el manejo de errores y valores nulos.
   - Verifica la verificación de características disponibles según el plan.
   - Utiliza mocktail para simular las dependencias de AcademyRepository y AppSubscriptionRepository.

### Próximos Pasos
1. **Implementar pruebas para RolePermissions**
   - Probar la validación de permisos por rol
   - Verificar la gestión de acceso a funcionalidades
   - Comprobar la restricción de operaciones según rol

3. **Implementar pruebas para validaciones de formularios**
   - Validar formularios de registro y login
   - Verificar manejo de errores de validación 