import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSearchBar extends ConsumerWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback onAddPressed;
  final String addButtonTooltip;

  const UserSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.onAddPressed,
    this.addButtonTooltip = 'Agregar',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Barra de búsqueda
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(),
              ),
              onChanged: onSearch,
            ),
          ),
          
          // Botón de agregar
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IconButton(
              onPressed: onAddPressed,
              icon: const Icon(
                Icons.person_add,
                color: Colors.white,
              ),
              tooltip: addButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }
} 