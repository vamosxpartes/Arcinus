import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting

class AcademyScreen extends ConsumerWidget {
  final String academyId;
  const AcademyScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyDetailsAsync = ref.watch(academyDetailsProvider(academyId));

    return Scaffold(
      appBar: AppBar(
        title: academyDetailsAsync.when(
          data: (academy) => Text(academy.name),
          loading: () => const Text('Cargando Academia...'),
          error: (_, __) => const Text('Detalles de Academia'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            // Consider navigating to a default/fallback route if cannot pop
            // e.g., context.go('/owner/dashboard');
          },
        ),
      ),
      body: academyDetailsAsync.when(
        data: (academy) => _buildAcademyDetails(context, academy),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar los detalles de la academia: $error\\nPor favor, asegúrate de que la academia exista y tengas acceso.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademyDetails(BuildContext context, AcademyModel academy) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        if (academy.logoUrl != null && academy.logoUrl!.isNotEmpty)
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(academy.logoUrl!),
              backgroundColor: Colors.grey[200],
              onBackgroundImageError: (_, __) {
                // Optionally handle image loading error, e.g., show placeholder
              },
            ),
          ),
        if (academy.logoUrl != null && academy.logoUrl!.isNotEmpty)
          const SizedBox(height: 16),
        Center(
          child: Text(
            academy.name,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        if (academy.description != null && academy.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              academy.description!,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        _buildDetailItem(context, Icons.sports_soccer, 'Deporte Principal', academy.sportCode), // Assuming sportCode is human-readable or needs mapping
        if (academy.email != null && academy.email!.isNotEmpty)
          _buildDetailItem(context, Icons.email_outlined, 'Email de Contacto', academy.email!),
        if (academy.phone != null && academy.phone!.isNotEmpty)
          _buildDetailItem(context, Icons.phone_outlined, 'Teléfono', academy.phone!),
        if (academy.address != null && academy.address!.isNotEmpty)
          _buildDetailItem(context, Icons.location_on_outlined, 'Dirección', academy.address!),
        if (academy.location.isNotEmpty) // location is required
           _buildDetailItem(context, Icons.map_outlined, 'Ubicación (Coord.)', academy.location),
        if (academy.createdAt != null)
          _buildDetailItem(context, Icons.calendar_today_outlined, 'Fecha de Creación', DateFormat.yMMMd('es').format(academy.createdAt!)),
        
        // TODO: Add more fields as needed, e.g., for managing members, schedules, etc.
        // Consider adding Edit Academy button if applicable for the owner
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar Academia'),
          onPressed: () {
            // TODO: Implement navigation to edit academy screen
            // context.go('/owner/academy/$academyId/edit');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente: Editar Academia')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 