import 'package:flutter/material.dart';

/// Widget que muestra el logo de Arcinus adaptado al tema actual.
///
/// Cambia automáticamente entre logo oscuro y claro según el brillo del tema.
class AdaptiveLogo extends StatelessWidget {
  /// Crea un widget de logo adaptativo.
  ///
  /// [size] define tanto el ancho como el alto (cuadrado).
  /// Si prefieres dimensiones específicas, usa [width] y [height].
  const AdaptiveLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// Tamaño del logo (ancho y alto iguales).
  final double? size;

  /// Ancho específico del logo.
  final double? width;

  /// Alto específico del logo.
  final double? height;

  /// Cómo se debe ajustar la imagen dentro de sus restricciones.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Determinar si estamos en modo oscuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Elegir el logo correcto según el tema
    final logoPath =
        isDarkMode
            ? 'assets/images/Logo_white.png'
            : 'assets/images/Logo_black.png';

    // Calcular ancho y alto
    final logoWidth = size ?? width;
    final logoHeight = size ?? height;

    return Image.asset(
      logoPath,
      width: logoWidth,
      height: logoHeight,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si la imagen no carga
        return Container(
          width: logoWidth,
          height: logoHeight,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.broken_image_outlined,
            size: (logoWidth ?? 24) / 2,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
