import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra y gestiona los pagos de un atleta específico
class AthletePaymentsScreen extends ConsumerStatefulWidget {
  /// ID del atleta cuyos pagos se mostrarán
  final String athleteId;
  
  /// Nombre del atleta (opcional)
  final String? athleteName;

  /// Constructor
  const AthletePaymentsScreen({
    super.key, 
    required this.athleteId,
    this.athleteName,
  });

  @override
  ConsumerState<AthletePaymentsScreen> createState() => _AthletePaymentsScreenState();
}

class _AthletePaymentsScreenState extends ConsumerState<AthletePaymentsScreen> {
  @override
  void initState() {
    super.initState();
    // Actualizar el título en el OwnerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title = widget.athleteName != null 
          ? 'Pagos de ${widget.athleteName}'
          : 'Pagos del atleta';
      ref.read(currentScreenTitleProvider.notifier).state = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observar los pagos del atleta específico
    final paymentsAsyncValue = ref.watch(athletePaymentsNotifierProvider(widget.athleteId));
    
    return Scaffold(
      body: Column(
        children: [
          // Información del atleta
          _buildAthleteInfo(),
          
          // Botones de filtro y actualización
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de pagos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtrar pagos',
                      onPressed: () {
                        // Implementar lógica de filtrado
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar pagos',
                      onPressed: () => ref.invalidate(athletePaymentsNotifierProvider(widget.athleteId)),
                    ),
                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a registrar pago con el ID del atleta pre-seleccionado
          final currentAcademyId = ref.read(currentAcademyIdProvider);
          if (currentAcademyId != null && currentAcademyId.isNotEmpty) {
            context.push(
              '/owner/academy/$currentAcademyId/payments/register',
              extra: {'preselectedAthleteId': widget.athleteId},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo determinar la academia actual')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Pago'),
      ),
    );
  }

  Widget _buildAthleteInfo() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.athleteName ?? 'Atleta',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'ID: ${widget.athleteId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            _buildPaymentSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsAsyncValue = ref.watch(athletePaymentsNotifierProvider(widget.athleteId));
        
        return paymentsAsyncValue.when(
          data: (payments) {
            final totalPaid = payments.fold<double>(0, (sum, payment) => sum + payment.amount);
            final lastPayment = payments.isNotEmpty 
              ? payments.reduce((a, b) => a.paymentDate.isAfter(b.paymentDate) ? a : b) 
              : null;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Total Pagado', 
                  NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalPaid)
                ),
                _buildInfoColumn(
                  'Último Pago', 
                  lastPayment != null 
                    ? DateFormat('dd/MM/yyyy').format(lastPayment.paymentDate)
                    : 'Ninguno'
                ),
                _buildInfoColumn(
                  'Cantidad de Pagos', 
                  payments.length.toString()
                ),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Text('Error al cargar el resumen de pagos'),
        );
      },
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Text(
          'No hay pagos registrados para este atleta',
          style: TextStyle(fontSize: 16),
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

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
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
            _showPaymentOptions(context, payment);
          },
        ),
        onTap: () {
          // Navegar a detalles del pago
          final currentAcademyId = ref.read(currentAcademyIdProvider);
          if (currentAcademyId != null && payment.id != null) {
            context.push('/owner/academy/$currentAcademyId/payments/${payment.id}');
          }
        },
      ),
    );
  }

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

  void _showPaymentOptions(BuildContext context, PaymentModel payment) {
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
                  // Navegar a detalles del pago
                  final currentAcademyId = ref.read(currentAcademyIdProvider);
                  if (currentAcademyId != null && payment.id != null) {
                    context.push('/owner/academy/$currentAcademyId/payments/${payment.id}');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a editar pago
                  final currentAcademyId = ref.read(currentAcademyIdProvider);
                  if (currentAcademyId != null && payment.id != null) {
                    context.push('/owner/academy/$currentAcademyId/payments/${payment.id}/edit');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePayment(context, payment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePayment(BuildContext context, PaymentModel payment) {
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
                // Eliminar pago y actualizar la lista
                if (payment.id != null) {
                  ref.read(paymentRepositoryProvider).deletePayment(payment.id!).then((_) {
                    // Invalidar el provider para refrescar la lista
                    ref.invalidate(athletePaymentsNotifierProvider(widget.athleteId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pago eliminado correctamente')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar el pago: $error')),
                    );
                  });
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
            onPressed: () => ref.invalidate(athletePaymentsNotifierProvider(widget.athleteId)),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
} 