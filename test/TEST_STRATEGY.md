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
- [x] Test de validaciones de login/registro

#### Usuarios
- [x] Test de UserRepository
- [x] Test de ClientUserProvider
- [x] Test de RolePermissions

#### Academias
- [x] Test de AcademyRepository
- [x] Test de AcademyNotifier
- [x] Test de SportCharacteristics

#### Pagos
- [x] Test de PaymentRepository
- [x] Test de PaymentNotifier

### Pruebas de Widgets (Prioridad Media)

#### Componentes Comunes
- [ ] Test de formularios reutilizables
- [ ] Test de cards y listados
- [ ] Test de diálogos y modales
- [x] Test de navegación (GoRouter)

#### Auth UI
- [x] Test de pantalla de login
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
   
7. **RolePermissions** (`test/unit_tests/core/auth/app_permissions_test.dart`) ✅
   - Prueba la validación de permisos por rol usando una clase de prueba independiente del provider.
   - Verifica el acceso según roles: superAdmin, propietario, colaborador, atleta y padre.
   - Comprueba el manejo de permisos para colaboradores con y sin membresías.
   - Valida el comportamiento con usuarios no autenticados.
   - Implementa pruebas exhaustivas para consultar permisos específicos y obtener listas de permisos.

8. **PermissionProvider** (`test/unit_tests/features/memberships/presentation/providers/permission_provider_test.dart`) ✅
   - Prueba la verificación de permisos basada en el rol del usuario y la academia.
   - Verifica acceso completo para superAdmin y propietario.
   - Comprueba permisos específicos para colaboradores según sus membresías.
   - Valida que atletas y padres no tengan acceso a funcionalidades administrativas.
   - Implementa pruebas para ambos providers: hasPermissionProvider y userPermissionsProvider.

9. **SportCharacteristics** (`test/unit_tests/features/academies/domain/sport_characteristics_test.dart`) ✅
   - Prueba las características específicas de cada deporte.
   - Verifica el correcto mapeo de posiciones y habilidades.
   - Comprueba la obtención de características según el deporte seleccionado.

10. **PaymentRepository** (`test/unit_tests/features/payments/data/repositories/payment_repository_test.dart`) ✅
   - Prueba operaciones de gestión de pagos en Firestore.
   - Verifica el correcto registro, obtención y eliminación de pagos.
   - Comprueba el filtrado de pagos por atleta y rango de fechas.
   - Verifica el manejo de errores de servidor y validación.

11. **PaymentNotifier** (`test/unit_tests/features/payments/presentation/providers/payment_notifier_test.dart`) ✅
   - Prueba la gestión del estado de pagos con Riverpod utilizando AsyncNotifier.
   - Verifica la correcta interacción con el PaymentRepository.
   - Comprueba el manejo de formularios de pago y su estado.
   - Verifica el flujo completo de registro y eliminación de pagos.

### Próximos Pasos
1. **Implementar pruebas de Widgets**
   - Pruebas para componentes UI comunes
   - Pruebas para pantallas principales
   - Pruebas de navegación

2. **Implementar pruebas de Integración**
   - Flujos completos de usuario
   - Escenarios de uso real
   - Pruebas end-to-end

## Pruebas de Widgets Implementadas
1. **PasswordStrengthMeter** (`test/widget_tests/common/components/password_strength_meter_test.dart`) ✅
   - Prueba el componente que muestra la fortaleza de contraseñas
   - Verifica que se muestre correctamente según diferentes entradas
   - Comprueba los colores y textos para diferentes niveles de fortaleza
   - Verifica la barra de progreso y su valor correspondiente
   - Valida el comportamiento cuando la contraseña está vacía

2. **LoginScreen** (`test/widget_tests/features/auth/ui/screens/login_screen_test.dart`) ✅
   - Prueba la renderización básica de la pantalla de inicio de sesión
   - Verifica que los elementos UI principales se muestren correctamente
   - Valida la visualización del diálogo de cuentas de prueba
   - Verifica el proceso de validación de formularios
   - Implementa pruebas para interacción con Riverpod y manejo de estado

3. **AppRouter** (`test/widget_tests/common/navigation/app_router_test.dart`) ✅
   - Prueba la navegación y redirección basada en autenticación
   - Verifica que usuarios no autenticados sean redirigidos a la pantalla de bienvenida
   - Comprueba que las rutas públicas sean accesibles sin autenticación
   - Enfocado en pruebas de redirección para rutas protegidas
   - Limitado a pruebas de pantallas accesibles sin autenticación debido a desafíos técnicos

## Desafíos y Próximos Pasos

### Desafíos Actuales
1. **Testeo de Widgets con Riverpod**: 
   - La versión actual de Riverpod utiliza generación de código, lo que dificulta los mocks directos
   - Hemos desarrollado un enfoque consistente para hacer override de providers en pruebas
   - Se han implementado MockNotifiers para simular el comportamiento de los providers generados

2. **Pruebas de GoRouter**:
   - La implementación de pruebas para GoRouter presenta desafíos debido a la forma en que se accede al estado de navegación
   - El uso de GoRouterState.of(context) en pruebas genera errores ya que no es accesible en el entorno de pruebas
   - Encontramos que es mejor verificar el resultado de la navegación comprobando widgets específicos que aparecen en pantalla
   - Las pruebas se enfocan en verificar redirecciones a pantallas accesibles sin autenticación (WelcomeScreen, LoginScreen)
   - Queda pendiente investigar maneras de probar shells anidados y rutas protegidas más complejas

### Próximos Pasos
1. **Continuar implementación de widget tests**:
   - Implementar pruebas para el formulario de registro
   - Añadir pruebas para componentes compartidos (cards, listados)
   - Probar las pantallas principales de cada rol
   - Investigar técnicas avanzadas para testear widgets en rutas protegidas

2. **Implementar pruebas de integración**:
   - Iniciar con flujos básicos end-to-end
   - Utilizar integration_test package de Flutter
   - Implementar escenarios de uso real que combinen múltiples pantallas y acciones