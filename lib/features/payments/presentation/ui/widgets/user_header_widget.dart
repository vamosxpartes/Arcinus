import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';

/// Header de usuario para la pantalla de pagos
/// Diseño compacto y moderno que muestra información esencial del atleta
class UserHeaderWidget extends StatelessWidget {
  final ClientUserModel? clientUser;
  final AcademyUserModel? academyUser;
  final bool hasActivePlan;
  final int totalRemainingDays;

  const UserHeaderWidget({
    super.key,
    this.clientUser,
    this.academyUser,
    this.hasActivePlan = false,
    this.totalRemainingDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (clientUser == null) {
      return _buildSelectUserPrompt();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkGray,
            AppTheme.mediumGray,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: hasActivePlan 
              ? AppTheme.courtGreen.withAlpha(50)
              : AppTheme.lightGray.withAlpha(30),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildUserInfo(),
            ),
            _buildStatusIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectUserPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.mediumGray,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.bonfireRed.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search,
            size: 48,
            color: AppTheme.bonfireRed,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            'Selecciona un atleta',
            style: TextStyle(
              fontSize: AppTheme.h3Size,
              fontWeight: FontWeight.w600,
              color: AppTheme.magnoliaWhite,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Elige el atleta para gestionar sus períodos de pago',
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final firstName = academyUser?.firstName ?? '';
    final lastName = academyUser?.lastName ?? '';
    final initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasActivePlan 
              ? [AppTheme.courtGreen, AppTheme.courtGreen.withAlpha(200)]
              : [AppTheme.bonfireRed, AppTheme.embers],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.magnoliaWhite.withAlpha(30),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '👤',
          style: const TextStyle(
            fontSize: AppTheme.h3Size,
            fontWeight: FontWeight.w700,
            color: AppTheme.magnoliaWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final userName = academyUser?.fullName ?? 'Usuario sin datos';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: const TextStyle(
            fontSize: AppTheme.subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.magnoliaWhite,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        if (academyUser?.phoneNumber != null) ...[
          Text(
            academyUser!.phoneNumber!,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              color: AppTheme.lightGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingXs),
        ],
        Row(
          children: [
            Icon(
              hasActivePlan ? Icons.verified_user : Icons.person_outline,
              size: 16,
              color: hasActivePlan ? AppTheme.courtGreen : AppTheme.lightGray,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              hasActivePlan ? 'Plan activo' : 'Sin plan activo',
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w600,
                color: hasActivePlan ? AppTheme.courtGreen : AppTheme.lightGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (!hasActivePlan) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.goldTrophy.withAlpha(20),
          borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          border: Border.all(
            color: AppTheme.goldTrophy.withAlpha(50),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.goldTrophy,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            const Text(
              'NUEVO',
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldTrophy,
              ),
            ),
          ],
        ),
      );
    }

    Color statusColor = AppTheme.courtGreen;
    String statusText = 'ACTIVO';
    IconData statusIcon = Icons.check_circle;

    if (totalRemainingDays <= 7) {
      statusColor = AppTheme.bonfireRed;
      statusText = 'CRÍTICO';
      statusIcon = Icons.warning;
    } else if (totalRemainingDays <= 15) {
      statusColor = AppTheme.goldTrophy;
      statusText = 'PRÓXIMO';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: statusColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            statusText,
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          if (totalRemainingDays > 0) ...[
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              '$totalRemainingDays días',
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 