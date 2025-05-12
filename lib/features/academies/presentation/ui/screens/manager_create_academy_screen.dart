import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/create_academy_provider.dart';
import 'package:arcinus/features/theme/ui/loading/loading_indicator.dart';
import 'package:arcinus/features/theme/ui/feedback/error_display.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManagerCreateAcademyScreen extends ConsumerStatefulWidget {
  const ManagerCreateAcademyScreen({super.key});

  @override
  ConsumerState<ManagerCreateAcademyScreen> createState() => _ManagerCreateAcademyScreenState();
}

class _ManagerCreateAcademyScreenState extends ConsumerState<ManagerCreateAcademyScreen> {
  int _currentStep = 0;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _logoImage;
  
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Inicializando ManagerCreateAcademyScreen',
      className: 'ManagerCreateAcademyScreen',
      functionName: 'initState'
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
      });
    }
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    AppLogger.logInfo(
      'Iniciando envío del formulario de creación desde Manager',
      className: 'ManagerCreateAcademyScreen',
      functionName: '_submitForm',
      params: {
        'paso': _currentStep.toString(),
        'nombre': ref.read(createAcademyProvider.notifier).nameController.text,
        'deporte': ref.read(createAcademyProvider.notifier).selectedSportCode ?? 'no seleccionado',
        'descripcion': _descriptionController.text.isEmpty ? 'vacío' : 'completo',
        'contacto': (_emailController.text.isNotEmpty || _phoneController.text.isNotEmpty) ? 'completo' : 'vacío',
        'tieneImagen': (_logoImage != null).toString()
      }
    );
    
    // Verificar que el formulario actual (paso 3) es válido
    final isCurrentFormValid = _formKeys[_currentStep].currentState?.validate() ?? false;
    
    AppLogger.logInfo(
      'Validación local del formulario',
      className: 'ManagerCreateAcademyScreen',
      functionName: '_submitForm',
      params: {
        'formValid': isCurrentFormValid.toString(),
        'currentStep': _currentStep.toString(),
      }
    );
    
    if (!isCurrentFormValid) {
      // Mostrar un mensaje de error si es necesario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa correctamente todos los campos')),
      );
      return;
    }
    
    final notifier = ref.read(createAcademyProvider.notifier);
    
    // Asegurarnos de que el formKey del notifier tenga un valor válido
    // Esto es un hack para que pase la validación en el notifier
    if (notifier.formKey.currentState == null) {
      // Asignar el formKey del notifier al formulario actual
      // O forzar a que se considere válido en el notifier
      AppLogger.logInfo(
        'Configurando formulario como pre-validado manualmente',
        className: 'ManagerCreateAcademyScreen',
        functionName: '_submitForm'
      );
      notifier.setFormPreValidated(true);
    }
    
    // Actualizar el notifier con los datos adicionales
    notifier.updateAdditionalInfo(
      description: _descriptionController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      logoFile: _logoImage
    );
    
    // Crear la academia
    notifier.createAcademy();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(createAcademyProvider.notifier);
    final state = ref.watch(createAcademyProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    // Extraer errores específicos del estado si existen
    String? nameErrorFromState;
    String? sportCodeErrorFromState;
    state.maybeWhen(
      error: (failure, nameError, sportCodeError) {
        nameErrorFromState = nameError;
        sportCodeErrorFromState = sportCodeError;
      },
      orElse: () {},
    );

    // Escuchar para mostrar errores como Snackbars (además del ErrorDisplay)
    ref.listen(createAcademyProvider, (previous, next) {
      next.maybeWhen(
        error: (failure, nameError, sportCodeError) {
          // Comprobar si el estado anterior NO era initial o error
          final wasNotInitialOrError = !(previous?.maybeMap(
                initial: (_) => true,
                error: (_) => true,
                orElse: () => false) ?? false);
          
          if (wasNotInitialOrError) {
            ScaffoldMessenger.of(context).showSnackBar(
              // Usar el mensaje del Failure
              SnackBar(content: Text('Error: ${failure.message}')), 
            );
          }
        },
        success: (academyId) {
          // En este caso, redirigir al dashboard de la academia recién creada
          AppLogger.logInfo('Academia creada con éxito ID: $academyId');
          
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Academia creada con éxito')),
          );
          
          // Redirección manual a la academia recién creada
          context.go('/manager/academy/$academyId');
        },
        orElse: () {},
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _previousStep,
            physics: const ClampingScrollPhysics(),
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Anterior'),
                        ),
                      ),
                    if (_currentStep > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : details.onStepContinue,
                        child: Text(_currentStep == 2 ? 'Crear' : 'Siguiente'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              // Paso 1: Información básica
              Step(
                title: const Text('Información Básica'),
                content: Form(
                  key: _formKeys[0],
                  child: Column(
                    children: [
                      TextFormField(
                        controller: notifier.nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Academia',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.business_rounded),
                          errorText: nameErrorFromState,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre de la academia';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: notifier.selectedSportCode,
                        hint: const Text('Selecciona un Deporte'),
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Deporte',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.sports_soccer),
                          errorText: sportCodeErrorFromState,
                        ),
                        items: notifier.availableSports.map((sport) {
                          return DropdownMenuItem<String>(
                            value: sport['code']!,
                            child: Text(sport['name']!),
                          );
                        }).toList(),
                        onChanged: isLoading ? null : (value) {
                          notifier.selectSport(value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Debes seleccionar un deporte';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        enabled: !isLoading,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
              ),
              
              // Paso 2: Información de contacto
              Step(
                title: const Text('Información de Contacto'),
                content: Form(
                  key: _formKeys[1],
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email de contacto',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !value.contains('@')) {
                            return 'Introduce un email válido';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        enabled: !isLoading,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
              ),
              
              // Paso 3: Imagen y vista previa
              Step(
                title: const Text('Logo e Imagen'),
                content: Form(
                  key: _formKeys[2],
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(
                              color: AppTheme.bonfireRed,
                              width: 2,
                            ),
                          ),
                          child: _logoImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(75),
                                  child: Image.file(_logoImage!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo, size: 40, color: AppTheme.bonfireRed),
                                    SizedBox(height: 8),
                                    Text('Añadir Logo', textAlign: TextAlign.center),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vista previa de tu Academia',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.bonfireRed,
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: _logoImage != null
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(_logoImage!),
                                        radius: 20,
                                      )
                                    : CircleAvatar(
                                        child: Icon(Icons.sports, color: AppTheme.magnoliaWhite),
                                        backgroundColor: AppTheme.bonfireRed,
                                        radius: 20,
                                      ),
                                title: Text(
                                  notifier.nameController.text.isEmpty 
                                      ? 'Nombre de la Academia' 
                                      : notifier.nameController.text,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  notifier.selectedSportCode != null
                                      ? notifier.availableSports
                                          .firstWhere((s) => s['code'] == notifier.selectedSportCode)['name']!
                                      : 'Deporte',
                                ),
                              ),
                              if (_descriptionController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(_descriptionController.text),
                                ),
                              if (_emailController.text.isNotEmpty || _phoneController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Información de contacto:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (_emailController.text.isNotEmpty)
                                        Text('Email: ${_emailController.text}'),
                                      if (_phoneController.text.isNotEmpty)
                                        Text('Teléfono: ${_phoneController.text}'),
                                    ],
                                  ),
                                ),
                              if (_addressController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Dirección: ${_addressController.text}'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          ),
          // Mostrar widget de error si el estado es error
          state.maybeWhen(
            error: (failure, nameError, sportCodeError) => Padding(
              padding: const EdgeInsets.only(top: 16.0),
              // Pasar el mensaje del failure genérico
              child: ErrorDisplay(error: failure.message),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          // Indicador de carga superpuesto
          if (isLoading)
            const LoadingIndicator(message: 'Creando academia...'),
        ],
      ),
    );
  }
} 