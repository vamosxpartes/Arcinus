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
- [ ] Verificar dependencias de pruebas en `pubspec.yaml`
- [ ] Configurar runner de pruebas en CI/CD
- [ ] Configurar análisis de cobertura

### Pruebas Unitarias (Prioridad Alta)

#### Core
- [ ] Test de modelos base (`User`, `Academy`, etc.)
- [ ] Test de utilidades de formato y validación
- [ ] Test de manejadores de errores (Either)

#### Auth
- [ ] Test de AuthRepository
- [ ] Test de AuthNotifier
- [ ] Test de validaciones de login/registro

#### Academias
- [ ] Test de AcademyRepository
- [ ] Test de AcademyNotifier
- [ ] Test de SportCharacteristics

#### Usuarios
- [ ] Test de UserRepository
- [ ] Test de UserNotifier
- [ ] Test de RolePermissions

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
- [ ] Documentar convenciones de pruebas
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