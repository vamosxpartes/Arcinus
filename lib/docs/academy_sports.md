# Módulo Academy Sports

## Descripción General

El módulo `academy_sports` se encarga de definir y gestionar las características y atributos específicos de los diferentes deportes que se pueden manejar dentro de una academia en la plataforma Arcinus. Este módulo no parece tener interfaces de usuario (pantallas) propias, sino que provee los modelos de datos y posiblemente la lógica de negocio para que otros módulos puedan configurar y utilizar información detallada de cada deporte.

## Modelos de Datos Principales

### 1. Características del Deporte (`sport_characteristics.dart`)

Nombre de la clase: `SportCharacteristics`

Este es el modelo central del módulo y define una estructura completa para almacenar todos los parámetros relevantes de un deporte. Utiliza `freezed` para la generación de código inmutable y `Hive` para el posible almacenamiento local de estas configuraciones.

#### Atributos Clave:

El modelo `SportCharacteristics` incluye, entre otros, los siguientes grupos de atributos:

*   **Características del Atleta:**
    *   `athleteStats` (List<String>): Lista de estadísticas relevantes para un atleta en ese deporte (ej: "Altura", "Velocidad Máxima").
    *   `statUnits` (Map<String, String>): Unidades para cada estadística (ej: {"Altura": "cm", "Velocidad Máxima": "km/h"}).
    *   `athleteSpecializations` (List<String>): Posibles especializaciones o roles técnicos dentro del deporte.
*   **Características del Equipo:**
    *   `positions` (List<String>): Nombres de las posiciones en el campo o juego.
    *   `formations` (Map<String, List<String>>): Definiciones de formaciones de equipo (ej: {"4-4-2": ["Defensa1", ..., "Delantero2"]}).
    *   `defaultPlayersPerTeam` (int): Número estándar de jugadores por equipo.
*   **Características de Entrenamiento:**
    *   `exerciseCategories` (List<String>): Categorías para clasificar ejercicios (ej: "Técnica", "Fuerza", "Resistencia").
    *   `predefinedExercises` (List<String>): Nombres o identificadores de ejercicios comunes.
    *   `equipmentNeeded` (List<String>): Tipos de equipamiento que pueden ser necesarios.
*   **Características de Partidos/Competencias:**
    *   `matchRules` (Map<String, dynamic>): Reglas específicas del juego (ej: {"duraciónPeriodo": 45, "unidadTiempo": "minutos"}).
    *   `scoreTypes` (List<String>): Diferentes maneras de anotar o puntuar.
    *   `foulTypes` (Map<String, dynamic>): Tipos de faltas o infracciones y sus posibles consecuencias o descripciones.
*   **Otros Parámetros Específicos:**
    *   `additionalParams` (Map<String, dynamic>): Un mapa flexible para cualquier otra característica relevante del deporte no cubierta por los campos anteriores.

#### Funcionalidad Adicional:

*   **Deserialización Segura (`fromJsonSafe`):** El modelo incluye un factory constructor `fromJsonSafe` que toma un `Map<String, dynamic>` (usualmente proveniente de un JSON) y lo convierte en una instancia de `SportCharacteristics`. Este método realiza una validación y sanitización de cada campo para asegurar la integridad de los datos, proveyendo valores por defecto si los datos de entrada son inválidos o están ausentes. Esto es crucial para la robustez del sistema al cargar configuraciones deportivas.
*   **Integración con Hive:** La anotación `@HiveType(typeId: 0)` y los `@HiveField` indican que este modelo está preparado para ser almacenado y recuperado de una base de datos local Hive, lo que podría usarse para caching o funcionamiento offline de las configuraciones deportivas.

## Estructura del Módulo (Parcial)

```
lib/features/academy_sports/
├── data/ // (Contenido específico no explorado aún)
├── models/
│   ├── sport_characteristics.dart
│   ├── sport_characteristics.freezed.dart // Auto-generado por freezed
│   └── sport_characteristics.g.dart     // Auto-generado por json_serializable/hive_generator
└── scripts/ // (Contenido específico no explorado aún)
```

## Próximos Pasos de Documentación

*   Explorar el contenido y propósito de las carpetas `data` y `scripts`.
*   Determinar cómo y dónde se crean/almacenan las instancias de `SportCharacteristics` (ej. ¿se cargan desde un servidor, se definen localmente, se gestionan a través de los `scripts`?).
*   Identificar si existen otros modelos o lógica de negocio relevante dentro de este módulo.
*   Clarificar cómo interactúa este módulo con otros módulos que podrían consumir estas definiciones deportivas (ej. módulos de gestión de atletas, planificación de entrenamientos, registro de partidos). 