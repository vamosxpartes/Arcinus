import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Widget stepper para seleccionar el número de períodos
/// Diseño similar a cronómetros con incremento/decremento
class PeriodStepperWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;
  final bool enabled;

  const PeriodStepperWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 12,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        border: Border.all(
          color: AppTheme.lightGray.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón incrementar
          _buildStepButton(
            icon: Icons.keyboard_arrow_up,
            onTap: enabled && value < maxValue
                ? () => onChanged(value + 1)
                : null,
          ),
          
          // Valor actual
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppTheme.lightGray.withAlpha(20),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: AppTheme.h3Size,
                  fontWeight: FontWeight.w700,
                  color: enabled ? AppTheme.magnoliaWhite : AppTheme.lightGray,
                ),
              ),
            ),
          ),
          
          // Botón decrementar
          _buildStepButton(
            icon: Icons.keyboard_arrow_down,
            onTap: enabled && value > minValue
                ? () => onChanged(value - 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null && enabled;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        child: Container(
          width: 80,
          height: 32,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [AppTheme.bonfireRed, AppTheme.embers],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: !isEnabled ? AppTheme.darkGray : null,
          ),
          child: Icon(
            icon,
            color: isEnabled ? AppTheme.magnoliaWhite : AppTheme.lightGray,
            size: 20,
          ),
        ),
      ),
    );
  }
} 