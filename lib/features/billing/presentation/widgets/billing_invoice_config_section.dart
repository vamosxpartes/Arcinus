import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget para la sección de configuración de facturación
class BillingInvoiceConfigSection extends StatelessWidget {
  /// Controladores de texto
  final TextEditingController prefixController;
  final TextEditingController consecutiveController;
  final TextEditingController resolutionController;

  /// Fecha de resolución
  final DateTime? resolutionDate;

  /// Callback para seleccionar fecha
  final VoidCallback onSelectResolutionDate;

  /// Constructor
  const BillingInvoiceConfigSection({
    required this.prefixController,
    required this.consecutiveController,
    required this.resolutionController,
    required this.resolutionDate,
    required this.onSelectResolutionDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Facturación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Prefijo y consecutivo
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: prefixController,
                    decoration: const InputDecoration(
                      labelText: 'Prefijo de Factura',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: FC',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el prefijo';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: consecutiveController,
                    decoration: const InputDecoration(
                      labelText: 'Consecutivo Actual',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 1001',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el consecutivo actual';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Resolución DIAN
            TextFormField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolución DIAN',
                border: OutlineInputBorder(),
                hintText: 'Ej: 18764000001234',
              ),
            ),
            const SizedBox(height: 16),
            
            // Fecha de resolución
            InkWell(
              onTap: onSelectResolutionDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Resolución DIAN',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resolutionDate != null
                          ? '${resolutionDate!.day}/${resolutionDate!.month}/${resolutionDate!.year}'
                          : 'Seleccionar fecha',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 