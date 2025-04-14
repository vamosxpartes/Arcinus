import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:arcinus/features/theme/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildNotLoggedInView();
        }
        return _buildProfileContent(context, ref, user);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.embers),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error al cargar perfil: $error',
          style: const TextStyle(color: AppTheme.bonfireRed),
        ),
      ),
    );
  }
  
  Widget _buildNotLoggedInView() {
    return const BaseScaffold(
      showNavigation: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 100,
              color: AppTheme.mediumGray,
            ),
            SizedBox(height: 16),
            Text(
              'Inicia sesión para ver tu perfil',
              style: TextStyle(
                fontSize: AppTheme.h3Size,
                color: AppTheme.magnoliaWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileContent(BuildContext context, WidgetRef ref, User user) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(context, user),
            _buildRoleSpecificContent(context, ref, user),
            const SizedBox(height: 20),
            _buildProfileOptions(context, ref),
            const SizedBox(height: 20),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.embers, AppTheme.bonfireRed.withAlpha(200)],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingLg,
        horizontal: AppTheme.spacingMd,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.magnoliaWhite.withAlpha(60),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.magnoliaWhite,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.magnoliaWhite,
                  ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: AppTheme.h2Size,
              fontWeight: FontWeight.bold,
              color: AppTheme.magnoliaWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            user.email,
            style: TextStyle(
              fontSize: AppTheme.bodySize,
              color: AppTheme.magnoliaWhite.withAlpha(200),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.magnoliaWhite.withAlpha(60),
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            ),
            child: Text(
              _getRoleText(user.role),
              style: const TextStyle(
                color: AppTheme.magnoliaWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoleSpecificContent(BuildContext context, WidgetRef ref, User user) {
    switch (user.role) {
      case UserRole.owner:
        return _buildOwnerContent(context, ref);
      case UserRole.athlete:
        return _buildAthleteContent(context, ref);
      case UserRole.parent:
        return _buildParentContent(context, ref);
      case UserRole.coach:
        return _buildCoachContent(context, ref);
      case UserRole.manager:
        return _buildManagerContent(context, ref);
      case UserRole.superAdmin:
        return _buildSuperAdminContent(context, ref);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOwnerContent(BuildContext context, WidgetRef ref) {
    final academyState = ref.watch(currentAcademyProvider);
    
    if (academyState == null) {
      return _buildInfoCard(
        title: 'Suscripción',
        content: 'No tienes una academia configurada',
        icon: Icons.school,
      );
    }
    
    return _buildInfoCard(
      title: 'Suscripción Arcinus',
      content: _getSubscriptionText(academyState.subscription),
      icon: Icons.workspace_premium,
      iconColor: AppTheme.goldTrophy,
    );
  }

  Widget _buildAthleteContent(BuildContext context, WidgetRef ref) {
    final academyState = ref.watch(currentAcademyProvider);
    
    if (academyState == null) {
      return _buildInfoCard(
        title: 'Academia',
        content: 'No estás inscrito en ninguna academia',
        icon: Icons.sports,
      );
    }
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Academia',
          content: academyState.name,
          icon: Icons.sports,
        ),
        _buildInfoCard(
          title: 'Deporte',
          content: academyState.sport,
          icon: Icons.sports_basketball,
        ),
      ],
    );
  }

  Widget _buildParentContent(BuildContext context, WidgetRef ref) {
    final academyState = ref.watch(currentAcademyProvider);
    
    if (academyState == null) {
      return _buildInfoCard(
        title: 'Academia',
        content: 'No tienes atletas inscritos en una academia',
        icon: Icons.family_restroom,
      );
    }
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Academia de tus atletas',
          content: academyState.name,
          icon: Icons.family_restroom,
        ),
        _buildInfoCard(
          title: 'Deporte',
          content: academyState.sport,
          icon: Icons.sports_basketball,
        ),
      ],
    );
  }

  Widget _buildCoachContent(BuildContext context, WidgetRef ref) {
    final academyState = ref.watch(currentAcademyProvider);
    
    if (academyState == null) {
      return _buildInfoCard(
        title: 'Academia',
        content: 'No formas parte de ninguna academia',
        icon: Icons.sports,
      );
    }
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Academia',
          content: academyState.name,
          icon: Icons.school,
        ),
        _buildInfoCard(
          title: 'Deporte',
          content: academyState.sport,
          icon: Icons.sports_basketball,
        ),
      ],
    );
  }

  Widget _buildManagerContent(BuildContext context, WidgetRef ref) {
    final academyState = ref.watch(currentAcademyProvider);
    
    if (academyState == null) {
      return _buildInfoCard(
        title: 'Academia',
        content: 'No administras ninguna academia',
        icon: Icons.business,
      );
    }
    
    return Column(
      children: [
        _buildInfoCard(
          title: 'Academia',
          content: academyState.name,
          icon: Icons.business,
        ),
        _buildInfoCard(
          title: 'Propietario',
          content: 'ID: ${academyState.ownerId}',
          icon: Icons.person,
        ),
      ],
    );
  }

  Widget _buildSuperAdminContent(BuildContext context, WidgetRef ref) {
    return _buildInfoCard(
      title: 'Administrador de Arcinus',
      content: 'Acceso completo al sistema',
      icon: Icons.admin_panel_settings,
      iconColor: AppTheme.goldTrophy,
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.mediumGray,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(AppTheme.inputRadius),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.magnoliaWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTheme.subtitleSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: AppTheme.bodySize,
                    color: AppTheme.magnoliaWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Text(
            'Opciones',
            style: TextStyle(
              fontSize: AppTheme.h3Size,
              fontWeight: FontWeight.bold,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ),
        _buildProfileOption(
          icon: Icons.settings,
          title: 'Configuración',
          onTap: () {},
        ),
        const Divider(color: AppTheme.darkGray),
        _buildProfileOption(
          icon: Icons.help_outline,
          title: 'Ayuda y Soporte',
          onTap: () {},
        ),
        const Divider(color: AppTheme.darkGray),
        _buildProfileOption(
          icon: Icons.privacy_tip_outlined,
          title: 'Política de Privacidad',
          onTap: () {},
        ),
        const Divider(color: AppTheme.darkGray),
        _buildProfileOption(
          icon: Icons.logout,
          title: 'Cerrar Sesión',
          onTap: () {
            ref.read(authStateProvider.notifier).signOut();
          },
          color: AppTheme.bonfireRed,
        ),
      ],
    );
  }
  
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.magnoliaWhite),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.magnoliaWhite,
          fontSize: AppTheme.bodySize,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.lightGray,
      ),
      onTap: onTap,
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppTheme.darkGray),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              Image.asset(
                'assets/icons/Logo_white.png',
                height: 40,
                width: 120,
                errorBuilder: (_, __, ___) => Container(
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.darkGray,
                    borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset('assets/icons/Logo_white.png', height: 20),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              const Text(
                'Arcinus v.1.0.0',
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Administrador';
      case UserRole.owner:
        return 'Propietario';
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Responsable';
      case UserRole.guest:
        return 'Invitado';
      }
  }
  
  String _getSubscriptionText(String subscription) {
    switch (subscription.toLowerCase()) {
      case 'free':
        return 'Plan Gratuito';
      case 'basic':
        return 'Plan Básico';
      case 'premium':
        return 'Plan Premium';
      case 'enterprise':
        return 'Plan Empresarial';
      default:
        return 'Plan ${subscription.toUpperCase()}';
    }
  }
} 