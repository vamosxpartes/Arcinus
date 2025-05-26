/// Mixin para validación de URLs de imágenes
mixin ImageValidationMixin {
  /// Valida si una URL es válida para imágenes
  bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      
      // Verificar que sea una URL válida
      if (!uri.hasScheme || (!uri.scheme.startsWith('http') && !uri.scheme.startsWith('https'))) {
        return false;
      }
      
      // Verificar que no sea una URL de ejemplo
      if (url.contains('example.com') || url.contains('placeholder') || url.contains('dummy')) {
        return false;
      }
      
      // Verificar extensiones de imagen comunes (opcional, Firebase Storage puede no tenerlas)
      final commonImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      final hasImageExtension = commonImageExtensions.any((ext) => url.toLowerCase().contains(ext));
      
      // Para Firebase Storage, también verificar el dominio
      final isFirebaseStorage = url.contains('firebasestorage.googleapis.com') || url.contains('firebase.googleapis.com');
      
      return isFirebaseStorage || hasImageExtension;
    } catch (e) {
      return false;
    }
  }
} 