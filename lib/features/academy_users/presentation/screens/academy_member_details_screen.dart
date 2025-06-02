import 'package:arcinus/features/academy_users/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:arcinus/features/academy_users_payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/academy_users/presentation/providers/academy_users_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/athlete_periods_info_provider.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/subscription_plans_provider.dart';

class AcademyMemberDetailsScreen extends ConsumerStatefulWidget {
  final String academyId;
  final String userId;
  final AcademyUserModel? initialUserData; // Datos iniciales si ya tenemos el objeto

  const AcademyMemberDetailsScreen({
    super.key,
    required this.academyId,
    required this.userId,
    this.initialUserData,
  });

  @override
  ConsumerState<AcademyMemberDetailsScreen> createState() => _AcademyUserDetailsScreenState();
}

class _AcademyUserDetailsScreenState extends ConsumerState<AcademyMemberDetailsScreen> {
  bool _titlePushed = false;

  @override
  void initState() {
    super.initState();
    
    // Si tenemos datos iniciales, actualizar el título inmediatamente
    if (widget.initialUserData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_titlePushed) {
          ref.read(titleManagerProvider.notifier).pushTitle('Detalles de ${widget.initialUserData!.fullName}');
          _titlePushed = true;
        }
      });
    }
  }

  void _updateTitleIfNeeded(AcademyUserModel user) {
    if (!_titlePushed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(titleManagerProvider.notifier).pushTitle('Detalles de ${user.fullName}');
          _titlePushed = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si tenemos datos iniciales los usamos, sino cargamos del provider
    final userAsyncValue = widget.initialUserData != null
        ? AsyncValue.data(widget.initialUserData!)
        : ref.watch(academyUserDetailsProvider(widget.academyId, widget.userId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _titlePushed) {
          // Restaurar el título anterior cuando se hace pop
          ref.read(titleManagerProvider.notifier).popTitle();
        }
      },
      child: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          
          // Actualizar título solo si no se ha hecho antes
          _updateTitleIfNeeded(user);
          
          final userRole = user.role != null
              ? AppRole.values.firstWhere(
                  (r) => r.name == user.role,
                  orElse: () => AppRole.atleta,
                )
              : AppRole.atleta;
              
          return _buildUserDetails(context, ref, user, userRole);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar los detalles: $error'),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, WidgetRef ref, AcademyUserModel user, AppRole userRole) {
    final isAthlete = userRole == AppRole.atleta;
    
    // Si es atleta, cargamos la información completa usando el nuevo sistema de períodos
    final athleteCompleteInfoAsync = isAthlete 
        ? ref.watch(athleteCompleteInfoProvider((
            academyId: widget.academyId,
            athleteId: user.id,
          )))
        : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil y datos básicos
          Card(
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
                        backgroundColor: _getRoleColor(user.role),
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
                    label: Text(_getRoleName(user.role)),
                    backgroundColor: _getRoleColor(user.role).withAlpha(20),
                    labelStyle: TextStyle(
                      color: _getRoleColor(user.role),
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
          ),
          
          const SizedBox(height: 16),
          
          // Tarjeta de suscripción para atletas
          if (isAthlete && athleteCompleteInfoAsync != null)
            athleteCompleteInfoAsync.when(
              data: (athleteInfo) => _buildSubscriptionCard(context, ref, user, athleteInfo),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error al cargar información de suscripción: $error'),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Información personal
          _buildSectionCard(
            context,
            'Información Personal',
            Icons.person,
            [
              _buildInfoRow(context, 'Fecha de nacimiento', user.birthDate != null 
                  ? DateFormat('dd/MM/yyyy').format(user.birthDate!)
                  : 'No disponible'),
              _buildInfoRow(context, 'Teléfono', user.phoneNumber ?? 'No disponible'),
              if (user.heightCm != null)
                _buildInfoRow(context, 'Altura', '${user.heightCm} cm'),
              if (user.weightKg != null)
                _buildInfoRow(context, 'Peso', '${user.weightKg} kg'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información médica
          _buildSectionCard(
            context,
            'Información Médica',
            Icons.medical_services,
            [
              _buildInfoRow(context, 'Alergias', user.allergies ?? 'Ninguna registrada'),
              _buildInfoRow(context, 'Condiciones médicas', user.medicalConditions ?? 'Ninguna registrada'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contacto de emergencia
          if (user.emergencyContact != null && user.emergencyContact!.isNotEmpty)
            _buildSectionCard(
              context,
              'Contacto de Emergencia',
              Icons.emergency,
              [
                _buildInfoRow(context, 'Nombre', user.emergencyContact!['name']?.toString() ?? 'No disponible'),
                _buildInfoRow(context, 'Teléfono', user.emergencyContact!['phone']?.toString() ?? 'No disponible'),
              ],
            ),
            
          const SizedBox(height: 16),
          
          // Información adicional
          _buildSectionCard(
            context,
            'Información Adicional',
            Icons.info,
            [
              _buildInfoRow(context, 'Miembro desde', DateFormat('dd/MM/yyyy').format(user.createdAt)),
              _buildInfoRow(context, 'Última actualización', DateFormat('dd/MM/yyyy').format(user.updatedAt)),
              _buildInfoRow(context, 'ID', user.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref, AcademyUserModel user, AthleteCompleteInfo athleteInfo) {
    if (!athleteInfo.hasActivePlan) {
      return Card(
        color: AppTheme.mediumGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          side: BorderSide(
            color: AppTheme.lightGray.withAlpha(50),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.goldTrophy.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.goldTrophy,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        'Este atleta no tiene un plan de suscripción asignado',
                        style: TextStyle(
                          fontSize: AppTheme.bodySize,
                          color: AppTheme.goldTrophy,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegisterPaymentScreen(
                          athleteId: widget.userId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_card, color: AppTheme.magnoliaWhite),
                  label: const Text(
                    'Asignar Plan y Registrar Pago',
                    style: TextStyle(
                      color: AppTheme.magnoliaWhite,
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bonfireRed,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Colores según estado de pago
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;
    
    switch (athleteInfo.clientUser.paymentStatus) {
      case PaymentStatus.active:
        statusColor = AppTheme.courtGreen;
        statusIcon = Icons.check_circle;
        statusText = 'Activo';
        break;
      case PaymentStatus.overdue:
        statusColor = AppTheme.goldTrophy;
        statusIcon = Icons.warning;
        statusText = 'Próximo a vencer';
        break;
      case PaymentStatus.inactive:
      // ignore: unreachable_switch_default
      default:
        statusColor = AppTheme.bonfireRed;
        statusIcon = Icons.cancel;
        statusText = 'Inactivo';
        break;
    }

    // Obtener información del plan actual si existe
    final currentPlanAsync = athleteInfo.currentSubscriptionPlanId != null
        ? ref.watch(subscriptionPlanProvider((
            academyId: widget.academyId,
            planId: athleteInfo.currentSubscriptionPlanId!,
          )))
        : null;

    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: statusColor.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withAlpha(30), statusColor.withAlpha(10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Pagos',
                        style: TextStyle(
                          fontSize: AppTheme.subtitleSize,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.magnoliaWhite,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            'Estado: $statusText',
                            style: TextStyle(
                              fontSize: AppTheme.secondarySize,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bonfireRed,
                    borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterPaymentScreen(
                            athleteId: widget.userId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.payment,
                      color: AppTheme.magnoliaWhite,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Estado de pago detallado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Estado de Suscripción: ${athleteInfo.clientUser.paymentStatus.displayName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppTheme.bodySize,
                    color: statusColor,
                  ),
                ),
                if (athleteInfo.remainingDays >= 0 && athleteInfo.clientUser.paymentStatus == PaymentStatus.active) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppTheme.spacingXs),
                    ),
                    child: Text(
                      '${athleteInfo.remainingDays} días restantes',
                      style: TextStyle(
                        fontSize: AppTheme.captionSize,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Detalles del plan
          if (currentPlanAsync != null)
            currentPlanAsync.when(
              data: (currentPlan) {
                if (currentPlan == null) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del plan
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray.withAlpha(10),
                          borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                          border: Border.all(
                            color: AppTheme.lightGray.withAlpha(30),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: AppTheme.goldTrophy,
                                  size: 16,
                                ),
                                const SizedBox(width: AppTheme.spacingXs),
                                Text(
                                  'Plan Actual',
                                  style: TextStyle(
                                    fontSize: AppTheme.secondarySize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingXs),
                            Text(
                              currentPlan.name,
                              style: TextStyle(
                                fontSize: AppTheme.bodySize,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.magnoliaWhite,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingXs),
                            Row(
                              children: [
                                Text(
                                  'Monto: ',
                                  style: TextStyle(
                                    fontSize: AppTheme.secondarySize,
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(currentPlan.amount)} ${currentPlan.currency}',
                                  style: TextStyle(
                                    fontSize: AppTheme.secondarySize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.magnoliaWhite,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingXs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.courtGreen.withAlpha(30),
                                    borderRadius: BorderRadius.circular(AppTheme.spacingXs),
                                  ),
                                  child: Text(
                                    currentPlan.billingCycle.displayName,
                                    style: TextStyle(
                                      fontSize: AppTheme.captionSize,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.courtGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Beneficios del plan (si existen)
                      if (currentPlan.benefits.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          'Beneficios Incluidos:',
                          style: TextStyle(
                            fontSize: AppTheme.secondarySize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightGray,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        ...currentPlan.benefits.take(3).map<Widget>((benefit) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppTheme.courtGreen,
                                ),
                                const SizedBox(width: AppTheme.spacingXs),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: TextStyle(
                                      fontSize: AppTheme.captionSize,
                                      color: AppTheme.lightGray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (currentPlan.benefits.length > 3)
                          Text(
                            '+ ${currentPlan.benefits.length - 3} beneficios más',
                            style: TextStyle(
                              fontSize: AppTheme.captionSize,
                              color: AppTheme.goldTrophy,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppTheme.spacingMd),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          
          // Información de fechas y progreso
          if (athleteInfo.nextPaymentDate != null && athleteInfo.lastPaymentDate != null)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppTheme.lightGray),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppTheme.lightGray,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        'Información de Pagos:',
                        style: TextStyle(
                          fontSize: AppTheme.secondarySize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Último pago',
                            style: TextStyle(
                              fontSize: AppTheme.captionSize,
                              color: AppTheme.lightGray,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(athleteInfo.lastPaymentDate!),
                            style: TextStyle(
                              fontSize: AppTheme.secondarySize,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.magnoliaWhite,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Próximo pago',
                            style: TextStyle(
                              fontSize: AppTheme.captionSize,
                              color: AppTheme.lightGray,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(athleteInfo.nextPaymentDate!),
                            style: TextStyle(
                              fontSize: AppTheme.secondarySize,
                              fontWeight: FontWeight.w700,
                              color: athleteInfo.remainingDays < 5
                                ? AppTheme.bonfireRed
                                : AppTheme.magnoliaWhite,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Barra de progreso
                  if (athleteInfo.remainingDays >= 0) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    
                    // Cálculo para la barra de progreso
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final lastPayment = athleteInfo.lastPaymentDate!;
                        final nextPayment = athleteInfo.nextPaymentDate!;
                        
                        // Solo mostrar si las fechas son lógicas
                        if (nextPayment.isAfter(now) && nextPayment.isAfter(lastPayment)) {
                          // Cálculo de días totales y restantes
                          final totalDays = nextPayment.difference(lastPayment).inDays;
                          final daysElapsed = now.difference(lastPayment).inDays;
                          
                          // Evitar división por cero
                          final double progressPercent = totalDays > 0 
                              ? daysElapsed / totalDays 
                              : 0.0;
                          
                          // Límites para asegurar que está entre 0 y 1
                          final double clampedProgress = progressPercent.clamp(0.0, 1.0);
                          
                          // Color según días restantes
                          final Color progressColor;
                          if (athleteInfo.remainingDays < 5) {
                            progressColor = AppTheme.bonfireRed;
                          } else if (athleteInfo.remainingDays < 15) {
                            progressColor = AppTheme.goldTrophy;
                          } else {
                            progressColor = AppTheme.courtGreen;
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Información sobre días restantes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progreso del período:',
                                    style: TextStyle(
                                      fontSize: AppTheme.captionSize,
                                      color: AppTheme.lightGray,
                                    ),
                                  ),
                                  Text(
                                    '${athleteInfo.remainingDays} días restantes',
                                    style: TextStyle(
                                      fontSize: AppTheme.captionSize,
                                      fontWeight: FontWeight.w600,
                                      color: athleteInfo.remainingDays < 5 ? AppTheme.bonfireRed : AppTheme.lightGray,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Barra de progreso
                              const SizedBox(height: AppTheme.spacingXs),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.spacingXs),
                                child: LinearProgressIndicator(
                                  value: clampedProgress,
                                  backgroundColor: AppTheme.lightGray.withAlpha(30),
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          );
                        }
                        
                        return const SizedBox.shrink();
                      }
                    ),
                  ],
                  
                  // Botón de acción principal
                  const SizedBox(height: AppTheme.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegisterPaymentScreen(
                              athleteId: widget.userId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment, color: AppTheme.magnoliaWhite),
                      label: const Text(
                        'Gestionar Pagos y Períodos',
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite,
                          fontSize: AppTheme.bodySize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.bonfireRed,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget para construir una sección de información
  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget para construir una fila de información
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Obtener un color para el rol
  Color _getRoleColor(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return Colors.purple;
      case AppRole.colaborador:
        return Colors.blue;
      case AppRole.atleta:
        return Colors.green;
      case AppRole.padre:
        return Colors.orange;
      case AppRole.superAdmin:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Obtener un nombre amigable para el rol
  String _getRoleName(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return 'Propietario';
      case AppRole.colaborador:
        return 'Colaborador';
      case AppRole.atleta:
        return 'Atleta';
      case AppRole.padre:
        return 'Padre/Responsable';
      case AppRole.superAdmin:
        return 'Administrador';
      default:
        return 'Desconocido';
    }
  }
} 