import 'package:flutter/material.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/athlete_periods_info_provider.dart';

/// Widget para mostrar advertencias y validaciones relacionadas con el pago
class PaymentWarnings extends StatelessWidget {
  final bool isPartialPayment;
  final double? totalPlanAmount;
  final double currentAmount;
  final String selectedCurrency;
  final DateTime paymentDate;
  final AcademyMemberUserModel? clientUser;
  final PaymentConfigModel? paymentConfig;
  final AthleteCompleteInfo? athleteInfo;

  const PaymentWarnings({
    super.key,
    required this.isPartialPayment,
    this.totalPlanAmount,
    required this.currentAmount,
    required this.selectedCurrency,
    required this.paymentDate,
    this.clientUser,
    this.paymentConfig,
    this.athleteInfo,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    
    // Advertencia de pago parcial
    if (isPartialPayment && totalPlanAmount != null) {
      widgets.add(_buildPartialPaymentWarning());
      
      // Advertencia si no se permiten pagos parciales
      if (paymentConfig != null && !paymentConfig!.allowPartialPayments) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(_buildPartialPaymentNotAllowedWarning());
      }
    }
    
    // Advertencia de descuento por pronto pago
    if (paymentConfig != null && paymentConfig!.earlyPaymentDiscount && _hasPaymentInfo()) {
      final discountWidget = _buildEarlyPaymentDiscountInfo();
      if (discountWidget != null) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 8));
        widgets.add(discountWidget);
      }
    }
    
    // Advertencia si la fecha de pago está fuera del período de gracia
    if (paymentConfig != null && _hasPaymentInfo() && _getNextPaymentDate() != null) {
      final gracePeriodWidget = _buildGracePeriodWarning();
      if (gracePeriodWidget != null) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 8));
        widgets.add(gracePeriodWidget);
      }
    }
    
    return Column(children: widgets);
  }

  /// Verifica si hay información de pago disponible
  bool _hasPaymentInfo() {
    return athleteInfo != null || clientUser != null;
  }

  /// Obtiene la próxima fecha de pago usando la nueva estructura o fallback
  DateTime? _getNextPaymentDate() {
    if (athleteInfo?.nextPaymentDate != null) {
      return athleteInfo!.nextPaymentDate;
    }
    
    // Fallback: En el nuevo sistema, esta información se calcula dinámicamente
    // por lo que si no tenemos AthleteCompleteInfo, no podemos determinarla
    return null;
  }

  Widget _buildPartialPaymentWarning() {
    final remainingAmount = totalPlanAmount! - currentAmount;
    final progressPercentage = currentAmount / totalPlanAmount!;
    
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Pago Parcial',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Barra de progreso del pago
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pagando:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '$currentAmount $selectedCurrency',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Restante:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '$remainingAmount $selectedCurrency',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total del plan: ${totalPlanAmount!} $selectedCurrency',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialPaymentNotAllowedWarning() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagos Parciales No Permitidos',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'La academia no permite pagos parciales según su configuración. Debes pagar el monto completo.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildEarlyPaymentDiscountInfo() {
    final nextPaymentDate = _getNextPaymentDate();
    
    if (nextPaymentDate == null) return null;
    
    final daysBeforePayment = nextPaymentDate.difference(paymentDate).inDays;
    
    if (daysBeforePayment >= paymentConfig!.earlyPaymentDays) {
      // Aplicar descuento
      final discountAmount = currentAmount * (paymentConfig!.earlyPaymentDiscountPercent / 100);
      final finalAmount = currentAmount - discountAmount;
      
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.discount, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Descuento por Pronto Pago',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${paymentConfig!.earlyPaymentDiscountPercent}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto original:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '$currentAmount $selectedCurrency',
                        style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Descuento:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '-$discountAmount $selectedCurrency',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a pagar:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$finalAmount $selectedCurrency',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pago realizado $daysBeforePayment días antes del vencimiento',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else if (daysBeforePayment > 0) {
      // Mostrar cuántos días faltan para el descuento
      final daysNeeded = paymentConfig!.earlyPaymentDays - daysBeforePayment;
      return Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descuento por Pronto Pago Disponible',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paga $daysNeeded días antes para obtener un ${paymentConfig!.earlyPaymentDiscountPercent}% de descuento',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return null;
  }

  Widget? _buildGracePeriodWarning() {
    final nextPaymentDate = _getNextPaymentDate();
    if (nextPaymentDate == null) return null;
    
    final gracePeriodEnd = nextPaymentDate.add(Duration(days: paymentConfig!.gracePeriodDays));
    
    if (paymentDate.isAfter(gracePeriodEnd)) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pago Fuera del Período de Gracia',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Este pago está fuera del período de gracia (${paymentConfig!.gracePeriodDays} días). Puede aplicar recargo por pago tardío.',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return null;
  }
} 