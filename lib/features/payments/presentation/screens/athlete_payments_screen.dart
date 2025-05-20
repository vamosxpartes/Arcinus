import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart'
    as subscriptions;
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/core/utils/app_logger.dart';

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
  ConsumerState<AthletePaymentsScreen> createState() =>
      _AthletePaymentsScreenState();
}

class _AthletePaymentsScreenState extends ConsumerState<AthletePaymentsScreen> {
  @override
  void initState() {
    super.initState();
    // Actualizar el título en el OwnerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title =
          widget.athleteName != null
              ? 'Pagos de ${widget.athleteName}'
              : 'Pagos del atleta';
      ref.read(currentScreenTitleProvider.notifier).state = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsyncValue = ref.watch(
      athletePaymentsNotifierProvider(widget.athleteId),
    );
    final currentAcademy = ref.watch(currentAcademyProvider);

    return Scaffold(
      body: Column(
        children: [
          // Información del atleta
          _buildAthleteInfo(),

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
                            athletePaymentsNotifierProvider(widget.athleteId),
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
              data: (payments) => _buildPaymentsList(context, payments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorWidget(context, error),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para gestionar plan de suscripción
          if (currentAcademy != null && currentAcademy.id != null)
            FloatingActionButton(
              heroTag: 'subscriptionPlan',
              backgroundColor: Colors.orange,
              onPressed:
                  () => _showSubscriptionPlanModal(context, currentAcademy.id!),
              child: const Icon(Icons.card_membership),
            ),
          const SizedBox(height: 16),
          // Botón para registrar pago
          FloatingActionButton(
            heroTag: 'registerPayment',
            onPressed: () {
              // Navegar a registrar pago con el ID del atleta pre-seleccionado
              final currentAcademy = ref.read(currentAcademyProvider);
              if (currentAcademy != null &&
                  currentAcademy.id != null &&
                  currentAcademy.id!.isNotEmpty) {
                context.push(
                  '/owner/academy/${currentAcademy.id}/payments/register',
                  extra: {'preselectedAthleteId': widget.athleteId},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo determinar la academia actual'),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteInfo() {
    final currentAcademy = ref.watch(currentAcademyProvider);
    final academyId = currentAcademy?.id ?? '';

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                // Información de suscripción
                if (academyId.isNotEmpty)
                  _buildSubscriptionBadge(context, academyId),
              ],
            ),
            const Divider(height: 32),
            _buildPaymentSummary(),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar el estado de suscripción en un badge
  Widget _buildSubscriptionBadge(BuildContext context, String academyId) {
    return Consumer(
      builder: (context, ref, child) {
        final clientUserAsync = ref.watch(clientUserProvider(widget.athleteId));

        return clientUserAsync.when(
          data: (clientUser) {
            if (clientUser == null) {
              return InkWell(
                onTap: () => _showSubscriptionPlanModal(context, academyId),
                child: const Chip(
                  label: Text('Sin Plan'),
                  backgroundColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              );
            }

            // Color basado en el estado de pago
            Color chipColor;
            IconData chipIcon;

            switch (clientUser.paymentStatus) {
              case PaymentStatus.active:
                chipColor = Colors.green;
                chipIcon = Icons.check_circle;
                break;
              case PaymentStatus.overdue:
                chipColor = Colors.orange;
                chipIcon = Icons.warning;
                break;
              case PaymentStatus.inactive:
              // ignore: unreachable_switch_default
              default:
                chipColor = Colors.grey;
                chipIcon = Icons.cancel;
                break;
            }

            return InkWell(
              onTap: () => _showSubscriptionPlanModal(context, academyId),
              child: Chip(
                avatar: Icon(chipIcon, color: Colors.white, size: 16),
                label: Text(
                  clientUser.subscriptionPlan?.name ??
                      clientUser.paymentStatus.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: chipColor,
              ),
            );
          },
          loading:
              () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          error:
              (_, __) => InkWell(
                onTap: () => _showSubscriptionPlanModal(context, academyId),
                child: const Chip(
                  label: Text('Error'),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
        );
      },
    );
  }

  // Modal para gestionar el plan de suscripción
  void _showSubscriptionPlanModal(BuildContext context, String academyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SubscriptionPlanModal(
          academyId: academyId,
          athleteId: widget.athleteId,
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsAsyncValue = ref.watch(
          athletePaymentsNotifierProvider(widget.athleteId),
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
                          athletePaymentsNotifierProvider(widget.athleteId),
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
                  athletePaymentsNotifierProvider(widget.athleteId),
                ),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}

/// Modal para gestionar el plan de suscripción
class _SubscriptionPlanModal extends ConsumerStatefulWidget {
  final String academyId;
  final String athleteId;

  const _SubscriptionPlanModal({
    required this.academyId,
    required this.athleteId,
  });

  @override
  ConsumerState<_SubscriptionPlanModal> createState() =>
      _SubscriptionPlanModalState();
}

class _SubscriptionPlanModalState
    extends ConsumerState<_SubscriptionPlanModal> {
  String? _selectedPlanId;
  DateTime _startDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isInitialized = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // La carga inicial del plan se hará durante el primer build en didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadCurrentPlan();
      _isInitialized = true;
    }
  }

  void _loadCurrentPlan() {
    final clientUserAsync = ref.read(clientUserProvider(widget.athleteId));
    clientUserAsync.when(
      data: (clientUser) {
        if (clientUser != null &&
            clientUser.subscriptionPlanId != null &&
            mounted) {
          setState(() {
            _selectedPlanId = clientUser.subscriptionPlanId;
          });
        }
      },
      error: (_, __) {
        // Si hay error, dejamos el valor por defecto (null)
      },
      loading: () {
        // No hacemos nada mientras carga
      },
    );
  }

  // Método para refrescar los planes de suscripción
  Future<void> _refreshSubscriptionPlans() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Invalidar los providers para forzar la recarga
      ref.invalidate(activeSubscriptionPlansProvider(widget.academyId));
      ref.invalidate(clientUserProvider(widget.athleteId));

      // Esperar un momento para que la UI refleje el estado de carga
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsyncValue = ref.watch(
      activeSubscriptionPlansProvider(widget.academyId),
    );
    final clientUserAsync = ref.watch(clientUserProvider(widget.athleteId));

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.blackSwarm,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestionar Plan de Suscripción',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      // Botón para actualizar los planes
                      IconButton(
                        icon:
                            _isRefreshing
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.refresh),
                        tooltip: 'Actualizar planes',
                        onPressed:
                            _isRefreshing ? null : _refreshSubscriptionPlans,
                      ),
                      // Botón para cerrar el modal
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Plan actual
              clientUserAsync.when(
                data: (clientUser) {
                  if (clientUser == null ||
                      clientUser.subscriptionPlan == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay plan de suscripción asignado actualmente',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Plan Actual: ${clientUser.subscriptionPlan!.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monto: ${clientUser.subscriptionPlan!.amount} ${clientUser.subscriptionPlan!.currency}',
                          ),
                          Text(
                            'Ciclo: ${clientUser.subscriptionPlan!.billingCycle.displayName}',
                          ),
                          if (clientUser.nextPaymentDate != null)
                            Text(
                              'Próximo pago: ${DateFormat('dd/MM/yyyy').format(clientUser.nextPaymentDate!)}',
                            ),
                          if (clientUser.remainingDays != null)
                            Text('Días restantes: ${clientUser.remainingDays}'),
                        ],
                      ),
                    ),
                  );
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (error, _) => Text('Error al cargar información: $error'),
              ),

              const SizedBox(height: 16),

              // Lista de planes disponibles
              plansAsyncValue.when(
                data: (plans) {
                  AppLogger.logInfo(
                    'Modal recibió ${plans.length} planes del provider.',
                    className: '_SubscriptionPlanModalState',
                    functionName: 'build',
                    params: {'count': plans.length},
                  );
                  for (var i = 0; i < plans.length; i++) {
                    final plan = plans[i];
                    AppLogger.logInfo(
                      'Plan[$i]: ID=${plan.id}, Name=${plan.name}, IsActive=${plan.isActive}', // Asumiendo que plan.name y plan.isActive existen
                      className: '_SubscriptionPlanModalState',
                      functionName: 'build',
                      params: {
                        'id': plan.id,
                        'name': plan.name,
                        'isActive': plan.isActive,
                      },
                    );
                  }

                  if (plans.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No hay planes de suscripción disponibles',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // 1. Filter plans to only include those with non-null IDs for the dropdown options
                  final List<subscriptions.SubscriptionPlanModel>
                  validPlansForDropdown =
                      plans.where((p) => p.id != null).toList();

                  AppLogger.logInfo(
                    'Después de filtrar por ID no nulo, validPlansForDropdown tiene ${validPlansForDropdown.length} planes.',
                    className: '_SubscriptionPlanModalState',
                    functionName: 'build',
                    params: {'count': validPlansForDropdown.length},
                  );
                  for (var i = 0; i < validPlansForDropdown.length; i++) {
                    final plan = validPlansForDropdown[i];
                    AppLogger.logInfo(
                      'ValidPlan[$i]: ID=${plan.id}, Name=${plan.name}',
                      className: '_SubscriptionPlanModalState',
                      functionName: 'build',
                      params: {'id': plan.id, 'name': plan.name},
                    );
                  }

                  // (La lógica del microtask para _selectedPlanId se mantiene, pero la determinación
                  // del valor para el DropdownButton será más específica)
                  // Esta lógica de planExists se usa para el setState en microtask, puede seguir usando 'plans' originales
                  final bool planExistsInOriginalPlans =
                      _selectedPlanId == null ||
                      plans.any((plan) => plan.id == _selectedPlanId);
                  if (!planExistsInOriginalPlans && mounted) {
                    Future.microtask(() {
                      if (mounted) {
                        // Añadir comprobación de mounted por si acaso
                        setState(() {
                          _selectedPlanId = null;
                        });
                      }
                    });
                  }

                  // 2. Determine the value for the DropdownButton.
                  // Debe ser null o uno de los IDs de validPlansForDropdown.
                  String? dropdownWidgetValue = _selectedPlanId;
                  if (_selectedPlanId != null) {
                    // Si _selectedPlanId no es null
                    // Comprobar si está presente en los IDs de los planes válidos (que tienen IDs no nulos)
                    if (!validPlansForDropdown.any(
                      (p) => p.id == _selectedPlanId,
                    )) {
                      // Si no está (p.ej., era el ID de un plan con ID nulo, o un ID no existente),
                      // entonces establece el dropdown a "Sin Plan" (null).
                      dropdownWidgetValue = null;
                    }
                    // De lo contrario, _selectedPlanId es un ID válido de validPlansForDropdown, así que se usa.
                  }
                  // Si _selectedPlanId ya era null, dropdownWidgetValue es null.

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleccione un plan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String?>(
                          value:
                              dropdownWidgetValue, // Usar el valor determinado
                          hint: const Text('Seleccionar Plan'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlanId = value;
                            });
                          },
                          items: [
                            // Opción para desactivar el plan
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Sin Plan (Desactivar)'),
                            ),
                            // 3. Iterar sobre los planes filtrados (validPlansForDropdown)
                            for (final plan in validPlansForDropdown)
                              DropdownMenuItem<String?>(
                                value: plan.id, // plan.id aquí no será null
                                child: Text(
                                  '${plan.name} - ${plan.amount} ${plan.currency} / ${plan.billingCycle.displayName}',
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Selector de fecha de inicio
                      if (_selectedPlanId != null) ...[
                        const Text(
                          'Fecha de inicio:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 7),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_startDate),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (error, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('Error al cargar planes: $error'),
                    ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _savePlan,
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePlan() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(clientUserRepositoryProvider);

      if (_selectedPlanId == null) {
        // Desactivar plan: actualizar datos de cliente para marcar como inactivo
        final clientData = {
          'subscriptionPlanId': null,
          'paymentStatus': PaymentStatus.inactive.name,
          'nextPaymentDate': null,
          'remainingDays': null,
        };

        final result = await repository.updateClientUser(
          widget.academyId,
          widget.athleteId,
          clientData,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al desactivar plan: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plan desactivado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Refrescar datos
            ref.invalidate(clientUserProvider(widget.athleteId));
            Navigator.pop(context);
          },
        );
      } else {
        // Asignar nuevo plan
        final result = await repository.assignSubscriptionPlan(
          widget.academyId,
          widget.athleteId,
          _selectedPlanId!,
          _startDate,
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al asignar plan: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plan asignado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Refrescar datos
            ref.invalidate(clientUserProvider(widget.athleteId));
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
