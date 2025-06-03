# Módulo de Gestión de Usuarios (User Management)

## Descripción General
El módulo de Gestión de Usuarios es responsable de definir modelos de datos detallados para los usuarios y proporcionar la lógica de repositorio base para interactuar con la información de los usuarios. Este módulo trabaja en conjunto con el módulo de Autenticación, extendiendo la información básica del usuario con datos más específicos y contextuales, especialmente en relación con las academias.

## Estructura del Módulo

### Componentes Clave

#### Modelos (`lib/core/user_management/models/`)
-   **`BaseUser` (`base_user.dart`)**: Define la estructura fundamental y compartida para cualquier tipo de usuario dentro de la aplicación. Incluye campos como `id`, `email`, `displayName`, `photoUrl`, `appRole`, `createdAt`, `updatedAt`, y posiblemente otros atributos generales. Utiliza `freezed` para la generación de código boilerplate y `json_serializable` para la (de)serialización.
-   **`AcademyUserContext` (`academy_user_context.dart`)**: Modelo crucial que representa el contexto específico de un usuario dentro de una o varias academias. Este modelo probablemente incluye información sobre los roles del usuario en diferentes academias, permisos, estado de membresía, y otra información contextual. También utiliza `freezed` y `json_serializable`.
-   **`Enums` (`enums.dart`)**: Define diversas enumeraciones utilizadas en los modelos de gestión de usuarios. Esto puede incluir roles específicos de academia, estados de membresía, tipos de permisos, etc. También incluye un archivo `.g.dart` generado.

#### Repositorios (`lib/core/user_management/repositories/`)
-   **`BaseUserRepository` (`base_user_repository.dart`)**: Define una interfaz (clase abstracta) para las operaciones CRUD (Crear, Leer, Actualizar, Eliminar) y otras operaciones relacionadas con los datos de los usuarios. Esta interfaz sería implementada por repositorios concretos en la capa de datos (posiblemente en el módulo de autenticación o un módulo de datos dedicado) que interactúan con Firestore u otra fuente de datos.

## Relación con Otros Módulos

-   **Módulo de Autenticación (`lib/core/auth/`)**:
    -   El módulo de Autenticación maneja el proceso de registro, inicio de sesión y el estado de autenticación general.
    -   El módulo de Gestión de Usuarios toma el `User` o `UserModel` básico del módulo de autenticación y lo enriquece o lo utiliza como base para contextos más detallados (como `AcademyUserContext`).
    -   Los `AppRole` definidos en el módulo de autenticación son probablemente referenciados o extendidos por los modelos en Gestión de Usuarios.
-   **Módulos de Features (ej. Academias, Miembros)**:
    -   Estos módulos consumirán los modelos y repositorios (o sus implementaciones) de Gestión de Usuarios para obtener y manipular información detallada de los usuarios en contextos específicos (por ejemplo, listar miembros de una academia, gestionar sus roles y permisos dentro de esa academia).

## Funcionalidades Principales

-   **Modelado de Datos de Usuario**: Proporcionar estructuras de datos robustas y bien definidas para los diferentes aspectos de la información del usuario.
-   **Abstracción de Repositorio**: Definir una capa de abstracción para el acceso a datos de usuario, permitiendo implementaciones flexibles (por ejemplo, Firestore, mock para pruebas).
-   **Contextualización de Usuarios**: Manejar la complejidad de los roles y permisos de los usuarios en diferentes contextos, especialmente en relación con las academias (a través de `AcademyUserContext`).

## Puntos Clave de Diseño

-   **Separación de Intereses**: Los modelos se centran en la estructura de los datos, mientras que los repositorios definen cómo interactuar con esos datos.
-   **Inmutabilidad y Generación de Código**: Uso de `freezed` para modelos inmutables y reducción de código boilerplate.
-   **Extensibilidad**: `BaseUser` sirve como una fundación que puede ser extendida o compuesta por otros modelos para diferentes necesidades.

## Posibles Interacciones (Flujos)

1.  **Carga del Perfil de Usuario**: Una pantalla de perfil podría usar una implementación de `BaseUserRepository` para obtener los datos de `BaseUser` y `AcademyUserContext` para el usuario logueado.
2.  **Gestión de Miembros de Academia**: Un feature de gestión de academias usaría los repositorios para listar usuarios (`AcademyUserContext`) asociados a una academia, actualizar sus roles (definidos en `enums.dart` y almacenados en `AcademyUserContext`), etc.

## Mejoras Futuras Potenciales

-   Introducción de más modelos específicos si surgen nuevos contextos de usuario.
-   Definición de casos de uso (Use Cases) específicos para la gestión de usuarios si la lógica de negocio se vuelve más compleja.
-   Implementación de estrategias de caching para los datos de usuario.
