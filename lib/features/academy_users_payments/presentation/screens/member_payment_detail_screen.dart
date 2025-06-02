import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_model.dart';
import 'package:arcinus/features/academy_users_payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra los detalles de pagos específicamente para clientes (atletas y padres)
class MemberPaymentDetailScreen extends ConsumerStatefulWidget {
  /// ID del usuario cliente cuyos pagos se mostrarán
  final String userId;

  /// Nombre del usuario (opcional)
  final String? userName;

  /// Constructor
  const MemberPaymentDetailScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  ConsumerState<MemberPaymentDetailScreen> createState() =>
      _ClientPaymentDetailScreenState();
}

class _ClientPaymentDetailScreenState
    extends ConsumerState<MemberPaymentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentsAsyncValue = ref.watch(
      athletePaymentsNotifierProvider(widget.userId),
    );

    return Scaffold(
      body: Column(
        children: [
          // Información de suscripción y estado
          _buildSubscriptionCard(),

          // Botones de filtro y actualización
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mi Historial de Pagos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar pagos',
                  onPressed:
                      () => ref.invalidate(
                        athletePaymentsNotifierProvider(widget.userId),
                      ),
                ),
              ],
            ),
          ),

          // Lista de pagos
          Expanded(
            child: paymentsAsyncValue.when(
              data: (payments) => _buildPaymentsList(context, payments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorWidget(context, error),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta con información de suscripción actual
  Widget _buildSubscriptionCard() {
    // Datos simulados para demostración
    final planName = 'Plan Mensual';
    final planPrice = '\$50.000 / mes';
    final nextPaymentDate = DateTime.now().add(const Duration(days: 15));
    final daysLeft = 15;
    final isActive = true;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  // ignore: dead_code
                  backgroundColor:
                      Colors.green.withAlpha(60),
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      // ignore: dead_code
                      isActive ? 'Estado: Activo' : 'Estado: Pendiente de pago',
                      style: TextStyle(
                        // ignore: dead_code
                        color: isActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Información de Suscripción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Plan Actual:', planName),
            _buildInfoRow('Precio:', planPrice),
            _buildInfoRow(
              'Próximo Pago:',
              DateFormat('dd/MM/yyyy').format(nextPaymentDate),
            ),
            _buildInfoRow('Días Restantes:', '$daysLeft días'),

            // Botón de acción según estado
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Ver Opciones de Pago'),
                onPressed: () {
                  // Implementar navegación a opciones de pago
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Opciones de pago'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construir fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Lista de pagos realizados
  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No tienes pagos registrados', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Tus pagos aparecerán aquí cuando los realices',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(context, payment);
      },
    );
  }

  // Tarjeta individual de pago
  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(payment.paymentDate);
    final formattedAmount = NumberFormat.currency(
      symbol: _getCurrencySymbol(payment.currency),
      decimalDigits: 2,
    ).format(payment.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withAlpha(60),
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                payment.concept ?? 'Pago',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              formattedAmount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('Fecha: $formattedDate'),
              ],
            ),
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.note, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Notas: ${payment.notes}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () {
          // Mostrar detalles completos del pago
          _showPaymentDetails(context, payment);
        },
      ),
    );
  }

  // Mostrar diálogo con detalles completos del pago
  void _showPaymentDetails(BuildContext context, PaymentModel payment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Detalles del Pago'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Concepto', payment.concept ?? 'Pago'),
                  _buildDetailRow(
                    'Monto',
                    NumberFormat.currency(
                      symbol: _getCurrencySymbol(payment.currency),
                      decimalDigits: 2,
                    ).format(payment.amount),
                  ),
                  _buildDetailRow(
                    'Fecha',
                    DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                  ),
                  _buildDetailRow('Método', 'No especificado'),
                  if (payment.notes != null && payment.notes!.isNotEmpty)
                    _buildDetailRow('Notas', payment.notes!),
                  if (payment.receiptUrl != null &&
                      payment.receiptUrl!.isNotEmpty)
                    _buildDetailRow('Comprobante', 'Disponible'),
                ],
              ),
            ),
            actions: [
              if (payment.receiptUrl != null && payment.receiptUrl!.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Ver comprobante'),
                      ),
                    );
                  },
                  child: const Text('Ver Comprobante'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // Construir fila de detalle para el diálogo
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Obtener símbolo de moneda según el código
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'COP':
        return 'COP';
      default:
        return currencyCode;
    }
  }

  // Widget de error
  Widget _buildErrorWidget(BuildContext context, Object error) {
    final failure =
        error is Failure ? error : Failure.unexpectedError(error: error);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            failure.maybeWhen(
              serverError: (message) => message,
              networkError: () => 'Error de red',
              authError: (code, message) => message,
              validationError: (message) => message,
              cacheError: (message) => message,
              unexpectedError:
                  (err, _) =>
                      err?.toString() ??
                      'Ocurrió un error inesperado al cargar los pagos',
              orElse: () => 'Ocurrió un error inesperado al cargar los pagos',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => ref.invalidate(
                  athletePaymentsNotifierProvider(widget.userId),
                ),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}
