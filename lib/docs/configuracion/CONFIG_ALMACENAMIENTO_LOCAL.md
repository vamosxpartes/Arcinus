# Implementación de Almacenamiento Local con Hive

Este documento explica la implementación del sistema de almacenamiento local y sincronización offline en la aplicación Arcinus.

## Estructura

La implementación se compone de:

1. **Configuración de Hive**
   - Inicialización en `main.dart`
   - Configuración en `HiveConfig`

2. **Modelos para Almacenamiento Local**
   - `UserHiveModel`: Versión del modelo User para almacenamiento local

3. **Servicios de Sincronización**
   - `ConnectivityService`: Monitoreo de conectividad
   - `OfflineOperationsService`: Cola de operaciones pendientes
   - `SyncService`: Sincronización automática

4. **Repositorios Locales**
   - `LocalUserRepository`: Operaciones CRUD locales para usuarios

5. **Integración con Servicios Existentes**
   - `UserService`: Ampliado para utilizar almacenamiento local

## Funcionamiento

### Almacenamiento Local
- Los datos se almacenan en cajas (boxes) Hive
- Cada entidad (usuario, academia, etc.) tiene su propia caja
- Los modelos Hive están adaptados para almacenamiento eficiente

### Sincronización
1. Al realizar operaciones CRUD:
   - Se verifica la conectividad
   - Si hay conexión, se realiza la operación remota y se guarda localmente
   - Sin conexión, se guarda localmente y se encola para sincronización

2. Sincronización automática:
   - Se ejecuta cada 15 minutos
   - Se ejecuta cuando se restablece la conectividad
   - Procesa operaciones pendientes en orden

3. Prioridad de datos:
   - Se prioriza la obtención de datos locales
   - Solo se accede a datos remotos si no hay datos locales

## Beneficios
- Acceso a datos sin conexión
- Operaciones encoladas automáticamente
- Sincronización transparente
- Menor uso de recursos y consultas a Firestore

## Ejemplo de Uso

### Obtener datos:
```dart
// El servicio primero intenta obtener datos localmente, luego remotamente
final user = await userService.getUserById(userId);
```

### Crear/Actualizar datos:
```dart
// La operación se realiza localmente si no hay conexión y se encola
await userService.createUser(
  email: 'usuario@ejemplo.com',
  password: '12345678',
  name: 'Usuario Ejemplo',
  role: UserRole.athlete,
  academyId: 'academia-id',
);
```

## Expansión del Sistema

Para añadir soporte offline a nuevas entidades:

1. Crear un modelo Hive para la entidad
2. Registrar el adaptador en `HiveConfig`
3. Crear un repositorio local para la entidad
4. Actualizar el servicio correspondiente

## Generación de Código

Para regenerar adaptadores:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
``` 