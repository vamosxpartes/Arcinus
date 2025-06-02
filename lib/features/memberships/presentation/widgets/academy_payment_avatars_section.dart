import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/utils/role_utils.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/athlete_periods_info_provider.dart';
import 'package:arcinus/features/subscriptions/domain/services/athlete_periods_helper.dart';

/// Widget modular para mostrar la sección horizontal de avatares de atletas
/// con indicadores de estado de pago.
class AcademyPaymentAvatarsSection extends ConsumerWidget {
  final List<AcademyUserModel> users;
  final String academyId;

  const AcademyPaymentAvatarsSection({
    super.key,
    required this.users,
    required this.academyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filtramos atletas 
    final athleteUsers = users.where((user) => 
      user.role == AppRole.atleta.name
    ).toList();
    
    // Si no hay atletas, no mostramos la sección
    if (athleteUsers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.blackSwarm,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkGray,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              'Usuarios próximos a pagar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightGray,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: FutureBuilder<List<AcademyUserModel>>(
              future: _sortAthletesByPaymentProximity(athleteUsers, ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mostrar loading state mientras cargamos los datos
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: athleteUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final athlete = athleteUsers[index];
                      return PaymentAvatarItem.loading(athlete);
                    },
                  );
                }
                
                final sortedAthletes = snapshot.data ?? athleteUsers;
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedAthletes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final athlete = sortedAthletes[index];
                    return PaymentAvatarItem(
                      athlete: athlete,
                      academyId: academyId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Ordena atletas por proximidad de fecha de pago usando únicamente información de períodos
  Future<List<AcademyUserModel>> _sortAthletesByPaymentProximity(
    List<AcademyUserModel> athletes, 
    WidgetRef ref
  ) async {
    final List<_AthleteWithPaymentData> athleteData = [];
    
    // Obtenemos datos de información completa para cada atleta
    for (final athlete in athletes) {
      try {
        final athleteCompleteInfo = await ref.read(athleteCompleteInfoProvider((
          academyId: academyId,
          athleteId: athlete.id,
        )).future);
        
        athleteData.add(_AthleteWithPaymentData(
          athlete: athlete,
          athleteInfo: athleteCompleteInfo,
        ));
      } catch (e) {
        // En caso de error, agregamos el atleta sin datos de pago
        athleteData.add(_AthleteWithPaymentData(
          athlete: athlete,
          athleteInfo: null,
        ));
      }
    }
    
    // Ordenamos por prioridad usando únicamente información de períodos
    athleteData.sort((a, b) {
      final now = DateTime.now();
      
      // Función para calcular la prioridad de pago (menor valor = mayor prioridad)
      int getPriority(_AthleteWithPaymentData data) {
        final athleteInfo = data.athleteInfo;
        
        // Si no hay datos del atleta: prioridad muy alta (necesita revisión)
        if (athleteInfo == null) {
          return 0;
        }
        
        // Si no hay información de períodos: prioridad alta (necesita configuración)
        if (athleteInfo.periodsInfo == null) {
          return 1;
        }
        
        final periodsInfo = athleteInfo.periodsInfo!;
        
        // Sin plan activo: prioridad muy alta (necesita asignación)
        if (!periodsInfo.hasActivePlan) {
          return 2;
        }
        
        // Período vencido: prioridad máxima
        if (periodsInfo.isExpired) {
          return 3;
        }
        
        // Próximo a vencer: prioridad alta
        if (periodsInfo.isNearExpiry) {
          return 4;
        }
        
        // Plan activo: ordenar por días restantes
        final remainingDays = periodsInfo.totalRemainingDays;
        
        // Menos de 5 días: prioridad alta
        if (remainingDays < 5) {
          return 100 + remainingDays;
        }
        // Menos de 15 días: prioridad media
        if (remainingDays < 15) {
          return 200 + remainingDays;
        }
        // Más de 15 días: prioridad baja pero ordenado por días
        return 1000 + remainingDays;
      }
      
      final priorityA = getPriority(a);
      final priorityB = getPriority(b);
      
      // Si tienen la misma prioridad, ordenamos por días restantes
      if (priorityA == priorityB) {
        int? getDaysRemaining(_AthleteWithPaymentData data) {
          final athleteInfo = data.athleteInfo;
          return athleteInfo?.periodsInfo?.totalRemainingDays;
        }
        
        final daysA = getDaysRemaining(a);
        final daysB = getDaysRemaining(b);
        
        if (daysA != null && daysB != null) {
          return daysA.compareTo(daysB);
        } else if (daysA != null) {
          return -1; // a tiene días, b no - a va primero
        } else if (daysB != null) {
          return 1; // b tiene días, a no - b va primero
        }
        // Si ninguno tiene días, mantener orden actual
        return 0;
      }
      
      return priorityA.compareTo(priorityB);
    });
    
    return athleteData.map((data) => data.athlete).toList();
  }
}

/// Widget individual para cada avatar de atleta con indicadores de pago
class PaymentAvatarItem extends ConsumerWidget {
  final AcademyUserModel athlete;
  final String academyId;
  final bool isLoading;
  final bool hasError;

  const PaymentAvatarItem({
    super.key,
    required this.athlete,
    required this.academyId,
    this.isLoading = false,
    this.hasError = false,
  });

  /// Constructor para estado de carga
  const PaymentAvatarItem.loading(
    this.athlete, {
    super.key,
  }) : academyId = '',
       isLoading = true,
       hasError = false;

  /// Constructor para estado de error
  const PaymentAvatarItem.error(
    this.athlete, {
    super.key,
  }) : academyId = '',
       isLoading = false,
       hasError = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildLoadingAvatar();
    }

    if (hasError) {
      return _buildErrorAvatar();
    }

    final paymentConfigAsync = ref.watch(paymentConfigProvider(academyId));
    final athleteCompleteInfoAsync = ref.watch(athleteCompleteInfoProvider((
      academyId: academyId,
      athleteId: athlete.id,
    )));
    
    return athleteCompleteInfoAsync.when(
      data: (athleteInfo) => paymentConfigAsync.when(
        data: (paymentConfig) => _buildActiveAvatar(
          context, 
          athleteInfo, 
          paymentConfig,
        ),
        loading: () => _buildLoadingAvatar(),
        error: (_, __) => _buildErrorAvatar(),
      ),
      loading: () => _buildLoadingAvatar(),
      error: (_, __) => _buildErrorAvatar(),
    );
  }

