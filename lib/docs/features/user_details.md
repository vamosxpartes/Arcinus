# Pantalla de Detalles de Usuario

## Propósito
Proporcionar una vista detallada de la información de cada usuario, permitiendo a los administradores visualizar sus datos y realizar acciones como edición o eliminación.

## Estructura
La pantalla de detalles está diseñada para ser genérica y adaptarse a cualquier tipo de usuario (Manager, Coach, Athlete, Parent, Owner), mostrando la información relevante según su rol.

## Ubicación
`lib/features/app/users/user/screens/user_details_screen.dart`

## Componentes Principales
- **Encabezado**: Muestra la foto de perfil y el nombre del usuario.
- **Información General**: Muestra datos básicos como email, rol y academia a la que pertenece.
- **Sección de Acciones**: Botones para editar o eliminar el usuario.

## Navegación
- Se accede a esta pantalla al hacer tap en una card de usuario en cualquier tab de la pantalla de gestión de usuarios.
- Desde aquí se puede navegar a los formularios de edición específicos para cada rol.

## Funcionalidades
1. **Visualización de datos**: Muestra la información del usuario de forma organizada.
2. **Edición**: Navega al formulario de edición correspondiente al tipo de usuario.
3. **Eliminación**: Permite eliminar el usuario con una confirmación previa.

## Interacciones con servicios
- Utiliza `UserService` para eliminar usuarios.
- Se conecta con los formularios de edición específicos para cada tipo de usuario.

## Consideraciones técnicas
- La pantalla es un `ConsumerWidget` que utiliza Riverpod para gestión de estado.
- Utiliza el patrón de navegación con retorno de resultado para actualizar las listas de usuarios cuando se realizan cambios.
- Al eliminar un usuario, se encarga de limpiar las referencias asociadas en otras entidades.

## Flujo de eliminación de usuario
1. Usuario hace tap en el botón de eliminar.
2. Se muestra un diálogo de confirmación.
3. Si confirma, se muestra un indicador de carga.
4. Se llama a `UserService.deleteUser()` con el ID y rol del usuario.
5. El servicio verifica si el usuario existe en Firestore:
   - Si existe: elimina el usuario y limpia sus referencias.
   - Si no existe: continúa con la limpieza de datos locales sin lanzar error.
6. Se maneja adecuadamente el cierre del diálogo de carga incluso en casos de error.
7. Se regresa a la pantalla anterior con un valor `true` para indicar que se eliminó y refrescar la lista.

## Manejo de errores
- Implementa una gestión robusta de errores durante la eliminación del usuario.
- Utiliza técnicas para almacenar referencias del contexto antes de operaciones asíncronas.
- Asegura que los diálogos de carga se cierren correctamente incluso cuando ocurren errores.
- Maneja el caso cuando el contexto ya no está montado después de una eliminación exitosa.
- Garantiza que el proceso de eliminación se complete incluso si la UI no puede actualizarse.
- Muestra mensajes apropiados al usuario según el resultado de la operación.

## Registro de cambios
- **v1.0.0**: Implementación inicial de la pantalla de detalles de usuario.
- **v1.0.1**: Añadidos botones de acción con estilos mejorados.
- **v1.0.2**: Mejorado el manejo de errores durante la eliminación de usuarios.
- **v1.0.3**: Implementada tolerancia a errores cuando el usuario no existe en Firestore.
- **v1.0.4**: Mejorado el manejo del contexto después de operaciones asíncronas.

## Próximas mejoras
- Añadir información adicional específica para cada tipo de usuario.
- Implementar historial de actividad.
- Añadir acciones específicas según el rol (ej: ver rendimiento para atletas). 