import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/features/memberships/presentation/providers/permission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget que muestra u oculta su contenido según los permisos del usuario.
///
/// Útil para adaptar la UI dinámicamente en función de los permisos de un
/// colaborador en una academia específica.
class PermissionGate extends ConsumerWidget {
  /// ID de la academia sobre la que se verifica el permiso.
  final String academyId;
  
  /// Permiso específico requerido para mostrar el contenido.
  ///
  /// Debe ser uno de los valores definidos en [AppPermissions].
  final String requiredPermission;
  
  /// Widget a mostrar si el usuario tiene el permiso.
  final Widget child;
  
  /// Widget opcional a mostrar si el usuario NO tiene el permiso.
  ///
  /// Si es null y el usuario no tiene el permiso, no se mostrará nada
  /// (widget invisible).
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.academyId,
    required this.requiredPermission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermissionAsync = ref.watch(hasPermissionProvider(
      (academyId: academyId, permission: requiredPermission),
    ));
    
    return hasPermissionAsync.when(
      data: (hasPermission) {
        if (hasPermission) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink(); // Invisible si no hay fallback
        }
      },
      loading: () => const SizedBox.shrink(), // Invisible mientras carga
      error: (_, __) => fallback ?? const SizedBox.shrink(), // Invisible en caso de error
    );
  }
}

/// Widget que muestra una lista de opciones/acciones según los permisos del usuario.
///
/// Útil para menús, barras de herramientas, etc. donde se muestran solo
/// las opciones que el usuario tiene permiso para usar.
class PermissionAwareActionList extends ConsumerWidget {
  /// ID de la academia sobre la que se verifican permisos.
  final String academyId;
  
  /// Lista de acciones con sus permisos requeridos.
  ///
  /// Cada acción debe tener un [Widget] a mostrar y el permiso requerido.
  /// Si el permiso es null, la acción siempre se mostrará.
  final List<({Widget child, String? requiredPermission})> actions;
  
  /// Espaciado entre las acciones.
  final double spacing;
  
  /// Padding alrededor de toda la lista de acciones.
  final EdgeInsetsGeometry padding;
  
  /// Si es true, las acciones se mostrarán en horizontal.
  /// Si es false, se mostrarán en vertical.
  final bool horizontal;

  const PermissionAwareActionList({
    super.key,
    required this.academyId,
    required this.actions,
    this.spacing = 8.0,
    this.padding = EdgeInsets.zero,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener todos los permisos del usuario actual
    final userPermissionsAsync = ref.watch(userPermissionsProvider(academyId));
    
    return userPermissionsAsync.when(
      data: (userPermissions) {
        // Filtrar las acciones que el usuario puede ver
        final visibleActions = actions.where((action) {
          // Si no requiere permiso, siempre mostrar
          if (action.requiredPermission == null) {
            return true;
          }
          
          // Si requiere permiso, verificar si el usuario lo tiene
          return userPermissions.contains(action.requiredPermission);
        }).toList();
        
        // Si no hay acciones visibles, no mostrar nada
        if (visibleActions.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Mostrar las acciones en un row o column según configuración
        return Padding(
          padding: padding,
          child: horizontal
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildChildren(visibleActions),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildChildren(visibleActions),
                ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  List<Widget> _buildChildren(List<({Widget child, String? requiredPermission})> visibleActions) {
    final result = <Widget>[];
    
    for (var i = 0; i < visibleActions.length; i++) {
      // Añadir el widget de la acción
      result.add(visibleActions[i].child);
      
      // Añadir espaciador si no es el último elemento
      if (i < visibleActions.length - 1) {
        result.add(
          horizontal 
              ? SizedBox(width: spacing) 
              : SizedBox(height: spacing),
        );
      }
    }
    
    return result;
  }
} 