import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/payment_history_screen.dart';
import 'package:arcinus/features/dev_tools/presentation/widgets/title_monitor_widget.dart';

/// Modelo para representar un paso de navegación en la prueba
class NavigationStep {
  final String stepName;
  final String expectedTitle;
  final VoidCallback action;
  final String description;
  final bool isCompleted;
  final String? actualTitle;

  const NavigationStep({
    required this.stepName,
    required this.expectedTitle,
    required this.action,
    required this.description,
    this.isCompleted = false,
    this.actualTitle,
  });

  NavigationStep copyWith({
    String? stepName,
    String? expectedTitle,
    VoidCallback? action,
    String? description,
    bool? isCompleted,
    String? actualTitle,
  }) {
    return NavigationStep(
      stepName: stepName ?? this.stepName,
      expectedTitle: expectedTitle ?? this.expectedTitle,
      action: action ?? this.action,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      actualTitle: actualTitle ?? this.actualTitle,
    );
  }
}

/// Pantalla de prueba de integración para títulos del AppBar
class AppBarTitleIntegrationTestScreen extends ConsumerStatefulWidget {
  const AppBarTitleIntegrationTestScreen({super.key});

  @override
  ConsumerState<AppBarTitleIntegrationTestScreen> createState() => _AppBarTitleIntegrationTestScreenState();
}

class _AppBarTitleIntegrationTestScreenState extends ConsumerState<AppBarTitleIntegrationTestScreen> {
  List<NavigationStep> _steps = [];
  int _currentStepIndex = 0;
  bool _isTestRunning = false;
  bool _isTestCompleted = false;
  String _currentTitle = '';
  bool _titlePushed = false;

