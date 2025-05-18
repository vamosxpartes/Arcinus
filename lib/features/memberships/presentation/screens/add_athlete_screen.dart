import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/memberships/presentation/providers/add_athlete_providers.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/memberships/domain/state/add_athlete_state.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Cambiar a StatefulWidget para gestionar los controllers localmente
class AddAthleteScreen extends ConsumerStatefulWidget {
  final String academyId;
  const AddAthleteScreen({super.key, required this.academyId});

  @override
  ConsumerState<AddAthleteScreen> createState() => _AddAthleteScreenState();
}

class _AddAthleteScreenState extends ConsumerState<AddAthleteScreen> {
  // Controllers locales que pertenecen al ciclo de vida del widget
  final Map<String, TextEditingController> _localControllers = {};
  
  bool _isInitialized = false;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Inicializando AddAthleteScreen con controllers locales',
      className: 'AddAthleteScreen',
      functionName: 'initState'
    );
    
    // Inicializar controllers locales
    _initControllers();
    
    // Marcar como inicializado
    _isInitialized = true;
  }
  
  // Inicializar controllers locales
  void _initControllers() {
    _localControllers.clear();
    
    // Crear controladores nuevos
    _localControllers['firstName'] = TextEditingController();
    _localControllers['lastName'] = TextEditingController();
    _localControllers['birthDate'] = TextEditingController();
    _localControllers['phoneNumber'] = TextEditingController();
    _localControllers['heightCm'] = TextEditingController();
    _localControllers['weightKg'] = TextEditingController();
    _localControllers['allergies'] = TextEditingController();
    _localControllers['medicalConditions'] = TextEditingController();
    _localControllers['emergencyContactName'] = TextEditingController();
    _localControllers['emergencyContactPhone'] = TextEditingController();
    _localControllers['position'] = TextEditingController();
    _localControllers['experience'] = TextEditingController();
    _localControllers['specialization'] = TextEditingController();
  }
  
  @override
  void dispose() {
    // Marcar como disposed para evitar actualizaciones tardías
    _isDisposed = true;
    
    AppLogger.logInfo(
      'Eliminando controllers en AddAthleteScreen',
      className: 'AddAthleteScreen',
      functionName: 'dispose'
    );
    
    // Limpiar controllers de forma segura
    for (final controller in _localControllers.values) {
      if (controller.hasListeners) {
        controller.dispose();
      }
    }
    _localControllers.clear();
    
    super.dispose();
  }
  
  // Resetear el formulario de forma segura
  void _resetForm() {
    if (_isDisposed) return;
    
    AppLogger.logInfo(
      'Reseteando formulario localmente',
      className: 'AddAthleteScreen',
      functionName: '_resetForm'
    );
    
    setState(() {
      // Eliminar y volver a crear controladores
      for (final controller in _localControllers.values) {
        if (controller.hasListeners) {
          controller.dispose();
        }
      }
      _localControllers.clear();
      
      // Inicializar controllers nuevos
      _initControllers();
    });
    
    // Resetear el estado en el provider
    ref.read(addAthleteProvider.notifier).resetForm();
  }
  
  // Método para sincronizar valores del estado al provider
  void _syncToProvider() {
    if (!mounted || _isDisposed) return;
    
    final notifier = ref.read(addAthleteProvider.notifier);
    
    // Solo sincronizar si ya se inicializaron los controllers
    if (!_isInitialized) return;
    
    // Actualizar solo los campos que tienen valores
    for (final entry in _localControllers.entries) {
      final key = entry.key;
      final controller = entry.value;
      
      try {
        if (controller.text.isNotEmpty) {
          switch(key) {
            case 'firstName':
              notifier.updateFirstName(controller.text);
              break;
            case 'lastName':
              notifier.updateLastName(controller.text);
              break;
            case 'phoneNumber':
              notifier.updatePhoneNumber(controller.text);
              break;
            case 'heightCm':
              notifier.updateHeight(controller.text);
              break;
            case 'weightKg':
              notifier.updateWeight(controller.text);
              break;
            case 'allergies':
              notifier.updateAllergies(controller.text);
              break;
            case 'medicalConditions':
              notifier.updateMedicalConditions(controller.text);
              break;
            case 'emergencyContactName':
              notifier.updateEmergencyContactName(controller.text);
              break;
            case 'emergencyContactPhone':
              notifier.updateEmergencyContactPhone(controller.text);
              break;
            case 'position':
              notifier.updatePosition(controller.text);
              break;
            case 'specialization':
              notifier.updateSpecialization(controller.text);
              break;
          }
        }
      } catch (e) {
        // Ignora errores si el controller ya no es válido
        AppLogger.logError(
          message: 'Error al acceder a controller $key: $e',
          className: 'AddAthleteScreen',
          functionName: '_syncToProvider'
        );
      }
    }
  }
  
  // Método para sincronizar datos de prueba a los controllers locales
  void _syncDataFromState() {
    if (!mounted || _isDisposed) return;
    
    final state = ref.read(addAthleteProvider);
    
    // Actualizar controllers con datos del estado de forma segura
    setState(() {
      for (final entry in _localControllers.entries) {
        final key = entry.key;
        final controller = entry.value;
        
        try {
          switch(key) {
            case 'firstName':
              if (state.firstName != null) controller.text = state.firstName!;
              break;
            case 'lastName':
              if (state.lastName != null) controller.text = state.lastName!;
              break;
            case 'birthDate':
              if (state.birthDate != null) controller.text = DateFormat('dd/MM/yyyy').format(state.birthDate!);
              break;
            case 'phoneNumber':
              if (state.phoneNumber != null) controller.text = state.phoneNumber!;
              break;
            case 'heightCm':
              if (state.heightCm != null) controller.text = state.heightCm!.toString();
              break;
            case 'weightKg':
              if (state.weightKg != null) controller.text = state.weightKg!.toString();
              break;
            case 'allergies':
              if (state.allergies != null) controller.text = state.allergies!;
              break;
            case 'medicalConditions':
              if (state.medicalConditions != null) controller.text = state.medicalConditions!;
              break;
            case 'emergencyContactName':
              if (state.emergencyContactName != null) controller.text = state.emergencyContactName!;
              break;
            case 'emergencyContactPhone':
              if (state.emergencyContactPhone != null) controller.text = state.emergencyContactPhone!;
              break;
            case 'position':
              if (state.position != null) controller.text = state.position!;
              break;
            case 'specialization':
              if (state.specialization != null) controller.text = state.specialization!;
              break;
          }
        } catch (e) {
          // Ignora errores si el controller ya no es válido
          AppLogger.logError(
            message: 'Error al actualizar controller $key: $e',
            className: 'AddAthleteScreen',
            functionName: '_syncDataFromState'
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Protección adicional para evitar actualizaciones después de dispose
    if (_isDisposed || !mounted) return const SizedBox.shrink();
    
    final activeAcademyState = ref.watch(currentAcademyProvider);
    final academyId = activeAcademyState?.id ?? widget.academyId;
    
    final addAthleteState = ref.watch(addAthleteProvider);
    final addAthleteNotifier = ref.read(addAthleteProvider.notifier);
    
    final userId = ref.read(authStateNotifierProvider).user?.id ?? '';
    
    // Escuchar cambios en los datos de prueba
    ref.listen(addAthleteProvider, (previous, next) {
      // Verificar mounted para evitar actualizaciones en widgets eliminados
      if (!mounted || _isDisposed) return;
      
      if (previous?.firstName != next.firstName ||
          previous?.lastName != next.lastName ||
          previous?.birthDate != next.birthDate) {
        // Solo sincronizar si ha habido cambios en los datos básicos
        // (posiblemente desde cargarDatosDePrueba)
        if (_isInitialized) {
          _syncDataFromState();
        }
      }
      
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atleta añadido correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Error al añadir atleta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    
    if (addAthleteState.isSuccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Atleta Registrado'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Atleta registrado correctamente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AppLogger.logInfo(
                    'Volviendo a la lista de atletas',
                    className: 'AddAthleteScreen',
                    functionName: 'onBackToList'
                  );
                  
                  // Primero navegar para evitar acceder a los controllers después
                  context.go('/manager/academy/$academyId/members');
                },
                child: const Text('Volver a la lista'),
              ),
              TextButton(
                onPressed: () {
                  // Resetear el formulario sin cambiar de pantalla
                  _resetForm();
                },
                child: const Text('Registrar otro atleta'),
              ),
            ],
          ),
        ),
      );
    }

    // Establecer título de la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Añadir Nuevo Atleta';
    });

    // Obtener formKeys locales para cada paso
    List<GlobalKey<FormState>> formKeys = [
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
    ];

    // Obtener la lista de pasos
    List<Step> steps = _getSteps(context, ref, addAthleteState, formKeys);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Atleta'),
        actions: [
          // Botón de datos de prueba
          IconButton(
            onPressed: () {
              addAthleteNotifier.cargarDatosDePrueba();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Datos de prueba cargados'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Cargar datos de prueba',
          ),
        ],
      ),
      body: addAthleteState.isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: addAthleteState.currentStep,
              onStepContinue: () {
                final isLastStep = addAthleteState.currentStep == steps.length - 1;
                
                // Validar el paso actual
                bool isCurrentFormValid = formKeys[addAthleteState.currentStep].currentState?.validate() ?? false;
                
                if (isLastStep) {
                  // Sincronizar datos de los controllers al provider
                  _syncToProvider();
                  
                  // Enviar formulario
                  addAthleteNotifier.submitForm(academyId, userId);
                } else if (isCurrentFormValid) {
                  addAthleteNotifier.nextStep();
                } else {
                  // Mostrar mensaje de error para campos requeridos
                  if (addAthleteState.currentStep == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor complete los campos obligatorios'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    // Para otros pasos, avanzar aunque no esté completo
                    addAthleteNotifier.nextStep();
                  }
                }
              },
              onStepCancel: () {
                addAthleteNotifier.previousStep();
              },
              onStepTapped: (step) {
                addAthleteNotifier.goToStep(step);
              },
              steps: steps,
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                final isLastStep = addAthleteState.currentStep == steps.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 140, 
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLastStep ? 'GUARDAR' : 'SIGUIENTE'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (addAthleteState.currentStep > 0)
                        SizedBox(
                          width: 120,
                          child: TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('ANTERIOR'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Método para obtener los pasos del formulario
  List<Step> _getSteps(
    BuildContext context, 
    WidgetRef ref, 
    AddAthleteState state,
    List<GlobalKey<FormState>> formKeys,
  ) {
    if (_isDisposed || !mounted) return [];
    
    final addAthleteNotifier = ref.read(addAthleteProvider.notifier);
    
    return <Step>[
      // Información Personal
      Step(
        state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 0,
        title: const Text('Información Personal'),
        content: Form(
          key: formKeys[0],
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _localControllers['firstName'],
                decoration: const InputDecoration(labelText: 'Nombres Completos'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los nombres';
                  }
                  return null;
                },
                onChanged: (value) => addAthleteNotifier.updateFirstName(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['lastName'],
                decoration: const InputDecoration(labelText: 'Apellidos Completos'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los apellidos';
                  }
                  return null;
                },
                onChanged: (value) => addAthleteNotifier.updateLastName(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['birthDate'],
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && !_isDisposed) {
                    addAthleteNotifier.updateBirthDate(picked);
                    setState(() {
                      _localControllers['birthDate']!.text = DateFormat('dd/MM/yyyy').format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['phoneNumber'],
                decoration: const InputDecoration(labelText: 'Número de Teléfono (Contacto)'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => addAthleteNotifier.updatePhoneNumber(value),
              ),
            ],
          ),
        ),
      ),
      
      // Información Física
      Step(
        state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 1,
        title: const Text('Información Física'),
        content: Form(
          key: formKeys[1],
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _localControllers['heightCm'],
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => addAthleteNotifier.updateHeight(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['weightKg'],
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => addAthleteNotifier.updateWeight(value),
              ),
            ],
          ),
        ),
      ),
      
      // Información de Salud
      Step(
        state: state.currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 2,
        title: const Text('Información de Salud'),
        content: Form(
          key: formKeys[2],
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _localControllers['allergies'],
                decoration: const InputDecoration(labelText: 'Alergias Conocidas'),
                maxLines: 2,
                onChanged: (value) => addAthleteNotifier.updateAllergies(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['medicalConditions'],
                decoration: const InputDecoration(labelText: 'Condiciones Médicas Relevantes'),
                maxLines: 2,
                onChanged: (value) => addAthleteNotifier.updateMedicalConditions(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['emergencyContactName'],
                decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Nombre)'),
                onChanged: (value) => addAthleteNotifier.updateEmergencyContactName(value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localControllers['emergencyContactPhone'],
                decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Teléfono)'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => addAthleteNotifier.updateEmergencyContactPhone(value),
              ),
            ],
          ),
        ),
      ),
      
      // Información Deportiva
      Step(
        state: state.currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 3,
        title: const Text('Información Deportiva'),
        content: Form(
          key: formKeys[3],
          child: Column(
            children: <Widget>[
              Consumer(
                builder: (context, ref, child) {
                  final positionsAsync = ref.watch(sportPositionsProvider(widget.academyId));
                  
                  return positionsAsync.when(
                    data: (positions) {
                      if (positions.isEmpty) {
                        return TextFormField(
                          controller: _localControllers['position'],
                          decoration: const InputDecoration(labelText: 'Posición Principal'),
                          onChanged: (value) => addAthleteNotifier.updatePosition(value),
                        );
                      } else {
                        return DropdownButtonFormField<String>(
                          value: state.position?.isNotEmpty == true && positions.contains(state.position) 
                            ? state.position 
                            : null,
                          decoration: const InputDecoration(labelText: 'Posición Principal'),
                          items: positions.map((position) => 
                            DropdownMenuItem(
                              value: position,
                              child: Text(position),
                            )
                          ).toList(),
                          onChanged: (value) {
                            if (value != null && !_isDisposed) {
                              addAthleteNotifier.updatePosition(value);
                              setState(() {
                                _localControllers['position']!.text = value;
                              });
                            }
                          },
                        );
                      }
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => TextFormField(
                      controller: _localControllers['position'],
                      decoration: const InputDecoration(
                        labelText: 'Posición Principal',
                        helperText: 'Error cargando posiciones',
                      ),
                      onChanged: (value) => addAthleteNotifier.updatePosition(value),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _localControllers['experience'],
                decoration: const InputDecoration(labelText: 'Experiencia (años)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  (addAthleteNotifier as dynamic).updateExperience(value);
                },
              ),
              
              const SizedBox(height: 15),
              
              Consumer(
                builder: (context, ref, child) {
                  final characteristicsAsync = ref.watch(academySportCharacteristicsProvider(widget.academyId));
                  
                  return characteristicsAsync.when(
                    data: (characteristics) {
                      if (characteristics == null || characteristics.athleteSpecializations.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return DropdownButtonFormField<String>(
                        value: state.specialization?.isNotEmpty == true && 
                              characteristics.athleteSpecializations.contains(state.specialization) 
                              ? state.specialization 
                              : null,
                        decoration: const InputDecoration(labelText: 'Especialización'),
                        items: characteristics.athleteSpecializations.map((specialization) => 
                          DropdownMenuItem(
                            value: specialization,
                            child: Text(specialization),
                          )
                        ).toList(),
                        onChanged: (value) {
                          if (value != null && !_isDisposed) {
                            (addAthleteNotifier as dynamic).updateSpecialization(value);
                            // También actualizar en el controlador local si existe para esta propiedad
                            if (_localControllers.containsKey('specialization')) {
                              setState(() {
                                _localControllers['specialization']!.text = value;
                              });
                            }
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      
      // Fotografía
      Step(
        state: state.currentStep >= 4 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 4,
        title: const Text('Fotografía'),
        content: Form(
          key: formKeys[4],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Añade una foto del atleta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (state.profileImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          state.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // En caso de error al cargar la imagen
                            return Container(
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'Error al cargar imagen',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Botón para eliminar la imagen en la esquina superior derecha
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              addAthleteNotifier.resetImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sin foto',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => addAthleteNotifier.pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => addAthleteNotifier.pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Plan de Suscripción
      Step(
        state: state.currentStep >= 5 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 5,
        title: const Text('Plan de Suscripción'),
        content: Form(
          key: formKeys[5],
          child: _buildSubscriptionPlanStep(widget.academyId, addAthleteNotifier),
        ),
      ),
    ];
  }

  // Widget para el paso de selección de plan de suscripción
  Widget _buildSubscriptionPlanStep(String academyId, dynamic addAthleteNotifier) {
    if (_isDisposed || !mounted) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final plansAsyncValue = ref.watch(activeSubscriptionPlansProvider(academyId));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asignar plan de suscripción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este paso es opcional. Puedes asignar un plan de suscripción ahora o hacerlo más tarde.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Lista de planes disponibles
            plansAsyncValue.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay planes disponibles. Puedes crearlos en la sección de Planes de Suscripción.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                
                return Column(
                  children: [
                    // Selector de planes
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar plan',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Seleccionar un plan (opcional)'),
                      value: null,
                      onChanged: (planId) {
                        if (planId != null) {
                          // Usar método dinámico para actualizar
                          addAthleteNotifier.updateSubscriptionPlan(planId);
                        }
                      },
                      items: [
                        // Opción para no seleccionar plan
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No asignar plan'),
                        ),
                        // Opciones de planes disponibles
                        ...plans.map((plan) => DropdownMenuItem<String>(
                          value: plan.id,
                          child: Text('${plan.name} - ${plan.amount} ${plan.currency} / ${plan.billingCycle.displayName}'),
                        )),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Selector de fecha de inicio
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now.subtract(const Duration(days: 7)), // Permitir seleccionar hasta 7 días atrás
                          lastDate: now.add(const Duration(days: 30)), // Permitir seleccionar hasta 30 días adelante
                        );
                        
                        if (date != null) {
                          // Usar método dinámico para actualizar
                          addAthleteNotifier.updateSubscriptionStartDate(date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        isEmpty: false,
                        child: Text(
                          // Obtener fecha de manera segura
                          _getSubscriptionDateText(addAthleteNotifier),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error al cargar planes: $error'),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Función auxiliar para obtener el texto de la fecha de manera segura
  String _getSubscriptionDateText(dynamic notifier) {
    try {
      final startDate = notifier.state.subscriptionStartDate;
      if (startDate != null && startDate is DateTime) {
        return DateFormat('dd/MM/yyyy').format(startDate);
      }
    } catch (e) {
      // Ignorar errores de acceso
    }
    return 'Seleccionar fecha (hoy por defecto)';
  }
} 