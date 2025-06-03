import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/super_admin/presentation/providers/owners_management_provider.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/owner_card.dart';

/// Pantalla de gestión de propietarios de academias
/// 
/// Permite ver, filtrar, buscar y gestionar todos los propietarios
/// registrados en la plataforma Arcinus.
class OwnersManageScreen extends ConsumerStatefulWidget {
  const OwnersManageScreen({super.key});

  @override
  ConsumerState<OwnersManageScreen> createState() => _OwnersManageScreenState();
}

class _OwnersManageScreenState extends ConsumerState<OwnersManageScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Pantalla de gestión de propietarios inicializada',
      className: 'OwnersManageScreen',
      functionName: 'initState',
    );
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ownersManagementProvider.notifier).loadOwners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownersManagementProvider);
    
    AppLogger.logInfo(
      'Building OwnersManageScreen',
      className: 'OwnersManageScreen',
      functionName: 'build',
      params: {
        'totalOwners': state.owners.length,
        'filteredOwners': state.filteredOwners.length,
        'isLoading': state.isLoading,
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.magnoliaWhite,
      body: Column(
        children: [
          // Header con título y estadísticas
          _buildHeader(state),
          
          // Barra de filtros y búsqueda
          _buildFiltersBar(state),
          
          // Lista de propietarios
          Expanded(
            child: _buildOwnersList(state),
          ),
        ],
      ),
    );
  }

  /// Construye el header con título y estadísticas rápidas
  Widget _buildHeader(OwnersManagementState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          const Text(
            'Gestión de Propietarios',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra todos los propietarios de academias registrados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(200),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas rápidas
          if (!state.isLoading)
            Row(
              children: [
                _buildQuickStat(
                  'Total',
                  state.owners.length.toString(),
                  Icons.people_outline,
                  Colors.white,
                ),
                const SizedBox(width: 24),
                _buildQuickStat(
                  'Activos',
                  _getCountByStatus(state.owners, OwnerStatus.active).toString(),
                  Icons.check_circle_outline,
                  Colors.green.shade200,
                ),
                const SizedBox(width: 24),
                _buildQuickStat(
                  'Pendientes',
                  _getCountByStatus(state.owners, OwnerStatus.pending).toString(),
                  Icons.hourglass_empty_outlined,
                  Colors.blue.shade200,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Construye la barra de filtros y búsqueda
  Widget _buildFiltersBar(OwnersManagementState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Campo de búsqueda
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(ownersManagementProvider.notifier).updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, email o academia...',
                    prefixIcon: const Icon(Icons.search_outlined),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(ownersManagementProvider.notifier).updateSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple.shade600, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Filtro por estado
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<OwnerStatusFilter>(
                  value: state.statusFilter,
                  onChanged: (filter) {
                    if (filter != null) {
                      ref.read(ownersManagementProvider.notifier).updateStatusFilter(filter);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple.shade600, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: OwnerStatusFilter.values.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(_getFilterLabel(filter)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Información de resultados
          Row(
            children: [
              Text(
                'Mostrando ${state.filteredOwners.length} de ${state.owners.length} propietarios',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              if (state.lastUpdate != null)
                Text(
                  'Actualizado: ${_formatLastUpdate(state.lastUpdate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la lista de propietarios
  Widget _buildOwnersList(OwnersManagementState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando propietarios...'),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(ownersManagementProvider.notifier).loadOwners();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.filteredOwners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.owners.isEmpty
                  ? 'No hay propietarios registrados'
                  : 'No se encontraron propietarios con los filtros aplicados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.searchQuery.isNotEmpty || state.statusFilter != OwnerStatusFilter.all) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(ownersManagementProvider.notifier).updateSearchQuery('');
                  ref.read(ownersManagementProvider.notifier).updateStatusFilter(OwnerStatusFilter.all);
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ownersManagementProvider.notifier).refreshOwners();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredOwners.length,
        itemBuilder: (context, index) {
          final owner = state.filteredOwners[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OwnerCard(
              owner: owner,
              onStatusChanged: (newStatus) {
                _handleStatusChange(owner.id, newStatus);
              },
            ),
          );
        },
      ),
    );
  }

  /// Construye una estadística rápida
  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Maneja el cambio de estado de un propietario
  void _handleStatusChange(String ownerId, OwnerStatus newStatus) {
    AppLogger.logInfo(
      'Cambiando estado del propietario',
      className: 'OwnersManageScreen',
      functionName: '_handleStatusChange',
      params: {
        'ownerId': ownerId,
        'newStatus': newStatus.toString(),
      },
    );

    ref.read(ownersManagementProvider.notifier).changeOwnerStatus(ownerId, newStatus);

    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado del propietario actualizado a ${_getStatusLabel(newStatus)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Obtiene el conteo de propietarios por estado
  int _getCountByStatus(List<OwnerData> owners, OwnerStatus status) {
    return owners.where((owner) => owner.status == status).length;
  }

  /// Obtiene la etiqueta del filtro
  String _getFilterLabel(OwnerStatusFilter filter) {
    switch (filter) {
      case OwnerStatusFilter.all:
        return 'Todos';
      case OwnerStatusFilter.active:
        return 'Activos';
      case OwnerStatusFilter.inactive:
        return 'Inactivos';
      case OwnerStatusFilter.suspended:
        return 'Suspendidos';
      case OwnerStatusFilter.pending:
        return 'Pendientes';
    }
  }

  /// Obtiene la etiqueta del estado
  String _getStatusLabel(OwnerStatus status) {
    switch (status) {
      case OwnerStatus.active:
        return 'Activo';
      case OwnerStatus.inactive:
        return 'Inactivo';
      case OwnerStatus.suspended:
        return 'Suspendido';
      case OwnerStatus.pending:
        return 'Pendiente';
    }
  }

  /// Formatea la última actualización
  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
} 