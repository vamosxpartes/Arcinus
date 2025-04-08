# Guía de Pruebas Manuales del Sistema de Entrenamientos

## Introducción

Esta guía proporciona instrucciones paso a paso para realizar pruebas manuales en el Sistema de Entrenamientos de Arcinus, con el objetivo de verificar que todas las funcionalidades operen correctamente.

## Requisitos Previos

- Dispositivo con la aplicación Arcinus instalada
- Cuenta con permisos de propietario o entrenador
- Academia configurada previamente
- Al menos un grupo y un entrenador creados en el sistema

## Flujo de Pruebas

### 1. Acceso al Sistema de Entrenamientos

1. Iniciar sesión en la aplicación con una cuenta de propietario o entrenador
2. En la pantalla principal, verificar la presencia del icono de entrenamientos en la barra de navegación
3. Hacer clic en el icono para acceder a la pantalla de entrenamientos
4. Verificar que se muestra la lista de entrenamientos con las pestañas "Activos" y "Plantillas"

### 2. Creación de un Entrenamiento

1. En la pantalla de lista de entrenamientos, hacer clic en el botón "+" en la esquina inferior derecha
2. Seleccionar "Nuevo Entrenamiento" en el menú emergente
3. Completar el formulario con la siguiente información:
   - Nombre: "Entrenamiento de Prueba"
   - Descripción: "Prueba del sistema de entrenamientos"
   - Seleccionar al menos un grupo
   - Seleccionar al menos un entrenador
   - Configurar la recurrencia como "Semanal"
   - Seleccionar al menos dos días de la semana
   - Establecer fecha de inicio como el día actual
   - Establecer fecha de fin como 30 días después de la fecha de inicio
4. Hacer clic en "Guardar"
5. Verificar que se redirige a la pantalla de lista de entrenamientos
6. Verificar que el nuevo entrenamiento aparece en la lista

### 3. Gestión de Sesiones

1. En la lista de entrenamientos, hacer clic en el entrenamiento recién creado
2. Verificar que se muestra la lista de sesiones generadas automáticamente
3. Verificar que las fechas de las sesiones corresponden a la recurrencia configurada
4. Verificar que la información del entrenamiento se muestra correctamente en la parte superior

### 4. Registro de Asistencia

1. En la lista de sesiones, seleccionar la primera sesión no completada
2. Hacer clic en el botón "Registrar Asistencia"
3. Verificar que se muestra la lista de atletas de los grupos seleccionados
4. Marcar la asistencia para algunos atletas (hacer clic en el checkbox)
5. Hacer clic en "Guardar"
6. Verificar que se redirige a la pantalla de lista de sesiones
7. Verificar que la asistencia se ha registrado correctamente (puede haber un indicador visual)

### 5. Completar una Sesión

1. En la lista de sesiones, seleccionar la sesión en la que se registró asistencia
2. Hacer clic en el botón "Completar Sesión"
3. Agregar una nota de sesión: "Sesión completada con éxito"
4. Hacer clic en "Completar"
5. Verificar que la sesión ahora aparece como completada en la lista
6. Verificar que ya no es posible registrar asistencia para esta sesión

### 6. Creación de una Plantilla

1. Volver a la pantalla de lista de entrenamientos
2. Hacer clic en el botón "+" en la esquina inferior derecha
3. Seleccionar "Nueva Plantilla" en el menú emergente
4. Completar el formulario con la siguiente información:
   - Nombre: "Plantilla de Prueba"
   - Descripción: "Prueba de creación de plantilla"
   - Seleccionar al menos un grupo
   - Seleccionar al menos un entrenador
5. Hacer clic en "Guardar"
6. Verificar que se redirige a la pantalla de lista de entrenamientos
7. Seleccionar la pestaña "Plantillas"
8. Verificar que la nueva plantilla aparece en la lista

### 7. Uso de una Plantilla

1. En la pestaña "Plantillas", hacer clic en la plantilla recién creada
2. En el diálogo que aparece, seleccionar "Usar como base"
3. Verificar que se abre el formulario con los datos de la plantilla precargados
4. Configurar la recurrencia como "Diaria"
5. Establecer fecha de inicio como el día actual
6. Establecer fecha de fin como 7 días después de la fecha de inicio
7. Hacer clic en "Guardar"
8. Verificar que se redirige a la pantalla de lista de entrenamientos
9. Verificar que el nuevo entrenamiento aparece en la lista
10. Hacer clic en el entrenamiento para ver las sesiones
11. Verificar que se han generado 7 sesiones (una por día)

### 8. Edición de un Entrenamiento

1. Volver a la pantalla de lista de entrenamientos
2. Mantener presionado sobre el primer entrenamiento creado
3. Seleccionar "Editar" en el menú contextual
4. Modificar el nombre a "Entrenamiento Modificado"
5. Hacer clic en "Guardar"
6. Verificar que el nombre del entrenamiento se ha actualizado en la lista

## Verificación de Casos Límite

### 1. Sin Grupos Disponibles

1. Crear un nuevo entrenamiento en una academia sin grupos
2. Verificar que se muestra un mensaje indicando que no hay grupos disponibles
3. Verificar que no es posible guardar el entrenamiento

### 2. Sin Entrenadores Disponibles

1. Crear un nuevo entrenamiento en una academia sin entrenadores
2. Verificar que se muestra un mensaje indicando que no hay entrenadores disponibles
3. Verificar que es posible guardar el entrenamiento sin entrenadores asignados

### 3. Fechas Inválidas

1. Intentar crear un entrenamiento con fecha de fin anterior a fecha de inicio
2. Verificar que se muestra un mensaje de error
3. Verificar que no es posible guardar el entrenamiento

## Registro de Resultados

Para cada prueba realizada, registrar:

- Si la funcionalidad opera como se esperaba
- Cualquier comportamiento inesperado o error encontrado
- Capturas de pantalla de los errores (si aplica)
- Sugerencias de mejora

## Finalización

Al completar todas las pruebas, compilar los resultados en un informe que incluya:

1. Resumen de pruebas realizadas
2. Lista de problemas encontrados
3. Sugerencias de mejora
4. Evaluación general del sistema

Este informe servirá como base para futuras mejoras del Sistema de Entrenamientos de Arcinus. 