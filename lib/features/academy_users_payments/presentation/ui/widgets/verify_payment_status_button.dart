import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_payments/presentation/providers/payment_status_verification_provider.dart';

/// Botón que permite a los administradores ejecutar manualmente
/// la verificación de estados de pago de los usuarios
class VerifyPaymentStatusButton extends ConsumerWidget {
  /// Constructor
  const VerifyPaymentStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationState = ref.watch(paymentStatusVerificationProvider);
    
    return verificationState.when(
      data: (_) => _buildButton(context, ref, false),
      loading: () => _buildButton(context, ref, true),
      error: (error, stack) => _buildErrorButton(context, ref, error),
    );
  }
  
  Widget _buildButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return ElevatedButton.icon(
      onPressed: isLoading 
          ? null 
          : () => _verifyPaymentStatus(ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.embers,
        foregroundColor: AppTheme.magnoliaWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: isLoading 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.magnoliaWhite,
              ),
            )
          : const Icon(Icons.refresh, size: 20),
      label: Text(isLoading ? 'Verificando...' : 'Verificar pagos'),
    );
  }
  
  Widget _buildErrorButton(BuildContext context, WidgetRef ref, Object error) {
    return ElevatedButton.icon(
      onPressed: () => _verifyPaymentStatus(ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: AppTheme.magnoliaWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: const Icon(Icons.error_outline, size: 20),
      label: const Text('Error - Reintentar'),
    );
  }
  
  Future<void> _verifyPaymentStatus(WidgetRef ref) async {
    await ref.read(paymentStatusVerificationProvider.notifier).verifyNow();
  }
} 