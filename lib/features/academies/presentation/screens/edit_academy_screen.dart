import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/edit_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/state/edit_academy_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditAcademyScreen extends ConsumerStatefulWidget {
  final AcademyModel initialAcademy;

  const EditAcademyScreen({super.key, required this.initialAcademy});

  @override
  ConsumerState<EditAcademyScreen> createState() => _EditAcademyScreenState();
}

class _EditAcademyScreenState extends ConsumerState<EditAcademyScreen> {

  @override
  void initState() {
    super.initState();
    // Podrías querer inicializar el provider aquí si es necesario,
    // aunque al ser .family, se inicializa al leerlo la primera vez.
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(editAcademyProvider(widget.initialAcademy).notifier);
    final state = ref.watch(editAcademyProvider(widget.initialAcademy));

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
      appBar: AppBar(
        title: const Text('Editar Academia'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: state.maybeWhen(
              loading: () => const Padding(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              orElse: () => IconButton(
                icon: const Icon(Icons.save),
                onPressed: notifier.saveChanges,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: notifier.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: notifier.nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la Academia'),
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
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notifier.phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono (Opcional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notifier.emailController,
                decoration: const InputDecoration(labelText: 'Email de Contacto (Opcional)'),
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
                decoration: const InputDecoration(labelText: 'Dirección (Opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.maybeWhen(
                  loading: () => null,
                  orElse: () => () => notifier.saveChanges(),
                ),
                child: state.maybeWhen(
                  loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  orElse: () => const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 