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
import 'package:arcinus/core/utils/app_logger.dart';

/// Pantalla que muestra los detalles de pagos específicamente para managers (propietarios y colaboradores)
class ManagerPaymentDetailScreen extends ConsumerStatefulWidget {
  /// ID del usuario cuyos pagos se mostrarán (atleta o padre)
  final String userId;

  /// Nombre del usuario (opcional)
  final String? userName;

  /// Rol del manager que visualiza la pantalla
  final AppRole managerRole;

  /// Constructor
  const ManagerPaymentDetailScreen({
    super.key,
    required this.userId,
    this.userName,
    required this.managerRole,
  });

  @override
  ConsumerState<ManagerPaymentDetailScreen> createState() =>
      _ManagerPaymentDetailScreenState();
}

class _ManagerPaymentDetailScreenState
    extends ConsumerState<ManagerPaymentDetailScreen> {
  // Estado de filtros
  String _filterBy = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Actualizar el título en el Shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title =
          widget.userName != null
              ? 'Pagos de ${widget.userName}'
              : 'Detalle de pagos';
      ref.read(currentScreenTitleProvider.notifier).state = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los pagos filtrados
    final filteredPaymentsAsyncValue = ref.watch(
      filteredAthletePaymentsProvider(
        FilteredPaymentParams(
          userId: widget.userId,
          filterBy: _filterBy,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );

    // Obtenemos los datos del usuario cliente para mostrar su información
    final clientUserAsyncValue = ref.watch(clientUserProvider(widget.userId));

    // Verificar si el usuario actual es propietario (para ciertas acciones)
    final isOwner = widget.managerRole == AppRole.propietario;

    return Scaffold(
      body: Column(
        children: [
          // Información del usuario y suscripción
          clientUserAsyncValue.when(
            data: (clientUser) => _buildUserInfoCard(clientUser, isOwner),
            loading: () => _buildLoadingUserCard(),
            error: (error, _) => _buildErrorUserCard(error),
          ),

          // Encabezado y filtros
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
                    // Botón de filtro
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtrar pagos',
                      onPressed: _showFilterDialog,
                    ),
                    // Botón de actualizar
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

          // Mostrar filtros activos
          if (_filterBy != 'all' || _startDate != null || _endDate != null)
            _buildActiveFilters(),

          // Lista de pagos
          Expanded(
            child: filteredPaymentsAsyncValue.when(
              data:
                  (payments) => _buildPaymentsList(context, payments, isOwner),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorWidget(context, error),
            ),
          ),
        ],
      ),
      // FAB para registrar un nuevo pago
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _registerNewPayment(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar Pago'),
      ),
    );
  }

  // Placeholder para el widget de información de usuario mientras carga
  Widget _buildLoadingUserCard() {
    return const Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Widget para mostrar error al cargar información del usuario
  Widget _buildErrorUserCard(Object error) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Error al cargar información del usuario: ${error.toString()}',
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para tarjeta con información del usuario y suscripción
  Widget _buildUserInfoCard(dynamic clientUser, bool isOwner) {
    // Por ahora usar datos simulados
    final userName = widget.userName ?? 'Usuario';
    final paymentStatus = 'active'; // Simulación
    final planName = 'Plan Mensual'; // Simulación
    final nextPaymentDate = DateTime.now().add(
      const Duration(days: 15),
    ); // Simulación

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
                      userName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'ID: ${widget.userId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                // Indicador de estado de pago
                _buildStatusBadge(paymentStatus),
              ],
            ),
            const Divider(height: 32),

            // Sección de suscripción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan de Suscripción',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                // Botón para cambiar plan (solo propietarios)
                if (isOwner)
                  TextButton(
                    onPressed: () => _changePlan(context),
                    child: const Text('Cambiar Plan'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plan actual:'),
                Text(
                  planName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Próximo pago:'),
                Text(
                  DateFormat('dd/MM/yyyy').format(nextPaymentDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Días restantes:'),
                Text(
                  '${nextPaymentDate.difference(DateTime.now()).inDays} días',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar estado de pago
  Widget _buildStatusBadge(String status) {
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

  // Widget para mostrar filtros activos
  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getActiveFiltersText(),
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 16, color: Colors.blue),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  // Obtener texto descriptivo de filtros activos
  String _getActiveFiltersText() {
    final List<String> filters = [];

    if (_filterBy != 'all') {
      switch (_filterBy) {
        case 'recent':
          filters.add('Últimos 30 días');
          break;
        case 'month':
          filters.add('Este mes');
          break;
        case 'year':
          filters.add('Este año');
          break;
        case 'custom':
          filters.add('Rango personalizado');
          break;
      }
    }

    if (_startDate != null && _endDate != null) {
      final start = DateFormat('dd/MM/yyyy').format(_startDate!);
      final end = DateFormat('dd/MM/yyyy').format(_endDate!);
      filters.add('De $start a $end');
    } else if (_startDate != null) {
      final start = DateFormat('dd/MM/yyyy').format(_startDate!);
      filters.add('Desde $start');
    } else if (_endDate != null) {
      final end = DateFormat('dd/MM/yyyy').format(_endDate!);
      filters.add('Hasta $end');
    }

    return filters.isEmpty
        ? 'Todos los pagos'
        : 'Filtros: ${filters.join(', ')}';
  }

  // Limpiar todos los filtros
  void _clearFilters() {
    setState(() {
      _filterBy = 'all';
      _startDate = null;
      _endDate = null;
    });
  }

  // Mostrar diálogo de filtros
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Filtrar Pagos'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filtros predefinidos
                        const Text('Período:'),
                        RadioListTile<String>(
                          title: const Text('Todos'),
                          value: 'all',
                          groupValue: _filterBy,
                          onChanged:
                              (value) => setState(() => _filterBy = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Últimos 30 días'),
                          value: 'recent',
                          groupValue: _filterBy,
                          onChanged:
                              (value) => setState(() => _filterBy = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Este mes'),
                          value: 'month',
                          groupValue: _filterBy,
                          onChanged:
                              (value) => setState(() => _filterBy = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Este año'),
                          value: 'year',
                          groupValue: _filterBy,
                          onChanged:
                              (value) => setState(() => _filterBy = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Personalizado'),
                          value: 'custom',
                          groupValue: _filterBy,
                          onChanged:
                              (value) => setState(() => _filterBy = value!),
                        ),

                        // Filtros de fecha personalizados
                        if (_filterBy == 'custom') ...[
                          const SizedBox(height: 16),
                          const Text('Rango de fechas:'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _startDate == null
                                        ? 'Fecha inicio'
                                        : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_startDate!),
                                  ),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _startDate = date);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _endDate == null
                                        ? 'Fecha fin'
                                        : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_endDate!),
                                  ),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => _endDate = date);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearFilters();
                      },
                      child: const Text('Limpiar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);

                        // Aplicar filtros
                        this.setState(() {
                          if (_filterBy == 'recent') {
                            _startDate = DateTime.now().subtract(
                              const Duration(days: 30),
                            );
                            _endDate = DateTime.now();
                          } else if (_filterBy == 'month') {
                            final now = DateTime.now();
                            _startDate = DateTime(now.year, now.month, 1);
                            _endDate = DateTime(now.year, now.month + 1, 0);
                          } else if (_filterBy == 'year') {
                            final now = DateTime.now();
                            _startDate = DateTime(now.year, 1, 1);
                            _endDate = DateTime(now.year, 12, 31);
                          } else if (_filterBy != 'custom') {
                            _startDate = null;
                            _endDate = null;
                          }
                        });
                      },
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Lista de pagos
  Widget _buildPaymentsList(
    BuildContext context,
    List<PaymentModel> payments,
    bool isOwner,
  ) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay pagos registrados', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Puedes registrar un nuevo pago con el botón + abajo',
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
        return _buildPaymentCard(context, payment, isOwner);
      },
    );
  }

  // Tarjeta de pago individual
  Widget _buildPaymentCard(
    BuildContext context,
    PaymentModel payment,
    bool isOwner,
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
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showPaymentOptions(context, payment, isOwner);
          },
        ),
        onTap: () {
          // _navigateToPaymentDetail(payment);
        },
      ),
    );
  }

  // Mostrar opciones de pago
  void _showPaymentOptions(
    BuildContext context,
    PaymentModel payment,
    bool isOwner,
  ) {
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
                },
              ),
              // Solo propietarios pueden editar
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    _editPayment(context, payment);
                  },
                ),
              // Generar comprobante
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Generar comprobante'),
                onTap: () {
                  Navigator.pop(context);
                  _generateReceipt(context, payment);
                },
              ),
              // Solo propietarios pueden eliminar
              if (isOwner)
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

  // Registrar un nuevo pago
  void _registerNewPayment(BuildContext context) {
    final currentAcademy = ref.read(currentAcademyProvider);

    if (currentAcademy != null && currentAcademy.id != null) {
      final route = '/manager/academy/${currentAcademy.id}/payments/register';
      final extra = {'preselectedAthleteId': widget.userId};

      context.push(route, extra: extra).then((_) {
        // Invalidar el provider para refrescar la lista
        ref.invalidate(athletePaymentsNotifierProvider(widget.userId));
      });

      AppLogger.logInfo(
        'Navegando a registrar pago para usuario',
        className: 'ManagerPaymentDetailScreen',
        functionName: '_registerNewPayment',
        params: {'userId': widget.userId, 'academyId': currentAcademy.id},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo determinar la academia actual'),
        ),
      );
    }
  }

  // Editar un pago existente
  void _editPayment(BuildContext context, PaymentModel payment) {
    if (payment.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se puede editar este pago')),
      );
      return;
    }

    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy != null && currentAcademy.id != null) {
      final route =
          '/manager/academy/${currentAcademy.id}/payments/${payment.id}/edit';

      context.push(route).then((_) {
        // Invalidar el provider para refrescar la lista
        ref.invalidate(athletePaymentsNotifierProvider(widget.userId));
      });

      AppLogger.logInfo(
        'Navegando a editar pago',
        className: 'ManagerPaymentDetailScreen',
        functionName: '_editPayment',
        params: {'paymentId': payment.id, 'academyId': currentAcademy.id},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo determinar la academia actual'),
        ),
      );
    }
  }

  // Generar comprobante de pago
  void _generateReceipt(BuildContext context, PaymentModel payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente: Generación de comprobantes')),
    );
  }

  // Cambiar plan de suscripción
  void _changePlan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente: Cambio de planes')),
    );
  }

  // Confirmar eliminación de pago
  void _confirmDeletePayment(BuildContext context, PaymentModel payment) {
    if (payment.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se puede eliminar este pago')),
      );
      return;
    }

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
                _deletePayment(payment);
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

  // Eliminar pago
  void _deletePayment(PaymentModel payment) {
    final currentAcademy = ref.read(currentAcademyProvider);

    if (currentAcademy?.id == null || payment.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se puede eliminar este pago')),
      );
      return;
    }

    ref
        .read(paymentRepositoryProvider)
        .deletePayment(currentAcademy!.id!, payment.id!)
        .then((_) {
          // Invalidar el provider para refrescar la lista
          ref.invalidate(athletePaymentsNotifierProvider(widget.userId));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pago eliminado correctamente')),
            );
          }
          AppLogger.logInfo(
            'Pago eliminado correctamente',
            className: 'ManagerPaymentDetailScreen',
            functionName: '_deletePayment',
            params: {'paymentId': payment.id, 'academyId': currentAcademy.id},
          );
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar el pago: $error')),
            );
          }
          AppLogger.logError(
            message: 'Error al eliminar pago',
            error: error,
            className: 'ManagerPaymentDetailScreen',
            functionName: '_deletePayment',
            params: {'paymentId': payment.id, 'academyId': currentAcademy.id},
          );
        });
  }

  // Obtener símbolo de moneda
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

