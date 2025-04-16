import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:arcinus/features/navigation/core/services/auth_routing_middleware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scaffold que integra el middleware de autenticación con el BaseScaffold.
///
/// Este widget extiende la funcionalidad del BaseScaffold verificando 
/// automáticamente el estado de autenticación y redirigiendo si es necesario.
class AuthScaffold extends ConsumerStatefulWidget {
  /// El contenido principal del scaffold
  final Widget body;
  
  /// Si se debe mostrar la barra de navegación inferior
  final bool showNavigation;
  
  /// AppBar opcional
  final PreferredSizeWidget? appBar;
  
  /// Botón de acción flotante opcional
  final Widget? floatingActionButton;
  
  /// Color de fondo del scaffold
  final Color? backgroundColor;
  
  /// Si el cuerpo debe extenderse debajo de la barra de navegación
  final bool extendBody;
  
  /// Padding opcional para el contenido principal
  final EdgeInsets? padding;
  
  /// Opcional: función para manejar el tap en el botón de agregar
  final VoidCallback? onAddButtonTap;
  
  /// Si se debe redirigir automáticamente cuando no hay autenticación
  final bool redirectOnUnauthenticated;
  
  const AuthScaffold({
    super.key,
    required this.body,
    this.showNavigation = true,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.padding,
    this.onAddButtonTap,
    this.redirectOnUnauthenticated = true,
  });
  
  @override
  ConsumerState<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends ConsumerState<AuthScaffold> {
  @override
  void initState() {
    super.initState();
    
    // Verificación post-frame para dar tiempo a que el context esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.redirectOnUnauthenticated) {
        AuthRoutingMiddleware.checkAuthentication(context, ref);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Configurar listener para cambios en autenticación
    AuthRoutingMiddleware.setupAuthListener(context, ref);
    
    return BaseScaffold(
      body: widget.body,
      showNavigation: widget.showNavigation,
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      backgroundColor: widget.backgroundColor,
      extendBody: widget.extendBody,
      padding: widget.padding,
      onAddButtonTap: widget.onAddButtonTap,
    );
  }
} 