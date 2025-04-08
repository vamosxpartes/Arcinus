# Diagramas del Sistema de Entrenamientos

Este documento presenta diagramas para visualizar la estructura y flujos del Sistema de Entrenamientos de Arcinus.

## Diagrama de Flujo de Navegación

```mermaid
flowchart TD
    HomeScreen[Pantalla Principal] --> TrainingListScreen[Lista de Entrenamientos]
    
    TrainingListScreen --> TrainingForm[Formulario de Entrenamiento]
    TrainingListScreen --> TemplateForm[Formulario de Plantilla]
    TrainingListScreen --> SessionListScreen[Lista de Sesiones]
    
    TemplateForm --> TrainingForm
    TrainingForm --> TrainingListScreen
    
    SessionListScreen --> AttendanceScreen[Registro de Asistencia]
    SessionListScreen --> CompleteSessionScreen[Completar Sesión]
    
    AttendanceScreen --> SessionListScreen
    CompleteSessionScreen --> SessionListScreen
```

## Diagrama de Modelo de Datos

```mermaid
classDiagram
    class Training {
        String id
        String name
        String description
        String academyId
        String createdBy
        DateTime createdAt
        bool isTemplate
        List~String~ coachIds
        List~String~ groupIds
        DateTime? startDate
        DateTime? endDate
        TrainingRecurrence? recurrence
        List~int~? daysOfWeek
    }
    
    class Session {
        String id
        String trainingId
        DateTime date
        bool completed
        String? notes
        Map~String, bool~ attendance
    }
    
    class TrainingRecurrence {
        <<enumeration>>
        daily
        weekly
        monthly
    }
    
    Training "1" -- "many" Session : generates
    TrainingRecurrence -- Training : defines
```

## Diagrama de Componentes del Sistema

```mermaid
flowchart LR
    subgraph UI[UI Layer]
        TrainingListScreen[Training List Screen]
        TrainingFormScreen[Training Form Screen]
        SessionListScreen[Session List Screen]
        AttendanceScreen[Attendance Screen]
    end
    
    subgraph UX[UX Layer]
        TrainingService[Training Service]
        TrainingProviders[Training Providers]
        SessionProviders[Session Providers]
    end
    
    subgraph External[External Services]
        FirebaseFirestore[Firebase Firestore]
    end
    
    TrainingListScreen --> TrainingProviders
    TrainingFormScreen --> TrainingService
    SessionListScreen --> SessionProviders
    AttendanceScreen --> SessionProviders
    
    TrainingProviders --> TrainingService
    SessionProviders --> TrainingService
    
    TrainingService --> FirebaseFirestore
```

## Diagrama de Secuencia: Creación de Entrenamiento

```mermaid
sequenceDiagram
    actor Usuario
    participant UI as UI Layer
    participant Service as Training Service
    participant DB as Firebase Firestore
    
    Usuario->>UI: Abre formulario de entrenamiento
    UI->>Service: Carga datos iniciales (grupos, entrenadores)
    Service->>DB: Consulta datos
    DB-->>Service: Retorna datos
    Service-->>UI: Muestra formulario
    
    Usuario->>UI: Completa formulario y guarda
    UI->>Service: Envía datos de entrenamiento
    Service->>Service: Valida datos
    Service->>DB: Guarda entrenamiento
    DB-->>Service: Confirma guardado
    
    alt Entrenamiento recurrente
        Service->>Service: Genera sesiones
        Service->>DB: Guarda sesiones
        DB-->>Service: Confirma guardado de sesiones
    end
    
    Service-->>UI: Notifica éxito
    UI-->>Usuario: Muestra lista actualizada
```

## Diagrama de Secuencia: Registro de Asistencia

```mermaid
sequenceDiagram
    actor Entrenador
    participant SessionList as Lista de Sesiones
    participant Attendance as Pantalla de Asistencia
    participant Service as Training Service
    participant DB as Firebase Firestore
    
    Entrenador->>SessionList: Selecciona sesión
    Entrenador->>SessionList: Presiona "Registrar Asistencia"
    SessionList->>Attendance: Navega a pantalla de asistencia
    
    Attendance->>Service: Solicita lista de atletas
    Service->>DB: Consulta atletas por grupo
    DB-->>Service: Retorna atletas
    Service-->>Attendance: Muestra lista de atletas
    
    Entrenador->>Attendance: Marca/desmarca asistencia
    Entrenador->>Attendance: Presiona "Guardar"
    
    Attendance->>Service: Envía registro de asistencia
    Service->>DB: Actualiza asistencia en la sesión
    DB-->>Service: Confirma actualización
    
    Service-->>Attendance: Notifica éxito
    Attendance-->>SessionList: Regresa a lista de sesiones
    SessionList-->>Entrenador: Muestra indicador de asistencia registrada
```

## Diagrama de Estados: Sesión de Entrenamiento

```mermaid
stateDiagram-v2
    [*] --> Creada: Generación automática
    Creada --> AsistenciaRegistrada: Registrar asistencia
    AsistenciaRegistrada --> Completada: Completar sesión
    Creada --> Completada: Completar sin asistencia
    Completada --> [*]
``` 