  @override
  void initState() {
    super.initState();
    
    // Actualizar el título del ManagerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_titlePushed) {
        ref.read(titleManagerProvider.notifier).pushTitle('AppBar Title Test');
        _titlePushed = true;
      }
    });
    
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps = [
      NavigationStep(
        stepName: 'Inicio',
        expectedTitle: 'AppBar Title Test',
        description: 'Pantalla inicial de prueba de títulos',
        action: () {
          // No hacer nada, ya estamos aquí
        },
      ),
      NavigationStep(
        stepName: 'Dashboard',
        expectedTitle: 'Panel de control',
        description: 'Navegar al dashboard del manager',
        action: () {
          context.go(AppRoutes.managerDashboard);
        },
      ),
      NavigationStep(
        stepName: 'Academia',
        expectedTitle: 'Academia', // Se actualizará con el nombre real
        description: 'Navegar a la pantalla de academia',
        action: () {
          final currentAcademy = ref.read(currentAcademyProvider);
          if (currentAcademy?.id != null) {
            context.go('/manager/academy/${currentAcademy!.id}');
          } else {
            _showError('No hay academia seleccionada');
          }
        },
      ),
      NavigationStep(
        stepName: 'Miembros',
        expectedTitle: 'Miembros',
        description: 'Navegar a la pantalla de miembros de la academia',
        action: () {
          final currentAcademy = ref.read(currentAcademyProvider);
          if (currentAcademy?.id != null) {
            context.go('/manager/academy/${currentAcademy!.id}/members');
          } else {
            _showError('No hay academia seleccionada');
          }
        },
      ),
      NavigationStep(
        stepName: 'Detalles de Usuario',
        expectedTitle: 'Detalles de', // Se completará con el nombre del usuario
        description: 'Navegar a los detalles de un usuario específico',
        action: () {
          _navigateToUserDetails();
        },
      ),
      NavigationStep(
        stepName: 'Historial de Pagos',
        expectedTitle: 'Historial de pagos',
        description: 'Navegar al historial de pagos del usuario',
        action: () {
          _navigateToPaymentHistory();
        },
      ),
      NavigationStep(
        stepName: 'Registro de Pago',
        expectedTitle: 'Gestión de Pagos',
        description: 'Navegar al registro de pagos',
        action: () {
          _navigateToRegisterPayment();
        },
      ),
    ];
  }



  void _verifyCurrentStepTitle(String actualTitle) {
    if (_currentStepIndex >= _steps.length) {
      AppLogger.logWarning(
        'Intento de verificar título fuera del rango de pasos',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_verifyCurrentStepTitle',
        params: {
          'currentStepIndex': _currentStepIndex,
          'totalSteps': _steps.length,
          'actualTitle': actualTitle,
        },
      );
      return;
    }
    
    final currentStep = _steps[_currentStepIndex];
    final isMatch = _titleMatches(actualTitle, currentStep.expectedTitle);
    
    setState(() {
      _steps[_currentStepIndex] = currentStep.copyWith(
        isCompleted: isMatch,
        actualTitle: actualTitle,
      );
    });
    
    AppLogger.logInfo(
      'Verificación automática de título',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_verifyCurrentStepTitle',
      params: {
        'stepIndex': _currentStepIndex,
        'stepName': currentStep.stepName,
        'expectedTitle': currentStep.expectedTitle,
        'actualTitle': actualTitle,
        'isMatch': isMatch,
        'testRunning': _isTestRunning,
      },
    );
    
    if (!isMatch) {
      AppLogger.logWarning(
        'Título no coincide con el esperado',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_verifyCurrentStepTitle',
        params: {
          'stepName': currentStep.stepName,
          'expected': currentStep.expectedTitle,
          'actual': actualTitle,
          'stepIndex': _currentStepIndex,
        },
      );
    } else {
      AppLogger.logInfo(
        'Título verificado correctamente',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_verifyCurrentStepTitle',
        params: {
          'stepName': currentStep.stepName,
          'title': actualTitle,
          'stepIndex': _currentStepIndex,
        },
      );
    }
  }

  bool _titleMatches(String actual, String expected) {
    // Normalizar espacios y caracteres especiales
    final normalizedActual = actual.trim().toLowerCase();
    final normalizedExpected = expected.trim().toLowerCase();
    
    // Para algunos títulos, verificamos que contengan el texto esperado
    if (expected == 'Academia') {
      // El título de academia incluye el nombre, así que verificamos que no sea el título anterior
      // y que contenga información de academia
      return actual != 'Miembros' && 
             actual != 'Panel de control' && 
             actual != 'AppBar Title Test' &&
             actual.isNotEmpty &&
             !actual.startsWith('Detalles de') &&
             !actual.startsWith('Historial de pagos') &&
             !actual.startsWith('Gestión de Pagos');
    }
    
    if (expected.startsWith('Detalles de')) {
      return normalizedActual.startsWith('detalles de');
    }
    
    if (expected.startsWith('Historial de pagos')) {
      return normalizedActual.startsWith('historial de pagos');
    }
    
    if (expected == 'Gestión de Pagos') {
      return normalizedActual.contains('gestión de pagos') || 
             normalizedActual.contains('gestion de pagos');
    }
    
    if (expected == 'Panel de control') {
      return normalizedActual.contains('panel') && 
             (normalizedActual.contains('control') || normalizedActual.contains('de'));
    }
    
    // Verificación exacta para otros casos
    return normalizedActual == normalizedExpected;
  }

  void _navigateToUserDetails() async {
    AppLogger.logInfo(
      'Iniciando navegación a detalles de usuario',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToUserDetails',
    );
    
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy?.id == null) {
      AppLogger.logError(
        message: 'No hay academia seleccionada para navegar a detalles de usuario',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToUserDetails',
      );
      _showError('No hay academia seleccionada');
      return;
    }

    AppLogger.logInfo(
      'Academia encontrada, obteniendo usuarios',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToUserDetails',
      params: {
        'academyId': currentAcademy!.id,
        'academyName': currentAcademy.name,
      },
    );

    try {
      // Obtener la lista de usuarios de la academia
      final usersAsync = ref.read(academyUsersProvider(currentAcademy.id!));
      
      usersAsync.when(
        data: (users) {
          AppLogger.logInfo(
            'Usuarios obtenidos exitosamente',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToUserDetails',
            params: {
              'usersCount': users.length,
            },
          );
          
          if (users.isNotEmpty) {
            // Tomar el primer usuario para la prueba
            final firstUser = users.first;
            
            AppLogger.logInfo(
              'Navegando a detalles del primer usuario',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToUserDetails',
              params: {
                'userId': firstUser.id,
                'userName': firstUser.fullName,
                'userRole': firstUser.role,
              },
            );
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AcademyUserDetailsScreen(
                  academyId: currentAcademy.id!,
                  userId: firstUser.id,
                  initialUserData: firstUser,
                ),
              ),
            );
          } else {
            AppLogger.logWarning(
              'No hay usuarios en la academia para la prueba',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToUserDetails',
              params: {
                'academyId': currentAcademy.id,
              },
            );
            _showError('No hay usuarios en la academia para probar');
          }
        },
        loading: () {
          AppLogger.logInfo(
            'Cargando usuarios de la academia',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToUserDetails',
          );
          _showError('Cargando usuarios...');
        },
        error: (error, _) {
          AppLogger.logError(
            message: 'Error al cargar usuarios de la academia',
            error: error,
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToUserDetails',
            params: {
              'academyId': currentAcademy.id,
            },
          );
          _showError('Error al cargar usuarios: $error');
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error crítico al navegar a detalles de usuario',
        error: e,
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToUserDetails',
        params: {
          'academyId': currentAcademy.id,
        },
      );
      _showError('Error al navegar a detalles de usuario: $e');
    }
  }

  void _navigateToPaymentHistory() async {
    AppLogger.logInfo(
      'Iniciando navegación a historial de pagos',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToPaymentHistory',
    );
    
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy?.id == null) {
      AppLogger.logError(
        message: 'No hay academia seleccionada para navegar a historial de pagos',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToPaymentHistory',
      );
      _showError('No hay academia seleccionada');
      return;
    }

    AppLogger.logInfo(
      'Academia encontrada, obteniendo usuarios para historial de pagos',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToPaymentHistory',
      params: {
        'academyId': currentAcademy!.id,
        'academyName': currentAcademy.name,
      },
    );

    try {
      // Obtener la lista de usuarios de la academia
      final usersAsync = ref.read(academyUsersProvider(currentAcademy.id!));
      
      usersAsync.when(
        data: (users) {
          AppLogger.logInfo(
            'Usuarios obtenidos para historial de pagos',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToPaymentHistory',
            params: {
              'usersCount': users.length,
            },
          );
          
          if (users.isNotEmpty) {
            // Tomar el primer usuario para la prueba
            final firstUser = users.first;
            
            AppLogger.logInfo(
              'Navegando a historial de pagos del primer usuario',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToPaymentHistory',
              params: {
                'userId': firstUser.id,
                'userName': firstUser.fullName,
              },
            );
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentHistoryScreen(
                  academyId: currentAcademy.id!,
                  athleteId: firstUser.id,
                  athleteName: firstUser.fullName,
                ),
              ),
            );
          } else {
            AppLogger.logWarning(
              'No hay usuarios en la academia para historial de pagos',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToPaymentHistory',
              params: {
                'academyId': currentAcademy.id,
              },
            );
            _showError('No hay usuarios en la academia para probar');
          }
        },
        loading: () {
          AppLogger.logInfo(
            'Cargando usuarios para historial de pagos',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToPaymentHistory',
          );
          _showError('Cargando usuarios...');
        },
        error: (error, _) {
          AppLogger.logError(
            message: 'Error al cargar usuarios para historial de pagos',
            error: error,
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToPaymentHistory',
            params: {
              'academyId': currentAcademy.id,
            },
          );
          _showError('Error al cargar usuarios: $error');
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error crítico al navegar a historial de pagos',
        error: e,
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToPaymentHistory',
        params: {
          'academyId': currentAcademy.id,
        },
      );
      _showError('Error al navegar a historial de pagos: $e');
    }
  }

  void _navigateToRegisterPayment() async {
    AppLogger.logInfo(
      'Iniciando navegación a registro de pago',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToRegisterPayment',
    );
    
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy?.id == null) {
      AppLogger.logError(
        message: 'No hay academia seleccionada para navegar a registro de pago',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToRegisterPayment',
      );
      _showError('No hay academia seleccionada');
      return;
    }

    AppLogger.logInfo(
      'Academia encontrada, obteniendo usuarios para registro de pago',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_navigateToRegisterPayment',
      params: {
        'academyId': currentAcademy!.id,
        'academyName': currentAcademy.name,
      },
    );

    try {
      // Obtener la lista de usuarios de la academia
      final usersAsync = ref.read(academyUsersProvider(currentAcademy.id!));
      
      usersAsync.when(
        data: (users) {
          AppLogger.logInfo(
            'Usuarios obtenidos para registro de pago',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToRegisterPayment',
            params: {
              'usersCount': users.length,
            },
          );
          
          if (users.isNotEmpty) {
            // Tomar el primer usuario para la prueba
            final firstUser = users.first;
            
            AppLogger.logInfo(
              'Navegando a registro de pago del primer usuario',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToRegisterPayment',
              params: {
                'userId': firstUser.id,
                'userName': firstUser.fullName,
              },
            );
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RegisterPaymentScreen(
                  athleteId: firstUser.id,
                ),
              ),
            );
          } else {
            AppLogger.logWarning(
              'No hay usuarios en la academia para registro de pago',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_navigateToRegisterPayment',
              params: {
                'academyId': currentAcademy.id,
              },
            );
            _showError('No hay usuarios en la academia para probar');
          }
        },
        loading: () {
          AppLogger.logInfo(
            'Cargando usuarios para registro de pago',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToRegisterPayment',
          );
          _showError('Cargando usuarios...');
        },
        error: (error, _) {
          AppLogger.logError(
            message: 'Error al cargar usuarios para registro de pago',
            error: error,
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_navigateToRegisterPayment',
            params: {
              'academyId': currentAcademy.id,
            },
          );
          _showError('Error al cargar usuarios: $error');
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error crítico al navegar a registro de pago',
        error: e,
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_navigateToRegisterPayment',
        params: {
          'academyId': currentAcademy.id,
        },
      );
      _showError('Error al navegar a registro de pago: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startTest() {
    setState(() {
      _isTestRunning = true;
      _isTestCompleted = false;
      _currentStepIndex = 0;
      
      // Reinicializar todos los pasos
      _steps = _steps.map((step) => step.copyWith(
        isCompleted: false,
        actualTitle: null,
      )).toList();
    });
    
    AppLogger.logInfo(
      'Iniciando prueba de integración de títulos automática',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_startTest',
      params: {
        'totalSteps': _steps.length,
        'currentTitle': _currentTitle,
      },
    );
    
    // Verificar el título inicial
    _verifyCurrentStepTitle(_currentTitle);
    
    // Iniciar navegación automática después de un breve delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isTestRunning) {
        _executeNextStep();
      }
    });
  }

  void _resetTest() {
    setState(() {
      _isTestRunning = false;
      _isTestCompleted = false;
      _currentStepIndex = 0;
      
      // Reinicializar todos los pasos
      _steps = _steps.map((step) => step.copyWith(
        isCompleted: false,
        actualTitle: null,
      )).toList();
    });
    
    AppLogger.logInfo(
      'Reiniciando prueba de integración de títulos',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_resetTest',
    );
  }

  void _executeNextStep() {
    if (_currentStepIndex >= _steps.length) {
      AppLogger.logInfo(
        'Todos los pasos completados, finalizando prueba',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_executeNextStep',
        params: {
          'totalSteps': _steps.length,
          'completedSteps': _steps.where((s) => s.isCompleted).length,
        },
      );
      _completeTest();
      return;
    }

    final currentStep = _steps[_currentStepIndex];
    
    AppLogger.logInfo(
      'Ejecutando paso de prueba automático',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_executeNextStep',
      params: {
        'stepIndex': _currentStepIndex,
        'stepName': currentStep.stepName,
        'expectedTitle': currentStep.expectedTitle,
        'currentTitle': _currentTitle,
        'description': currentStep.description,
      },
    );
    
    // Ejecutar la acción del paso
    try {
      AppLogger.logInfo(
        'Iniciando acción del paso',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_executeNextStep',
        params: {
          'stepName': currentStep.stepName,
          'action': 'executing',
        },
      );
      
      currentStep.action();
      
      AppLogger.logInfo(
        'Acción del paso ejecutada exitosamente',
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_executeNextStep',
        params: {
          'stepName': currentStep.stepName,
          'action': 'completed',
        },
      );
      
      // Esperar un poco para que se procese la navegación
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          AppLogger.logInfo(
            'Avanzando al siguiente paso',
            className: 'AppBarTitleIntegrationTestScreen',
            functionName: '_executeNextStep',
            params: {
              'currentStepIndex': _currentStepIndex,
              'nextStepIndex': _currentStepIndex + 1,
              'currentTitle': _currentTitle,
            },
          );
          
          setState(() {
            _currentStepIndex++;
          });
          
          // Si no es el último paso, continuar automáticamente
          if (_currentStepIndex < _steps.length) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted && _isTestRunning) {
                AppLogger.logInfo(
                  'Continuando con navegación automática',
                  className: 'AppBarTitleIntegrationTestScreen',
                  functionName: '_executeNextStep',
                  params: {
                    'nextStepIndex': _currentStepIndex,
                    'remainingSteps': _steps.length - _currentStepIndex,
                  },
                );
                _executeNextStep();
              }
            });
          } else {
            AppLogger.logInfo(
              'Último paso alcanzado, completando prueba',
              className: 'AppBarTitleIntegrationTestScreen',
              functionName: '_executeNextStep',
            );
            _completeTest();
          }
        }
      });
    } catch (e) {
      AppLogger.logError(
        message: 'Error crítico ejecutando paso de prueba automática',
        error: e,
        className: 'AppBarTitleIntegrationTestScreen',
        functionName: '_executeNextStep',
        params: {
          'stepName': currentStep.stepName,
          'stepIndex': _currentStepIndex,
          'expectedTitle': currentStep.expectedTitle,
          'currentTitle': _currentTitle,
        },
      );
      
      _showError('Error en el paso ${currentStep.stepName}: $e');
      
      // Detener la prueba automática en caso de error
      setState(() {
        _isTestRunning = false;
      });
    }
  }

  void _completeTest() {
    setState(() {
      _isTestRunning = false;
      _isTestCompleted = true;
    });
    
    final completedSteps = _steps.where((step) => step.isCompleted).length;
    final totalSteps = _steps.length;
    
    AppLogger.logInfo(
      'Prueba de integración completada',
      className: 'AppBarTitleIntegrationTestScreen',
      functionName: '_completeTest',
      params: {
        'completedSteps': completedSteps,
        'totalSteps': totalSteps,
        'successRate': '${(completedSteps / totalSteps * 100).toStringAsFixed(1)}%',
      },
    );
    
    // Mostrar resultado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: Text(
          'Prueba Completada',
          style: TextStyle(color: AppTheme.magnoliaWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pasos completados: $completedSteps/$totalSteps',
              style: TextStyle(color: AppTheme.lightGray),
            ),
            Text(
              'Tasa de éxito: ${(completedSteps / totalSteps * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: completedSteps == totalSteps ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: AppTheme.bonfireRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el título actual
    final currentTitle = ref.watch(titleManagerProvider);
    
    // Escuchar cambios en el título usando el TitleManager
    ref.listen(titleManagerProvider, (previous, current) {
      if (mounted && previous != current) {
        setState(() {
          _currentTitle = current;
        });
        
        AppLogger.logInfo(
          'Título cambiado durante la prueba',
          className: 'AppBarTitleIntegrationTestScreen',
          functionName: 'build',
          params: {
            'previousTitle': previous,
            'currentTitle': current,
            'currentStep': _currentStepIndex < _steps.length ? _steps[_currentStepIndex].stepName : 'N/A',
          },
        );
        
        // Verificar si el título coincide con el esperado
        if (_isTestRunning && _currentStepIndex < _steps.length) {
          _verifyCurrentStepTitle(current);
        }
      }
    });
    
    // Actualizar el título actual si no está inicializado
    if (_currentTitle.isEmpty && currentTitle.isNotEmpty) {
      _currentTitle = currentTitle;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _titlePushed) {
          // Restaurar el título anterior cuando se hace pop
          ref.read(titleManagerProvider.notifier).popTitle();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.blackSwarm,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.bonfireRed.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.bonfireRed.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.title,
                          color: AppTheme.bonfireRed,
                          size: 24,
                        ),
                        SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'AppBar Title Integration Test',
                          style: TextStyle(
                            color: AppTheme.bonfireRed,
                            fontSize: AppTheme.bodySize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Esta prueba navega por diferentes pantallas y verifica que los títulos del AppBar se actualicen correctamente.',
                      style: TextStyle(
                        color: AppTheme.lightGray,
                        fontSize: AppTheme.secondarySize,
                        letterSpacing: 0.25,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Título actual: $_currentTitle',
                      style: TextStyle(
                        color: AppTheme.magnoliaWhite,
                        fontSize: AppTheme.secondarySize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppTheme.spacingLg),
              
                             // Controles de prueba
               Column(
                 children: [
                   // Primera fila - Botón principal
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: _isTestRunning ? null : _startTest,
                       icon: Icon(_isTestRunning ? Icons.hourglass_empty : Icons.play_arrow),
                       label: Text(_isTestRunning ? 'Ejecutando...' : 'Iniciar Prueba'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.bonfireRed,
                         foregroundColor: AppTheme.magnoliaWhite,
                         padding: EdgeInsets.symmetric(vertical: 12),
                       ),
                     ),
                   ),
                   
                   SizedBox(height: AppTheme.spacingSm),
                   
                   // Segunda fila - Botones secundarios
                   Row(
                     children: [
                       if (_isTestRunning)
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: () {
                               setState(() {
                                 _isTestRunning = false;
                               });
                               AppLogger.logInfo(
                                 'Prueba automática detenida por el usuario',
                                 className: 'AppBarTitleIntegrationTestScreen',
                                 functionName: 'build',
                                 params: {
                                   'currentStepIndex': _currentStepIndex,
                                   'totalSteps': _steps.length,
                                 },
                               );
                             },
                             icon: Icon(Icons.stop),
                             label: Text('Detener'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppTheme.goldTrophy,
                               foregroundColor: AppTheme.magnoliaWhite,
                               padding: EdgeInsets.symmetric(vertical: 12),
                             ),
                           ),
                         ),
                       if (!_isTestRunning && (_isTestCompleted || _currentStepIndex > 0))
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: _resetTest,
                             icon: Icon(Icons.refresh),
                             label: Text('Reiniciar'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppTheme.courtGreen,
                               foregroundColor: AppTheme.magnoliaWhite,
                               padding: EdgeInsets.symmetric(vertical: 12),
                             ),
                           ),
                         ),
                     ],
                   ),
                 ],
               ),
              
                             SizedBox(height: AppTheme.spacingLg),
               
               // Monitor de títulos
               TitleMonitorWidget(
                 onTitleChanged: (newTitle) {
                   // Verificar automáticamente el título cuando cambie
                   if (_isTestRunning && _currentStepIndex < _steps.length) {
                     _verifyCurrentStepTitle(newTitle);
                   }
                 },
                 showHistory: true,
                 maxHistoryItems: 5, // Reducir el número de elementos del historial
               ),
               
               SizedBox(height: AppTheme.spacingLg),
               
               // Lista de pasos
              Text(
                'Pasos de la Prueba:',
                style: TextStyle(
                  color: AppTheme.magnoliaWhite,
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: AppTheme.spacingSm),
              
              // Lista de pasos (sin Expanded para permitir scroll general)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                    final step = _steps[index];
                    final isCurrentStep = index == _currentStepIndex && _isTestRunning;
                    
                    return Card(
                      color: isCurrentStep 
                          ? AppTheme.nbaBluePrimary.withAlpha(40)
                          : AppTheme.darkGray,
                      margin: EdgeInsets.only(bottom: AppTheme.spacingSm),
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingMd),
                        child: Row(
                          children: [
                            // Icono de estado
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: step.isCompleted 
                                    ? Colors.green
                                    : isCurrentStep
                                        ? AppTheme.nbaBluePrimary
                                        : AppTheme.lightGray,
                              ),
                              child: Icon(
                                step.isCompleted 
                                    ? Icons.check
                                    : isCurrentStep
                                        ? Icons.play_arrow
                                        : Icons.radio_button_unchecked,
                                color: AppTheme.magnoliaWhite,
                                size: 16,
                              ),
                            ),
                            
                            SizedBox(width: AppTheme.spacingMd),
                            
                            // Contenido del paso
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${step.stepName}',
                                    style: TextStyle(
                                      color: AppTheme.magnoliaWhite,
                                      fontSize: AppTheme.bodySize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    step.description,
                                    style: TextStyle(
                                      color: AppTheme.lightGray,
                                      fontSize: AppTheme.secondarySize,
                                    ),
                                  ),
                                  Text(
                                    'Título esperado: ${step.expectedTitle}',
                                    style: TextStyle(
                                      color: AppTheme.goldTrophy,
                                      fontSize: AppTheme.secondarySize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (step.actualTitle != null)
                                    Text(
                                      'Título actual: ${step.actualTitle}',
                                      style: TextStyle(
                                        color: step.isCompleted ? Colors.green : Colors.orange,
                                        fontSize: AppTheme.secondarySize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 