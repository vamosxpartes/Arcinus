import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra la lista de pagos de la academia
class PaymentsScreen extends ConsumerWidget {
  /// Constructor
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ahora observamos el AsyncValue
    final paymentsAsyncValue = ref.watch(academyPaymentsNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros de búsqueda
            },
          ),
          // Añadir un botón para refrescar manualmente
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(academyPaymentsNotifierProvider),
           ),
        ],
      ),
      // Usamos .when para manejar los diferentes estados de AsyncValue
      body: paymentsAsyncValue.when(
        data: (payments) => _buildPaymentsList(context, payments, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(context, error, ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Actualizar la navegación a la pantalla de registro
          // context.push('/owner/payments/register'); // Asegúrate que la ruta es correcta
           context.push('/owner/payments/register'); // Usar la ruta completa correcta
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Pago'), // Texto más descriptivo
      ),
    );
  }

  // Renombrado de _buildBody a _buildPaymentsList
  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments, WidgetRef ref) {
    if (payments.isEmpty) {
      return const Center(
        child: Text(
          'No hay pagos registrados',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(context, payment, ref);
      },
    );
  }

  // Modificado _buildErrorWidget para aceptar Object (error) y llamar a refreshPayments
  Widget _buildErrorWidget(BuildContext context, Object error, WidgetRef ref) {
    // Convertir el Object a Failure si es posible
    final failure = error is Failure ? error : Failure.unexpectedError(error: error);
  
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            failure.maybeWhen(
              serverError: (message) => message,
              networkError: () => 'Error de red',
              authError: (code, message) => message,
              validationError: (message) => message,
              cacheError: (message) => message,
              unexpectedError: (err, _) => err?.toString() ?? 'Ocurrió un error inesperado al cargar los pagos',
              orElse: () => 'Ocurrió un error inesperado al cargar los pagos',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(academyPaymentsNotifierProvider),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment, WidgetRef ref) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(payment.paymentDate);
    final formattedAmount = NumberFormat.currency(
      symbol: _getCurrencySymbol(payment.currency),
      decimalDigits: 2,
    ).format(payment.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
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
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                const Text('Atleta:'),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    payment.athleteId, // TODO: Mostrar nombre del atleta
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showPaymentOptions(context, payment, ref);
          },
        ),
        onTap: () {
          // TODO: Navegar a la vista detallada del pago
        },
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, PaymentModel payment, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar a la vista detallada del pago
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar a la pantalla de edición de pago
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePayment(context, payment, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePayment(BuildContext context, PaymentModel payment, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar pago'),
          content: const Text('¿Estás seguro de que deseas eliminar este pago? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (payment.id != null) {
                  final notifier = ref.read(academyPaymentsNotifierProvider.notifier);
                  notifier.deletePayment(payment.id!);
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'MXN':
        return '\$';
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      default:
        return currencyCode;
    }
  }
} 