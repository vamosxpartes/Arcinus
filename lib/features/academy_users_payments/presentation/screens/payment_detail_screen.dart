import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_model.dart';
import 'package:arcinus/features/academy_users_payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/academy_users_payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra los detalles de pagos con adaptación según el rol del usuario
class PaymentDetailScreen extends ConsumerStatefulWidget {
  /// ID del usuario cuyos pagos se mostrarán (atleta o padre)
  final String userId;

  /// Nombre del usuario (opcional)
  final String? userName;

  /// Rol del usuario que visualiza la pantalla (para adaptar la UI)
  final AppRole viewerRole;

  /// Constructor
  const PaymentDetailScreen({
    super.key,
    required this.userId,
    this.userName,
    required this.viewerRole,
  });

  @override
  ConsumerState<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Actualizar el título en el Shell (según corresponda al rol)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title =
          widget.userName != null
              ? 'Pagos de ${widget.userName}'
              : 'Detalle de pagos';

      // Solo actualizar el título si estamos en el OwnerShell
      if (widget.viewerRole == AppRole.propietario ||
          widget.viewerRole == AppRole.colaborador) {
        ref.read(currentScreenTitleProvider.notifier).state = title;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsyncValue = ref.watch(
      athletePaymentsNotifierProvider(widget.userId),
    );
    final bool isManagerView =
        widget.viewerRole == AppRole.propietario ||
        widget.viewerRole == AppRole.colaborador;

    return Scaffold(
      body: Column(
        children: [
          // Información del usuario (atleta/padre)
          _buildUserInfo(isManagerView),

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
                  'Historial de pagos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (isManagerView) // Solo mostrar filtro para managers
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
                      onPressed:
                          () => ref.invalidate(
                            athletePaymentsNotifierProvider(widget.userId),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de pagos
          Expanded(
            child: paymentsAsyncValue.when(
              data:
                  (payments) =>
                      _buildPaymentsList(context, payments, isManagerView),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorWidget(context, error),
            ),
          ),
        ],
      ),
      floatingActionButton:
          isManagerView
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Solo los managers pueden registrar nuevos pagos
                  final currentAcademy = ref.read(currentAcademyProvider);
                  if (currentAcademy != null &&
                      currentAcademy.id != null &&
                      currentAcademy.id!.isNotEmpty) {
                    context.push(
                      '/owner/academy/${currentAcademy.id}/payments/register',
                      extra: {'preselectedAthleteId': widget.userId},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo determinar la academia actual',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Registrar Pago'),
              )
              : null, // No mostrar FAB para roles que no son manager
    );
  }

  Widget _buildUserInfo(bool isManagerView) {
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
                      widget.userName ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (isManagerView) // Solo mostrar ID para managers
                      Text(
                        'ID: ${widget.userId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                const Spacer(),
                // Opcional: Indicador de estado de pago
                _buildPaymentStatusIndicator(),
              ],
            ),
            const Divider(height: 32),
            _buildPaymentSummary(),

            // Información de plan de suscripción (a implementar)
            if (isManagerView) _buildSubscriptionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusIndicator() {
    const status = 'active'; // Simulación: Cambiar por datos reales

    Color statusColor;
    String statusText;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Activo';
        break;
      case 'overdue':
        statusColor = Colors.orange;
        statusText = 'En mora';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inactivo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubscriptionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan de Suscripción',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Plan Mensual'), Text('\$50.000 / mes')],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Próximo pago:'),
              Text(
                DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.now().add(const Duration(days: 15))),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (widget.viewerRole ==
              AppRole.propietario) // Solo para propietarios
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implementar navegación a cambio de plan
                },
                child: const Text('Cambiar Plan'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsAsyncValue = ref.watch(
          athletePaymentsNotifierProvider(widget.userId),
        );

        return paymentsAsyncValue.when(
          data: (payments) {
            final totalPaid = payments.fold<double>(
              0,
              (sum, payment) => sum + payment.amount,
            );
            final lastPayment =
                payments.isNotEmpty
                    ? payments.reduce(
                      (a, b) => a.paymentDate.isAfter(b.paymentDate) ? a : b,
                    )
                    : null;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Total Pagado',
                  NumberFormat.currency(
                    symbol: '\$',
                    decimalDigits: 2,
                  ).format(totalPaid),
                ),
                _buildInfoColumn(
                  'Último Pago',
                  lastPayment != null
                      ? DateFormat('dd/MM/yyyy').format(lastPayment.paymentDate)
                      : 'Ninguno',
                ),
                _buildInfoColumn(
                  'Cantidad de Pagos',
                  payments.length.toString(),
                ),
              ],
            );
          },
          loading:
              () => const Center(
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(
    BuildContext context,
    List<PaymentModel> payments,
    bool isManagerView,
  ) {
    if (payments.isEmpty) {
      return const Center(
        child: Text('No hay pagos registrados', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(context, payment, isManagerView);
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentModel payment,
    bool isManagerView,
  ) {
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
        trailing:
            isManagerView
                ? IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showPaymentOptions(context, payment);
                  },
                )
                : null, // Solo mostrar opciones para managers
        onTap: () {
          // Para usuario cliente: solo ver detalle
          // Para managers: ver detalle con opciones
          final currentAcademy = ref.read(currentAcademyProvider);
          if (currentAcademy != null &&
              currentAcademy.id != null &&
              payment.id != null) {
            final route =
                isManagerView
                    ? '/owner/academy/${currentAcademy.id}/payments/${payment.id}'
                    : '/client/payments/${payment.id}'; // Ruta para cliente
            context.push(route);
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
    // Solo los managers pueden ver estas opciones
    if (widget.viewerRole != AppRole.propietario &&
        widget.viewerRole != AppRole.colaborador) {
      return;
    }

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
                  final currentAcademy = ref.read(currentAcademyProvider);
                  if (currentAcademy != null &&
                      currentAcademy.id != null &&
                      payment.id != null) {
                    context.push(
                      '/owner/academy/${currentAcademy.id}/payments/${payment.id}',
                    );
                  }
                },
              ),
              // Solo propietarios pueden editar
              if (widget.viewerRole == AppRole.propietario)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navegar a editar pago
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy != null &&
                        currentAcademy.id != null &&
                        payment.id != null) {
                      context.push(
                        '/owner/academy/${currentAcademy.id}/payments/${payment.id}/edit',
                      );
                    }
                  },
                ),
              // Solo propietarios pueden eliminar
              if (widget.viewerRole == AppRole.propietario)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
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
    // Verificación adicional de permisos
    if (widget.viewerRole != AppRole.propietario) {
      return;
    }

    final currentAcademy = ref.read(currentAcademyProvider);
    final academyId = currentAcademy?.id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar pago'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este pago? Esta acción no se puede deshacer.',
          ),
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
                if (payment.id != null && academyId != null) {
                  ref
                      .read(paymentRepositoryProvider)
                      .deletePayment(academyId, payment.id!)
                      .then((_) {
                        // Invalidar el provider para refrescar la lista
                        ref.invalidate(
                          athletePaymentsNotifierProvider(widget.userId),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pago eliminado correctamente'),
                            ),
                          );
                        }
                      })
                      .catchError((error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al eliminar el pago: $error',
                              ),
                            ),
                          );
                        }
                      });
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

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
