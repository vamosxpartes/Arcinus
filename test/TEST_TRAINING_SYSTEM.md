# Pruebas del Sistema de Entrenamientos y Sesiones de Arcinus

Este documento provee un plan detallado de pruebas para validar el funcionamiento correcto del Sistema de Entrenamientos y Sesiones en Arcinus.

## 1. Pruebas de Navegación

### 1.1 Acceso al Sistema de Entrenamientos
- [ ] Verificar que se muestra el icono de entrenamientos en la barra de navegación
- [ ] Al hacer clic en el icono, navegar a la pantalla de lista de entrenamientos
- [ ] Verificar que la pantalla muestra correctamente las pestañas "Activos" y "Plantillas"

### 1.2 Navegación entre Pantallas
- [ ] Verificar navegación desde lista de entrenamientos a creación de entrenamiento
- [ ] Verificar navegación desde lista de entrenamientos a creación de plantilla
- [ ] Verificar navegación desde entrenamiento a lista de sesiones
- [ ] Verificar navegación desde sesión a registro de asistencia
- [ ] Verificar que al completar una acción se regresa a la pantalla anterior

## 2. Pruebas de Creación de Entrenamientos

### 2.1 Creación de Entrenamiento Normal
- [ ] Verificar que se puede crear un entrenamiento con datos básicos (nombre, descripción)
- [ ] Verificar asignación de grupos al entrenamiento
- [ ] Verificar asignación de entrenadores al entrenamiento
- [ ] Verificar configuración de recurrencia (diaria, semanal, mensual)
- [ ] Verificar selección de fechas de inicio y fin
- [ ] Verificar que al guardar se crea correctamente en Firebase

### 2.2 Creación de Plantilla
- [ ] Verificar que se puede crear una plantilla con datos básicos
- [ ] Verificar que la plantilla aparece en la pestaña "Plantillas"
- [ ] Verificar que la plantilla no genera sesiones automáticamente

## 3. Pruebas de Gestión de Sesiones

### 3.1 Generación de Sesiones
- [ ] Verificar que un entrenamiento recurrente genera sesiones correctamente
- [ ] Verificar que las sesiones generadas tienen la información correcta del entrenamiento
- [ ] Verificar que las fechas de las sesiones siguen el patrón de recurrencia
- [ ] Verificar límites: generación para un rango amplio de fechas

### 3.2 Visualización de Sesiones
- [ ] Verificar que la lista de sesiones muestra información correcta (fecha, nombre)
- [ ] Verificar que se distinguen sesiones completadas y pendientes
- [ ] Verificar que se muestra correctamente información de grupos y entrenadores

## 4. Pruebas de Registro de Asistencia

### 4.1 Registro de Asistencia
- [ ] Verificar acceso a la pantalla de registro de asistencia
- [ ] Verificar que se muestran todos los atletas asignados
- [ ] Verificar que se puede marcar/desmarcar asistencia
- [ ] Verificar que los cambios se guardan correctamente en Firebase

### 4.2 Completar Sesión
- [ ] Verificar que se puede marcar una sesión como completada
- [ ] Verificar que se pueden agregar notas al completar
- [ ] Verificar que el estado de completado se refleja en la lista de sesiones

## 5. Pruebas de Edición y Eliminación

### 5.1 Edición
- [ ] Verificar que se puede editar un entrenamiento existente
- [ ] Verificar que los cambios se reflejan correctamente
- [ ] Verificar edición de entrenamientos recurrentes

### 5.2 Eliminación
- [ ] Verificar que se puede eliminar un entrenamiento
- [ ] Verificar que se eliminan correctamente las sesiones asociadas
- [ ] Verificar confirmación antes de eliminar

## 6. Pruebas de Casos Límite

### 6.1 Manejo de Datos Vacíos
- [ ] Verificar comportamiento cuando no hay grupos disponibles
- [ ] Verificar comportamiento cuando no hay entrenadores disponibles
- [ ] Verificar comportamiento cuando no hay sesiones generadas

### 6.2 Manejo de Errores
- [ ] Verificar manejo de errores de conexión
- [ ] Verificar validación de formularios
- [ ] Verificar manejo de datos inconsistentes

## Instrucciones para la Ejecución de Pruebas

1. Iniciar sesión con una cuenta de propietario o entrenador
2. Navegar a la sección de entrenamientos
3. Seguir los pasos detallados para cada prueba
4. Documentar cualquier comportamiento inesperado o error
5. Marcar cada prueba como completada cuando se verifique su correcto funcionamiento

## Registro de Resultados

Fecha de prueba: ________________

Versión de la aplicación: ________________

Dispositivo utilizado: ________________

Tester: ________________

Resultado general: ________________

Notas adicionales: ________________ 