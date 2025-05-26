import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Widget para los botones de acción en la configuración de facturación
class BillingActionButtons extends StatelessWidget {
  /// Si está cargando
  final bool isLoading;

  /// Callback para vista previa
  final VoidCallback onPreviewInvoice;

  /// Callback para guardar configuración
  final VoidCallback onSaveBillingConfig;

  /// Constructor
  const BillingActionButtons({
    required this.isLoading,
    required this.onPreviewInvoice,
    required this.onSaveBillingConfig,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPreviewInvoice,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Vista Previa'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSaveBillingConfig,
            icon: const Icon(Icons.save),
            label: isLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.embers,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
} 