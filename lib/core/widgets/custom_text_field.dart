import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcinus/core/constants/app_colors.dart';

/// Widget de campo de texto personalizado para la aplicación
class CustomTextField extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController? controller;
  
  /// Texto de etiqueta
  final String? labelText;
  
  /// Texto de ayuda
  final String? hintText;
  
  /// Texto de error
  final String? errorText;
  
  /// Icono de prefijo
  final Widget? prefixIcon;
  
  /// Icono de sufijo
  final Widget? suffixIcon;
  
  /// Si el campo es de contraseña
  final bool obscureText;
  
  /// Si el campo está habilitado
  final bool enabled;
  
  /// Si el campo es de solo lectura
  final bool readOnly;
  
  /// Número máximo de líneas
  final int? maxLines;
  
  /// Número mínimo de líneas
  final int? minLines;
  
  /// Longitud máxima del texto
  final int? maxLength;
  
  /// Tipo de teclado
  final TextInputType? keyboardType;
  
  /// Acción del teclado
  final TextInputAction? textInputAction;
  
  /// Función de validación
  final String? Function(String?)? validator;
  
  /// Función cuando cambia el texto
  final void Function(String)? onChanged;
  
  /// Función cuando se envía el texto
  final void Function(String)? onSubmitted;
  
  /// Función cuando se toca el campo
  final VoidCallback? onTap;
  
  /// Lista de formateadores de entrada
  final List<TextInputFormatter>? inputFormatters;
  
  /// Estilo del texto
  final TextStyle? style;
  
  /// Padding del contenido
  final EdgeInsetsGeometry? contentPadding;
  
  /// Si debe expandirse para llenar el ancho disponible
  final bool expanded;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.style,
    this.contentPadding,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      style: style,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        labelStyle: TextStyle(
          color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
        ),
      ),
    );

    return expanded
        ? Expanded(child: textField)
        : textField;
  }
} 