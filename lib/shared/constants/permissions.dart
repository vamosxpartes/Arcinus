import '../models/user.dart';

/// Constantes para los permisos de la aplicación
class Permissions {
  // Permisos de superAdmin
  static const String managePlatform = 'managePlatform';  
  static const String viewAllAcademies = 'viewAllAcademies';
  static const String manageSubscriptions = 'manageSubscriptions';
  static const String managePaymentPlans = 'managePaymentPlans';
  
  // Permisos administrativos
  static const String createAcademy = 'createAcademy';
  static const String manageAcademy = 'manageAcademy';
  static const String manageUsers = 'manageUsers';
  static const String manageCoaches = 'manageCoaches';
  static const String manageGroups = 'manageGroups';
  static const String assignPermissions = 'assignPermissions';
  
  // Permisos financieros
  static const String managePayments = 'managePayments';
  static const String viewFinancials = 'viewFinancials';
  
  // Permisos de entrenamiento
  static const String createTraining = 'createTraining';
  static const String viewAllTrainings = 'viewAllTrainings';
  static const String editTraining = 'editTraining';
  
  // Permisos de ejercicios
  static const String createExercise = 'createExercise';
  static const String viewAllExercises = 'viewAllExercises';
  static const String editExercise = 'editExercise';
  
  // Permisos de clases
  static const String scheduleClass = 'scheduleClass';
  static const String takeAttendance = 'takeAttendance';
  static const String viewAllAttendance = 'viewAllAttendance';
  
  // Permisos de evaluación
  static const String evaluateAthletes = 'evaluateAthletes';
  static const String viewAllEvaluations = 'viewAllEvaluations';
  
  // Permisos de comunicación
  static const String sendNotifications = 'sendNotifications';
  static const String useChat = 'useChat';
  
  /// Función para obtener permisos predeterminados por rol
  static Map<String, bool> getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return {
          // Permisos de nivel plataforma
          managePlatform: true,
          viewAllAcademies: true,
          manageSubscriptions: true,
          managePaymentPlans: true,
          
          // Todos los demás permisos
          createAcademy: true,
          manageAcademy: true,
          manageUsers: true,
          manageCoaches: true,
          manageGroups: true,
          assignPermissions: true,
          managePayments: true,
          viewFinancials: true,
          createTraining: true,
          viewAllTrainings: true,
          editTraining: true,
          createExercise: true,
          viewAllExercises: true,
          editExercise: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: true,
          evaluateAthletes: true,
          viewAllEvaluations: true,
          sendNotifications: true,
          useChat: true,
        };
      
      case UserRole.owner:
        return {
          // Permisos de nivel plataforma (ninguno)
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          
          createAcademy: false,  // Se revoca después del primer uso
          manageAcademy: true,
          manageUsers: true,
          manageCoaches: true,
          manageGroups: true,
          assignPermissions: true,
          managePayments: true,
          viewFinancials: true,
          createTraining: true,
          viewAllTrainings: true,
          editTraining: true,
          createExercise: true,
          viewAllExercises: true,
          editExercise: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: true,
          evaluateAthletes: true,
          viewAllEvaluations: true,
          sendNotifications: true,
          useChat: true,
        };
        
      case UserRole.manager:
        return {
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          createAcademy: false,
          manageAcademy: false,
          manageUsers: true,
          manageCoaches: true,
          manageGroups: true,
          assignPermissions: false,
          managePayments: true,
          viewFinancials: true,
          createTraining: true,
          viewAllTrainings: true,
          editTraining: true,
          createExercise: true,
          viewAllExercises: true,
          editExercise: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: true,
          evaluateAthletes: true,
          viewAllEvaluations: true,
          sendNotifications: true,
          useChat: true,
        };
        
      case UserRole.coach:
        return {
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          createAcademy: false,
          manageAcademy: false,
          manageUsers: false,
          manageCoaches: false,
          manageGroups: false,
          assignPermissions: false,
          managePayments: false,
          viewFinancials: false,
          createTraining: true,
          viewAllTrainings: false,
          editTraining: true,
          createExercise: true,
          viewAllExercises: true,
          editExercise: true,
          scheduleClass: true,
          takeAttendance: true,
          viewAllAttendance: false,
          evaluateAthletes: true,
          viewAllEvaluations: false,
          sendNotifications: true,
          useChat: true,
        };
        
      case UserRole.athlete:
      case UserRole.parent:
        return {
          useChat: true,
          // Todos los demás permisos en false
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          createAcademy: false,
          manageAcademy: false,
          manageUsers: false,
          manageCoaches: false,
          manageGroups: false,
          assignPermissions: false,
          managePayments: false,
          viewFinancials: false,
          createTraining: false,
          viewAllTrainings: false,
          editTraining: false,
          createExercise: false,
          viewAllExercises: true, // Pueden ver ejercicios
          editExercise: false,
          scheduleClass: false,
          takeAttendance: false,
          viewAllAttendance: false,
          evaluateAthletes: false,
          viewAllEvaluations: false,
          sendNotifications: false,
        };
        
      case UserRole.guest:
      return {
          // Ningún permiso
          managePlatform: false,
          viewAllAcademies: false,
          manageSubscriptions: false,
          managePaymentPlans: false,
          createAcademy: false,
          manageAcademy: false,
          manageUsers: false,
          manageCoaches: false,
          manageGroups: false,
          assignPermissions: false,
          managePayments: false,
          viewFinancials: false,
          createTraining: false,
          viewAllTrainings: false,
          editTraining: false,
          createExercise: false,
          viewAllExercises: false,
          editExercise: false,
          scheduleClass: false,
          takeAttendance: false,
          viewAllAttendance: false,
          evaluateAthletes: false,
          viewAllEvaluations: false,
          sendNotifications: false,
          useChat: false,
        };
    }
  }
} 