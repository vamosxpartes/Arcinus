import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/dev_tools/presentation/screens/appbar_title_integration_test_screen.dart';

/// Modelo para representar un caso de uso de prueba
class UseCaseTest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const UseCaseTest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// Pantalla para probar diferentes casos de uso de la aplicación
class UseCaseTestScreen extends ConsumerWidget {
  const UseCaseTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useCases = _getUseCases(context);

    return Scaffold(
      backgroundColor: AppTheme.blackSwarm,
      appBar: AppBar(
        title: const Text('Test de Casos de Uso'),
        backgroundColor: AppTheme.blackSwarm,
        foregroundColor: AppTheme.magnoliaWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.goldTrophy.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldTrophy.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: AppTheme.goldTrophy,
                        size: 24,
                      ),
                      SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Herramientas de Desarrollo',
                        style: TextStyle(
                          color: AppTheme.goldTrophy,
                          fontSize: AppTheme.bodySize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Prueba diferentes funcionalidades y casos de uso de la aplicación para validar el comportamiento esperado.',
                    style: TextStyle(
                      color: AppTheme.lightGray,
                      fontSize: AppTheme.secondarySize,
                      letterSpacing: 0.25,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppTheme.spacingLg),
            
            // Lista de casos de uso
            Expanded(
              child: ListView.separated(
                itemCount: useCases.length,
                separatorBuilder: (context, index) => SizedBox(height: AppTheme.spacingMd),
                itemBuilder: (context, index) {
                  final useCase = useCases[index];
                  return _buildUseCaseCard(context, useCase);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta para un caso de uso
  Widget _buildUseCaseCard(BuildContext context, UseCaseTest useCase) {
    return Card(
      color: AppTheme.darkGray,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: useCase.color.withAlpha(60),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: useCase.onTap ?? () => _showNotImplemented(context, useCase.title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Icono
              Container(
                padding: EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: useCase.color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  useCase.icon,
                  color: useCase.color,
                  size: 24,
                ),
              ),
              
              SizedBox(width: AppTheme.spacingMd),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      useCase.title,
                      style: TextStyle(
                        color: AppTheme.magnoliaWhite,
                        fontSize: AppTheme.bodySize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXs),
                    Text(
                      useCase.description,
                      style: TextStyle(
                        color: AppTheme.lightGray,
                        fontSize: AppTheme.secondarySize,
                        letterSpacing: 0.25,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.lightGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene la lista de casos de uso disponibles
  List<UseCaseTest> _getUseCases(BuildContext context) {
    return [
      UseCaseTest(
        id: 'appbar_title_test',
        title: 'AppBar Title Test',
        description: 'Prueba la funcionalidad de títulos dinámicos en la barra de aplicación',
        icon: Icons.title,
        color: AppTheme.bonfireRed,
        onTap: () => _testAppBarTitle(context),
      ),
      UseCaseTest(
        id: 'create_user_test',
        title: 'Create User Test',
        description: 'Simula el proceso de creación de usuarios y validación de datos',
        icon: Icons.person_add,
        color: AppTheme.nbaBluePrimary,
        onTap: () => _testCreateUser(context),
      ),
      UseCaseTest(
        id: 'user_payment_test',
        title: 'User Payment Test',
        description: 'Prueba el flujo de pagos y transacciones de usuarios',
        icon: Icons.payment,
        color: AppTheme.goldTrophy,
        onTap: () => _testUserPayment(context),
      ),
             UseCaseTest(
         id: 'navigation_test',
         title: 'Navigation Test',
         description: 'Valida la navegación entre pantallas y rutas de la aplicación',
         icon: Icons.navigation,
         color: AppTheme.courtGreen,
         onTap: () => _testNavigation(context),
       ),
       UseCaseTest(
         id: 'auth_flow_test',
         title: 'Authentication Flow Test',
         description: 'Prueba el flujo completo de autenticación y autorización',
         icon: Icons.security,
         color: AppTheme.nbaBluePrimary,
         onTap: () => _testAuthFlow(context),
       ),
       UseCaseTest(
         id: 'academy_management_test',
         title: 'Academy Management Test',
         description: 'Simula operaciones de gestión de academias y miembros',
         icon: Icons.school,
         color: AppTheme.goldTrophy,
         onTap: () => _testAcademyManagement(context),
       ),
       UseCaseTest(
         id: 'error_handling_test',
         title: 'Error Handling Test',
         description: 'Prueba el manejo de errores y casos excepcionales',
         icon: Icons.error_outline,
         color: AppTheme.embers,
         onTap: () => _testErrorHandling(context),
       ),
       UseCaseTest(
         id: 'performance_test',
         title: 'Performance Test',
         description: 'Evalúa el rendimiento de la aplicación bajo diferentes cargas',
         icon: Icons.speed,
         color: AppTheme.courtGreen,
         onTap: () => _testPerformance(context),
       ),
    ];
  }

  /// Muestra un diálogo para casos de uso no implementados
  void _showNotImplemented(BuildContext context, String testName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: Text(
          'Test no implementado',
          style: TextStyle(color: AppTheme.magnoliaWhite),
        ),
        content: Text(
          'El test "$testName" aún no ha sido implementado.',
          style: TextStyle(color: AppTheme.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: TextStyle(color: AppTheme.bonfireRed),
            ),
          ),
        ],
      ),
    );
  }

  /// Test de títulos de AppBar
  void _testAppBarTitle(BuildContext context) {
    AppLogger.logInfo(
      'Ejecutando test de AppBar Title',
      className: 'UseCaseTestScreen',
      functionName: '_testAppBarTitle',
    );
    
    // Navegar a la pantalla de prueba de integración de títulos
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AppBarTitleIntegrationTestScreen(),
      ),
    );
  }

  /// Test de creación de usuarios
  void _testCreateUser(BuildContext context) {
    AppLogger.logInfo(
      'Ejecutando test de Create User',
      className: 'UseCaseTestScreen',
      functionName: '_testCreateUser',
    );
    
    _showTestDialog(
      context,
      'Create User Test',
      AppTheme.nbaBluePrimary,
      [
        '• Validación de email',
        '• Validación de contraseña',
        '• Campos obligatorios',
        '• Duplicados de usuario',
        '• Roles y permisos',
      ],
    );
  }

  /// Test de pagos de usuarios
  void _testUserPayment(BuildContext context) {
    AppLogger.logInfo(
      'Ejecutando test de User Payment',
      className: 'UseCaseTestScreen',
      functionName: '_testUserPayment',
    );
    
    _showTestDialog(
      context,
      'User Payment Test',
      AppTheme.goldTrophy,
      [
        '• Procesamiento de pagos',
        '• Validación de tarjetas',
        '• Manejo de errores de pago',
        '• Confirmación de transacciones',
        '• Historial de pagos',
      ],
    );
  }

  /// Test de navegación
  void _testNavigation(BuildContext context) {
    AppLogger.logInfo(
      'Ejecutando test de Navigation',
      className: 'UseCaseTestScreen',
      functionName: '_testNavigation',
    );
    
         _showTestDialog(
       context,
       'Navigation Test',
       AppTheme.courtGreen,
       [
         '• Rutas válidas e inválidas',
         '• Parámetros de ruta',
         '• Navegación anidada',
         '• Back navigation',
         '• Deep linking',
       ],
     );
   }

   /// Test de flujo de autenticación
   void _testAuthFlow(BuildContext context) {
     AppLogger.logInfo(
       'Ejecutando test de Auth Flow',
       className: 'UseCaseTestScreen',
       functionName: '_testAuthFlow',
     );
     
     _showTestDialog(
       context,
       'Authentication Flow Test',
       AppTheme.nbaBluePrimary,
       [
         '• Login exitoso/fallido',
         '• Registro de usuarios',
         '• Recuperación de contraseña',
         '• Sesiones expiradas',
         '• Autorización por roles',
       ],
     );
   }

   /// Test de gestión de academias
   void _testAcademyManagement(BuildContext context) {
     AppLogger.logInfo(
       'Ejecutando test de Academy Management',
       className: 'UseCaseTestScreen',
       functionName: '_testAcademyManagement',
     );
     
     _showTestDialog(
       context,
       'Academy Management Test',
       AppTheme.goldTrophy,
       [
         '• Creación de academias',
         '• Gestión de miembros',
         '• Permisos y roles',
         '• Configuración de academia',
         '• Eliminación de datos',
       ],
     );
   }

   /// Test de manejo de errores
   void _testErrorHandling(BuildContext context) {
     AppLogger.logInfo(
       'Ejecutando test de Error Handling',
       className: 'UseCaseTestScreen',
       functionName: '_testErrorHandling',
     );
     
     _showTestDialog(
       context,
       'Error Handling Test',
       AppTheme.embers,
       [
         '• Errores de red',
         '• Errores de validación',
         '• Excepciones no controladas',
         '• Timeouts',
         '• Recuperación de errores',
       ],
     );
   }

   /// Test de rendimiento
   void _testPerformance(BuildContext context) {
     AppLogger.logInfo(
       'Ejecutando test de Performance',
       className: 'UseCaseTestScreen',
       functionName: '_testPerformance',
     );
     
     _showTestDialog(
       context,
       'Performance Test',
       AppTheme.courtGreen,
      [
        '• Tiempo de carga',
        '• Uso de memoria',
        '• Renderizado de listas',
        '• Navegación fluida',
        '• Optimización de imágenes',
      ],
    );
  }

  /// Muestra un diálogo genérico para tests
  void _showTestDialog(
    BuildContext context,
    String title,
    Color color,
    List<String> testCases,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Casos de prueba:',
              style: TextStyle(
                color: AppTheme.magnoliaWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacingSm),
            Text(
              testCases.join('\n'),
              style: TextStyle(color: AppTheme.lightGray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
} 