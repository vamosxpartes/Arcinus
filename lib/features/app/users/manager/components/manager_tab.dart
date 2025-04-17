import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/manager/core/services/manager_providers.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/app/users/user/screens/user_details_screen.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerTab extends ConsumerWidget {
  final TextEditingController searchController;

  const ManagerTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    developer.log(
      'Construyendo ManagerTab con query: "${userManagement.searchQuery}"',
      name: 'ManagerTab',
    );

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar gerente
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar gerentes...',
          onSearch: (query) {
            developer.log(
              'Búsqueda de gerentes: "$query"',
              name: 'ManagerTab',
            );
            userManagementNotifier.updateSearchQuery(query);
          },
        ),
        
        const Divider(),
        
        // Lista de gerentes
        Expanded(
          child: _buildManagerList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  Widget _buildManagerList(BuildContext context, WidgetRef ref, String searchQuery) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      developer.log(
        'Error: No hay academia seleccionada para listar gerentes',
        name: 'ManagerTab',
      );
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }
    
    developer.log(
      'Cargando lista de gerentes para academia: ${currentAcademy.academyId}',
      name: 'ManagerTab',
    );
    
    final managersData = ref.watch(managersProvider(currentAcademy.academyId));
    
    return managersData.when(
      data: (managers) {
        // Filtrar gerentes según búsqueda
        final filteredManagers = managers.where((manager) {
          if (manager is User) {
            return manager.name.toLowerCase().contains(searchQuery.toLowerCase());
          } else if (manager is Map<String, dynamic>) {
            final name = manager['name']?.toString() ?? '';
            return name.toLowerCase().contains(searchQuery.toLowerCase());
          }
          return false;
        }).toList();
        
        developer.log(
          'Gerentes cargados: ${managers.length}, filtrados: ${filteredManagers.length}',
          name: 'ManagerTab',
        );
        
        if (filteredManagers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay gerentes registrados'
                      : 'No se encontraron gerentes con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredManagers.length,
          itemBuilder: (context, index) {
            final manager = filteredManagers[index];
            
            // Determinar si es un usuario pendiente o activo
            final bool isPending = manager is Map<String, dynamic> && (manager['isPending'] == true);
            final String name = manager is User ? manager.name : (manager['name']?.toString() ?? 'Sin nombre');
            final String? email = manager is User ? manager.email : null;
            final String? profileImageUrl = manager is User ? manager.profileImageUrl : null;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPending ? Colors.orange : Colors.deepPurple,
                  child: profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profileImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          isPending ? Icons.pending : Icons.admin_panel_settings,
                          color: Colors.white
                        ),
                ),
                title: Text(name),
                subtitle: email != null 
                    ? Text(email)
                    : const Text('Pendiente de activación', 
                        style: TextStyle(color: Colors.orange)),
                trailing: isPending
                    ? const Chip(
                        label: Text('Pendiente'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
                onTap: () {
                  if (manager is User) {
                    developer.log(
                      'Tap en gerente: ${manager.name} (${manager.id})',
                      name: 'ManagerTab',
                    );
                    _showManagerDetails(context, ref, manager, currentAcademy.academyId);
                  } else if (manager is Map<String, dynamic>) {
                    // Mostrar detalles del usuario pendiente
                    _showPendingManagerDetails(context, manager);
                  }
                },
              ),
            );
          },
        );
      },
      loading: () {
        developer.log(
          'Cargando datos de gerentes...',
          name: 'ManagerTab',
        );
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        developer.log(
          'Error al cargar gerentes: $error',
          name: 'ManagerTab',
          error: error,
          stackTrace: stack,
        );
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        );
      },
    );
  }

  void _showPendingManagerDetails(BuildContext context, Map<String, dynamic> pendingManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerente Pendiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${pendingManager['name']}'),
            const SizedBox(height: 8),
            Text('Código de activación: ${pendingManager['id']}'),
            const SizedBox(height: 16),
            const Text(
              'Este gerente está pendiente de activación. '
              'Comparte el código de activación con el usuario para que pueda completar su registro.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Nuevo método para mostrar los detalles del manager
    // Nuevo método para mostrar los detalles del manager
  void _showManagerDetails(BuildContext context, WidgetRef ref, User manager, String academyId) {
    developer.log(
      'Navegando a detalles de gerente: ${manager.name} (${manager.id})',
      name: 'ManagerTab',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          userId: manager.id,
          userRole: UserRole.manager,
          user: manager,
        ),
      ),
    ).then((result) {
      // Si se eliminó el usuario o se realizó algún cambio, refrescar la lista
      if (result == true) {
        developer.log(
          'Actualización detectada en detalles, refrescando lista de gerentes',
          name: 'ManagerTab',
        );
        // Asegúrate que el provider 'managersProvider' acepte 'academyId'
        ref.invalidate(managersProvider(academyId)); // <-- ESTA ES LA LÍNEA IMPORTANTE
      }
    });
  }
  
  // Mantener el método de edición por si se necesita directamente
} 