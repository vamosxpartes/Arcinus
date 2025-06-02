import 'package:arcinus/core/utils/constants/app_assets.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/core/auth/presentation/state/auth_state.dart';
import 'package:arcinus/core/auth/presentation/ui/widgets/password_strength_meter.dart';
import 'package:arcinus/core/auth/presentation/ui/widgets/profile_image_picker.dart';
import 'package:arcinus/core/auth/presentation/ui/widgets/smart_error_text.dart';
import 'package:arcinus/core/auth/presentation/providers/registration_form_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Pantalla para registrar un nuevo usuario con formulario por pasos.
///
/// Se implementa usando un enfoque personalizado con IndexedStack 
/// y se integra con los providers de autenticación de Riverpod.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Crea una instancia de [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // FormGroups para cada paso
  final _credentialsFormGroup = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
    'confirmPassword': FormControl<String>(
      validators: [Validators.required],
    ),
  }, validators: [
    Validators.mustMatch('password', 'confirmPassword'),
  ]);

  final _profileFormGroup = FormGroup({
    'displayName': FormControl<String>(
      validators: [Validators.required],
    ),
    'lastName': FormControl<String>(
      validators: [Validators.required],
    ),
    'phoneNumber': FormControl<String>(),
  });

  // Controladores para observar cambios en tiempo real
  late TextEditingController _passwordController;
  
  // Conectividad para registro en modo offline
  final _connectivityProvider = StreamProvider<bool>((ref) {
    return Connectivity().onConnectivityChanged.map((result) {
      return !result.contains(ConnectivityResult.none);
    });
  });

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _credentialsFormGroup.control('password').valueChanges.listen((value) {
      _passwordController.text = value as String? ?? '';
    });
    
    // Cargar datos guardados previamente
    _loadSavedFormData();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFormData() async {
    // Aquí implementaremos la carga desde Hive/SharedPreferences
    final formData = ref.read(registrationFormProvider);
    
    if (formData.email.isNotEmpty) {
      _credentialsFormGroup.control('email').value = formData.email;
    }
    // Cargar otros campos guardados
  }

  // Guardar progreso automáticamente
  void _saveFormProgress() {
    final notifier = ref.read(registrationFormProvider.notifier);
    
    // Guardar datos del formulario actual
    if (_credentialsFormGroup.valid) {
      notifier.updateEmail(_credentialsFormGroup.control('email').value as String?);
      notifier.updatePassword(_credentialsFormGroup.control('password').value as String?);
    }
    
    if (_profileFormGroup.valid) {
      notifier.updateName(_profileFormGroup.control('displayName').value as String?);
      notifier.updateLastName(_profileFormGroup.control('lastName').value as String?);
      if (_profileFormGroup.control('phoneNumber').value != null) {
        notifier.updatePhone(_profileFormGroup.control('phoneNumber').value as String?);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Observar el estado de autenticación para mostrar errores
    final authState = ref.watch(authStateNotifierProvider);
    final isOnline = ref.watch(_connectivityProvider).value ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner de conectividad
          if (!isOnline)
            Container(
              color: Colors.orange[100],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexión. Puedes continuar completando el formulario, pero necesitarás conectarte a internet para finalizar el registro.',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          
          // Cuerpo principal
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Diseño adaptativo
                if (constraints.maxWidth > 900) {
                  return _buildWideLayout(theme, textTheme, authState);
                } else {
                  return _buildCompactLayout(theme, textTheme, authState);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Layout para pantallas grandes (tablet/desktop)
  Widget _buildWideLayout(ThemeData theme, TextTheme textTheme, dynamic authState) {
    return Row(
      children: [
        // Panel informativo lateral
        Expanded(
          flex: 2,
          child: Container(
            color: theme.primaryColor.withAlpha(30),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.logoBlack,
                  height: 100,
                ),
                const SizedBox(height: 32),
                Text(
                  'Bienvenido a Arcinus',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'La plataforma integral para gestionar tu academia deportiva',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Indicador de progreso
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: Colors.grey[300],
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Paso ${_currentStep + 1} de 3',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        // Formulario
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título del paso actual
                Text(
                  _getStepTitle(),
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Formulario actual
                _buildCurrentForm(authState),
                
                // Botones de navegación
                const SizedBox(height: 32),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Layout para pantallas pequeñas (móvil)
  Widget _buildCompactLayout(ThemeData theme, TextTheme textTheme, dynamic authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                AppAssets.logoBlack,
                height: 80,
              ),
            ),
          ),

          // Título y progreso
          Text(
            'Crea tu cuenta',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${_currentStep + 1} de 3',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey[300],
            color: AppTheme.bonfireRed ,
          ),
          const SizedBox(height: 24),
          
          // Título del paso actual
          Text(
            _getStepTitle(),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Formulario actual
          _buildCurrentForm(authState),
          
          // Botones de navegación
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // Obtener el título del paso actual
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Datos de acceso';
      case 1:
        return 'Información personal';
      case 2:
        return 'Configuración de academia';
      default:
        return '';
    }
  }

  // Construir el formulario actual según el paso
  Widget _buildCurrentForm(dynamic authState) {
    switch (_currentStep) {
      case 0:
        return _buildCredentialsForm(authState);
      case 1:
        return _buildProfileForm();
      case 2:
        return _buildAcademyForm();
      default:
        return const SizedBox();
    }
  }

  // Construir los botones de navegación
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botón Anterior (excepto en el primer paso)
        _currentStep > 0
            ? Expanded(
                child: OutlinedButton(
                  onPressed: _handleCancel,
                  child: const Text('ANTERIOR'),
                ),
              )
            : const Spacer(),
            
        const SizedBox(width: 16),
        
        // Botón Siguiente/Crear cuenta
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleContinue,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_currentStep < 2 ? 'SIGUIENTE' : 'CREAR CUENTA'),
          ),
        ),
      ],
    );
  }

  // Formulario de credenciales (paso 1)
  Widget _buildCredentialsForm(dynamic authState) {
    // Verificamos si es una instancia de AuthState y si tiene error
    final hasError = authState is AuthState && authState.hasError;
    
    return ReactiveForm(
      formGroup: _credentialsFormGroup,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          ReactiveTextField<String>(
            formControlName: 'email',
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validationMessages: {
              'required': (error) => 'El correo electrónico es obligatorio',
              'email': (error) => 'Por favor ingresa un correo electrónico válido',
            },
          ),
          const SizedBox(height: 16),

          // Password
          ReactiveTextField<String>(
            formControlName: 'password',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              'required': (error) => 'La contraseña es obligatoria',
              'minLength': (error) => 'La contraseña debe tener al menos 6 caracteres',
            },
          ),
          
          // Indicador de fortaleza de contraseña
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: PasswordStrengthMeter(
              password: _passwordController.text,
            ),
          ),

          // Confirm Password
          ReactiveTextField<String>(
            formControlName: 'confirmPassword',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              'required': (error) => 'Por favor confirma tu contraseña',
              'mustMatch': (error) => 'Las contraseñas no coinciden',
            },
          ),
          const SizedBox(height: 16),

          // Mostrar errores de auth si los hay
          if (hasError && !_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SmartErrorText(
                error: authState.error?.toString(),
                field: 'auth',
              ),
            ),

          // Opción de iniciar sesión
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('¿Ya tienes una cuenta?', 
                       style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Inicia sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formulario de perfil (paso 2)
  Widget _buildProfileForm() {
    return ReactiveForm(
      formGroup: _profileFormGroup,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de imagen de perfil
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: ProfileImagePicker(),
            ),
          ),
          
          // Nombre
          ReactiveTextField<String>(
            formControlName: 'displayName',
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              'required': (error) => 'El nombre es obligatorio',
            },
          ),
          const SizedBox(height: 16),
          
          // Apellido
          ReactiveTextField<String>(
            formControlName: 'lastName',
            decoration: const InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              'required': (error) => 'El apellido es obligatorio',
            },
          ),
          const SizedBox(height: 16),
           
          // Teléfono (opcional)
          ReactiveTextField<String>(
            formControlName: 'phoneNumber',
            decoration: const InputDecoration(
              labelText: 'Teléfono (opcional)',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // Formulario de academia (paso 3)
  Widget _buildAcademyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Casi listo!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Después de crear tu cuenta, podrás configurar tu academia deportiva con toda la información necesaria.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Términos y condiciones
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Términos y condiciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Al crear una cuenta, aceptas los términos y condiciones de uso de la plataforma Arcinus.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Acepto los términos y condiciones'),
                  value: true, // Conectar con un estado real
                  onChanged: (value) {
                    // Implementar lógica
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Manejar botón continuar
  void _handleContinue() {
    if (_currentStep == 0) {
      if (_credentialsFormGroup.valid) {
        setState(() {
          _currentStep = 1;
          _saveFormProgress();
        });
        // Registrar analytics
        _trackRegistrationStep(1, isSuccess: true);
      } else {
        _credentialsFormGroup.markAllAsTouched();
        // Registrar analytics
        _trackRegistrationStep(1, isSuccess: false);
      }
    } else if (_currentStep == 1) {
      if (_profileFormGroup.valid) {
        setState(() {
          _currentStep = 2;
          _saveFormProgress();
        });
        // Registrar analytics
        _trackRegistrationStep(2, isSuccess: true);
      } else {
        _profileFormGroup.markAllAsTouched();
        // Registrar analytics
        _trackRegistrationStep(2, isSuccess: false);
      }
    } else if (_currentStep == 2) {
      _register();
    }
  }

  // Manejar botón anterior
  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Registrar usuario
  Future<void> _register() async {
    if (_credentialsFormGroup.valid && _profileFormGroup.valid) {
      final email = _credentialsFormGroup.control('email').value as String;
      final password = _credentialsFormGroup.control('password').value as String;
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        AppLogger.logInfo('Iniciando registro de usuario: $email');
        
        // Utilizamos el método correcto para crear un usuario
        await ref.read(authStateNotifierProvider.notifier).createUserWithEmailAndPassword(
          email, 
          password,
        );
        
        // Si llegamos aquí, la operación fue exitosa (de lo contrario habría lanzado una excepción)
        AppLogger.logInfo('Usuario registrado con éxito');
        _trackRegistrationStep(3, isSuccess: true);
        // El provider de auth se encargará de la redirección
        
      } catch (e, s) {
        setState(() {
          _isLoading = false;
        });
        AppLogger.logError(
          message: 'Error inesperado en registro',
          error: e,
          stackTrace: s,
        );
        _trackRegistrationStep(3, isSuccess: false);
      }
    } else {
      if (!_credentialsFormGroup.valid) {
        setState(() {
          _currentStep = 0;
        });
        _credentialsFormGroup.markAllAsTouched();
      } else if (!_profileFormGroup.valid) {
        setState(() {
          _currentStep = 1;
        });
        _profileFormGroup.markAllAsTouched();
      }
    }
  }
  
  // Registrar analítica
  void _trackRegistrationStep(int step, {bool isSuccess = true}) {
    // Aquí integraremos con FirebaseAnalytics
    AppLogger.logInfo('Registration Step $step: ${isSuccess ? 'Success' : 'Failed'}');
  }
} 