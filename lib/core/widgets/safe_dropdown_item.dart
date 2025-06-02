import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Widget seguro para items de dropdown que maneja correctamente las constraints
/// y evita errores de RenderFlex con widgets Expanded en contextos unbounded.
class SafeDropdownItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double? maxWidth;
  final VoidCallback? onTap;

  const SafeDropdownItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.maxWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: maxWidth,
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
          minHeight: 48,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading widget (avatar, icon, etc.)
            leading,
            
            const SizedBox(width: AppTheme.spacingSm),
            
            // Main content area - usando Flexible en lugar de Expanded
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppTheme.bodySize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: AppTheme.secondarySize,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing widget (price, status, etc.)
            if (trailing != null) ...[
              const SizedBox(width: AppTheme.spacingSm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget específico para items de dropdown de planes de suscripción
class PlanDropdownItem extends StatelessWidget {
  final String planName;
  final double amount;
  final String currency;
  final String billingCycle;
  final Color? indicatorColor;
  final VoidCallback? onTap;

  const PlanDropdownItem({
    super.key,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    this.indicatorColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeDropdownItem(
      onTap: onTap,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: indicatorColor ?? AppTheme.courtGreen,
          shape: BoxShape.circle,
        ),
      ),
      title: planName,
      subtitle: '$amount $currency - $billingCycle',
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withAlpha(20),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '\$$amount',
          style: TextStyle(
            fontSize: AppTheme.captionSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightGray,
          ),
        ),
      ),
    );
  }
}

/// Widget específico para items de dropdown de atletas
class AthleteDropdownItem extends StatelessWidget {
  final String athleteName;
  final String athleteEmail;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const AthleteDropdownItem({
    super.key,
    required this.athleteName,
    required this.athleteEmail,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeDropdownItem(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.lightGray.withAlpha(30),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(
                athleteName.isNotEmpty ? athleteName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.magnoliaWhite,
                ),
              )
            : null,
      ),
      title: athleteName,
      subtitle: athleteEmail,
    );
  }
}

/// Helper para crear dropdowns seguros con mejor manejo de constraints
class SafeDropdownHelper {
  /// Crea un DropdownButtonFormField con configuración segura
  static Widget createSafeDropdown<T>({
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    T? value,
    String? hint,
    String? label,
    Widget? prefixIcon,
    FormFieldValidator<T>? validator,
    bool isExpanded = true,
    double? menuMaxHeight,
    Color? dropdownColor,
    TextStyle? style,
    InputDecoration? decoration,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,
      menuMaxHeight: menuMaxHeight ?? 300,
      dropdownColor: dropdownColor ?? AppTheme.darkGray,
      style: style ?? const TextStyle(color: AppTheme.magnoliaWhite),
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: AppTheme.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: BorderSide(color: AppTheme.lightGray.withAlpha(30)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: BorderSide(color: AppTheme.lightGray.withAlpha(30)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: const BorderSide(color: AppTheme.bonfireRed),
            ),
            hintStyle: const TextStyle(color: AppTheme.lightGray),
          ),
    );
  }
} 