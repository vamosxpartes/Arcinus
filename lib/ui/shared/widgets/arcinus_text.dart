import 'package:flutter/material.dart';
import '../theme/arcinus_text_styles.dart';

/// Widget de texto reutilizable que aplica los estilos definidos en ArcinusTextStyles
class ArcinusText extends StatelessWidget {
  /// Texto a mostrar
  final String text;

  /// Estilo de texto predefinido a utilizar
  final TextStyle style;

  /// Color del texto
  final Color? color;

  /// Peso de la fuente
  final FontWeight? weight;

  /// Alineación del texto
  final TextAlign? textAlign;

  /// Estilo de desbordamiento
  final TextOverflow? overflow;

  /// Número máximo de líneas
  final int? maxLines;

  /// Si el texto se debe escalar con el tamaño de fuente del sistema
  final bool? softWrap;

  /// Decoración del texto (subrayado, tachado, etc.)
  final TextDecoration? decoration;

  /// Si permite escalado de texto del sistema
  final bool? allowFontScaling;

  /// Constructor para texto estilo H1
  ArcinusText.h1(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.h1();

  /// Constructor para texto estilo H2
  ArcinusText.h2(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.h2();

  /// Constructor para texto estilo H3
  ArcinusText.h3(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.h3();

  /// Constructor para texto estilo de subtítulo
  ArcinusText.subtitle(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.subtitle();

  /// Constructor para texto estilo de cuerpo
  ArcinusText.body(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.body();

  /// Constructor para texto estilo secundario
  ArcinusText.secondary(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.secondary();

  /// Constructor para texto estilo caption (pequeño)
  ArcinusText.caption(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.caption();

  /// Constructor para texto estilo estadísticas
  ArcinusText.stats(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.stats();

  /// Constructor para texto estilo botón
  ArcinusText.button(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.button();

  /// Constructor para texto estilo etiqueta
  ArcinusText.label(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.label();

  /// Constructor para texto estilo enlace
  ArcinusText.link(
    this.text, {
    super.key,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration = TextDecoration.underline,
    this.allowFontScaling,
  }) : style = ArcinusTextStyles.link();

  /// Constructor para texto con estilo personalizado
  const ArcinusText({
    super.key,
    required this.text,
    required this.style,
    this.color,
    this.weight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.decoration,
    this.allowFontScaling,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveStyle = style;
    
    // Aplicar color personalizado si se proporciona
    if (color != null) {
      effectiveStyle = effectiveStyle.copyWith(color: color);
    }
    
    // Aplicar peso personalizado si se proporciona
    if (weight != null) {
      effectiveStyle = effectiveStyle.copyWith(fontWeight: weight);
    }
    
    // Aplicar decoración si se proporciona
    if (decoration != null) {
      effectiveStyle = effectiveStyle.copyWith(decoration: decoration);
    }
    
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      // ignore: deprecated_member_use
      textScaleFactor: allowFontScaling == false ? 1.0 : null,
    );
  }
} 