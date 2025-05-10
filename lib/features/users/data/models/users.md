# Módulo de Usuarios en Arcinus

## Descripción General
El módulo de usuarios proporciona un conjunto de modelos, servicios y utilidades para gestionar los diferentes tipos de usuarios en la aplicación Arcinus. La aplicación distingue entre diferentes roles de usuario, cada uno con sus propias características y permisos.

## Tipos de Usuarios

### 1. Usuarios Gestores (`ManagerUserModel`)
Los usuarios gestores son aquellos responsables de administrar academias o equipos:

- **Propietarios**: Dueños de academias con acceso completo a la gestión.
- **Colaboradores**: Personal con permisos específicos asignados por propietarios.

Características:
- Permisos configurables mediante `ManagerPermission`
- Estados de cuenta mediante `ManagerStatus`
- Capacidad para gestionar múltiples academias (propietarios)
- Métricas de gestión (número de usuarios, academias, etc.)

### 2. Usuarios Clientes (`ClientUserModel`)
Los usuarios clientes son aquellos que consumen los servicios de las academias:

- **Atletas**: Deportistas registrados en una academia.
- **Padres**: Responsables o tutores vinculados a uno o más atletas.

Características:
- Estado de pagos mediante `PaymentStatus`
- Planes de suscripción activos
- Información de facturación y próximos pagos
- Vinculación entre padres y atletas

### 3. Superadministradores
Usuarios con acceso a funciones de administración global de la plataforma.

## Estructura de Datos en Firestore

### Colección `users`
Datos básicos compartidos por todos los usuarios:
- ID único
- Correo electrónico
- Nombre completo
- Rol (AppRole)
- Información de contacto
- Fecha de registro

### Colección `academies/{academyId}/users`
Datos específicos de usuarios dentro de cada academia:
- Para gestores (propietarios y colaboradores):
  - Permisos específicos
  - Estado de la cuenta
  - Métricas de gestión

- Para clientes (atletas y padres):
  - Datos de suscripción
  - Estado de pagos
  - Vinculaciones padre-atleta

## Flujos Principales

### 1. Creación de Usuarios
- **Registro general**: Crea entrada básica en `users`
- **Asignación de rol**: Configura el rol inicial (propietario, atleta, etc.)
- **Configuración específica**: Crea el documento correspondiente según el rol

### 2. Gestión de Permisos
- **Propietarios**: Acceso completo a su academia
- **Colaboradores**: Permisos específicos asignados por propietarios
- **Clientes**: Acceso limitado a sus propios datos y servicios contratados

### 3. Vinculación Padre-Atleta
- Posibilidad de vincular cuentas de padres con múltiples atletas
- Gestión unificada de pagos y comunicaciones

## Implementación

### Repositorios
- `UserRepository`: Operaciones básicas comunes a todos los usuarios
- `ManagerUserRepository`: Operaciones específicas para usuarios gestores
- `ClientUserRepository`: Operaciones específicas para usuarios clientes

### Modelos
- `User`: Modelo base con información compartida
- `ManagerUserModel`: Para propietarios y colaboradores
- `ClientUserModel`: Para atletas y padres
- Enums asociados: `AppRole`, `ManagerPermission`, `PaymentStatus`

## Mejores Prácticas
1. Utilizar el repositorio adecuado según el tipo de operación
2. Validar siempre los permisos antes de realizar operaciones
3. Mantener la coherencia entre los datos básicos y específicos
4. Utilizar transacciones para operaciones que afecten a múltiples documentos 