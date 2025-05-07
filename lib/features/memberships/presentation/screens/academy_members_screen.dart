import 'package:arcinus/features/memberships/presentation/screens/academy_members_list_screen.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyMembersScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersScreen> createState() => _AcademyMembersScreenState();
}

class _AcademyMembersScreenState extends ConsumerState<AcademyMembersScreen> {
  @override
  void initState() {
    super.initState();
    // Actualizar el título en el OwnerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Miembros de la Academia';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simplemente redirigir a la nueva pantalla de lista de miembros
    return AcademyMembersListScreen(academyId: widget.academyId);
  }
} 