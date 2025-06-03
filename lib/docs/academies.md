# Módulo Academies

## Descripción General

El módulo `academies` se encarga de la gestión de la información fundamental de las academias registradas en la plataforma. Principalmente, permite la edición de los detalles de una academia existente.

## Pantallas Principales

### 1. Edición de Academia (`edit_academy_screen.dart`)

Nombre de la clase: `EditAcademyScreen`

Esta pantalla proporciona una interfaz para modificar la información de una academia. La información está organizada en pestañas para facilitar su gestión.

#### Funcionalidades Clave:

*   **Navegación por Pestañas (`TabController`):** La pantalla utiliza un `TabController` con tres pestañas:
    *   **Información:** Para editar los datos básicos de la academia.
    *   **Contacto:** Para editar la información de contacto.
    *   **Apariencia:** Para gestionar el logo de la academia.

*   **Pestaña 'Información':**
    *   **Nombre de la Academia:** Campo de texto (`notifier.nameController`) para el nombre oficial. Es obligatorio.
    *   **Descripción:** Campo de texto (`notifier.descriptionController`) para una descripción de la academia (multilínea).
    *   **Vista Previa de Tarjeta (`_buildPreviewCard`):** Muestra una previsualización de cómo se vería la tarjeta de la academia con la información ingresada (nombre, descripción, logo).

*   **Pestaña 'Contacto':**
    *   **Teléfono:** Campo de texto (`notifier.phoneController`) para el número de teléfono.
    *   **Email de Contacto:** Campo de texto (`notifier.emailController`) para la dirección de correo electrónico. Incluye validación básica de formato de email.
    *   **Dirección:** Campo de texto (`notifier.addressController`) para la dirección física (multilínea).

*   **Pestaña 'Apariencia':**
    *   **Carga de Logo (`_pickImage`):**
        *   Permite al usuario seleccionar una imagen de la galería del dispositivo usando `ImagePicker`.
        *   La imagen seleccionada (`_logoImage`) se muestra como vista previa.
        *   Un booleano `_hasChangedLogo` rastrea si el logo ha sido modificado por el usuario.
    *   Visualización del logo actual o el nuevo logo seleccionado.

*   **Guardado de Cambios:**
    *   Utiliza `editAcademyProvider` para manejar el estado y la lógica de guardado.
    *   El `notifier.formKey` se usa para la validación del formulario en la pestaña 'Información'.
    *   Al intentar guardar, el `editAcademyProvider` se encarga de actualizar la `AcademyModel`.
    *   (La lógica específica de cómo se sube el `_logoImage` y se actualiza la `logoUrl` en el `AcademyModel` estaría dentro del `EditAcademyNotifier`).

*   **Gestión de Estado y Notificaciones (`EditAcademyState`):
    *   Escucha los cambios en `editAcademyProvider` para mostrar mensajes al usuario:
        *   **Éxito (`success`):** Muestra un `SnackBar` indicando "Academia actualizada con éxito".
        *   **Error (`error`):** Muestra un `SnackBar` con el mensaje de error proporcionado por `failure.message`.
    *   Muestra un indicador de carga (`LoadingIndicator`) mientras el estado es `loading`.

#### Parámetros Requeridos:

*   `initialAcademy` (AcademyModel): El estado original de la academia antes de cualquier edición. Se utiliza para inicializar el `editAcademyProvider`.
*   `academy` (AcademyModel): El modelo de la academia que se está editando. (Nota: la distinción entre `initialAcademy` y `academy` como parámetros separados sugiere que `academy` podría ser una copia que se modifica, o hay una razón específica para pasar ambos. Usualmente, solo se pasaría el objeto a editar y el provider manejaría su estado inicial y los cambios).

#### Lógica de Negocio y Comportamiento:

*   **Estado de Carga (`isLoading`):** Controla la visibilidad del `LoadingIndicator`.
*   **Validación de Formularios:** Se aplica validación al nombre de la academia y al formato del email.

#### Proveedores (Providers) Relevantes:

*   `editAcademyProvider`: Un `StateNotifierProvider` que gestiona el estado (`EditAcademyState`) y la lógica de negocio (`EditAcademyNotifier`) para la edición de la academia. Se inicializa con `initialAcademy`.

#### Modelos de Datos:

*   `AcademyModel`: Modelo que encapsula toda la información de una academia.

#### Estado (State):

*   `EditAcademyState`: Representa los diferentes estados del proceso de edición (ej. `initial`, `loading`, `success`, `error`).

## Estructura del Módulo

```
lib/features/academies/
├── data/
│   └── models/
│       └── academy_model.dart
├── domain/ 
├── presentation/
│   ├── providers/
│   │   ├── edit_academy_provider.dart
│   │   └── state/
│   │       └── edit_academy_state.dart
│   ├── screens/
│   │   └── edit_academy_screen.dart
│   └── ui/ (Contenido específico no explorado aún, podría incluir widgets como _buildPreviewCard)
└── academies.md (documentación interna, actualmente vacía)
```

## Próximos Pasos de Documentación

*   Detallar la implementación de `EditAcademyNotifier` y cómo maneja la actualización de datos y la subida del logo.
*   Documentar la estructura y contenido de la carpeta `domain`.
*   Explorar y documentar los componentes dentro de `lib/features/academies/presentation/ui/`.
*   Aclarar el propósito de tener tanto `initialAcademy` como `academy` como parámetros en `EditAcademyScreen`. 