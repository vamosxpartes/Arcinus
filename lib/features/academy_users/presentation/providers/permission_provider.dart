import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academy_users/data/models/membership_model.dart';
import 'package:arcinus/features/academy_users/presentation/providers/membership_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para verificar permisos de usuario.
///
/// Este provider basado en familia necesita:
/// - El ID de la academia que se está consultando [academyId]
/// - El permiso específico a verificar [permission]
final hasPermissionProvider = FutureProvider.family.autoDispose<bool, ({String academyId, String permission})>(
  (ref, params) async {
    final academyId = params.academyId;
    final permission = params.permission;
    
    final authState = ref.watch(authStateNotifierProvider);
    
    // Si no hay usuario autenticado, nunca tiene permisos
    if (!authState.isAuthenticated || authState.user == null) {
      return false;
    }
 
    final currentUser = authState.user!;
    final userId = currentUser.id;
    
    // SuperAdmin siempre tiene todos los permisos
    if (currentUser.role == AppRole.superAdmin) {
      return true;
    }
    
    // Propietario siempre tiene todos los permisos en su academia
    // Modificar cuando conozcamos cómo identificar la relación propietario-academia
    if (currentUser.role == AppRole.propietario) {
      return true;
    }
    
    // Para colaboradores, verificar permisos específicos
    if (currentUser.role == AppRole.colaborador) {
      try {
        // Obtener membresías para esta academia
        final memberships = await ref.watch(academyMembersProvider(academyId).future);
        
        // Buscar la membresía de este usuario
        final membership = memberships.firstWhere(
          (m) => m.userId == userId,
          // Si no se encuentra, retornar una membresía sin permisos
          orElse: () => MembershipModel(
            userId: '',
            academyId: '',
            role: AppRole.desconocido,
            addedAt: DateTime.now(),
            permissions: const [],
          ),
        );
        
        // Verificar si tiene el permiso específico
        return membership.permissions.contains(permission);
      } catch (e) {
        // Si hay error al obtener permisos, negar acceso por seguridad
        return false;
      }
    }
    
    // Atletas y padres no tienen permisos administrativos, pero podrían tener
    // permisos específicos en el futuro (ver sus propios datos, etc.)
    return false;
  }
);

/// Provider que expone todos los permisos que tiene el usuario actual
/// en una academia específica.
final userPermissionsProvider = FutureProvider.family.autoDispose<List<String>, String>(
  (ref, academyId) async {
    final authState = ref.watch(authStateNotifierProvider);
    
    // Si no hay usuario autenticado, no tiene permisos
    if (!authState.isAuthenticated || authState.user == null) {
      return [];
    }
 
    final currentUser = authState.user!;
    final userId = currentUser.id;
    
    // SuperAdmin tiene todos los permisos
    if (currentUser.role == AppRole.superAdmin) {
      return AppPermissions.allPermissions;
    }
    
    // Propietario tiene todos los permisos en su academia
    // Modificar cuando conozcamos cómo identificar la relación propietario-academia
    if (currentUser.role == AppRole.propietario) {
      return AppPermissions.allPermissions;
    }
    
    // Para colaboradores, obtener permisos específicos de su membresía
    if (currentUser.role == AppRole.colaborador) {
      try {
        // Obtener membresías para esta academia
        final memberships = await ref.watch(academyMembersProvider(academyId).future);
        
        // Buscar la membresía de este usuario
        final membership = memberships.firstWhere(
          (m) => m.userId == userId,
          orElse: () => MembershipModel(
            userId: '',
            academyId: '',
            role: AppRole.desconocido,
            addedAt: DateTime.now(),
            permissions: const [],
          ),
        );
        
        // Retornar los permisos que tiene
        return membership.permissions;
      } catch (e) {
        return [];
      }
    }
    
    // Atletas y padres por ahora no tienen permisos administrativos
    return [];
  }
); 