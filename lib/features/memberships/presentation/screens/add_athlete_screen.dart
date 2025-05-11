import 'package:arcinus/features/memberships/domain/state/add_athlete_state.dart';
import 'package:arcinus/features/memberships/presentation/providers/add_athlete_providers.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddAthleteScreen extends ConsumerWidget {
  final String academyId;
  const AddAthleteScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener la notificación y estado del formulario
    final addAthleteState = ref.watch(addAthleteNotifierProvider);
    final addAthleteNotifier = ref.read(addAthleteNotifierProvider.notifier);
    
    // Obtener los controladores de formulario
    final controllers = ref.watch(addAthleteControllersProvider);

    // Configurar título en la navegación
    ref.listen(addAthleteNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        // Mostrar snackbar de éxito y volver a la lista de atletas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atleta añadido correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (next.isError) {
        // Mostrar snackbar de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Error al añadir atleta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Efecto para configurar el título
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Añadir Nuevo Atleta';
    });

    // Obtener la lista de pasos
    List<Step> steps = _getSteps(context, ref, addAthleteState, controllers);

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
                if (isLastStep) {
                  // Obtener datos de los controladores para campos que puedan haberse editado
                  final firstName = controllers['firstName']!.text;
                  final lastName = controllers['lastName']!.text;
                  final phoneNumber = controllers['phoneNumber']!.text;
                  final heightCm = controllers['heightCm']!.text;
                  final weightKg = controllers['weightKg']!.text;
                  final allergies = controllers['allergies']!.text;
                  final medicalConditions = controllers['medicalConditions']!.text;
                  final emergencyContactName = controllers['emergencyContactName']!.text;
                  final emergencyContactPhone = controllers['emergencyContactPhone']!.text;
                  final position = controllers['position']!.text;
                  
                  // Actualizar estado con los valores más recientes
                  addAthleteNotifier.updateFirstName(firstName);
                  addAthleteNotifier.updateLastName(lastName);
                  addAthleteNotifier.updatePhoneNumber(phoneNumber);
                  addAthleteNotifier.updateHeight(heightCm);
                  addAthleteNotifier.updateWeight(weightKg);
                  addAthleteNotifier.updateAllergies(allergies);
                  addAthleteNotifier.updateMedicalConditions(medicalConditions);
                  addAthleteNotifier.updateEmergencyContactName(emergencyContactName);
                  addAthleteNotifier.updateEmergencyContactPhone(emergencyContactPhone);
                  addAthleteNotifier.updatePosition(position);
                  
                  final userId = 'usuario_actual'; // Este debería venir de un provider de autenticación
                  
                  // Enviar formulario
                  addAthleteNotifier.submitForm(academyId, userId);
                } else if (addAthleteState.isStepValid) {
                  addAthleteNotifier.nextStep();
                } else {
                  // Mostrar mensaje de error para campos requeridos
                  if (addAthleteState.currentStep == 0 && !addAthleteState.isPersonalInfoValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor complete los campos obligatorios'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
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

  List<Step> _getSteps(
    BuildContext context, 
    WidgetRef ref, 
    AddAthleteState state,
    Map<String, TextEditingController> controllers,
  ) {
    final addAthleteNotifier = ref.read(addAthleteNotifierProvider.notifier);
    final addAthleteControllers = ref.read(addAthleteControllersProvider.notifier);
    
    return <Step>[
      Step(
        state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 0,
        title: const Text('Información Personal'),
        content: Column(
          children: <Widget>[
            TextFormField(
              controller: controllers['firstName'],
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
              controller: controllers['lastName'],
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
              controller: controllers['birthDate'],
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
                if (picked != null) {
                  addAthleteNotifier.updateBirthDate(picked);
                  addAthleteControllers.setDateText(picked);
                }
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers['phoneNumber'],
              decoration: const InputDecoration(labelText: 'Número de Teléfono (Contacto)'),
              keyboardType: TextInputType.phone,
              onChanged: (value) => addAthleteNotifier.updatePhoneNumber(value),
            ),
          ],
        ),
      ),
      Step(
        state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 1,
        title: const Text('Información Física'),
        content: Column(
          children: <Widget>[
            TextFormField(
              controller: controllers['heightCm'],
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => addAthleteNotifier.updateHeight(value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers['weightKg'],
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => addAthleteNotifier.updateWeight(value),
            ),
          ],
        ),
      ),
      Step(
        state: state.currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 2,
        title: const Text('Información de Salud'),
        content: Column(
          children: <Widget>[
            TextFormField(
              controller: controllers['allergies'],
              decoration: const InputDecoration(labelText: 'Alergias Conocidas'),
              maxLines: 2,
              onChanged: (value) => addAthleteNotifier.updateAllergies(value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers['medicalConditions'],
              decoration: const InputDecoration(labelText: 'Condiciones Médicas Relevantes'),
              maxLines: 2,
              onChanged: (value) => addAthleteNotifier.updateMedicalConditions(value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers['emergencyContactName'],
              decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Nombre)'),
              onChanged: (value) => addAthleteNotifier.updateEmergencyContactName(value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllers['emergencyContactPhone'],
              decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Teléfono)'),
              keyboardType: TextInputType.phone,
              onChanged: (value) => addAthleteNotifier.updateEmergencyContactPhone(value),
            ),
          ],
        ),
      ),
      Step(
        state: state.currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 3,
        title: const Text('Información Deportiva'),
        content: Column(
          children: <Widget>[
            Consumer(
              builder: (context, ref, child) {
                final positionsAsync = ref.watch(sportPositionsProvider(academyId));
                
                return positionsAsync.when(
                  data: (positions) {
                    if (positions.isEmpty) {
                      return TextFormField(
                        controller: controllers['position'],
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
                          if (value != null) {
                            addAthleteNotifier.updatePosition(value);
                            controllers['position']!.text = value;
                          }
                        },
                      );
                    }
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => TextFormField(
                    controller: controllers['position'],
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
              controller: controllers['experience'] ?? TextEditingController(),
              decoration: const InputDecoration(labelText: 'Experiencia (años)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (addAthleteNotifier is AddAthleteNotifier) {
                  (addAthleteNotifier as dynamic).updateExperience(value);
                }
              },
            ),
            
            const SizedBox(height: 15),
            
            Consumer(
              builder: (context, ref, child) {
                final characteristicsAsync = ref.watch(academySportCharacteristicsProvider(academyId));
                
                return characteristicsAsync.when(
                  data: (characteristics) {
                    if (characteristics == null || characteristics.athleteSpecializations.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: null,
                      decoration: const InputDecoration(labelText: 'Especialización'),
                      items: characteristics.athleteSpecializations.map((specialization) => 
                        DropdownMenuItem(
                          value: specialization,
                          child: Text(specialization),
                        )
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          if (addAthleteNotifier is AddAthleteNotifier) {
                            (addAthleteNotifier as dynamic).updateSpecialization(value);
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
      Step(
        state: state.currentStep >= 4 ? StepState.complete : StepState.indexed,
        isActive: state.currentStep >= 4,
        title: const Text('Fotografía'),
        content: Column(
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
    ];
  }
} 