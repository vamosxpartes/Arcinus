import 'package:arcinus/ux/features/permission/providers/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget que solo reconstruye su hijo cuando cambian los permisos específicos que está observando
class PermissionBuilder extends ConsumerWidget {
  final List<String> permissions;
  final bool requireAll;
  final Widget Function(BuildContext context, bool hasPermission) builder;
  final Widget? fallback;

  /// Constructor
  /// [permissions] Lista de permisos a verificar
  /// [requireAll] Si es true, todos los permisos deben cumplirse; si es false, con uno es suficiente
  /// [builder] Función que construye el widget basado en si tiene o no los permisos
  /// [fallback] Widget a mostrar si no tiene los permisos (opcional)
  const PermissionBuilder({
    super.key,
    required this.permissions,
    this.requireAll = false,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar el provider de lote de permisos para optimizar rendimiento
    final permissionBatch = ref.watch(permissionBatchProvider(permissions));
    
    // Determinar si tiene los permisos necesarios
    final hasRequiredPermissions = requireAll
        ? permissions.every((p) => permissionBatch[p] == true)
        : permissions.any((p) => permissionBatch[p] == true);
    
    // Construir widget según tenga o no los permisos
    return builder(context, hasRequiredPermissions);
  }
}

/// Widget que muestra su contenido solo si el usuario tiene los permisos requeridos
class PermissionGate extends ConsumerWidget {
  final List<String> permissions;
  final bool requireAll;
  final Widget child;
  final Widget? fallback;

  /// Constructor
  /// [permissions] Lista de permisos requeridos
  /// [requireAll] Si es true, todos los permisos son necesarios; si es false, con uno es suficiente
  /// [child] Widget a mostrar si tiene los permisos
  /// [fallback] Widget a mostrar si no tiene los permisos (opcional)
  const PermissionGate({
    super.key,
    required this.permissions,
    this.requireAll = false,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PermissionBuilder(
      permissions: permissions,
      requireAll: requireAll,
      builder: (context, hasPermission) {
        if (hasPermission) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Widget que muestra diferentes contenidos basado en permisos
class PermissionSwitch extends ConsumerWidget {
  final Map<List<String>, Widget> cases;
  final Widget? defaultWidget;
  final bool requireAll;

  /// Constructor
  /// [cases] Mapa de permisos a widgets
  /// [defaultWidget] Widget a mostrar si ninguna condición se cumple (opcional)
  /// [requireAll] Si es true, todos los permisos son necesarios; si es false, con uno es suficiente
  const PermissionSwitch({
    super.key,
    required this.cases,
    this.defaultWidget,
    this.requireAll = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.watch(permissionServiceProvider);
    
    // Evaluar cada caso y mostrar el primer widget cuya condición se cumpla
    for (final entry in cases.entries) {
      final permissions = entry.key;
      final widget = entry.value;
      
      final hasPermission = requireAll
          ? permissionService.hasAllPermissions(permissions)
          : permissionService.hasAnyPermission(permissions);
      
      if (hasPermission) {
        return widget;
      }
    }
    
    // Si ningún caso aplica, mostrar widget por defecto
    return defaultWidget ?? const SizedBox.shrink();
  }
} 