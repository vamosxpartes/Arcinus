import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';

/// Widget que muestra un indicador visual del estado de pago de un usuario
class PaymentStatusBadge extends StatelessWidget {
  /// Estado de pago a mostrar
  final PaymentStatus status;
  
  /// Tamaño del texto, por defecto es pequeño
  final bool isSmall;
  
  /// Si es true, muestra un icono junto al texto
  final bool showIcon;
  
  /// Constructor
  const PaymentStatusBadge({
    required this.status,
    this.isSmall = true,
    this.showIcon = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;
    
    // Determinar color, icono y texto según estado
    switch (status) {
      case PaymentStatus.active:
        color = Colors.green;
        icon = Icons.check_circle;
        text = status.displayName;
        break;
      case PaymentStatus.overdue:
        color = Colors.orange;
        icon = Icons.warning;
        text = status.displayName;
        break;
      case PaymentStatus.inactive:
      // ignore: unreachable_switch_default
      default:
        color = AppTheme.mediumGray;
        icon = Icons.cancel;
        text = status.displayName;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon, 
              color: color, 
              size: isSmall ? 14 : 18,
            ),
            SizedBox(width: 4),
          ],
          Text(
            text, 
            style: TextStyle(
              color: color, 
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
} 