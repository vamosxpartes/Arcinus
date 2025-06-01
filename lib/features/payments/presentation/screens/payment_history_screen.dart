import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

/// Pantalla que muestra el historial de pagos de un atleta específico
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  /// ID del atleta
  final String athleteId;
  
  /// ID de la academia
  final String academyId;
  
  /// Nombre del atleta (opcional, para mostrar en el título)
  final String? athleteName;

  const PaymentHistoryScreen({
    super.key,
    required this.athleteId,
    required this.academyId,
    this.athleteName,
  });

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  bool _titlePushed = false;

  @override
  void initState() {
    super.initState();
    
    // Actualizar el título del ManagerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_titlePushed) {
        final title = widget.athleteName != null 
          ? 'Historial de pagos - ${widget.athleteName}'
          : 'Historial de pagos';
        ref.read(titleManagerProvider.notifier).pushTitle(title);
        _titlePushed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsyncValue = ref.watch(
      athletePaymentsNotifierProvider(widget.athleteId),
    );
    final clientUserAsyncValue = ref.watch(clientUserProvider(widget.athleteId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _titlePushed) {
          // Restaurar el título anterior cuando se hace pop
          ref.read(titleManagerProvider.notifier).popTitle();
        }
      },
      child: Column(
        children: [
          // Información del atleta
          _buildAthleteInfoCard(context, ref, clientUserAsyncValue),
          
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

  /// Construye la tarjeta de información del atleta
  Widget _buildAthleteInfoCard(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<ClientUserModel?> clientUserAsyncValue
  ) {
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
                  radius: 30,
                  backgroundColor: AppTheme.bonfireRed,
                  child: Text(
                    widget.athleteName?.isNotEmpty == true
                      ? widget.athleteName![0].toUpperCase()
                      : 'A',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.athleteName ?? 'Atleta',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.athleteId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Información de suscripción
            const SizedBox(height: 16),
            clientUserAsyncValue.when(
              data: (clientUser) => _buildSubscriptionInfo(context, clientUser),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Text(
                'Error al cargar información de suscripción',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la información de suscripción del atleta
  Widget _buildSubscriptionInfo(BuildContext context, ClientUserModel? clientUser) {
    if (clientUser?.subscriptionPlan == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Text('Sin plan de suscripción asignado'),
          ],
        ),
      );
    }

    final plan = clientUser!.subscriptionPlan!;
    final status = clientUser.paymentStatus;
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case PaymentStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case PaymentStatus.overdue:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case PaymentStatus.inactive:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estado: ${status.displayName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Plan: ${plan.name}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'Monto: ${plan.amount} ${plan.currency}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (clientUser.nextPaymentDate != null)
            Text(
              'Próximo pago: ${DateFormat('dd/MM/yyyy').format(clientUser.nextPaymentDate!)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  /// Construye la lista de pagos
  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay pagos registrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los pagos aparecerán aquí una vez que se registren',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de pagos (${payments.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${_calculateTotalPayments(payments)} ${payments.isNotEmpty ? payments.first.currency : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.bonfireRed,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentCard(context, payment, index == 0);
            },
          ),
        ),
      ],
    );
  }

  /// Construye una tarjeta de pago individual
  Widget _buildPaymentCard(BuildContext context, PaymentModel payment, bool isLatest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: isLatest ? 4 : 2,
      child: Container(
        decoration: isLatest
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.bonfireRed, width: 2),
            )
          : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del pago
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.concept ?? 'Pago de suscripción',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${payment.amount} ${payment.currency}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bonfireRed,
                        ),
                      ),
                      if (payment.isPartialPayment)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pago parcial',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // Detalles adicionales
              if (payment.notes?.isNotEmpty == true ||
                  payment.periodStartDate != null ||
                  payment.periodEndDate != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
              ],
              
              // Período cubierto
              if (payment.periodStartDate != null && payment.periodEndDate != null)
                _buildDetailRow(
                  context,
                  'Período cubierto',
                  '${DateFormat('dd/MM/yyyy').format(payment.periodStartDate!)} - ${DateFormat('dd/MM/yyyy').format(payment.periodEndDate!)}',
                  Icons.date_range,
                ),
              
              // Notas
              if (payment.notes?.isNotEmpty == true)
                _buildDetailRow(
                  context,
                  'Notas',
                  payment.notes!,
                  Icons.note,
                ),
              
              // Si es el último pago, mostrar badge
              if (isLatest)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bonfireRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Último pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una fila de detalle
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Calcula el total de todos los pagos
  double _calculateTotalPayments(List<PaymentModel> payments) {
    return payments.fold(0.0, (total, payment) => total + payment.amount);
  }

  /// Construye el widget de error
  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los pagos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Reintenta cargar los datos
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}