/// Clase que centraliza las rutas a los assets de la aplicación.
///
/// Usar estas constantes en lugar de strings directamente ayuda a prevenir
/// errores tipográficos y facilita la refactorización.
class AppAssets {
  // --- DIRECTORIOS BASE ---
  static const String _base = 'assets';
  
  // Los siguientes directorios están preparados para uso futuro
  // pero se comentan para evitar advertencias de campos no utilizados
  // static const String _images = '$_base/images';
  static const String _icons = '$_base/icons';
  // static const String _fonts = '$_base/fonts';
  // static const String _config = '$_base/config';

  // --- IMÁGENES ESPECÍFICAS (Añadir según sea necesario) ---
  // Ejemplo: static const String logo = '$_images/logo.png';
  // Ejemplo: static const String placeholder = '$_images/placeholder.jpg';

  // --- ICONOS ESPECÍFICOS (Añadir según sea necesario) ---
  // Ejemplo: static const String backArrow = '$_icons/back_arrow.svg';
  /// Ruta al asset del logo negro (PNG).
  static const String logoBlack = '$_icons/Logo_black.png'; // Usado en pubspec

  // --- FUENTES (Generalmente se referencian por familia en ThemeData) ---
  // static const String robotoRegular = '$_fonts/Roboto-Regular.ttf';

  // --- ARCHIVOS DE CONFIGURACIÓN (Añadir según sea necesario) ---
  // Ejemplo: static const String remoteConfigDefaults = '$_config/remote_config_defaults.json';

  // --- OTROS ASSETS (Como Lottie, Rive, etc.) ---
  static const String logoWhite = '$_icons/Logo_white.png'; // Usado en pubspec

}
