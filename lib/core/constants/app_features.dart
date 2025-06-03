/// Definición oficial de las features de la aplicación Arcinus
///
/// Este archivo contiene todas las funcionalidades de la app organizadas por estado
/// de desarrollo y disponibilidad por rol de usuario.

/// Estados de desarrollo de las features
enum FeatureStatus {
  /// Feature completamente funcional y disponible en producción
  production,
  
  /// Feature establecida con funcionalidad básica, puede tener mejoras pendientes
  established,
  
  /// Feature en desarrollo o por validar, no completamente funcional
  development,
  
  /// Feature planificada pero no iniciada su desarrollo
  planned,
  
  /// Feature solo disponible para desarrollo y testing
  devOnly,
}

/// Categorías de features para organización
enum FeatureCategory {
  /// Funcionalidades principales de gestión
  core,
  
  /// Gestión de academias
  academyManagement,
  
  /// Gestión de usuarios y miembros
  userManagement,
  
  /// Gestión financiera y facturación
  billing,
  
  /// Comunicación y redes sociales
  communication,
  
  /// Personalización y marca
  branding,
  
  /// Operaciones y logística
  operations,
  
  /// Analytics y reportes
  analytics,
  
  /// Administración del sistema
  systemAdmin,
  
  /// Configuración personal
  personal,
  
  /// Herramientas de desarrollo
  development,
}

/// Roles que pueden acceder a cada feature
enum FeatureRole {
  /// Super administrador del sistema
  superAdmin,
  
  /// Propietario de academia
  owner,
  
  /// Colaborador de academia
  collaborator,
  
  /// Atleta
  athlete,
  
  /// Padre/tutor
  parent,
  
  /// Cualquier usuario gestor (owner o collaborator)
  manager,
  
  /// Todos los usuarios autenticados
  authenticated,
  
  /// Usuarios no autenticados
  guest,
}

/// Definición de una feature de la aplicación
class AppFeature {
  /// Identificador único de la feature
  final String id;
  
  /// Nombre para mostrar al usuario
  final String displayName;
  
  /// Descripción detallada de la funcionalidad
  final String description;
  
  /// Estado actual de desarrollo
  final FeatureStatus status;
  
  /// Categoría a la que pertenece
  final FeatureCategory category;
  
  /// Roles que pueden acceder a esta feature
  final List<FeatureRole> allowedRoles;
  
  /// Ruta de navegación (si aplica)
  final String? route;
  
  /// Icono representativo
  final String? iconName;
  
  /// Features dependientes que deben estar disponibles
  final List<String> dependencies;
  
  /// Notas adicionales sobre la implementación
  final String? notes;

  const AppFeature({
    required this.id,
    required this.displayName,
    required this.description,
    required this.status,
    required this.category,
    required this.allowedRoles,
    this.route,
    this.iconName,
    this.dependencies = const [],
    this.notes,
  });
}

/// Extensiones para facilitar el uso de los enums
extension FeatureStatusExtension on FeatureStatus {
  String get displayName {
    switch (this) {
      case FeatureStatus.production:
        return 'En Producción';
      case FeatureStatus.established:
        return 'Establecida';
      case FeatureStatus.development:
        return 'En Desarrollo';
      case FeatureStatus.planned:
        return 'Planificada';
      case FeatureStatus.devOnly:
        return 'Solo Desarrollo';
    }
  }
  
  bool get isAvailable {
    return this == FeatureStatus.production || this == FeatureStatus.established;
  }
}

extension FeatureCategoryExtension on FeatureCategory {
  String get displayName {
    switch (this) {
      case FeatureCategory.core:
        return 'Funciones Principales';
      case FeatureCategory.academyManagement:
        return 'Gestión de Academias';
      case FeatureCategory.userManagement:
        return 'Gestión de Usuarios';
      case FeatureCategory.billing:
        return 'Facturación';
      case FeatureCategory.communication:
        return 'Comunicación';
      case FeatureCategory.branding:
        return 'Marca y Diseño';
      case FeatureCategory.operations:
        return 'Operaciones';
      case FeatureCategory.analytics:
        return 'Analytics';
      case FeatureCategory.systemAdmin:
        return 'Administración';
      case FeatureCategory.personal:
        return 'Configuración Personal';
      case FeatureCategory.development:
        return 'Herramientas de Desarrollo';
    }
  }
}

