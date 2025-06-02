import 'package:flutter/material.dart';
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';
import 'package:arcinus/features/academy_users/presentation/utils/user_role_utils.dart';

class UserProfileHeader extends StatelessWidget {
  final AcademyUserModel user;

  const UserProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto de perfil
            Center(
              child: Hero(
                tag: 'user_avatar_${user.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: UserRoleUtils.getRoleColor(user.role),
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre completo
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            // Rol
            Chip(
              label: Text(UserRoleUtils.getRoleName(user.role)),
              backgroundColor: UserRoleUtils.getRoleColor(user.role).withAlpha(20),
              labelStyle: TextStyle(
                color: UserRoleUtils.getRoleColor(user.role),
                fontWeight: FontWeight.bold,
              ),
            ),
            // Posición si es un atleta
            if (user.position != null && user.position!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Posición: ${user.position}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 