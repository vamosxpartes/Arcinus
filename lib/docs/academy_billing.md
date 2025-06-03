# Módulo Academy Billing

## Descripción General

El módulo `academy_billing` gestiona toda la configuración relacionada con la facturación de una academia. Esto incluye los datos fiscales, la información para la generación de facturas, y la personalización de las mismas, como el logo y las notas adicionales.

Permite a los administradores de la academia configurar cómo se emitirán las facturas, asegurando el cumplimiento de los requisitos fiscales y la personalización de la información que aparece en ellas.

## Pantallas Principales

### 1. Configuración de Facturación (`billing_config_screen.dart`)

Nombre de la clase: `BillingConfigScreen`

Esta pantalla es la interfaz principal para que los administradores de una academia configuren todos los detalles relacionados con la facturación.

#### Funcionalidades Clave:

*   **Formulario de Datos de Facturación:**
    *   Permite ingresar y modificar la información fiscal y de contacto de la academia:
        *   Nombre Legal/Razón Social (`_legalNameController`)
        *   NIT (`_nitController`) y Dígito de Verificación (`_nitDvController`)
        *   Dirección (`_addressController`), Ciudad (`_cityController`), Departamento/Estado (`_stateController`)
        *   Teléfono (`_phoneController`), Email de Facturación (`_emailController`)
    *   Configuración específica de facturación (Colombia):
        *   Régimen Tributario (`_taxRegime`): Opciones como 'Ordinario', 'Simple'.
        *   Responsabilidad Fiscal (`_fiscalResponsibility`): Opciones como 'Responsable de IVA', 'No responsable de IVA', etc.
        *   Porcentaje de IVA por Defecto (`_defaultVAT`): Opciones como 19%, 5%, 0%.
        *   Prefijo de Factura (`_prefixController`)
        *   Consecutivo Actual (`_consecutiveController`)
        *   Resolución de Facturación (`_resolutionController`) y Fecha de Resolución (`_resolutionDate`)
*   **Carga de Logo:**
    *   Permite seleccionar un archivo de imagen (`_logoFile`) para el logo de la academia que aparecerá en las facturas.
    *   Valida la imagen del logo utilizando `ImageValidationMixin`.
    *   Muestra el logo actual (`_logoUrl`) si ya está configurado.
    *   Intenta usar el logo general de la academia como fallback si no hay un logo específico para facturación.
    *   Maneja URLs de logos inválidas o de ejemplo, marcándolas como `_hasInvalidLogo`.
*   **Notas Adicionales:**
    *   Campo para texto libre (`_additionalNotesController`) que se puede incluir en las facturas (ej. términos y condiciones).
*   **Carga de Configuración Existente (`_loadBillingConfig`):**
    *   Al iniciar la pantalla, intenta cargar la configuración de facturación previamente guardada para la academia, utilizando `billingConfigProvider`.
    *   Popula los campos del formulario con los datos cargados.
*   **Guardado de Configuración:**
    *   (Se asume una función `_saveBillingConfig` o similar, no visible en las primeras 200 líneas, que se activa al enviar el formulario `_formKey`).
    *   Esta función probablemente actualiza los datos mediante `billingConfigProvider` y sube el logo a Firebase Storage si se ha seleccionado uno nuevo.
*   **Generación y Compartir de Factura de Ejemplo (Funcionalidad Implícita por Imports):**
    *   Los imports de `InvoicePdfService` y `ShareService` sugieren que la pantalla podría tener una opción para generar una factura de ejemplo con la configuración actual y compartirla.
    *   El import de `InvoiceModel` refuerza esta idea.

#### Parámetros Requeridos:

*   `academyId` (String): El identificador de la academia para la cual se está configurando la facturación.

#### Lógica de Negocio y Comportamiento:

*   **Estado de Carga (`_isLoading`):** Muestra un indicador de carga mientras se obtienen o guardan los datos.
*   **Validación de Formularios (`_formKey`):** Utiliza un `GlobalKey<FormState>` para validar los campos del formulario antes de guardar.
*   **Valores Predeterminados:** Establece valores predeterminados para los menús desplegables (régimen tributario, responsabilidad fiscal, IVA) si no hay una configuración previa o si los valores guardados no son válidos.
*   **Manejo de Errores:** Muestra mensajes (ej. `ScaffoldMessenger`) en caso de errores al cargar o guardar la configuración.
*   **Logging:** Utiliza `AppLogger` para registrar eventos importantes, errores y advertencias durante el proceso de configuración.

#### Proveedores (Providers) Relevantes:

*   `billingConfigProvider`: Provider principal para obtener y actualizar `BillingConfigModel`.
*   `academyProvider`: Utilizado para obtener información general de la academia, como el logoURL de fallback.

#### Modelos de Datos:

*   `BillingConfigModel`: Modelo que encapsula toda la información de configuración de facturación.
*   `InvoiceModel`: Modelo que representa una factura (probablemente usado para la generación de ejemplos).

#### Servicios:

*   `InvoicePdfService`: Servicio para generar el PDF de las facturas.
*   `ShareService`: Servicio para compartir archivos (como el PDF de la factura).

#### Mixins:

*   `ImageValidationMixin`: Proporciona métodos para validar el archivo de imagen del logo.

## Estructura del Módulo

```
lib/features/academy_billing/
├── data/
│   └── models/
│       ├── billing_config_model.dart
│       └── invoice_model.dart
├── domain/ 
├── presentation/
│   ├── mixins/
│   │   └── image_validation_mixin.dart
│   ├── providers/
│   │   └── billing_config_provider.dart
│   ├── screens/
│   │   └── billing_config_screen.dart
│   └── widgets/  // (Contenido específico no explorado aún)
├── services/
│   ├── invoice_pdf_service.dart
│   └── share_service.dart
└── academy_billing.md (documentación interna)
```

## Próximos Pasos de Documentación

*   Detallar la funcionalidad de guardado (`_saveBillingConfig` o similar).
*   Describir el proceso de subida y gestión del logo con Firebase Storage.
*   Documentar los widgets específicos dentro de `lib/features/academy_billing/presentation/widgets/`.
*   Explorar y documentar las carpetas `domain` y `data` con mayor detalle.
*   Revisar el archivo `academy_billing.md` interno para información complementaria. 