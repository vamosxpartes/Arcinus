import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/utils/role_utils.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

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

  /// Ordena atletas por proximidad de fecha de pago
  Future<List<AcademyUserModel>> _sortAthletesByPaymentProximity(
    List<AcademyUserModel> athletes, 
    WidgetRef ref
  ) async {
    final List<_AthleteWithPaymentData> athleteData = [];
    final clientUserRepository = ref.read(clientUserRepositoryProvider);
    
    // Obtenemos datos de pago para cada atleta
    for (final athlete in athletes) {
      try {
        final clientUserResult = await clientUserRepository.getClientUser(
          academyId, 
          athlete.id
        );
        
        final clientUser = clientUserResult.fold(
          (failure) => null,
          (user) => user,
        );
        
        athleteData.add(_AthleteWithPaymentData(
          athlete: athlete,
          clientUser: clientUser,
        ));
      } catch (e) {
        // En caso de error, agregamos el atleta sin datos de pago
        athleteData.add(_AthleteWithPaymentData(
          athlete: athlete,
          clientUser: null,
        ));
      }
    }
    
    // Ordenamos por prioridad de pago
    athleteData.sort((a, b) {
      final now = DateTime.now();
      
      // Función para calcular la prioridad de pago (menor valor = mayor prioridad)
      int getPriority(_AthleteWithPaymentData data) {
        final clientUser = data.clientUser;
        
        // Si no hay datos de cliente o no tiene plan: prioridad muy alta (necesita asignación)
        if (clientUser == null || clientUser.subscriptionPlan == null) {
          return 0;
        }
        
        // Si está vencido (overdue): prioridad máxima
        if (clientUser.paymentStatus == PaymentStatus.overdue) {
          return 1;
        }
        
        // Si está inactivo pero tiene plan: prioridad alta (necesita pago)
        if (clientUser.paymentStatus == PaymentStatus.inactive) {
          return 2;
        }
        
        // Si está activo y tiene fecha de pago específica
        if (clientUser.paymentStatus == PaymentStatus.active && 
            clientUser.nextPaymentDate != null) {
          final daysRemaining = clientUser.nextPaymentDate!.difference(now).inDays;
          
          // Menor a 0 días (vencido pero no marcado como overdue): prioridad muy alta
          if (daysRemaining < 0) {
            return 1;
          }
          // Menor a 5 días: prioridad alta
          if (daysRemaining < 5) {
            return 3;
          }
          // Menor a 15 días: prioridad media
          if (daysRemaining < 15) {
            return 4;
          }
          // Más de 15 días: prioridad baja pero ordenado por días restantes
          return 5000 + daysRemaining;
        }
        
        // Si está activo pero no tiene nextPaymentDate (plan asignado sin pago registrado)
        // Usar remainingDays como aproximación si está disponible
        if (clientUser.paymentStatus == PaymentStatus.active && 
            clientUser.remainingDays != null) {
          final remainingDays = clientUser.remainingDays!;
          
          // Aplicar lógica similar pero con menos prioridad que fechas específicas
          if (remainingDays < 5) {
            return 6; // Prioridad alta pero menor que fechas específicas
          }
          if (remainingDays < 15) {
            return 7; // Prioridad media-alta
          }
          return 8000 + remainingDays; // Prioridad baja
        }
        
        // Activo sin fecha de próximo pago ni remainingDays: prioridad más baja
        return 10000;
      }
      
      final priorityA = getPriority(a);
      final priorityB = getPriority(b);
      
      // Si tienen la misma prioridad, ordenamos por días restantes (si disponible)
      if (priorityA == priorityB) {
        // Calcular días restantes para ordenamiento
        int? getDaysRemaining(_AthleteWithPaymentData data) {
          final clientUser = data.clientUser;
          if (clientUser?.nextPaymentDate != null) {
            return clientUser!.nextPaymentDate!.difference(now).inDays;
          } else if (clientUser?.remainingDays != null) {
            return clientUser!.remainingDays!;
          }
          return null;
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
    final clientUserAsync = ref.watch(clientUserProvider(athlete.id));
    
    return clientUserAsync.when(
      data: (clientUser) => paymentConfigAsync.when(
        data: (paymentConfig) => _buildActiveAvatar(
          context, 
          clientUser, 
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
    ClientUserModel? clientUser,
    PaymentConfigModel paymentConfig,
  ) {
    final bool hasPlan = clientUser?.subscriptionPlan != null;
    final now = DateTime.now();
    
    // Usar clientUser.paymentStatus para determinar el estado
    final bool needsPaymentAttention = clientUser == null || // Si no hay datos del cliente
                                     !hasPlan || // Si no tiene plan asignado
                                     clientUser.paymentStatus == PaymentStatus.overdue || // Si está en mora
                                     (clientUser.paymentStatus == PaymentStatus.inactive && hasPlan); // Si está inactivo pero TIENE plan

    final bool isInGracePeriod = clientUser?.paymentStatus == PaymentStatus.overdue && 
                                 clientUser?.nextPaymentDate != null &&
                                 now.isBefore(clientUser!.nextPaymentDate!.add(Duration(days: paymentConfig.gracePeriodDays))) &&
                                 now.isAfter(clientUser.nextPaymentDate!);

    // Calcular días restantes de manera unificada
    int? displayDaysRemaining;
    bool isEstimated = false;
    
    if (clientUser?.nextPaymentDate != null) {
      // Usar fecha específica de próximo pago si está disponible (días reales)
      displayDaysRemaining = clientUser!.nextPaymentDate!.difference(now).inDays;
      isEstimated = false;
    } else if (clientUser?.remainingDays != null && hasPlan && clientUser?.paymentStatus == PaymentStatus.active) {
      // Para planes asignados sin pago registrado, usar remainingDays como aproximación
      displayDaysRemaining = clientUser!.remainingDays!;
      isEstimated = clientUser.isEstimatedDays;
    }

    // Determinar si mostrar alerta visual (borde e icono superior)
    final bool showVisualAlert = needsPaymentAttention || 
                               isInGracePeriod ||
                               (hasPlan && displayDaysRemaining != null && displayDaysRemaining < 5 && clientUser.paymentStatus == PaymentStatus.active);

    Color borderColor = Colors.transparent;
    if (needsPaymentAttention && clientUser?.paymentStatus == PaymentStatus.overdue) { 
      borderColor = AppTheme.bonfireRed; 
    } else if (needsPaymentAttention && !hasPlan) { 
      borderColor = AppTheme.goldTrophy;
    } else if (isInGracePeriod) {
      borderColor = AppTheme.goldTrophy;
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
                    clientUser: clientUser,
                    hasPlan: hasPlan,
                    displayDaysRemaining: displayDaysRemaining,
                    isEstimated: isEstimated,
                    isInGracePeriod: isInGracePeriod,
                  ),
                ),
                
                // Indicador de color en la esquina superior para alertar sobre pago
                if (showVisualAlert)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: PaymentAlertIndicator(
                      clientUser: clientUser,
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

  void _navigateToPayments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterPaymentScreen(
          athleteId: athlete.id,
        ),
      ),
    );
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
            onTap: () {
              Navigator.pop(context);
              _navigateToPayments(context);
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
  final ClientUserModel? clientUser;
  final bool hasPlan;
  final int? displayDaysRemaining;
  final bool isEstimated;
  final bool isInGracePeriod;

  const PaymentStatusIndicator({
    super.key,
    required this.clientUser,
    required this.hasPlan,
    required this.displayDaysRemaining,
    required this.isEstimated,
    required this.isInGracePeriod,
  });

  @override
  Widget build(BuildContext context) {
    // Log detallado del estado del indicador
    AppLogger.logInfo(
      'Construyendo PaymentStatusIndicator',
      className: 'PaymentStatusIndicator',
      params: {
        'clientUser_id': clientUser?.id,
        'clientUser_status': clientUser?.paymentStatus.toString(),
        'hasPlan': hasPlan,
        'displayDaysRemaining': displayDaysRemaining,
        'isEstimated': isEstimated,
        'isInGracePeriod': isInGracePeriod,
        'nextPaymentDate': clientUser?.nextPaymentDate?.toString(),
        'lastPaymentDate': clientUser?.lastPaymentDate?.toString(),
        'subscriptionPlan_id': clientUser?.subscriptionPlan?.id,
        'subscriptionPlan_name': clientUser?.subscriptionPlan?.name,
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
    if (clientUser == null || !hasPlan) {
      // No hay datos de cliente o no tiene plan
      AppLogger.logInfo(
        'Mostrando indicador de asignar plan',
        className: 'PaymentStatusIndicator',
        params: {
          'clientUser_null': clientUser == null,
          'hasPlan': hasPlan,
        }
      );
      return const Icon(
        Icons.playlist_add_check, // Icono para asignar plan
        size: 12,
        color: AppTheme.goldTrophy,
      );
    }

    final paymentStatus = clientUser!.paymentStatus;
    AppLogger.logInfo(
      'Determinando contenido del indicador según estado de pago',
      className: 'PaymentStatusIndicator',
      params: {
        'paymentStatus': paymentStatus.toString(),
        'displayDaysRemaining': displayDaysRemaining,
        'isInGracePeriod': isInGracePeriod,
      }
    );

    switch (paymentStatus) {
      case PaymentStatus.overdue:
        AppLogger.logInfo(
          'Mostrando indicador de pago vencido',
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
      case PaymentStatus.inactive:
        // Inactivo pero con plan implica que necesita pagar para activar
        AppLogger.logInfo(
          'Mostrando indicador de pago inactivo',
          className: 'PaymentStatusIndicator'
        );
        return const Icon(
          Icons.attach_money, 
          size: 12,
          color: AppTheme.bonfireRed,
        );
      case PaymentStatus.active:
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
              'isEstimated': isEstimated,
              'color': daysColor.toString(),
            }
          );
          
          // Mostrar días restantes con color apropiado
          return Text(
            isEstimated ? '~$displayDaysRemaining' : '$displayDaysRemaining',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: daysColor,
            ),
          );
        } else {
          // Activo pero sin información de días
          AppLogger.logWarning(
            'Estado activo pero sin información de días restantes',
            className: 'PaymentStatusIndicator',
            params: {
              'clientUser_id': clientUser!.id,
              'nextPaymentDate': clientUser!.nextPaymentDate?.toString(),
            }
          );
          return const Icon(
            Icons.check_circle_outline,
            size: 12,
            color: Colors.green,
          );
        }
    }
  }
}

/// Widget para el indicador de alerta en la esquina superior del avatar
class PaymentAlertIndicator extends StatelessWidget {
  final ClientUserModel? clientUser;
  final bool hasPlan;
  final bool isInGracePeriod;
  final int? displayDaysRemaining;

  const PaymentAlertIndicator({
    super.key,
    required this.clientUser,
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
    if (clientUser?.paymentStatus == PaymentStatus.overdue) {
      return AppTheme.bonfireRed;
    } else if (!hasPlan || clientUser?.paymentStatus == PaymentStatus.inactive) {
      return AppTheme.goldTrophy; // Naranja para "atención requerida"
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
  final ClientUserModel? clientUser;
  
  _AthleteWithPaymentData({
    required this.athlete,
    this.clientUser,
  });
} 