/// Catálogo oficial de features de la aplicación Arcinus
class AppFeatures {
  static const List<AppFeature> _features = [
    // === FUNCIONES PRINCIPALES (CORE) ===
    AppFeature(
      id: 'dashboard',
      displayName: 'Dashboard',
      description: 'Panel de control principal con resumen de actividad y métricas clave',
      status: FeatureStatus.established,
      category: FeatureCategory.core,
      allowedRoles: [FeatureRole.manager, FeatureRole.superAdmin],
      route: '/manager',
      iconName: 'dashboard',
      notes: 'Funcionalidad básica implementada, pendiente añadir widgets de estadísticas',
    ),
    
    AppFeature(
      id: 'academy_management',
      displayName: 'Academia',
      description: 'Gestión completa de información de academias: creación, edición, configuración',
      status: FeatureStatus.established,
      category: FeatureCategory.academyManagement,
      allowedRoles: [FeatureRole.manager],
      route: '/manager/academy/:academyId',
      iconName: 'school',
      notes: 'Edición básica implementada, pendiente añadir más configuraciones avanzadas',
    ),
    
    AppFeature(
      id: 'members_management',
      displayName: 'Miembros',
      description: 'Gestión de atletas, padres/tutores y colaboradores de la academia',
      status: FeatureStatus.established,
      category: FeatureCategory.userManagement,
      allowedRoles: [FeatureRole.manager],
      route: '/manager/academy/:academyId/members',
      iconName: 'groups',
      dependencies: ['academy_management'],
      notes: 'Gestión de atletas funcional, pendiente implementar padres/tutores y colaboradores',
    ),
    
    // === SUSCRIPCIONES Y FACTURACIÓN ===
    AppFeature(
      id: 'subscription_plans',
      displayName: 'Planes de Suscripción',
      description: 'Creación y gestión de planes de suscripción para usuarios de la academia',
      status: FeatureStatus.established,
      category: FeatureCategory.billing,
      allowedRoles: [FeatureRole.manager],
      iconName: 'card_membership',
      dependencies: ['academy_management'],
      notes: 'Funcionalidad básica implementada, integrada con pagos',
    ),
    
    AppFeature(
      id: 'payments_management',
      displayName: 'Pagos',
      description: 'Gestión de pagos de suscripciones y seguimiento de estado financiero',
      status: FeatureStatus.established,
      category: FeatureCategory.billing,
      allowedRoles: [FeatureRole.manager],
      route: '/manager/academy/:academyId/payments',
      iconName: 'payment',
      dependencies: ['subscription_plans', 'members_management'],
      notes: 'Sistema de pagos básico funcional',
    ),
    
    AppFeature(
      id: 'billing_advanced',
      displayName: 'Facturación',
      description: 'Configuración de facturación y reportes financieros de la academia',
      status: FeatureStatus.established,
      category: FeatureCategory.billing,
      allowedRoles: [FeatureRole.manager],
      iconName: 'receipt_long',
      dependencies: ['academy_management'],
      notes: 'Configuración de facturación implementada en pestañas de academia',
    ),
    
    // === OPERACIONES Y LOGÍSTICA ===
    AppFeature(
      id: 'inventory',
      displayName: 'Inventario',
      description: 'Gestión de equipamiento, materiales y recursos de la academia',
      status: FeatureStatus.planned,
      category: FeatureCategory.operations,
      allowedRoles: [FeatureRole.manager],
      iconName: 'inventory_2',
      dependencies: ['academy_management'],
      notes: 'Sistema completo de inventario con control de stock',
    ),
    
    AppFeature(
      id: 'facilities',
      displayName: 'Instalaciones',
      description: 'Gestión de espacios físicos, canchas, aulas y equipamientos',
      status: FeatureStatus.planned,
      category: FeatureCategory.operations,
      allowedRoles: [FeatureRole.manager],
      iconName: 'location_on',
      dependencies: ['academy_management'],
      notes: 'Incluye reservas de espacios y mantenimiento',
    ),
    
    AppFeature(
      id: 'scheduling',
      displayName: 'Horarios',
      description: 'Planificación y gestión de horarios de entrenamientos y actividades',
      status: FeatureStatus.planned,
      category: FeatureCategory.operations,
      allowedRoles: [FeatureRole.manager],
      iconName: 'calendar_today',
      dependencies: ['members_management', 'facilities'],
      notes: 'Sistema completo de calendario con notificaciones',
    ),
    
    AppFeature(
      id: 'notifications',
      displayName: 'Notificaciones',
      description: 'Sistema de notificaciones push, email y SMS para usuarios',
      status: FeatureStatus.planned,
      category: FeatureCategory.communication,
      allowedRoles: [FeatureRole.manager],
      iconName: 'notifications',
      dependencies: ['members_management'],
      notes: 'Notificaciones automáticas y manuales',
    ),
    
    // === ENTRENAMIENTO Y GRUPOS ===
    AppFeature(
      id: 'groups',
      displayName: 'Grupos',
      description: 'Organización de atletas en grupos, equipos y categorías',
      status: FeatureStatus.planned,
      category: FeatureCategory.userManagement,
      allowedRoles: [FeatureRole.manager],
      iconName: 'groups_2',
      dependencies: ['members_management'],
      notes: 'Grupos por edad, nivel, modalidad deportiva',
    ),
    
    AppFeature(
      id: 'trainings',
      displayName: 'Entrenamientos',
      description: 'Planificación, seguimiento y evaluación de entrenamientos',
      status: FeatureStatus.planned,
      category: FeatureCategory.operations,
      allowedRoles: [FeatureRole.manager],
      iconName: 'fitness_center',
      dependencies: ['groups', 'scheduling'],
      notes: 'Incluye planes de entrenamiento y progreso de atletas',
    ),
    
    // === COMUNICACIÓN Y REDES SOCIALES ===
    AppFeature(
      id: 'social_media',
      displayName: 'Redes Sociales',
      description: 'Integración con redes sociales y gestión de contenido',
      status: FeatureStatus.planned,
      category: FeatureCategory.communication,
      allowedRoles: [FeatureRole.manager],
      iconName: 'share',
      dependencies: ['academy_management'],
      notes: 'Publicación automática de logros y eventos',
    ),
    
    AppFeature(
      id: 'documents_policies',
      displayName: 'Normas y Documentos',
      description: 'Gestión de reglamentos, políticas y documentos oficiales',
      status: FeatureStatus.planned,
      category: FeatureCategory.academyManagement,
      allowedRoles: [FeatureRole.manager],
      iconName: 'gavel',
      dependencies: ['academy_management'],
      notes: 'Sistema de documentos con firmas digitales',
    ),
    
    // === MARCA Y PERSONALIZACIÓN ===
    AppFeature(
      id: 'branding',
      displayName: 'Marca y Personalización',
      description: 'Personalización de colores, logos y apariencia de la academia',
      status: FeatureStatus.planned,
      category: FeatureCategory.branding,
      allowedRoles: [FeatureRole.owner],
      iconName: 'brush',
      dependencies: ['academy_management'],
      notes: 'Temas personalizados y white-label',
    ),
    
    // === ANALYTICS Y ESTADÍSTICAS ===
    AppFeature(
      id: 'owner_statistics',
      displayName: 'Estadísticas',
      description: 'Métricas de rendimiento, ingresos y análisis de datos',
      status: FeatureStatus.planned,
      category: FeatureCategory.analytics,
      allowedRoles: [FeatureRole.owner],
      iconName: 'bar_chart',
      dependencies: ['payments_management', 'members_management'],
      notes: 'Dashboard analítico con métricas clave de negocio',
    ),
    
    // === ADMINISTRACIÓN DEL SISTEMA (SUPER ADMIN) ===
    AppFeature(
      id: 'global_plans_management',
      displayName: 'Gestión de Planes Globales',
      description: 'Administración de planes de suscripción a nivel de plataforma',
      status: FeatureStatus.established,
      category: FeatureCategory.systemAdmin,
      allowedRoles: [FeatureRole.superAdmin],
      route: '/super-admin/global-plans',
      iconName: 'card_membership',
      notes: 'Sistema completo de gestión de planes globales',
    ),
    
    AppFeature(
      id: 'owners_management',
      displayName: 'Gestión de Propietarios',
      description: 'Administración de cuentas de propietarios de academias',
      status: FeatureStatus.established,
      category: FeatureCategory.systemAdmin,
      allowedRoles: [FeatureRole.superAdmin],
      route: '/superadmin/owners',
      iconName: 'supervisor_account',
      notes: 'CRUD completo de propietarios y sus academias',
    ),
    
    AppFeature(
      id: 'system_analytics',
      displayName: 'Análisis del Sistema',
      description: 'Métricas globales de la plataforma y análisis de uso',
      status: FeatureStatus.development,
      category: FeatureCategory.systemAdmin,
      allowedRoles: [FeatureRole.superAdmin],
      route: '/superadmin/analytics',
      iconName: 'analytics',
      notes: 'Dashboard con métricas de toda la plataforma',
    ),
    
    // === CONFIGURACIÓN PERSONAL ===
    AppFeature(
      id: 'user_profile',
      displayName: 'Mi Perfil',
      description: 'Gestión de información personal del usuario',
      status: FeatureStatus.established,
      category: FeatureCategory.personal,
      allowedRoles: [FeatureRole.authenticated],
      route: '/manager/profile',
      iconName: 'person',
      notes: 'Edición básica de perfil implementada',
    ),
    
    AppFeature(
      id: 'user_settings',
      displayName: 'Configuración',
      description: 'Ajustes personales y preferencias de la aplicación',
      status: FeatureStatus.established,
      category: FeatureCategory.personal,
      allowedRoles: [FeatureRole.authenticated],
      route: '/manager/settings',
      iconName: 'settings',
      notes: 'Configuraciones básicas disponibles',
    ),
    
    // === HERRAMIENTAS DE DESARROLLO ===
    AppFeature(
      id: 'use_case_testing',
      displayName: 'Test de Casos de Uso',
      description: 'Herramientas para probar casos de uso y funcionalidades',
      status: FeatureStatus.devOnly,
      category: FeatureCategory.development,
      allowedRoles: [FeatureRole.manager], // Disponible para testing
      route: '/manager/dev-tools/use-case-test',
      iconName: 'bug_report',
      notes: 'Solo disponible en modo desarrollo',
    ),
  ];
  
