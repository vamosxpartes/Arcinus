import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/presentation/screens/athlete_payments_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/memberships/presentation/utils/role_utils.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyUserCard extends ConsumerWidget {
  final AcademyUserModel user;
  final String academyId;

  const AcademyUserCard({
    Key? key,
    required this.user,
    required this.academyId,
  }) : super(key: key);

  String formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determinamos el rol del usuario
    final userRole = user.role != null
        ? AppRole.values.firstWhere(
            (r) => r.name == user.role,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
    
    final isAthlete = userRole == AppRole.atleta;
    
    // Obtenemos datos del cliente para atletas (información de pagos)
    final clientUserAsyncValue = isAthlete 
        ? ref.watch(clientUserProvider(user.id)) 
        : null;
    
    // Placeholder para grupos (por ahora)
    final String groupPlaceholder = isAthlete 
        ? 'Grupo Principal' 
        : (userRole == AppRole.padre ? 'Padre/Tutor' : 'Staff');
    
    // Contenido de la tarjeta
    Widget cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          // Avatar
          Hero(
            tag: 'user_avatar_${user.id}',
            child: CircleAvatar(
              radius: 24,
              backgroundColor: RoleUtils.getRoleColor(userRole),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del usuario
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 2),
                
                // Grupo y rol
                Row(
                  children: [
                    // Placeholder del grupo
                    Flexible(
                      child: Text(
                        groupPlaceholder,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Separador
                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightGray,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Posición/rol
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: RoleUtils.getRoleColor(userRole).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        RoleUtils.getRoleName(userRole),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: RoleUtils.getRoleColor(userRole),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Barra de progreso (solo para atletas con información de pago)
                if (isAthlete && clientUserAsyncValue != null)
                  clientUserAsyncValue.when(
                    data: (clientUser) {
                      // Registramos información para debug
                      AppLogger.logInfo(
                        'Procesando datos de pago para usuario ${user.id}',
                        className: 'AcademyUserCard',
                        params: {
                          'nombre': user.fullName,
                          'tiene_plan': clientUser?.subscriptionPlan != null,
                          'estado_pago': clientUser?.paymentStatus.toString(),
                          'fecha_próximo_pago': clientUser?.nextPaymentDate?.toString(),
                          'fecha_último_pago': clientUser?.lastPaymentDate?.toString(),
                          'días_restantes': clientUser?.remainingDays?.toString(),
                        }
                      );
                      
                      // Si el usuario no tiene plan, mostrar barra gris inactiva
                      if (clientUser == null || clientUser.subscriptionPlan == null) {
                        AppLogger.logInfo(
                          'Mostrando barra inactiva para usuario sin plan: ${user.id}',
                          className: 'AcademyUserCard'
                        );
                        return _buildInactiveProgressBar();
                      }
                      
                      // Verificar si tenemos fecha de próximo pago
                      if (clientUser.nextPaymentDate == null) {
                        AppLogger.logWarning(
                          'Usuario con plan sin fecha de próximo pago: ${user.id}',
                          className: 'AcademyUserCard'
                        );
                        return _buildInactiveProgressBar();
                      }
                      
                      final now = DateTime.now();
                      final nextPaymentDate = clientUser.nextPaymentDate!;
                      
                      // Calcular la duración del plan en días según el ciclo de facturación
                      final int planDurationInDays = _getPlanDurationInDays(clientUser.subscriptionPlan!);
                      
                      // Determinar la fecha de inicio (preferimos lastPaymentDate, si no está disponible calculamos desde nextPaymentDate)
                      final DateTime startDate = clientUser.lastPaymentDate ?? 
                        nextPaymentDate.subtract(Duration(days: planDurationInDays));
                      
                      // Calcular días totales, transcurridos y restantes
                      final int totalDays = planDurationInDays;
                      final int daysElapsed = now.difference(startDate).inDays;
                      final int daysRemaining = nextPaymentDate.difference(now).inDays;
                      
                      // Calcular progreso (entre 0.0 y 1.0)
                      final double progress = (daysElapsed / totalDays).clamp(0.0, 1.0);
                      
                      // Determinar el color según si está vencido o no
                      final bool isOverdue = now.isAfter(nextPaymentDate);
                      final Color progressColor = _getProgressColor(daysRemaining, isOverdue);
                      
                      AppLogger.logInfo(
                        'Cálculo unificado de barra de progreso para usuario ${user.id}',
                        className: 'AcademyUserCard',
                        params: {
                          'fecha_inicio': startDate.toString(),
                          'fecha_próximo_pago': nextPaymentDate.toString(),
                          'duración_plan_días': totalDays.toString(),
                          'días_transcurridos': daysElapsed.toString(),
                          'días_restantes': daysRemaining.toString(),
                          'progreso': progress.toString(),
                          'está_vencido': isOverdue.toString(),
                        }
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Barra de progreso
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                minHeight: 3,
                              ),
                            ),
                            
                            // Fecha de próximo pago
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isOverdue 
                                    ? 'Vencido: ${formatDate(nextPaymentDate)}'
                                    : 'Próximo: ${formatDate(nextPaymentDate)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getTextColor(daysRemaining, isOverdue),
                                  ),
                                ),
                                Text(
                                  isOverdue 
                                    ? 'Pago pendiente'
                                    : '$daysRemaining días',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getTextColor(daysRemaining, isOverdue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    error: (error, stack) {
                      AppLogger.logError(
                        message: 'Error al cargar datos del cliente',
                        error: error,
                        stackTrace: stack,
                        className: 'AcademyUserCard',
                        params: {'userId': user.id}
                      );
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
          
          // Flecha para indicar que se puede navegar
          Icon(
            Icons.chevron_right,
            color: AppTheme.lightGray,
            size: 20,
          ),
        ],
      ),
    );
    
    // Acciones para el Dismissible
    final List<Widget> slideActions = [
      // Acción de ver detalles (deslizar izquierda)
      Container(
        color: AppTheme.mediumGray,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(height: 4),
                Text(
                  'Detalles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    
    // Acción de pagos solo para atletas
    if (isAthlete) {
      slideActions.add(
        Container(
          color: AppTheme.embers,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_outlined, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    'Pagos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Construimos el dismissible con el card
    return Dismissible(
      key: Key('user_dismiss_${user.id}'),
      background: slideActions[0], // Acción al deslizar a la derecha (detalles)
      secondaryBackground: isAthlete ? slideActions[1] : slideActions[0], // Acción al deslizar a la izquierda (pagos)
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Deslizar a la derecha: ir a detalles
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AcademyUserDetailsScreen(
                academyId: academyId,
                userId: user.id,
                initialUserData: user,
              ),
            ),
          );
        } else if (direction == DismissDirection.endToStart && isAthlete) {
          // Deslizar a la izquierda: ir a pagos (solo atletas)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AthletePaymentsScreen(
                athleteId: user.id,
                athleteName: user.fullName,
              ),
            ),
          );
        }
        return false; // No eliminar el item
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AcademyUserDetailsScreen(
                  academyId: academyId,
                  userId: user.id,
                  initialUserData: user,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: cardContent,
        ),
      ),
    );
  }

  // Retorna un widget de barra de progreso inactiva
  Widget _buildInactiveProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra gris inactiva
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              minHeight: 3,
            ),
          ),
          
          // Texto de inactivo
          const SizedBox(height: 4),
          const Text(
            'Usuario inactivo',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // Calcula la duración del plan en días según el ciclo de facturación
  int _getPlanDurationInDays(SubscriptionPlanModel plan) {
    // Si el plan tiene billingCycle como texto (desde JSON)
    final String? cycleName = plan.billingCycle is String 
        ? plan.billingCycle as String
        : null;
        
    // Usar el enum BillingCycle si está disponible
    final BillingCycle cycle = cycleName != null
        ? BillingCycle.values.firstWhere(
            (e) => e.name == cycleName,
            orElse: () => BillingCycle.monthly,
          )
        : (plan.billingCycle is BillingCycle 
            ? plan.billingCycle as BillingCycle 
            : BillingCycle.monthly);
    
    // Convertir meses a días aproximados
    switch (cycle) {
      case BillingCycle.annual:
        return 365; // Un año
      case BillingCycle.biannual:
        return 180; // Seis meses aproximados
      case BillingCycle.quarterly:
        return 90; // Tres meses aproximados
      case BillingCycle.monthly:
      default:
        return 30; // Un mes aproximado
    }
  }
  
  // Determina el color de la barra de progreso
  Color _getProgressColor(int daysRemaining, bool isOverdue) {
    if (isOverdue) {
      return AppTheme.bonfireRed; // Rojo para vencido
    } else if (daysRemaining < 5) {
      return AppTheme.bonfireRed; // Rojo para casi vencido
    } else if (daysRemaining < 15) {
      return AppTheme.goldTrophy; // Amarillo/naranja para próximo a vencer
    } else {
      return AppTheme.courtGreen; // Verde para pago al día
    }
  }
  
  // Determina el color del texto
  Color _getTextColor(int daysRemaining, bool isOverdue) {
    if (isOverdue || daysRemaining < 5) {
      return AppTheme.bonfireRed;
    }
    return AppTheme.lightGray;
  }
} 