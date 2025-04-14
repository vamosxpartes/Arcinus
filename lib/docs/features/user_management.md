# Gestión de Usuarios

## Propósito
Este módulo proporciona una interfaz completa para la gestión de todos los tipos de usuarios en la plataforma. Permite visualizar, crear, editar y eliminar usuarios, así como asignarlos a grupos y academias.

## Estructura
El módulo está organizado por roles de usuario, con componentes y pantallas específicas para cada tipo:

- **Managers**: Administradores de academias
- **Coaches**: Entrenadores
- **Athletes**: Atletas/Deportistas
- **Parents**: Padres/Responsables
- **Owners**: Propietarios (solo visible para superadministradores)

## Componentes

### Pantallas principales
- `UserManagementScreen`: Pantalla principal con pestañas para cada tipo de usuario
- `UserDetailsScreen`: Pantalla que muestra información detallada de un usuario específico
- Formularios específicos para cada rol:
  - `AthleteFormScreen`
  - `CoachFormScreen`
  - `ManagerFormScreen`
  - `ParentFormScreen`
  - `OwnerFormScreen`

### Componentes de UI
- Pestañas para cada tipo de usuario:
  - `ManagerTab`
  - `CoachTab`
  - `AthleteTab`
  - `ParentTab`
  - `OwnerTab`
- `UserFormContainer`: Componente reutilizable para el formulario de invitación de usuarios

### Servicios
- `UserService`: Servicio principal para operaciones CRUD de usuarios
- Proveedores específicos:
  - `managersProvider`
  - `coachesProvider`
  - `athletesProvider`
  - `parentsProvider`
  - `ownersProvider`
- `userManagementProvider`: Gestiona el estado global de la pantalla de gestión de usuarios

## Flujo de navegación

1. El usuario navega a la pantalla de gestión de usuarios (`UserManagementScreen`)
2. Selecciona una pestaña correspondiente al tipo de usuario
3. Puede:
   - Ver la lista de usuarios
   - Buscar usuarios específicos
   - Hacer tap en un usuario para ver sus detalles en `UserDetailsScreen`
   - Desde la pantalla de detalles, puede editar o eliminar el usuario
   - Crear un nuevo usuario mediante el botón de acción flotante

## Funcionalidades principales

- **Visualización de usuarios**: Listado con búsqueda y filtrado
- **Detalles de usuario**: Vista detallada con toda la información del usuario
- **Creación de usuarios**: Formularios específicos por rol
- **Edición de usuarios**: Actualización de datos personales y asignaciones
- **Eliminación de usuarios**: Con confirmación y limpieza de referencias
- **Asignación a grupos**: Para atletas y entrenadores
- **Asociación padres-atletas**: Vinculación de padres con sus hijos/atletas

## Restricciones de acceso

- Los permisos varían según el rol del usuario actual:
  - SuperAdmin: Acceso completo a todas las funcionalidades y tipos de usuario
  - Owner: Gestión completa dentro de su academia, sin acceso a otros owners
  - Manager: Gestión de entrenadores, atletas y padres, sin acceso a owners
  - Coach: Solo visualización limitada

## Manejo de datos

La gestión de usuarios utiliza Firestore con la siguiente estructura:

- Colección `superadmins`: Almacena usuarios con rol de superadministrador
- Colección `owners`: Almacena usuarios con rol de propietario
- Colección `academies/{academyId}/users`: Almacena todos los usuarios regulares (managers, coaches, athletes, parents) asociados a una academia específica

Cada usuario se almacena en una única ubicación dependiendo de su rol:
- Superadmins → Colección `superadmins`
- Owners → Colección `owners`
- Usuarios regulares → Subcolección `users` dentro de cada academia

Los usuarios regulares ya no se almacenan en la colección principal `/users`, sino exclusivamente en la subcolección de la academia a la que pertenecen.

## Solución de Problemas

### Errores de Permisos tras Actualización a v1.3.0

Si después de actualizar a la versión 1.3.0 experimentas errores de permisos en Firestore, especialmente al iniciar sesión, verifica lo siguiente:

1. **Errores comunes**:
   - `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation`
   - Sesiones que se inician en Firebase Auth pero no cargan los datos del usuario

2. **Causas principales**:
   - `FirebaseAuthRepository._getUserData` podría estar buscando usuarios en la antigua colección `/users`
   - Las reglas de seguridad de Firestore no incluyen permisos para acceder a las nuevas ubicaciones
   - Usuarios existentes que aún no han sido migrados a la nueva estructura

3. **Soluciones**:
   - Actualiza el método `_getUserData` para buscar en `academies/{academyId}/users/{userId}`
   - Verifica que las reglas de seguridad permitan acceso a las subcolecciones de usuarios
   - Migra los usuarios existentes de la colección principal a las subcolecciones

4. **Migración de datos**:
   ```dart
   // Ejemplo de código para migrar usuarios
   Future<void> migrateUserToAcademySubcollection(String userId, String academyId) async {
     final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
     if (userDoc.exists) {
       final data = userDoc.data()!;
       await FirebaseFirestore.instance.collection('academies').doc(academyId).collection('users').doc(userId).set(data);
     }
   }
   ```

5. **Actualización de reglas de seguridad**:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Acceso a subcolecciones de usuarios en academias
       match /academies/{academyId}/users/{userId} {
         allow read: if request.auth != null && (request.auth.uid == userId || hasAcademyRole(academyId, ['owner', 'manager']));
       }
     }
   }
   ```

## Registro de cambios

- **v1.0.0**: Implementación inicial de la gestión de usuarios con pestañas y formularios básicos
- **v1.1.0**: Añadida funcionalidad de búsqueda y filtrado de usuarios
- **v1.2.0**: Implementada pantalla de detalles de usuario con opciones de edición y eliminación
- **v1.2.1**: Mejorada la eliminación de usuarios con limpieza de referencias en grupos y relaciones
- **v1.3.0**: Reestructuración del almacenamiento de usuarios en Firestore: todos los usuarios regulares ahora se almacenan exclusivamente en la subcolección de su academia, eliminando el almacenamiento dual en la colección principal

## Próximas mejoras

- Implementar importación masiva de usuarios
- Añadir historial de actividad por usuario
- Mejorar la gestión de permisos granulares
- Implementar estadísticas y reportes de usuarios 