/// Rutas específicas de Autenticación.
///
/// Contiene todas las rutas relacionadas con el proceso de autenticación.
class AuthRoutes {
  // --- Ruta base de autenticación ---
  static const String root = '/auth';
  
  // --- Rutas de autenticación ---
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // --- Acceso para miembros/invitados ---
  static const String memberAccess = '/auth/member-access';
  static const String guestAccess = '/auth/guest-access';
  
  // --- Validación y verificación ---
  static const String twoFactorAuth = '/auth/2fa';
  static const String phoneVerification = '/auth/phone-verification';
  
  // --- Onboarding ---
  static const String completeProfile = '/auth/complete-profile';
  static const String selectRole = '/auth/select-role';
  static const String termsAndConditions = '/auth/terms';
} 