  /// Obtiene todas las features disponibles
  static List<AppFeature> get all => _features;
  
  /// Obtiene features por estado de desarrollo
  static List<AppFeature> getByStatus(FeatureStatus status) {
    return _features.where((feature) => feature.status == status).toList();
  }
  
  /// Obtiene features por categoría
  static List<AppFeature> getByCategory(FeatureCategory category) {
    return _features.where((feature) => feature.category == category).toList();
  }
  
  /// Obtiene features disponibles para un rol específico
  static List<AppFeature> getByRole(FeatureRole role) {
    return _features.where((feature) => feature.allowedRoles.contains(role)).toList();
  }
  
  /// Obtiene features que están en producción o establecidas
  static List<AppFeature> get available {
    return _features.where((feature) => feature.status.isAvailable).toList();
  }
  
  /// Obtiene una feature por su ID
  static AppFeature? getById(String id) {
    try {
      return _features.firstWhere((feature) => feature.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtiene features que pueden ser mostradas en el drawer para un rol
  static List<AppFeature> getDrawerFeatures(FeatureRole role) {
    return _features
        .where((feature) => 
            feature.allowedRoles.contains(role) && 
            feature.route != null &&
            feature.category != FeatureCategory.development)
        .toList();
  }
  
  /// Obtiene el conteo de features por estado
  static Map<FeatureStatus, int> get statusCount {
    final Map<FeatureStatus, int> count = {};
    for (final status in FeatureStatus.values) {
      count[status] = getByStatus(status).length;
    }
    return count;
  }
  
  /// Obtiene el conteo de features por categoría
  static Map<FeatureCategory, int> get categoryCount {
    final Map<FeatureCategory, int> count = {};
    for (final category in FeatureCategory.values) {
      count[category] = getByCategory(category).length;
    }
    return count;
  }
} 