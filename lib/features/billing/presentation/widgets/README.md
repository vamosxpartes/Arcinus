# Widgets de Configuración de Facturación

Esta carpeta contiene los widgets modulares para la pantalla de configuración de facturación, organizados siguiendo las mejores prácticas de Flutter y arquitectura limpia.

## Estructura de Widgets

### 🖼️ BillingLogoSection
**Archivo:** `billing_logo_section.dart`

Widget responsable de la gestión del logo para facturas:
- Subida de imágenes a Firebase Storage
- Validación de URLs de imágenes
- Manejo de estados de carga
- Eliminación de logos existentes
- Detección y manejo de logos inválidos

**Características:**
- Integración completa con Firebase Storage
- Validación automática de URLs
- Manejo de errores robusto
- UI responsiva con indicadores de carga

### 📋 BillingFiscalDataSection
**Archivo:** `billing_fiscal_data_section.dart`

Widget para la captura de datos fiscales de la empresa:
- Información legal (razón social, NIT, DV)
- Régimen tributario y responsabilidad fiscal
- Datos de contacto (dirección, teléfono, email)
- Configuración de IVA predeterminado

**Validaciones incluidas:**
- Formato de NIT y dígito verificador
- Validación de email
- Campos obligatorios
- Dropdowns con opciones predefinidas

### ⚙️ BillingInvoiceConfigSection
**Archivo:** `billing_invoice_config_section.dart`

Widget para configuración específica de facturación:
- Prefijo y consecutivo de facturas
- Resolución DIAN
- Fecha de resolución
- Selector de fechas integrado

**Funcionalidades:**
- Validación de formatos numéricos
- Selector de fechas nativo
- Campos con hints informativos

### 📝 BillingNotesSection
**Archivo:** `billing_notes_section.dart`

Widget simple para notas adicionales:
- Campo de texto multilínea
- Términos y condiciones personalizables
- Texto de ayuda con ejemplos

### 🎯 BillingActionButtons
**Archivo:** `billing_action_buttons.dart`

Widget para botones de acción principales:
- Botón de vista previa de factura
- Botón de guardar configuración
- Estados de carga integrados
- Diseño responsivo

## Mixin de Utilidades

### 🔍 ImageValidationMixin
**Archivo:** `../mixins/image_validation_mixin.dart`

Mixin reutilizable para validación de URLs de imágenes:
- Validación de esquemas HTTP/HTTPS
- Detección de URLs de ejemplo/placeholder
- Verificación de extensiones de imagen
- Soporte específico para Firebase Storage

## Arquitectura y Beneficios

### ✅ Ventajas de la Modularización

1. **Separación de Responsabilidades**
   - Cada widget tiene una responsabilidad específica
   - Lógica de negocio separada de la presentación
   - Fácil mantenimiento y testing

2. **Reutilización**
   - Widgets pueden ser reutilizados en otras pantallas
   - Mixins compartidos entre componentes
   - Código DRY (Don't Repeat Yourself)

3. **Testabilidad**
   - Widgets independientes fáciles de testear
   - Mocks y stubs más simples
   - Tests unitarios más enfocados

4. **Escalabilidad**
   - Fácil agregar nuevas funcionalidades
   - Modificaciones aisladas sin afectar otros componentes
   - Estructura clara para nuevos desarrolladores

### 🏗️ Patrón de Comunicación

Los widgets utilizan callbacks para comunicarse con el widget padre:
- `onLogoUpdated`: Actualiza estado del logo
- `onLoadingChanged`: Maneja estados de carga
- `onTaxRegimeChanged`: Cambios en dropdowns
- `onSelectResolutionDate`: Selección de fechas

### 📦 Archivo Barrel

El archivo `widgets.dart` actúa como barrel file, exportando todos los widgets para facilitar las importaciones:

```dart
// Importación simplificada
import 'package:arcinus/features/billing/presentation/widgets/widgets.dart';
```

## Uso en la Pantalla Principal

La pantalla `BillingConfigScreen` ahora es mucho más limpia y enfocada en:
- Gestión del estado global
- Coordinación entre widgets
- Lógica de negocio de alto nivel
- Navegación y persistencia

## Mejores Prácticas Implementadas

1. **Widget Composition**: Widgets pequeños y enfocados
2. **Immutable Widgets**: Uso de `const` constructors donde es posible
3. **Proper State Management**: Estado local vs estado compartido
4. **Error Handling**: Manejo robusto de errores en cada componente
5. **Accessibility**: Widgets accesibles por defecto
6. **Performance**: Optimizaciones de renderizado
7. **Documentation**: Documentación clara en cada widget

## Próximos Pasos

- [ ] Agregar tests unitarios para cada widget
- [ ] Implementar tests de integración
- [ ] Agregar soporte para temas personalizados
- [ ] Implementar animaciones de transición
- [ ] Agregar soporte para localización 