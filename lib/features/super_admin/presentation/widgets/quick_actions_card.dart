import 'package:flutter/material.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Widget para mostrar acciones rápidas del SuperAdmin
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildActionItem(
                      context,
                      icon: Icons.person_add_outlined,
                      title: 'Aprobar Propietarios',
                      description: 'Revisar solicitudes pendientes',
                      color: Colors.blue,
                      onTap: () => _handleApproveOwners(context),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildActionItem(
                      context,
                      icon: Icons.subscriptions_outlined,
                      title: 'Gestionar Planes',
                      description: 'Configurar suscripciones',
                      color: Colors.purple,
                      onTap: () => _handleManagePlans(context),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildActionItem(
                      context,
                      icon: Icons.sports_outlined,
                      title: 'Deportes Globales',
                      description: 'Administrar deportes',
                      color: Colors.green,
                      onTap: () => _handleManageSports(context),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildActionItem(
                      context,
                      icon: Icons.backup_outlined,
                      title: 'Sistema de Respaldos',
                      description: 'Gestionar backups',
                      color: Colors.orange,
                      onTap: () => _handleBackupSystem(context),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildActionItem(
                      context,
                      icon: Icons.security_outlined,
                      title: 'Auditoría de Seguridad',
                      description: 'Revisar logs de seguridad',
                      color: Colors.red,
                      onTap: () => _handleSecurityAudit(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de navegación para las acciones rápidas
  void _handleApproveOwners(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a aprobación de propietarios',
      className: 'QuickActionsCard',
      functionName: '_handleApproveOwners',
    );
    
    // TODO: Implementar navegación a SuperAdminRoutes.ownersApproval
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a aprobación de propietarios...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleManagePlans(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a gestión de planes',
      className: 'QuickActionsCard',
      functionName: '_handleManagePlans',
    );
    
    // TODO: Implementar navegación a SuperAdminRoutes.subscriptionPlans
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a gestión de planes...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleManageSports(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a gestión de deportes',
      className: 'QuickActionsCard',
      functionName: '_handleManageSports',
    );
    
    // TODO: Implementar navegación a SuperAdminRoutes.sports
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a gestión de deportes...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleBackupSystem(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a sistema de respaldos',
      className: 'QuickActionsCard',
      functionName: '_handleBackupSystem',
    );
    
    // TODO: Implementar navegación a SuperAdminRoutes.systemBackups
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a sistema de respaldos...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSecurityAudit(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a auditoría de seguridad',
      className: 'QuickActionsCard',
      functionName: '_handleSecurityAudit',
    );
    
    // TODO: Implementar navegación a SuperAdminRoutes.security
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando a auditoría de seguridad...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 