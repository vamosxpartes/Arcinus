import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:logger/logger.dart';

part 'register_payment_screen.g.dart';

// Instancia de Logger
final _logger = Logger();

/// Pantalla para registrar un nuevo pago
class RegisterPaymentScreen extends ConsumerStatefulWidget {
  /// Constructor
  const RegisterPaymentScreen({super.key});

  @override
  RegisterPaymentScreenState createState() => RegisterPaymentScreenState();
}

class RegisterPaymentScreenState extends ConsumerState<RegisterPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedAthleteId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String _selectedCurrency = 'MXN';

  final List<String> _currencies = ['MXN', 'USD', 'EUR'];
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observar el estado del formulario
    // final formState = ref.watch(paymentFormNotifierProvider);
    
    // Si cambia el estado a éxito, cerrar la pantalla
    ref.listen(paymentFormNotifierProvider, (previous, current) {
      if (!_isLoading && current.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
      
      if (!_isLoading && current.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              current.failure!.maybeWhen(
                serverError: (message) => message,
                orElse: () => 'Error al registrar el pago',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      setState(() {
        _isLoading = current.isSubmitting;
      });
    });
    
    // Obtener la lista de atletas de la academia
    final athletesAsyncValue = ref.watch(academyAthletesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Pago',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Selección de atleta
              _buildAthleteSelector(athletesAsyncValue),
              const SizedBox(height: 16),
              
              // Monto
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de monto
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
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
                      value: _selectedCurrency,
                      items: _currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCurrency = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Concepto
              TextFormField(
                controller: _conceptController,
                decoration: const InputDecoration(
                  labelText: 'Concepto',
                  prefixIcon: Icon(Icons.subject),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Mensualidad Octubre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un concepto para el pago';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Fecha de pago
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Pago',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_paymentDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Notas adicionales sobre el pago',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Botón de registro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPayment,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Registrar Pago'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAthleteSelector(AsyncValue<List<UserModel>> athletesAsyncValue) {
    return athletesAsyncValue.when(
      data: (athletes) {
        if (athletes.isEmpty) {
          return const Text(
            'No hay atletas registrados en la academia',
            style: TextStyle(color: Colors.red),
          );
        }
        
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Seleccionar Atleta',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          value: _selectedAthleteId,
          items: athletes.map((athlete) {
            return DropdownMenuItem<String>(
              value: athlete.id,
              child: Text('${athlete.displayName ?? 'Sin nombre'} (${athlete.email})'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAthleteId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona un atleta';
            }
            return null;
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text(
        'Error al cargar atletas: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(paymentFormNotifierProvider.notifier);
      
      notifier.submitPayment(
        athleteId: _selectedAthleteId!,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        paymentDate: _paymentDate,
        concept: _conceptController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
    }
  }
}

/// Provider para obtener los atletas de la academia actual
@riverpod
Future<List<UserModel>> academyAthletes(Ref ref) async {
  // Devolver una lista vacía temporalmente para evitar errores
  _logger.w('ADVERTENCIA: academyAthletesProvider está devolviendo una lista vacía.');
  return Future.value([]); 
} 