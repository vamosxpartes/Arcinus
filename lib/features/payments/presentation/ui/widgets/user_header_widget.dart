import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/subscriptions/domain/services/athlete_periods_helper.dart';

/// Header de usuario para la pantalla de pagos
/// Diseño compacto y moderno que muestra información esencial del atleta
/// USA ÚNICAMENTE información de períodos (nuevo sistema)
class UserHeaderWidget extends StatelessWidget {
  final ClientUserModel? clientUser;
  final AcademyUserModel? academyUser;
  final AthletePeriodsInfo? periodsInfo; // REQUERIDO: Información de períodos

  const UserHeaderWidget({
    super.key,
    this.clientUser,
    this.academyUser,
    required this.periodsInfo, // Ahora es requerido
  });

  @override
  Widget build(BuildContext context) {
    if (clientUser == null) {
      return _buildSelectUserPrompt();
    }

    // Solo usar información de períodos
    final hasActivePlan = periodsInfo?.hasActivePlan ?? false;
    final remainingDays = periodsInfo?.totalRemainingDays ?? 0;

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

    // Determinar colores basándose únicamente en información de períodos
    List<Color> gradientColors;
    
    if (periodsInfo != null) {
      if (periodsInfo!.isExpired) {
        // Período vencido - rojo crítico
        gradientColors = [AppTheme.bonfireRed, AppTheme.embers];
      } else if (periodsInfo!.isNearExpiry) {
        // Cerca del vencimiento - amarillo de advertencia
        gradientColors = [AppTheme.goldTrophy, AppTheme.goldTrophy.withAlpha(200)];
      } else if (periodsInfo!.hasActivePlan) {
        // Plan activo y saludable - verde
        gradientColors = [AppTheme.courtGreen, AppTheme.courtGreen.withAlpha(200)];
      } else {
        // Sin plan activo - rojo
        gradientColors = [AppTheme.bonfireRed, AppTheme.embers];
      }
    } else {
      // Sin información de períodos - estado neutral
      gradientColors = [AppTheme.lightGray, AppTheme.mediumGray];
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
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
    
    // Determinar texto de estado basándose únicamente en información de períodos
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (periodsInfo != null) {
      if (periodsInfo!.isExpired) {
        statusText = 'Plan vencido';
        statusColor = AppTheme.bonfireRed;
        statusIcon = Icons.error_outline;
      } else if (periodsInfo!.isNearExpiry) {
        statusText = 'Próximo a vencer';
        statusColor = AppTheme.goldTrophy;
        statusIcon = Icons.warning_outlined;
      } else if (periodsInfo!.hasActivePlan) {
        statusText = '${periodsInfo!.activePeriodsCount} período${periodsInfo!.activePeriodsCount > 1 ? 's' : ''} activo${periodsInfo!.activePeriodsCount > 1 ? 's' : ''}';
        statusColor = AppTheme.courtGreen;
        statusIcon = Icons.verified_user;
      } else {
        statusText = 'Sin plan activo';
        statusColor = AppTheme.lightGray;
        statusIcon = Icons.person_outline;
      }
    } else {
      // Sin información de períodos
      statusText = 'Cargando información...';
      statusColor = AppTheme.lightGray;
      statusIcon = Icons.hourglass_empty;
    }
    
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
              statusIcon,
              size: 16,
              color: statusColor,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              statusText,
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    // Si no hay información de períodos, mostrar indicador de carga
    if (periodsInfo == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withAlpha(20),
          borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          border: Border.all(
            color: AppTheme.lightGray.withAlpha(50),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              color: AppTheme.lightGray,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            const Text(
              'CARGANDO',
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
      );
    }

    // Si no tiene plan activo
    if (!periodsInfo!.hasActivePlan) {
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

    // Determinar estado basándose únicamente en información de períodos
    Color statusColor = AppTheme.courtGreen;
    String statusText = 'ACTIVO';
    IconData statusIcon = Icons.check_circle;
    int displayDays = periodsInfo!.totalRemainingDays;

    if (periodsInfo!.isExpired) {
      statusColor = AppTheme.bonfireRed;
      statusText = 'VENCIDO';
      statusIcon = Icons.error;
      displayDays = 0;
    } else if (periodsInfo!.isNearExpiry) {
      statusColor = AppTheme.bonfireRed;
      statusText = 'CRÍTICO';
      statusIcon = Icons.warning;
      displayDays = periodsInfo!.totalRemainingDays;
    } else if (periodsInfo!.totalRemainingDays <= 15) {
      statusColor = AppTheme.goldTrophy;
      statusText = 'PRÓXIMO';
      statusIcon = Icons.schedule;
      displayDays = periodsInfo!.totalRemainingDays;
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
          if (displayDays > 0) ...[
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              '$displayDays días',
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