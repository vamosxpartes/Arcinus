import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/edit_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/state/edit_academy_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/features/theme/ui/loading/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditAcademyScreen extends ConsumerStatefulWidget {
  final AcademyModel initialAcademy;
  final AcademyModel academy;

  const EditAcademyScreen({
    super.key, 
    required this.initialAcademy, 
    required this.academy
  });

  @override
  ConsumerState<EditAcademyScreen> createState() => _EditAcademyScreenState();
}

class _EditAcademyScreenState extends ConsumerState<EditAcademyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _logoImage;
  bool _hasChangedLogo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedImage != null) {
      setState(() {
        _logoImage = File(pickedImage.path);
        _hasChangedLogo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(editAcademyProvider(widget.initialAcademy).notifier);
    final state = ref.watch(editAcademyProvider(widget.initialAcademy));
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    ref.listen<EditAcademyState>(editAcademyProvider(widget.initialAcademy), (_, next) {
      next.maybeWhen(
        success: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Academia actualizada con éxito')));
          // Opcional: navegar hacia atrás
          // if (mounted) Navigator.of(context).pop();
        },
        error: (failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        },
        orElse: () { /* No hacer nada en otros estados (initial, loading) */ },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Información'),
                  Tab(text: 'Contacto'),
                  Tab(text: 'Apariencia'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Información básica
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: notifier.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: notifier.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la Academia',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es obligatorio';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: notifier.descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            _buildPreviewCard(notifier, context),
                          ],
                        ),
                      ),
                    ),
                    
                    // Tab 2: Información de contacto
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: notifier.phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: notifier.emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email de Contacto',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty && !value.contains('@')) {
                                 return 'Introduce un email válido';
                              }
                              return null;
                            }
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: notifier.addressController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    // Tab 3: Apariencia y logo
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Logo de la Academia',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightGray.withAlpha(60),
                                      borderRadius: BorderRadius.circular(75),
                                      border: Border.all(
                                        color: AppTheme.bonfireRed,
                                        width: 2,
                                      ),
                                    ),
                                    child: _logoImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(75),
                                            child: Image.file(_logoImage!, fit: BoxFit.cover),
                                          )
                                        : widget.academy.logoUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(75),
                                                child: Image.network(
                                                  widget.academy.logoUrl, 
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    const Icon(Icons.sports, size: 50, color: AppTheme.bonfireRed),
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.add_a_photo, size: 40, color: AppTheme.bonfireRed),
                                                  SizedBox(height: 8),
                                                  Text('Cambiar Logo', textAlign: TextAlign.center),
                                                ],
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Aquí podrían ir futuras opciones de tema, colores, etc.
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Opciones de Personalización',
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Próximamente podrás personalizar los colores y el tema de tu academia.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Indicador de carga
          if (isLoading)
            const LoadingIndicator(message: 'Guardando cambios...'),
        ],
      ),
      // FloatingActionButton para guardar cambios
      floatingActionButton: state.maybeWhen(
        loading: () => null, // No mostrar FAB mientras se carga
        orElse: () => FloatingActionButton(
          onPressed: () {
            if (notifier.formKey.currentState?.validate() ?? false) {
              if (_hasChangedLogo && _logoImage != null) {
                notifier.saveChangesWithLogo(_logoImage!);
              } else {
                notifier.saveChanges();
              }
            }
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(EditAcademyNotifier notifier, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista previa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.bonfireRed,
              ),
            ),
            const Divider(),
            ListTile(
              leading: _logoImage != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(_logoImage!),
                      radius: 20,
                    )
                  : widget.academy.logoUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(widget.academy.logoUrl),
                          radius: 20,
                          onBackgroundImageError: (exception, stackTrace) => 
                            const Icon(Icons.sports, color: AppTheme.bonfireRed),
                        )
                      : CircleAvatar(
                          backgroundColor: AppTheme.bonfireRed,
                          radius: 20,
                          child: Icon(Icons.sports, color: AppTheme.magnoliaWhite),
                        ),
              title: Text(
                notifier.nameController.text.isEmpty 
                    ? widget.academy.name
                    : notifier.nameController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Deporte: ${widget.academy.sportCode}'),
            ),
            if (notifier.descriptionController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(notifier.descriptionController.text),
              ),
          ],
        ),
      ),
    );
  }
} 