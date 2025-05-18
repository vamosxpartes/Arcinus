import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/navigation/app_routes.dart';

const String _createNewAcademyValue = '__CREATE_NEW_ACADEMY__';

/// Widget que construye el drawer de navegación para roles de gestión.
class ManagerDrawer extends ConsumerWidget {
  /// El contexto desde donde se llama
  final BuildContext context;
  
  /// El rol del usuario actual
  final AppRole? userRole;

  /// Constructor para ManagerDrawer
  const ManagerDrawer({super.key, required this.context, required this.userRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar que el rol es de gestión
    final isManager = userRole == AppRole.propietario || userRole == AppRole.colaborador;
    if (!isManager) {
      AppLogger.logWarning(
        'Usuario no gestor intentando acceder a ManagerDrawer',
        className: 'ManagerDrawer',
        functionName: 'build',
        params: {'role': userRole?.name ?? 'desconocido'},
      );
      return const Drawer(
        child: Center(child: Text('Acceso no autorizado')),
      );
    }
    
    return Drawer(
      backgroundColor: AppTheme.blackSwarm,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, ref),
          _buildDrawerNavItems(context, ref),
        ],
      ),
    );
  }

  // Header del drawer con información del usuario y selector de academia
  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final userId = authState.user?.id;
    final userProfileAsyncValue = userId != null ? ref.watch(userProfileProvider(userId)) : null;
    final academiesAsync = userId != null ? ref.watch(ownerAcademiesProvider(userId)) : null;
    
    // Usar el provider que contiene el objeto completo
    final currentAcademy = ref.watch(currentAcademyProvider);

    // Color del header según el rol
    final headerColor = userRole == AppRole.propietario 
        ? AppTheme.bonfireRed
        : AppTheme.nbaBluePrimary;

    return DrawerHeader(
      decoration: BoxDecoration(
        color: headerColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.go('/manager/profile');
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.magnoliaWhite, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.darkGray,
                    child: Icon(Icons.person, size: 22, color: AppTheme.magnoliaWhite),
                  ),
                ),
                SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userId != null && userProfileAsyncValue != null)
                        userProfileAsyncValue.when(
                          data: (userProfile) => Text(
                            userProfile?.name?.isNotEmpty == true ? userProfile!.name! : (authState.user?.email ?? 'Usuario'),
                            style: TextStyle(
                              color: AppTheme.magnoliaWhite,
                              fontSize: AppTheme.bodySize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => Text(
                            'Cargando...',
                            style: TextStyle(color: AppTheme.lightGray, fontSize: AppTheme.secondarySize, fontWeight: FontWeight.w600),
                          ),
                          error: (e, s) => Text(
                            authState.user?.email ?? 'Error al cargar nombre',
                            style: TextStyle(color: AppTheme.goldTrophy, fontSize: AppTheme.secondarySize, fontWeight: FontWeight.w600),
                          ),
                        )
                      else
                        Text(
                          authState.user?.email ?? 'Usuario',
                          style: TextStyle(
                            color: AppTheme.magnoliaWhite,
                            fontSize: AppTheme.bodySize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        userRole == AppRole.propietario ? 'Propietario' : 'Colaborador',
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite.withAlpha(170),
                          fontSize: AppTheme.secondarySize,
                          letterSpacing: 0.25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacingSm),
          if (userId != null && academiesAsync != null)
            academiesAsync.when(
              data: (academies) {
                List<DropdownMenuItem<String>> dropdownItems = academies
                    .map<DropdownMenuItem<String>>((AcademyModel academy) {
                  return DropdownMenuItem<String>(
                    value: academy.id,
                    child: Text(
                      academy.name, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTheme.secondarySize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.25,
                      ),
                    ),
                  );
                }).toList();

                // Añadir opción para crear nueva academia solo para propietarios
                if (userRole == AppRole.propietario) {
                  dropdownItems.add(
                    DropdownMenuItem<String>(
                      value: _createNewAcademyValue,
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 18, color: AppTheme.bonfireRed),
                          SizedBox(width: AppTheme.spacingSm),
                          Text(
                            'Crear Nueva Academia',
                            style: TextStyle(
                              fontSize: AppTheme.secondarySize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Establecer automáticamente la primera academia como valor predeterminado
                if (currentAcademy == null && academies.isNotEmpty) {
                  // Usar Future.microtask para evitar actualizar el estado durante la construcción
                  Future.microtask(() {
                    // Establecer la academia completa
                    ref.read(currentAcademyProvider.notifier).state = academies.first;
                  });
                }

                if (academies.isEmpty) {
                  // Si no hay academias y es propietario, mostrar botón de crear
                  if (userRole == AppRole.propietario) {
                    return ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline, color: AppTheme.magnoliaWhite, size: 18),
                      label: Text(
                        'Crear Academia',
                        style: TextStyle(
                          fontSize: AppTheme.secondarySize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(AppRoutes.managerCreateAcademy);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.magnoliaWhite.withAlpha(60),
                        foregroundColor: AppTheme.magnoliaWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  } else {
                    // Para colaboradores sin academias
                    return Center(
                      child: Text(
                        'No tienes academias asignadas',
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite.withAlpha(170),
                          fontSize: AppTheme.secondarySize,
                          letterSpacing: 0.25,
                        ),
                      ),
                    );
                  }
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                  decoration: BoxDecoration(
                    color: AppTheme.magnoliaWhite.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentAcademy?.id ?? (academies.isNotEmpty ? academies.first.id : null),
                      isExpanded: true,
                      dropdownColor: headerColor.withAlpha(240),
                      icon: Icon(Icons.arrow_drop_down, color: AppTheme.magnoliaWhite),
                      style: TextStyle(
                        color: AppTheme.magnoliaWhite, 
                        fontSize: AppTheme.secondarySize,
                        letterSpacing: 0.25,
                      ),
                      hint: Text(
                        'Seleccionar Academia', 
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite.withAlpha(170),
                          fontSize: AppTheme.secondarySize,
                          letterSpacing: 0.25,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == _createNewAcademyValue) {
                            Navigator.pop(context); // Cerrar el drawer
                            context.go(AppRoutes.managerCreateAcademy);
                          } else {
                            // Buscar la academia completa por ID
                            final selectedAcademy = academies.firstWhere(
                              (academy) => academy.id == newValue,
                              orElse: () => throw Exception('Academia no encontrada: $newValue'),
                            );
                            // Establecer el objeto completo
                            ref.read(currentAcademyProvider.notifier).state = selectedAcademy;
                          }
                        }
                      },
                      items: dropdownItems,
                    ),
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.magnoliaWhite),
                  strokeWidth: 2,
                ),
              ),
              error: (error, stack) => Text(
                'Error: $error', 
                style: TextStyle(
                  color: AppTheme.magnoliaWhite,
                  fontSize: AppTheme.secondarySize,
                  letterSpacing: 0.25,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Elementos de navegación
  Widget _buildDrawerNavItems(BuildContext context, WidgetRef ref) {
      
    return Column(
      children: [
        // --- SECCIÓN 1: FUNCIONALIDADES ACTIVAS ---
        Padding(
          padding: EdgeInsets.only(left: AppTheme.spacingMd, top: AppTheme.spacingMd, bottom: AppTheme.spacingSm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FUNCIONES PRINCIPALES',
              style: TextStyle(
                color: AppTheme.bonfireRed,
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        // --- Dashboard ---
        _buildDrawerItem(
          context,
          AppRoutes.managerDashboard,
          Icons.dashboard,
          'Dashboard',
          isActive: true,
        ),
        
        // --- Academia ---
        ListTile(
          dense: true,
          leading: Icon(Icons.school, color: AppTheme.bonfireRed, size: 20),
          title: Text(
            'Academia',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.magnoliaWhite,
              fontSize: AppTheme.bodySize,
              letterSpacing: 0.15,
            )
          ),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go('/manager/academy/${currentAcademy.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecciona una academia primero')),
              );
            }
          },
        ),
        
        // --- Miembros ---
        ListTile(
          dense: true,
          leading: Icon(Icons.groups, color: AppTheme.bonfireRed, size: 20),
          title: Text(
            'Miembros',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.magnoliaWhite,
              fontSize: AppTheme.bodySize,
              letterSpacing: 0.15,
            )
          ),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go(AppRoutes.managerAcademyMembers.replaceAll(':academyId', currentAcademy.id!));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecciona una academia para ver sus miembros.')),
              );
            }
          },
        ),
        
        // --- Planes de Suscripción ---
        ListTile(
          dense: true,
          leading: Icon(Icons.subscriptions, color: AppTheme.bonfireRed, size: 20),
          title: Text(
            'Planes',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.magnoliaWhite,
              fontSize: AppTheme.bodySize,
              letterSpacing: 0.15,
            )
          ),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              // Utilizamos una ruta temporal ya que la definitiva deberá agregarse en el router
              context.go('/manager/academy/${currentAcademy.id}/subscription-plans');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecciona una academia primero')),
              );
            }
          },
        ),
        
        // --- SECCIÓN 2: FUNCIONALIDADES EN DESARROLLO ---
        Divider(color: AppTheme.darkGray),
        
        Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: Text(
            'PRÓXIMAMENTE',
            style: TextStyle(
              color: AppTheme.lightGray,
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // --- Inventario ---
        _buildDrawerItem(
          context,
          '',
          Icons.inventory_2_outlined,
          'Inventario',
          isActive: false,
        ),
        
        // --- Facturación ---
        _buildDrawerItem(
          context,
          '',
          Icons.receipt_long_outlined,
          'Facturación',
          isActive: false,
        ),
        
        // --- Normas y documentos ---
        _buildDrawerItem(
          context,
          '',
          Icons.gavel_outlined,
          'Normas y documentos',
          isActive: false,
        ),
        
        // --- Redes sociales ---
        _buildDrawerItem(
          context,
          '',
          Icons.share_outlined,
          'Redes sociales',
          isActive: false,
        ),
        
        // --- Marca y personalización ---
        _buildDrawerItem(
          context,
          '',
          Icons.brush_outlined,
          'Marca y personalización',
          isActive: false,
        ),
        
        // --- Instalaciones ---
        _buildDrawerItem(
          context,
          '',
          Icons.location_on_outlined,
          'Instalaciones',
          isActive: false,
        ),
        
        // --- Notificaciones ---
        _buildDrawerItem(
          context,
          '',
          Icons.notifications_outlined,
          'Notificaciones',
          isActive: false,
        ),
        
        // --- Horarios ---
        _buildDrawerItem(
          context,
          '',
          Icons.calendar_today,
          'Horarios',
          isActive: false,
        ),
        
        // --- Estadísticas (solo propietarios) ---
        if (userRole == AppRole.propietario)
          _buildDrawerItem(
            context,
            '',
            Icons.bar_chart,
            'Estadísticas',
            isActive: false,
          ),
          
        // --- Grupos ---
        _buildDrawerItem(
          context,
          '',
          Icons.groups_2,
          'Grupos',
          isActive: false,
        ),
        
        // --- Entrenamientos ---
        _buildDrawerItem(
          context,
          '',
          Icons.fitness_center,
          'Entrenamientos',
          isActive: false,
        ),
        
        // --- SECCIÓN 3: CUENTA Y CONFIGURACIÓN ---
        Divider(color: AppTheme.darkGray),
        
        Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: Text(
            'MI CUENTA',
            style: TextStyle(
              color: AppTheme.bonfireRed,
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // --- Perfil ---
        _buildDrawerItem(
          context,
          AppRoutes.managerProfile,
          Icons.person,
          'Mi Perfil',
          isActive: true,
        ),
        
        // --- Ajustes ---
        _buildDrawerItem(
          context,
          AppRoutes.managerSettings,
          Icons.settings,
          'Configuración',
          isActive: true,
        ),
        
        // --- Cerrar Sesión ---
        _buildDrawerItem(
          context,
          '',
          Icons.logout,
          'Cerrar Sesión',
          isActive: true,
          onTap: () => _confirmSignOut(context, ref),
        ),
        
        // --- Pie del Drawer ---
        Container(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          alignment: Alignment.center,
          child: Text(
            'Arcinus v1.0.0',
            style: TextStyle(
              color: AppTheme.lightGray, 
              fontSize: AppTheme.captionSize,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
  
  // Widget para construir elementos del drawer de manera consistente
  Widget _buildDrawerItem(
    BuildContext context,
    String route,
    IconData icon,
    String title, {
    bool isActive = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon, 
        color: isActive ? AppTheme.bonfireRed : AppTheme.lightGray,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isActive ? AppTheme.magnoliaWhite : AppTheme.lightGray,
          fontSize: AppTheme.bodySize,
          letterSpacing: 0.15,
        ),
      ),
      enabled: isActive,
      onTap: onTap ?? (isActive && route.isNotEmpty ? () => _navigateTo(context, route) : null),
    );
  }
  
  // Navegación con cierre de drawer
  void _navigateTo(BuildContext context, String route) {
    // Cerrar el drawer primero
    Navigator.pop(context);
    // Luego navegar
    context.go(route);
    
    AppLogger.logInfo(
      'Navegando desde drawer',
      className: 'ManagerDrawer',
      functionName: '_navigateTo',
      params: {'route': route},
    );
  }
  
  // Confirmar cierre de sesión
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar drawer
              // Cerrar sesión
              ref.read(authStateNotifierProvider.notifier).signOut();
            },
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
} 