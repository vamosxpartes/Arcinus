import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/academy/academy_controller.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyListScreen extends ConsumerWidget {
  const AcademyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationService navigationService = NavigationService();
    final userAcademies = ref.watch(userAcademiesProvider);
    final userAsync = ref.watch(authStateProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis Academias',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Solo mostramos el botón de crear si el usuario es propietario
                          userAsync.whenData((user) {
                            if (user?.role == UserRole.owner) {
                              return IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/create-academy');
                                },
                                tooltip: 'Crear Academia',
                              );
                            }
                            return const SizedBox.shrink();
                          }).valueOrNull ?? const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Lista de academias
                  userAcademies.when(
                    data: (academies) {
                      if (academies.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No tienes academias',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Crea una nueva academia o únete a una existente',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final academy = academies[index];
                              return _AcademyCard(
                                academy: academy,
                                onTap: () {
                                  ref.read(academyControllerProvider).selectAcademy(academy);
                                  // Navegar a los detalles de la academia
                                  Navigator.pushNamed(context, '/academy-details');
                                },
                              );
                            },
                            childCount: academies.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text('Error: $error'),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(userAcademiesProvider);
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Barra de navegación
            CustomNavigationBar(
              pinnedItems: navigationService.pinnedItems,
              allItems: NavigationItems.allItems,
              activeRoute: '/academies',
              onItemTap: (item) => navigationService.navigateToRoute(context, item.destination),
              onItemLongPress: (item) => navigationService.togglePinItem(item, context: context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyCard extends StatelessWidget {
  final Academy academy;
  final VoidCallback onTap;
  
  const _AcademyCard({
    required this.academy,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar o logo de academia
            Expanded(
              flex: 3,
              child: academy.logo != null
                  ? Image.network(
                      academy.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : _buildPlaceholder(theme),
            ),
            
            // Información de la academia
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      academy.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      academy.sport,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mostrar número de atletas o grupos si están disponibles
                    if (academy.athleteIds?.isNotEmpty == true)
                      Text(
                        '${academy.athleteIds!.length} atletas',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.sports,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(125),
        ),
      ),
    );
  }
} 