/// Parámetros para filtrado de pagos
class FilteredPaymentParams {
  final String userId;
  final String filterBy;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilteredPaymentParams({
    required this.userId,
    required this.filterBy,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilteredPaymentParams &&
        other.userId == userId &&
        other.filterBy == filterBy &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(userId, filterBy, startDate, endDate);
}

/// Provider para obtener pagos filtrados
final filteredAthletePaymentsProvider = Provider.family<
  AsyncValue<List<PaymentModel>>,
  FilteredPaymentParams
>((ref, params) {
  final paymentsAsyncValue = ref.watch(
    athletePaymentsNotifierProvider(params.userId),
  );

  return paymentsAsyncValue.whenData((payments) {
    if (params.filterBy == 'all' &&
        params.startDate == null &&
        params.endDate == null) {
      return payments;
    }

    return payments.where((payment) {
      bool matchesFilter = true;

      // Filtro por fecha
      if (params.startDate != null) {
        matchesFilter =
            matchesFilter && payment.paymentDate.isAfter(params.startDate!);
      }
      if (params.endDate != null) {
        // Incluir todo el día final
        final endOfDay = DateTime(
          params.endDate!.year,
          params.endDate!.month,
          params.endDate!.day,
          23,
          59,
          59,
        );
        matchesFilter = matchesFilter && payment.paymentDate.isBefore(endOfDay);
      }

      return matchesFilter;
    }).toList();
  });
});

// Provider simulado para datos del cliente (a implementar con el modelo real después)
final clientUserProvider = Provider.family<AsyncValue<dynamic>, String>((
  ref,
  userId,
) {
  // Simular una carga de datos
  return const AsyncValue.data({});
});
