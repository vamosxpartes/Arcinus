import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/create_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/state/create_academy_state.dart';
import 'package:arcinus/core/theme/ui/loading/loading_indicator.dart'; // Usar el mismo LoadingIndicator
import 'package:arcinus/core/theme/ui/feedback/error_display.dart'; // Usar el mismo ErrorDisplay
import 'package:go_router/go_router.dart'; // Importar GoRouter
import 'package:arcinus/core/navigation/app_routes.dart'; // Importar rutas de la app
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class CreateAcademyScreen extends ConsumerStatefulWidget {
  const CreateAcademyScreen({super.key});

  @override
  ConsumerState<CreateAcademyScreen> createState() => _CreateAcademyScreenState();
}

class _CreateAcademyScreenState extends ConsumerState<CreateAcademyScreen> {
  // Ya no mantenemos el _currentStep aquí, ahora está en el estado
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // Arreglo de claves de formulario para cada paso
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Inicializando CreateAcademyScreen',
      className: 'CreateAcademyScreen',
      functionName: 'initState'
    );
    
    // Logging de controladores inicializados
    AppLogger.logInfo(
      'Controladores de texto inicializados',
      className: 'CreateAcademyScreen',
      functionName: 'initState',
      params: {
        'controllers': 'descripción, teléfono, email, dirección',
        'formKeys': '${_formKeys.length} formKeys'
      }
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo(
      'Liberando recursos de CreateAcademyScreen',
      className: 'CreateAcademyScreen',
      functionName: 'dispose'
    );
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Método para seleccionar una imagen
  Future<void> _pickImage() async {
    AppLogger.logInfo(
      'Iniciando selección de imagen',
      className: 'CreateAcademyScreen',
      functionName: '_pickImage'
    );
    final notifier = ref.read(createAcademyProvider.notifier);
    await notifier.selectAndUpdateLogo(ImageSource.gallery);
  }

  // Método para avanzar al siguiente paso
  void _nextStep(FormStep currentStep) {
    AppLogger.logInfo(
      'Intentando avanzar al siguiente paso',
      className: 'CreateAcademyScreen',
      functionName: '_nextStep',
      params: {
        'pasoActual': currentStep.name,
        'formKeyValid': (_formKeys[currentStep.index].currentState?.validate() ?? false).toString()
      }
    );
    
    if (_formKeys[currentStep.index].currentState!.validate()) {
      // Actualizar la información adicional antes de navegar
      final notifier = ref.read(createAcademyProvider.notifier);
      
      // Registrar los valores actuales que se van a guardar
      AppLogger.logInfo(
        'Guardando información antes de navegar',
        className: 'CreateAcademyScreen',
        functionName: '_nextStep',
        params: {
          'descripcion': _descriptionController.text.isEmpty ? 'vacía' : '${_descriptionController.text.length} caracteres',
          'telefono': _phoneController.text.isEmpty ? 'vacío' : _phoneController.text,
          'email': _emailController.text.isEmpty ? 'vacío' : _emailController.text,
          'direccion': _addressController.text.isEmpty ? 'vacía' : '${_addressController.text.length} caracteres'
        }
      );
      
      notifier.updateAdditionalInfo(
        description: _descriptionController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
      );
      
      // Navegar al siguiente paso según el paso actual
      switch (currentStep) {
        case FormStep.basicInfo:
          AppLogger.logInfo(
            'Navegando de información básica a información de contacto',
            className: 'CreateAcademyScreen',
            functionName: '_nextStep'
          );
          notifier.navigateToStep(FormStep.contactInfo);
          break;
        case FormStep.contactInfo:
          AppLogger.logInfo(
            'Navegando de información de contacto a selección de logo',
            className: 'CreateAcademyScreen',
            functionName: '_nextStep'
          );
          notifier.navigateToStep(FormStep.logoImage);
          break;
        case FormStep.logoImage:
          AppLogger.logInfo(
            'En el último paso, iniciando envío del formulario',
            className: 'CreateAcademyScreen',
            functionName: '_nextStep'
          );
          _submitForm();
          break;
      }
    } else {
      AppLogger.logWarning(
        'Validación fallida, no se puede avanzar al siguiente paso',
        className: 'CreateAcademyScreen',
        functionName: '_nextStep',
        params: {'pasoActual': currentStep.name}
      );
    }
  }

  // Método para retroceder al paso anterior
  void _previousStep(FormStep currentStep) {
    AppLogger.logInfo(
      'Retrocediendo al paso anterior',
      className: 'CreateAcademyScreen',
      functionName: '_previousStep',
      params: {'pasoActual': currentStep.name}
    );
    
    final notifier = ref.read(createAcademyProvider.notifier);
    
    switch (currentStep) {
      case FormStep.basicInfo:
        AppLogger.logInfo(
          'Ya en el primer paso, no se puede retroceder más',
          className: 'CreateAcademyScreen',
          functionName: '_previousStep'
        );
        break;
      case FormStep.contactInfo:
        AppLogger.logInfo(
          'Navegando de información de contacto a información básica',
          className: 'CreateAcademyScreen',
          functionName: '_previousStep'
        );
        notifier.navigateToStep(FormStep.basicInfo);
        break;
      case FormStep.logoImage:
        AppLogger.logInfo(
          'Navegando de selección de logo a información de contacto',
          className: 'CreateAcademyScreen',
          functionName: '_previousStep'
        );
        notifier.navigateToStep(FormStep.contactInfo);
        break;
    }
  }

  void _submitForm() {
    final notifier = ref.read(createAcademyProvider.notifier);
    
    // Actualizar por última vez la información adicional
    notifier.updateAdditionalInfo(
      description: _descriptionController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
    );
    
    AppLogger.logInfo(
      'Iniciando envío del formulario de creación',
      className: 'CreateAcademyScreen',
      functionName: '_submitForm',
      params: {
        'paso': notifier.state.maybeMap(
          initial: (s) => s.currentStep.index.toString(),
          orElse: () => '2'
        ),
        'nombre': notifier.nameController.text,
        'deporte': notifier.selectedSportCode ?? 'no seleccionado',
        'descripcion': _descriptionController.text.isEmpty ? 'vacío' : 'completo',
        'contacto': (_emailController.text.isNotEmpty || _phoneController.text.isNotEmpty) ? 'completo' : 'vacío',
        'tieneImagen': (notifier.state.maybeMap(
          initial: (s) => s.logoFile,
          navigating: (s) => s.logoFile,
          selectingImage: (s) => s.logoFile,
          loading: (s) => s.logoFile,
          error: (s) => s.logoFile,
          orElse: () => null,
        ) != null).toString()
      }
    );
    
    // Crear la academia
    notifier.createAcademy();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createAcademyProvider);
    final notifier = ref.read(createAcademyProvider.notifier);
    
    // Logging del estado actual en cada reconstrucción del widget
    AppLogger.logInfo(
      'Construyendo UI con estado actual',
      className: 'CreateAcademyScreen',
      functionName: 'build',
      params: {
        'estadoActual': state.runtimeType.toString(),
        'nombreAcademia': notifier.nameController.text.isEmpty ? 'vacío' : notifier.nameController.text,
        'deporteSeleccionado': notifier.selectedSportCode ?? 'no seleccionado'
      }
    );
    
    // Determinar el paso actual desde el estado
    final currentStep = state.maybeMap(
      initial: (s) => s.currentStep,
      navigating: (s) => s.currentStep,
      selectingImage: (s) => s.currentStep,
      loading: (s) => s.currentStep,
      error: (s) => s.currentStep,
      orElse: () => FormStep.basicInfo,
    );
    
    // Determinar el índice del paso actual para el Stepper
    final currentStepIndex = currentStep.index;
    
    // Determinar si está cargando
    final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);
    
    // Determinar si está seleccionando imagen
    final isSelectingImage = state.maybeMap(selectingImage: (_) => true, orElse: () => false);
    
    // Obtener el archivo de logo desde el estado
    final logoFile = state.maybeMap(
      initial: (s) => s.logoFile,
      navigating: (s) => s.logoFile,
      selectingImage: (s) => s.logoFile,
      loading: (s) => s.logoFile,
      error: (s) => s.logoFile,
      orElse: () => null,
    );

    // Extraer errores específicos del estado si existen
    String? nameErrorFromState;
    String? sportCodeErrorFromState;
    String? emailErrorFromState;
    
    state.maybeMap(
      error: (error) {
        nameErrorFromState = error.nameError;
        sportCodeErrorFromState = error.sportCodeError;
        emailErrorFromState = error.emailError;
      },
      orElse: () {},
    );

    // Escuchar para mostrar errores como Snackbars y manejar navegación
    ref.listen(createAcademyProvider, (previous, current) {
      current.maybeMap(
        error: (error) {
          // Comprobar si el estado anterior NO era initial o error
          final wasNotError = previous?.maybeMap(
            error: (_) => false,
            orElse: () => true,
          ) ?? true;
          
          if (wasNotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.failure.message}')), 
            );
          }
        },
        success: (success) {
          // La navegación debería ocurrir automáticamente por GoRouter.redirect
          AppLogger.logInfo('Academia creada con éxito ID: ${success.academyId}. GoRouter debería redirigir.');
          
          // Redirección manual al dashboard del propietario
          AppLogger.logInfo('Forzando redirección manual a la ruta del propietario');
          context.go(AppRoutes.ownerRoot);
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Academia'),
      ),
      body: Stack(
        children: [
          Stepper(
            currentStep: currentStepIndex,
            onStepContinue: () => _nextStep(currentStep),
            onStepCancel: () => _previousStep(currentStep),
            physics: const ClampingScrollPhysics(),
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    if (currentStepIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading || isSelectingImage ? null : details.onStepCancel,
                          child: const Text('Anterior'),
                        ),
                      ),
                    if (currentStepIndex > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading || isSelectingImage ? null : details.onStepContinue,
                        child: Text(currentStepIndex == 2 ? 'Crear' : 'Siguiente'),
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
                        enabled: !isLoading && !isSelectingImage,
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
                        onChanged: isLoading || isSelectingImage ? null : (value) {
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
                        enabled: !isLoading && !isSelectingImage,
                      ),
                    ],
                  ),
                ),
                isActive: currentStepIndex >= 0,
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
                        decoration: InputDecoration(
                          labelText: 'Email de contacto',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          errorText: emailErrorFromState,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !value.contains('@')) {
                            return 'Introduce un email válido';
                          }
                          return null;
                        },
                        enabled: !isLoading && !isSelectingImage,
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
                        enabled: !isLoading && !isSelectingImage,
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
                        enabled: !isLoading && !isSelectingImage,
                      ),
                    ],
                  ),
                ),
                isActive: currentStepIndex >= 1,
              ),
              
              // Paso 3: Imagen y vista previa
              Step(
                title: const Text('Logo e Imagen'),
                content: Form(
                  key: _formKeys[2],
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isLoading || isSelectingImage ? null : _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withAlpha(60),
                            borderRadius: BorderRadius.circular(75),
                            border: Border.all(
                              color: AppTheme.bonfireRed,
                              width: 2,
                            ),
                          ),
                          child: logoFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(75),
                                  child: Image.file(logoFile, fit: BoxFit.cover),
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
                                leading: logoFile != null
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(logoFile),
                                        radius: 20,
                                      )
                                    : CircleAvatar(
                                        backgroundColor: AppTheme.bonfireRed,
                                        radius: 20,
                                        child: Icon(Icons.sports, color: AppTheme.magnoliaWhite),
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
                isActive: currentStepIndex >= 2,
              ),
            ],
          ),
          // Mostrar widget de error si el estado es error
          state.maybeMap(
            error: (error) => Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ErrorDisplay(error: error.failure.message),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          // Indicador de carga o selección de imagen
          if (isLoading)
            const LoadingIndicator(message: 'Creando academia...'),
          if (isSelectingImage)
            const LoadingIndicator(message: 'Seleccionando imagen...'),
        ],
      ),
    );
  }
} 