  Widget _buildActiveAvatar(
    BuildContext context,
    AthleteCompleteInfo athleteInfo,
    PaymentConfigModel paymentConfig,
  ) {
    final now = DateTime.now();
    
    // ÚNICAMENTE usar información de períodos
    if (athleteInfo.periodsInfo == null) {
      // Sin información de períodos - mostrar estado neutral
      return _buildNeutralAvatar(context);
    }
    
    final periodsInfo = athleteInfo.periodsInfo!;
    
    // Determinar estado basándose únicamente en información de períodos
    final bool hasPlan = periodsInfo.hasActivePlan;
    bool needsPaymentAttention = false;
    bool isInGracePeriod = false;
    int? displayDaysRemaining;
    Color borderColor = Colors.transparent;
    bool showVisualAlert = false;
    
    if (periodsInfo.isExpired) {
      needsPaymentAttention = true;
      showVisualAlert = true;
      borderColor = AppTheme.bonfireRed;
      displayDaysRemaining = 0;
    } else if (periodsInfo.isNearExpiry) {
      needsPaymentAttention = true;
      showVisualAlert = true;
      borderColor = AppTheme.goldTrophy;
      displayDaysRemaining = periodsInfo.totalRemainingDays;
    } else if (periodsInfo.hasActivePlan) {
      needsPaymentAttention = false;
      displayDaysRemaining = periodsInfo.totalRemainingDays;
      
      // Determinar alerta visual basándose en días restantes
      if (periodsInfo.totalRemainingDays < 5) {
        showVisualAlert = true;
        borderColor = AppTheme.goldTrophy;
      } else if (periodsInfo.totalRemainingDays < 15) {
        showVisualAlert = false; // No mostrar borde para alertas menores
      }
    } else {
      needsPaymentAttention = true;
      showVisualAlert = true;
      borderColor = AppTheme.goldTrophy;
      displayDaysRemaining = null;
    }
    
    // Verificar período de gracia si hay próxima fecha de pago
    if (periodsInfo.nextPaymentDate != null) {
      final gracePeriodEnd = periodsInfo.nextPaymentDate!.add(Duration(days: paymentConfig.gracePeriodDays));
      isInGracePeriod = now.isAfter(periodsInfo.nextPaymentDate!) && now.isBefore(gracePeriodEnd);
      
      if (isInGracePeriod) {
        showVisualAlert = true;
        borderColor = AppTheme.goldTrophy;
      }
    }

    return GestureDetector(
      onTap: () => _navigateToPayments(context),
      onLongPress: () => _showContextMenu(context),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                // Avatar con borde de estado
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor, 
                      width: borderColor == Colors.transparent ? 0 : 3
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: RoleUtils.getRoleColor(AppRole.atleta),
                    backgroundImage: athlete.profileImageUrl != null
                        ? NetworkImage(athlete.profileImageUrl!)
                        : null,
                    child: athlete.profileImageUrl == null
                        ? Text(
                            athlete.firstName.isNotEmpty ? athlete.firstName[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                
                // Indicador numérico con los días restantes o estado de pago
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: PaymentStatusIndicator(
                    periodsInfo: periodsInfo,
                    hasPlan: hasPlan,
                    displayDaysRemaining: displayDaysRemaining,
                    isInGracePeriod: isInGracePeriod,
                  ),
                ),
                
                // Indicador de color en la esquina superior para alertar sobre pago
                if (showVisualAlert)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: PaymentAlertIndicator(
                      periodsInfo: periodsInfo,
                      hasPlan: hasPlan,
                      isInGracePeriod: isInGracePeriod,
                      displayDaysRemaining: displayDaysRemaining,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${athlete.firstName.split(' ')[0]}.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para avatares sin información de períodos
  Widget _buildNeutralAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPayments(context),
      onLongPress: () => _showContextMenu(context),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.lightGray,
                  backgroundImage: athlete.profileImageUrl != null
                      ? NetworkImage(athlete.profileImageUrl!)
                      : null,
                  child: athlete.profileImageUrl == null
                      ? Text(
                          athlete.firstName.isNotEmpty ? athlete.firstName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                
                // Indicador de carga
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.blackSwarm,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightGray),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${athlete.firstName.split(' ')[0]}.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: RoleUtils.getRoleColor(AppRole.atleta).withAlpha(90),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(60),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAvatar() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: RoleUtils.getRoleColor(AppRole.atleta),
            child: const Icon(Icons.error, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${athlete.firstName.split(' ')[0]}.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPayments(BuildContext context) async {
    AppLogger.logInfo(
      'Navegando a pantalla de pagos desde AcademyPaymentAvatarsSection',
      className: 'PaymentAvatarItem',
      params: {
        'athleteId': athlete.id,
        'athleteName': athlete.firstName,
        'academyId': academyId,
      }
    );
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterPaymentScreen(
          athleteId: athlete.id,
        ),
      ),
    );
    
    // *** NUEVO: Si se registró un pago, notificar para refresh de la sección ***
    if (result == true || result == 'payment_registered') {
      AppLogger.logInfo(
        'Pago registrado exitosamente desde avatar section, refrescando datos',
        className: 'PaymentAvatarItem',
        params: {
          'athleteId': athlete.id,
          'academyId': academyId,
          'result': result.toString(),
        }
      );
      
      // El widget padre (AcademyMembersScreen) ya manejará el refresh global
      // pero podemos forzar una reconstrucción local si es necesario
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Ver detalles del atleta'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AcademyUserDetailsScreen(
                    academyId: academyId,
                    userId: athlete.id,
                    initialUserData: athlete,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Gestionar pagos'),
            onTap: () async {
              Navigator.pop(context);
              await _navigateToPayments(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Ver asistencia'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de asistencia en desarrollo'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget para el indicador de estado de pago en la esquina inferior del avatar
class PaymentStatusIndicator extends StatelessWidget {
  final AthletePeriodsInfo periodsInfo;
  final bool hasPlan;
  final int? displayDaysRemaining;
  final bool isInGracePeriod;

  const PaymentStatusIndicator({
    super.key,
    required this.periodsInfo,
    required this.hasPlan,
    required this.displayDaysRemaining,
    required this.isInGracePeriod,
  });

  @override
  Widget build(BuildContext context) {
    // Log detallado del estado del indicador usando información de períodos
    AppLogger.logInfo(
      'Construyendo PaymentStatusIndicator con información de períodos',
      className: 'PaymentStatusIndicator',
      params: {
        'hasPlan': hasPlan,
        'displayDaysRemaining': displayDaysRemaining,
        'isInGracePeriod': isInGracePeriod,
        'isExpired': periodsInfo.isExpired,
        'isNearExpiry': periodsInfo.isNearExpiry,
        'totalRemainingDays': periodsInfo.totalRemainingDays,
        'activePeriodsCount': periodsInfo.activePeriodsCount,
      }
    );

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.blackSwarm,
          width: 1.5,
        ),
      ),
      child: Center(
        child: _buildIndicatorContent(),
      ),
    );
  }

  Widget _buildIndicatorContent() {
    if (!hasPlan) {
      // No tiene plan
      AppLogger.logInfo(
        'Mostrando indicador de asignar plan',
        className: 'PaymentStatusIndicator',
        params: {
          'hasPlan': hasPlan,
        }
      );
      return const Icon(
        Icons.playlist_add_check, // Icono para asignar plan
        size: 12,
        color: AppTheme.goldTrophy,
      );
    }

    // Usar únicamente información de períodos para determinar el contenido
    AppLogger.logInfo(
      'Determinando contenido del indicador según información de períodos',
      className: 'PaymentStatusIndicator',
      params: {
        'isExpired': periodsInfo.isExpired,
        'isNearExpiry': periodsInfo.isNearExpiry,
        'displayDaysRemaining': displayDaysRemaining,
        'isInGracePeriod': isInGracePeriod,
      }
    );

    if (periodsInfo.isExpired) {
      AppLogger.logInfo(
        'Mostrando indicador de período vencido',
        className: 'PaymentStatusIndicator'
      );
      return const Text(
        '!',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.bonfireRed,
        ),
      );
    }

    if (displayDaysRemaining != null) {
      // Si displayDaysRemaining es negativo, mostrar alerta
      if (displayDaysRemaining! < 0 && !isInGracePeriod) {
        AppLogger.logWarning(
          'Días restantes negativos sin período de gracia',
          className: 'PaymentStatusIndicator',
          params: {
            'displayDaysRemaining': displayDaysRemaining,
            'isInGracePeriod': isInGracePeriod,
          }
        );
        return const Text(
          '!',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.bonfireRed,
          ),
        );
      }
      
      // Determinar color basado en días restantes
      Color daysColor;
      if (displayDaysRemaining! < 5) {
        daysColor = AppTheme.bonfireRed;
      } else if (displayDaysRemaining! < 15) {
        daysColor = AppTheme.goldTrophy;
      } else {
        daysColor = Colors.black;
      }
      
      AppLogger.logInfo(
        'Mostrando días restantes en indicador',
        className: 'PaymentStatusIndicator',
        params: {
          'displayDaysRemaining': displayDaysRemaining,
          'color': daysColor.toString(),
        }
      );
      
      // Mostrar días restantes con color apropiado
      return Text(
        '$displayDaysRemaining',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: daysColor,
        ),
      );
    } else {
      // Activo pero sin información de días restantes
      AppLogger.logInfo(
        'Estado activo pero sin información específica de días restantes',
        className: 'PaymentStatusIndicator',
        params: {
          'hasPlan': hasPlan,
          'totalRemainingDays': periodsInfo.totalRemainingDays,
        },
      );
      return const Icon(
        Icons.check_circle_outline,
        size: 12,
        color: Colors.green,
      );
    }
  }
}

/// Widget para el indicador de alerta en la esquina superior del avatar
class PaymentAlertIndicator extends StatelessWidget {
  final AthletePeriodsInfo periodsInfo;
  final bool hasPlan;
  final bool isInGracePeriod;
  final int? displayDaysRemaining;

  const PaymentAlertIndicator({
    super.key,
    required this.periodsInfo,
    required this.hasPlan,
    required this.isInGracePeriod,
    required this.displayDaysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getAlertColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.blackSwarm,
          width: 1,
        ),
      ),
    );
  }

  Color _getAlertColor() {
    // Usar únicamente información de períodos
    if (periodsInfo.isExpired) {
      return AppTheme.bonfireRed;
    } else if (!hasPlan) {
      return AppTheme.goldTrophy; // Dorado para "atención requerida"
    } else if (isInGracePeriod) {
      return AppTheme.goldTrophy;
    } else if (displayDaysRemaining != null && displayDaysRemaining! < 5) {
      return AppTheme.bonfireRed;
    } else {
      return AppTheme.goldTrophy;
    }
  }
}

/// Clase auxiliar para almacenar datos de atleta con información de pago
class _AthleteWithPaymentData {
  final AcademyUserModel athlete;
  final AthleteCompleteInfo? athleteInfo;
  
  _AthleteWithPaymentData({
    required this.athlete,
    this.athleteInfo,
  });
} 