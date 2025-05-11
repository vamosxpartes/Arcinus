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
import 'package:arcinus/features/theme/ux/app_theme.dart';
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

    return DrawerHeader(
      decoration: BoxDecoration(
        color: userRole == AppRole.propietario 
              ? AppTheme.bonfireRed
              : AppTheme.embers, // Diferente color para colaboradores
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
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.darkGray,
                  child: Icon(Icons.person, size: 25, color: AppTheme.magnoliaWhite),
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
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => Text(
                            'Cargando...',
                            style: TextStyle(color: AppTheme.lightGray, fontSize: AppTheme.secondarySize, fontWeight: FontWeight.bold),
                          ),
                          error: (e, s) => Text(
                            authState.user?.email ?? 'Error al cargar nombre',
                            style: TextStyle(color: AppTheme.goldTrophy, fontSize: AppTheme.secondarySize, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Text(
                          authState.user?.email ?? 'Usuario',
                          style: TextStyle(
                            color: AppTheme.magnoliaWhite,
                            fontSize: AppTheme.bodySize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        userRole == AppRole.propietario ? 'Propietario' : 'Colaborador',
                        style: TextStyle(
                          color: AppTheme.lightGray,
                          fontSize: AppTheme.secondarySize,
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
                    child: Text(academy.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList();

                // Añadir opción para crear nueva academia solo para propietarios
                if (userRole == AppRole.propietario) {
                  dropdownItems.add(
                    DropdownMenuItem<String>(
                      value: _createNewAcademyValue,
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20, color: AppTheme.bonfireRed),
                          SizedBox(width: AppTheme.spacingSm),
                          Text('Crear Nueva Academia'),
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
                      icon: Icon(Icons.add_circle_outline, color: AppTheme.magnoliaWhite),
                      label: Text('Crear Academia'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/manager/academy/create');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.magnoliaWhite.withAlpha(60),
                        foregroundColor: AppTheme.magnoliaWhite,
                      ),
                    );
                  } else {
                    // Para colaboradores sin academias
                    return Center(
                      child: Text(
                        'No tienes academias asignadas',
                        style: TextStyle(color: AppTheme.lightGray),
                      ),
                    );
                  }
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                  decoration: BoxDecoration(
                    color: AppTheme.magnoliaWhite.withAlpha(40),
                    borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentAcademy?.id ?? (academies.isNotEmpty ? academies.first.id : null),
                      isExpanded: true,
                      dropdownColor: userRole == AppRole.propietario
                          ? AppTheme.bonfireRed.withAlpha(240)
                          : AppTheme.embers.withAlpha(240),
                      icon: Icon(Icons.arrow_drop_down, color: AppTheme.magnoliaWhite),
                      style: TextStyle(color: AppTheme.magnoliaWhite, fontSize: AppTheme.secondarySize),
                      hint: Text('Seleccionar Academia', style: TextStyle(color: AppTheme.lightGray)),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == _createNewAcademyValue) {
                            Navigator.pop(context); // Cerrar el drawer
                            context.go('/manager/academy/create');
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
                ),
              ),
              error: (error, stack) => Text(
                'Error: $error', 
                style: TextStyle(color: AppTheme.magnoliaWhite),
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
          padding: EdgeInsets.only(left: AppTheme.spacingSm, top: AppTheme.spacingSm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FUNCIONES PRINCIPALES',
              style: TextStyle(
                color: AppTheme.bonfireRed,
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // --- Dashboard ---
        ListTile(
          leading: Icon(Icons.dashboard, color: AppTheme.bonfireRed),
          title: Text('Dashboard'),
          onTap: () {
            _navigateTo(context, AppRoutes.managerDashboard);
          },
        ),
        
        // --- Miembros ---
        ListTile(
          leading: Icon(Icons.groups, color: AppTheme.bonfireRed),
          title: Text('Miembros'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go('${AppRoutes.managerAcademyMembers.replaceAll(':academyId', currentAcademy.id!)}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecciona una academia para ver sus miembros.')),
              );
            }
          },
        ),
        
        // --- Planes de Suscripción ---
        ListTile(
          leading: Icon(Icons.subscriptions, color: AppTheme.bonfireRed),
          title: Text('Planes de Suscripción'),
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
          padding: EdgeInsets.all(AppTheme.spacingSm),
          child: Text(
            'PRÓXIMAMENTE',
            style: TextStyle(
              color: AppTheme.lightGray,
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // --- Academia ---
        ListTile(
          leading: Icon(Icons.school, color: AppTheme.lightGray),
          title: Text('Academia'),
          enabled: false,
          onTap: null,
        ),
        
        // --- Horarios ---
        ListTile(
          leading: Icon(Icons.calendar_today, color: AppTheme.lightGray),
          title: Text('Horarios'),
          enabled: false,
          onTap: null,
        ),
        
        // --- Estadísticas (solo propietarios) ---
        if (userRole == AppRole.propietario)
          ListTile(
            leading: Icon(Icons.bar_chart, color: AppTheme.lightGray),
            title: Text('Estadísticas'),
            enabled: false,
            onTap: null,
          ),
          
        // --- Grupos ---
        ListTile(
          leading: Icon(Icons.groups_2, color: AppTheme.lightGray),
          title: Text('Grupos'),
          enabled: false,
          onTap: null,
        ),
        
        // --- Entrenamientos ---
        ListTile(
          leading: Icon(Icons.fitness_center, color: AppTheme.lightGray),
          title: Text('Entrenamientos'),
          enabled: false,
          onTap: null,
        ),
        
        // --- SECCIÓN 3: CUENTA Y CONFIGURACIÓN ---
        Divider(color: AppTheme.darkGray),
        
        Padding(
          padding: EdgeInsets.all(AppTheme.spacingSm),
          child: Text(
            'MI CUENTA',
            style: TextStyle(
              color: AppTheme.bonfireRed,
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // --- Perfil ---
        ListTile(
          leading: Icon(Icons.person, color: AppTheme.bonfireRed),
          title: Text('Mi Perfil'),
          onTap: () {
            _navigateTo(context, AppRoutes.managerProfile);
          },
        ),
        
        // --- Ajustes ---
        ListTile(
          leading: Icon(Icons.settings, color: AppTheme.bonfireRed),
          title: Text('Configuración'),
          onTap: () {
            _navigateTo(context, AppRoutes.managerSettings);
          },
        ),
        
        // --- Cerrar Sesión ---
        ListTile(
          leading: Icon(Icons.logout, color: AppTheme.bonfireRed),
          title: Text('Cerrar Sesión'),
          onTap: () {
            _confirmSignOut(context, ref);
          },
        ),
        
        // --- Pie del Drawer ---
        Container(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          alignment: Alignment.center,
          child: Text(
            'Arcinus v1.0.0',
            style: TextStyle(color: AppTheme.lightGray, fontSize: AppTheme.captionSize),
          ),
        ),
      ],
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