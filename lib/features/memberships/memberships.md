# Módulo de Membresías

## Descripción General
El módulo de membresías gestiona la relación entre los usuarios y las academias deportivas en la aplicación Arcinus. Proporciona las herramientas necesarias para administrar diferentes tipos de miembros (atletas, colaboradores, propietarios, padres), sus roles, permisos y toda la información relacionada.

## Estructura del Módulo

### Capa de Dominio
- **Entidades**: Definiciones base de los conceptos de membresía.
- **Modelos**: Estructuras de datos para membresías y usuarios académicos.
- **Repositorios**: Interfaces para definir las operaciones relacionadas con membresías.

### Capa de Datos
- **Modelos**:
  - `MembershipModel`: Representa la relación entre un usuario y una academia, incluyendo su rol y permisos.
  - `MemberWithProfile`: Combina datos de membresía con información de perfil del usuario.
- **Repositorios**:
  - `MembershipRepositoryImpl`: Implementación de las operaciones CRUD para membresías.
  - `AcademyMembersRepository`: Gestiona las operaciones relacionadas con miembros de la academia.
  - `AcademyUsersRepository`: Administra datos de usuarios dentro del contexto de una academia.

### Capa de Presentación
- **Providers**: Proveedores Riverpod para acceder a los datos de membresías y usuarios.
- **Screens**:
  - `AcademyMembersScreen`: Pantalla principal que muestra todos los miembros de una academia.
  - `AcademyUserDetailsScreen`: Muestra detalles de un usuario específico.
  - `AddAthleteScreen`: Formulario para añadir nuevos atletas a la academia.
  - `EditPermissionsScreen`: Permite modificar los permisos de un miembro.
  - `InviteMemberScreen`: Permite invitar a nuevos miembros a unirse a la academia.
  - `MemberDetailsScreen`: Muestra detalles completos de un miembro.
- **Widgets**: Componentes reutilizables para la interfaz de usuario.

## Estructura en Firestore

```
/academies/{academyId}/
    ├── memberships/             # Colección de membresías
    │   ├── {membershipId}/      # Documento de membresía individual
    │   │   ├── userId           # ID del usuario
    │   │   ├── academyId        # ID de la academia
    │   │   ├── role             # Rol en la academia (propietario, colaborador, atleta, padre)
    │   │   ├── permissions      # Lista de permisos (para colaboradores)
    │   │   ├── addedAt          # Fecha de adición a la academia
    │   │   └── ...
    │   └── ...
    │
    ├── users/                   # Colección de usuarios de la academia
    │   ├── {userId}/            # Documento de usuario en la academia
    │   │   ├── firstName        # Nombre
    │   │   ├── lastName         # Apellido
    │   │   ├── profileImageUrl  # URL de imagen de perfil
    │   │   ├── birthDate        # Fecha de nacimiento
    │   │   ├── phoneNumber      # Número de teléfono
    │   │   ├── heightCm         # Altura en cm (para atletas)
    │   │   ├── weightKg         # Peso en kg (para atletas)
    │   │   ├── position         # Posición deportiva (para atletas)
    │   │   ├── role             # Rol en la academia
    │   │   ├── allergies        # Alergias (para atletas)
    │   │   ├── medicalConditions # Condiciones médicas (para atletas)
    │   │   ├── emergencyContact # Contacto de emergencia
    │   │   ├── createdBy        # ID del usuario que creó este registro
    │   │   ├── createdAt        # Fecha de creación
    │   │   └── updatedAt        # Fecha de última actualización
    │   └── ...
```

## Roles y Permisos

### Roles Principales
- **Propietario**: Dueño de la academia con acceso completo.
- **Colaborador**: Personal de la academia con permisos configurables.
- **Atleta**: Deportista registrado en la academia.
- **Padre/Responsable**: Tutor legal vinculado a uno o más atletas.

### Sistema de Permisos
Los permisos se asignan a nivel de membresía y determinan qué acciones puede realizar un usuario en una academia específica. Los propietarios tienen acceso completo por defecto, mientras que los colaboradores tienen permisos específicos asignados.

## Integración con Otros Módulos

### Módulo de Pagos
Las membresías están vinculadas al módulo de pagos para gestionar:
- Estado de pago de los atletas
- Planes de suscripción asignados
- Historial de pagos

### Módulo de Auth
La autenticación y gestión de usuarios base se maneja a través del módulo de Auth, mientras que las membresías gestionan la relación específica con cada academia.

### Módulo de Academias
Las membresías existen en el contexto de una academia específica y proporcionan la lógica de acceso a sus funcionalidades.

## Flujos de Trabajo Principales

1. **Añadir Miembros**:
   - Invitar colaboradores vía email
   - Registrar atletas directamente
   - Vincular padres con atletas

2. **Gestionar Miembros**:
   - Ver lista de todos los miembros
   - Filtrar por rol (atletas, colaboradores, padres)
   - Ver detalles de un miembro específico

3. **Administrar Permisos**:
   - Asignar permisos a colaboradores
   - Configurar acceso a funcionalidades específicas

4. **Visualizar Pagos y Estados**:
   - Ver estado de pago de atletas
   - Acceder a registro de pagos por miembro

## Características Pendientes

- Implementar sistema de membresías familiares (vinculación padres-atletas)
- Mejorar la gestión de permisos con roles personalizados
- Añadir más métricas y analíticas por tipo de miembro
- Implementar funcionalidad de importación/exportación de miembros 