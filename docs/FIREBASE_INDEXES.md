# Índices de Firebase Firestore

Este archivo documenta los índices de Firebase Firestore que pueden ser necesarios para la aplicación Arcinus.

## Índices Actuales Requeridos

### Índices Básicos (Automáticos)
Firebase crea automáticamente índices de campo único para todos los campos que se usan en consultas `where`, `orderBy`, etc.

### Índices Compuestos

#### 1. Períodos de Suscripción - Consulta Básica
**Colección**: `academies/{academyId}/subscription_assignments`
**Campos**:
- `athleteId` (Ascending)
- `status` (Ascending)

**Uso**: Consultas básicas de períodos por atleta y estado.

#### 2. Períodos de Suscripción - Con Fechas (Opcional)
**Colección**: `academies/{academyId}/subscription_assignments`
**Campos**:
- `athleteId` (Ascending)
- `status` (Ascending)
- `endDate` (Ascending)

**Uso**: Si necesitas consultas optimizadas con filtros de fecha.

#### 3. Períodos de Suscripción - Con Fecha de Inicio (Opcional)
**Colección**: `academies/{academyId}/subscription_assignments`
**Campos**:
- `athleteId` (Ascending)
- `status` (Ascending)
- `startDate` (Ascending)

**Uso**: Para consultas de períodos futuros optimizadas.

## Estado Actual de la Implementación

### ✅ Optimización Implementada
La aplicación actualmente usa **filtrado en memoria** para evitar la necesidad de índices complejos:

1. **Consulta Base**: Solo usa `athleteId` y `status`
2. **Filtrado**: Las comparaciones de fechas se realizan en el cliente
3. **Ordenamiento**: Se realiza en memoria después del filtrado

### ✅ Ventajas de la Implementación Actual
- ✅ No requiere índices complejos
- ✅ Flexible para cambios futuros
- ✅ Menor latencia en consultas simples
- ✅ Menos dependencias de configuración de Firebase

### ⚠️ Consideraciones de Rendimiento
- **Pequeña escala** (< 1000 períodos por atleta): Rendimiento excelente
- **Mediana escala** (1000-10000 períodos): Rendimiento bueno
- **Gran escala** (> 10000 períodos): Considerar índices compuestos

## Cuándo Crear Índices Compuestos

### Crear índices si experimentas:
1. **Latencia alta** en consultas de períodos (> 2 segundos)
2. **Alto volumen** de períodos por atleta (> 1000)
3. **Consultas frecuentes** con filtros complejos de fechas
4. **Errores de timeout** en consultas

### Comandos para Crear Índices

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Autenticar
firebase login

# Configurar proyecto
firebase use [project-id]

# Desplegar índices
firebase deploy --only firestore:indexes
```

### Archivo firestore.indexes.json
```json
{
  "indexes": [
    {
      "collectionGroup": "subscription_assignments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "athleteId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "subscription_assignments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "athleteId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "endDate", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## Monitoreo y Métricas

### Métricas a Vigilar
1. **Latencia de consultas**: Tiempo promedio de respuesta
2. **Uso de lectura**: Documentos leídos por consulta
3. **Errores de consulta**: Timeouts o fallos
4. **Memoria del cliente**: Uso de memoria para filtrado

### Herramientas de Monitoreo
- Firebase Console > Firestore > Usage
- App Logger para métricas personalizadas
- Performance Monitoring de Firebase

## Recomendaciones

### Para Desarrollo
✅ **Usar implementación actual** (filtrado en memoria)
- Más flexible para cambios
- Menos configuración
- Rendimiento adecuado para desarrollo

### Para Producción
🔍 **Evaluar según métricas reales**:
1. Medir rendimiento con datos reales
2. Crear índices solo si es necesario
3. Monitorear métricas continuamente

### Optimizaciones Futuras
1. **Caché en cliente** para consultas frecuentes
2. **Paginación** para grandes volúmenes de datos
3. **Consultas batch** para múltiples atletas
4. **Cloud Functions** para agregaciones complejas

## Contacto

Para preguntas sobre índices de Firebase o optimización de consultas, consultar:
- Documentación de Firebase: https://firebase.google.com/docs/firestore/query-data/indexing
- Equipo de desarrollo de Arcinus 