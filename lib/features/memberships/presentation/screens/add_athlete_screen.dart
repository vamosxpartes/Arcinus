import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddAthleteScreen extends ConsumerStatefulWidget {
  final String academyId;
  const AddAthleteScreen({super.key, required this.academyId});

  @override
  ConsumerState<AddAthleteScreen> createState() => _AddAthleteScreenState();
}

class _AddAthleteScreenState extends ConsumerState<AddAthleteScreen> {
  int _currentStep = 0;

  // TODO: Definir controladores para los campos del formulario

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Añadir Nuevo Atleta';
       // Asegurarse que el currentAcademyIdProvider está actualizado si es necesario
      final currentAcademy = ref.read(currentAcademyIdProvider);
      if (currentAcademy == null || currentAcademy != widget.academyId) {
        // Potencialmente actualizar, aunque la navegación debería manejar esto
        // ref.read(currentAcademyIdProvider.notifier).state = widget.academyId;
      }
    });
  }

  List<Step> _getSteps() {
    return <Step>[
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: const Text('Información Personal'),
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombres Completos'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Apellidos Completos'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
              // TODO: validator, onSaved, DatePicker
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Número de Teléfono (Contacto)'),
              // TODO: validator, onSaved
            ),
            // ... más campos personales
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: const Text('Información Física'),
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              // TODO: validator, onSaved
            ),
            // ... más campos físicos
          ],
        ),
      ),
      Step(
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 2,
        title: const Text('Información de Salud'),
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Alergias Conocidas'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Condiciones Médicas Relevantes'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Nombre)'),
              // TODO: validator, onSaved
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contacto de Emergencia (Teléfono)'),
              // TODO: validator, onSaved
            ),
            // ... más campos de salud
          ],
        ),
      ),
      Step(
        state: _currentStep >= 3 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 3,
        title: const Text('Información Deportiva'),
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Posición Principal'),
              // TODO: validator, onSaved
            ),
            // TODO: Experiencia previa (Switch/Checkbox + TextField), Nivel de Habilidad (Dropdown)
            // ... más campos deportivos
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          final isLastStep = _currentStep == _getSteps().length - 1;
          if (isLastStep) {
            // TODO: Lógica para enviar el formulario
            print('Formulario completado y enviado');
          } else {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: _getSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _currentStep == _getSteps().length - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 140, // Ancho fijo para evitar el error de BoxConstraints
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'GUARDAR' : 'SIGUIENTE'),
                  ),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('ANTERIOR'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
} 