import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';

/// Widget para el formulario principal de registro de pago
class PaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController conceptController;
  final TextEditingController notesController;
  final DateTime paymentDate;
  final String selectedCurrency;
  final String selectedPaymentMethod;
  final bool isPartialPayment;
  final double? totalPlanAmount;
  final ClientUserModel? clientUser;
  final PaymentConfigModel? paymentConfig;
  final List<String> currencies;
  final List<String> paymentMethods;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onPaymentMethodChanged;
  final ValueChanged<String> onAmountChanged;
  final bool isLoading;

  const PaymentForm({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.conceptController,
    required this.notesController,
    required this.paymentDate,
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.isPartialPayment,
    this.totalPlanAmount,
    this.clientUser,
    this.paymentConfig,
    required this.currencies,
    required this.paymentMethods,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onAmountChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Pago',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Monto y moneda
          _buildAmountAndCurrencyRow(),
          const SizedBox(height: 16),

          // Concepto
          _buildConceptField(),
          const SizedBox(height: 16),

          // Fecha de pago (automática)
          _buildPaymentDateField(context),
          const SizedBox(height: 8),
          
          // Información sobre la fecha automática
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La fecha de registro se establece automáticamente al momento de procesar el pago.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Método de pago
          _buildPaymentMethodField(),
          const SizedBox(height: 16),

          // Notas
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildAmountAndCurrencyRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de monto
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixIcon: const Icon(Icons.attach_money),
              border: const OutlineInputBorder(),
              suffixIcon: _buildAmountSuffixIcon(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            readOnly: _isAmountReadOnly(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa un monto';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Monto inválido';
              }
              return null;
            },
            onChanged: onAmountChanged,
          ),
        ),
        const SizedBox(width: 8),

        // Selector de moneda
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Moneda',
              border: OutlineInputBorder(),
            ),
            value: selectedCurrency,
            items: currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCurrencyChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildAmountSuffixIcon() {
    if (_isAmountReadOnly()) {
      return const Icon(Icons.lock, color: Colors.grey);
    }
    if (isPartialPayment && totalPlanAmount != null) {
      final currentAmount = double.tryParse(amountController.text) ?? 0;
      final progressPercentage = currentAmount / totalPlanAmount!;
      return Container(
        margin: const EdgeInsets.all(8),
        child: CircularProgressIndicator(
          value: progressPercentage,
          strokeWidth: 3,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }
    return null;
  }

  bool _isAmountReadOnly() {
    return clientUser?.subscriptionPlan != null && 
           !(paymentConfig?.earlyPaymentDiscount ?? false);
  }

  Widget _buildConceptField() {
    return TextFormField(
      controller: conceptController,
      decoration: const InputDecoration(
        labelText: 'Concepto',
        prefixIcon: Icon(Icons.subject),
        border: OutlineInputBorder(),
        hintText: 'Ej: Mensualidad Octubre',
      ),
      readOnly: _isConceptReadOnly(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa un concepto para el pago';
        }
        return null;
      },
    );
  }

  bool _isConceptReadOnly() {
    return clientUser?.subscriptionPlan != null && 
           !(paymentConfig?.earlyPaymentDiscount ?? false);
  }

  Widget _buildPaymentDateField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Registro del Pago',
          prefixIcon: Icon(Icons.calendar_today),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          suffixIcon: Icon(Icons.lock, color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(paymentDate),
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Text(
              '(Automática)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Método de Pago',
        prefixIcon: Icon(Icons.payment),
        border: OutlineInputBorder(),
      ),
      value: selectedPaymentMethod,
      items: paymentMethods.map((method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Row(
            children: [
              Icon(_getPaymentMethodIcon(method), size: 20),
              const SizedBox(width: 8),
              Text(method),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onPaymentMethodChanged(value);
        }
      },
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'transferencia':
        return Icons.account_balance;
      case 'tarjeta de crédito':
        return Icons.credit_card;
      case 'tarjeta de débito':
        return Icons.payment;
      default:
        return Icons.payments;
    }
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: notesController,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
        hintText: 'Notas adicionales sobre el pago',
      ),
      maxLines: 3,
    );
  }
} 