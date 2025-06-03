# Módulo Academy Users Payments

## Descripción General

El módulo `academy_users_payments` se encarga de toda la gestión de pagos relacionados con los usuarios de una academia. Esto incluye el registro de nuevos pagos, la visualización del historial de pagos, y la configuración de métodos o pasarelas de pago.

## Pantallas Principales

### 1. Listado de Pagos de la Academia (`payments_screen.dart`)

Nombre de la clase: `PaymentsScreen`

Esta pantalla muestra una lista de todos los pagos registrados para la academia activa. Permite a los administradores tener una visión general de las transacciones.

#### Funcionalidades Clave:

*   **Visualización de Pagos:** Muestra una lista de pagos (`_buildPaymentsList`) utilizando tarjetas individuales (`_buildPaymentCard`) para cada transacción.
*   **Información por Pago:** Cada tarjeta muestra detalles como el concepto del pago, el monto (formateado con símbolo de moneda), la fecha, y el atleta asociado (si aplica).
*   **Actualización de Datos:**
    *   Botón para actualizar manualmente la lista de pagos, invalidando `academyPaymentsNotifierProvider`.
    *   Manejo de estados de carga (`CircularProgressIndicator`) y error (`_buildErrorWidget`).
*   **Filtrado (Placeholder):** Incluye un botón para filtrar pagos, aunque la lógica específica de filtrado aún no está implementada en el fragmento analizado.
*   **Navegación para Registrar Pago:** Un `FloatingActionButton` permite navegar a la pantalla de registro de nuevos pagos (`context.push('/owner/academy/:id/payments/register')`).
*   **Gestión del Título de la Pantalla:** Actualiza el título de la pantalla a "Pagos" usando `currentScreenTitleProvider`.

#### Proveedores (Providers) Relevantes (según imports y uso):

*   `academyPaymentsNotifierProvider`: Provider principal para obtener y gestionar la lista de pagos de la academia.
*   `currentAcademyProvider`: Para obtener el ID de la academia actual y construir las rutas de navegación.
*   `currentScreenTitleProvider`: Para actualizar el título de la pantalla en el shell principal.

#### Interacciones y Lógica Adicional:

*   Formatea fechas (`DateFormat`) y montos de moneda (`NumberFormat`).
*   Determina el símbolo de la moneda (`_getCurrencySymbol` - no visible en el fragmento, pero inferido).

## Estructura del Módulo (Parcial)

```
lib/features/academy_users_payments/
├── data/
│   └── models/
│       └── payment_model.dart // Inferido por los imports
├── domain/
├── presentation/
│   ├── providers/
│   │   └── payment_providers.dart // Contiene academyPaymentsNotifierProvider
│   ├── screens/
│   │   ├── payments_screen.dart
│   │   ├── register_payment_screen.dart // Destino de navegación
│   │   ├── payment_detail_screen.dart
│   │   ├── member_payment_detail_screen.dart
│   │   ├── manager_payment_detail_screen.dart
│   │   └── payment_config_screen.dart
│   └── ui/ // (Contenido específico no explorado aún)
├── services/
│   └── payment_status_service.dart // Existente en la raíz del módulo
├── payment_status.dart // Existente en la raíz del módulo
└── payment.md (documentación interna)
```

## Próximos Pasos de Documentación

*   Documentar las otras pantallas identificadas en `lib/features/academy_users_payments/presentation/screens/`:
    *   `register_payment_screen.dart`
    *   `payment_config_screen.dart`
    *   `payment_detail_screen.dart`
    *   `member_payment_detail_screen.dart`
    *   `manager_payment_detail_screen.dart`
*   Detallar la funcionalidad de los `providers` clave, especialmente `academyPaymentsNotifierProvider`.
*   Describir los servicios como `payment_status_service.dart`.
*   Explorar y documentar las carpetas `domain`, `data` (incluyendo `PaymentModel`), y `ui`.
*   Revisar el archivo Markdown interno (`payment.md`) para información complementaria. 