# Widgets Modulares de Pagos

Esta carpeta contiene widgets modulares reutilizables para la funcionalidad de pagos en la aplicación Arcinus.

## Estructura de Widgets

### 🏃‍♂️ `AthleteInfoCard`
**Archivo:** `athlete_info_card.dart`

Widget para mostrar la información completa del atleta seleccionado, incluyendo:
- Avatar y datos básicos
- Estado de suscripción
- Información del plan actual
- Indicador de días restantes hasta el próximo pago
- Botón para editar plan (opcional)

**Uso:**
```dart
AthleteInfoCard(
  clientUser: clientUser,
  academyUser: academyUser,
  onEditPlan: () => _showPlanEditDialog(),
)
```

### 👥 `AthleteSelector`
**Archivo:** `athlete_selector.dart`

Widget para seleccionar un atleta de la lista de atletas de la academia.

**Características:**
- Dropdown con búsqueda
- Avatares y información básica
- Estados de carga y error
- Validación de selección

**Uso:**
```dart
AthleteSelector(
  selectedAthleteId: selectedId,
  onAthleteChanged: (id) => setState(() => selectedId = id),
  athletesAsyncValue: ref.watch(athletesProvider),
)
```

### 💳 `PaymentForm`
**Archivo:** `payment_form.dart`

Formulario principal para capturar los datos del pago.

**Campos incluidos:**
- Monto y moneda
- Concepto del pago
- Fecha de pago
- Método de pago
- Notas adicionales

**Características:**
- Validación automática
- Campos de solo lectura según configuración
- Indicadores visuales para pagos parciales
- Formateo de números

**Uso:**
```dart
PaymentForm(
  formKey: _formKey,
  amountController: _amountController,
  conceptController: _conceptController,
  // ... otros parámetros
  onAmountChanged: (value) => _updatePartialPayment(value),
)
```

### ⚠️ `PaymentWarnings`
**Archivo:** `payment_warnings.dart`

Widget para mostrar advertencias y validaciones relacionadas con el pago.

**Tipos de advertencias:**
- Pago parcial con progreso visual
- Pagos parciales no permitidos
- Descuentos por pronto pago
- Pagos fuera del período de gracia

**Uso:**
```dart
PaymentWarnings(
  isPartialPayment: isPartial,
  totalPlanAmount: totalAmount,
  currentAmount: currentAmount,
  paymentDate: paymentDate,
  clientUser: clientUser,
  paymentConfig: config,
)
```

### ⚙️ `BillingConfigInfo`
**Archivo:** `billing_config_info.dart`

Widget para mostrar la configuración de facturación de la academia.

**Información mostrada:**
- Modo de facturación (prepago, mes en curso, mes vencido)
- Período de gracia
- Descuentos por pronto pago
- Recargos por pago tardío
- Configuraciones adicionales

**Uso:**
```dart
BillingConfigInfo(
  paymentConfig: paymentConfig,
)
```

### 📅 `ServiceDatesSection`
**Archivo:** `service_dates_section.dart`

Widget para mostrar y editar las fechas de servicio del pago.

**Características:**
- Fechas de inicio y fin del servicio
- Barra de progreso del período
- Duración total en días
- Edición de fecha de inicio (cuando está permitido)
- Advertencias para fechas retroactivas

**Uso:**
```dart
ServiceDatesSection(
  serviceStartDate: startDate,
  serviceEndDate: endDate,
  showStartDateSelector: canEditStartDate,
  onSelectServiceStartDate: () => _selectStartDate(),
)
```

### 📋 `PlanAssignmentForm`
**Archivo:** `plan_assignment_form.dart`

Formulario para asignar planes de suscripción a atletas.

**Características:**
- Selector de planes con detalles visuales
- Información detallada del plan seleccionado
- Selector de fecha de asignación
- Estados de carga y error
- Validación de formulario

**Uso:**
```dart
PlanAssignmentForm(
  formKey: _planFormKey,
  selectedPlanId: selectedPlanId,
  startDate: startDate,
  isSubmitting: isSubmitting,
  plansAsync: ref.watch(plansProvider),
  onPlanChanged: (id) => setState(() => selectedPlanId = id),
  onSavePlan: () => _savePlan(),
)
```

## Ventajas de la Modularización

### 🔧 **Mantenibilidad**
- Cada widget tiene una responsabilidad específica
- Fácil localización y corrección de errores
- Código más legible y organizado

### 🔄 **Reutilización**
- Widgets pueden ser utilizados en diferentes pantallas
- Consistencia visual en toda la aplicación
- Reducción de código duplicado

### 🧪 **Testabilidad**
- Cada widget puede ser probado de forma independiente
- Mocking más sencillo de dependencias
- Tests más enfocados y específicos

### 📈 **Escalabilidad**
- Fácil agregar nuevas funcionalidades
- Modificaciones aisladas sin afectar otros componentes
- Mejor separación de responsabilidades

## Uso en la Pantalla Principal

La pantalla modularizada `RegisterPaymentScreenModular` utiliza todos estos widgets:

```dart
// Importar todos los widgets
import 'package:arcinus/features/payments/presentation/ui/widgets/widgets.dart';

// Usar en el build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Información del atleta
        if (hasSelectedAthlete)
          AthleteInfoCard(
            clientUser: clientUser,
            academyUser: academyUser,
            onEditPlan: _showPlanEditDialog,
          ),
        
        // Selector de atleta
        if (!hasSelectedAthlete)
          AthleteSelector(
            selectedAthleteId: selectedId,
            onAthleteChanged: _onAthleteChanged,
            athletesAsyncValue: athletesAsync,
          ),
        
        // Formulario según el estado
        if (hasPlan)
          _buildPaymentSection()
        else
          _buildPlanAssignmentSection(),
      ],
    ),
  );
}
```

## Mejores Prácticas Implementadas

### 🎯 **Single Responsibility Principle**
Cada widget tiene una única responsabilidad bien definida.

### 🔒 **Encapsulación**
Los widgets encapsulan su lógica interna y exponen una API clara.

### 🔄 **Composición sobre Herencia**
Se favorece la composición de widgets pequeños sobre widgets monolíticos.

### 📝 **Documentación**
Cada widget está documentado con su propósito y uso.

### ✅ **Validación**
Validaciones apropiadas en cada nivel del formulario.

### 🎨 **Consistencia Visual**
Uso consistente de colores, espaciado y tipografía según el tema de la app.

## Archivos de Soporte

- **`widgets.dart`**: Archivo de índice que exporta todos los widgets
- **`verify_payment_status_button.dart`**: Widget existente para verificar estado de pagos

Esta modularización mejora significativamente la mantenibilidad y escalabilidad del código de pagos en Arcinus. 