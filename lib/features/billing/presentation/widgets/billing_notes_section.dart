import 'package:flutter/material.dart';

/// Widget para la sección de notas y términos en la configuración de facturación
class BillingNotesSection extends StatelessWidget {
  /// Controlador de texto para notas adicionales
  final TextEditingController additionalNotesController;

  /// Constructor
  const BillingNotesSection({
    required this.additionalNotesController,
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
              'Notas y Términos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: additionalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                border: OutlineInputBorder(),
                hintText: 'Ej: Esta factura se asimila en todos sus efectos a una letra de cambio según Art. 774 Código de Comercio',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
} 