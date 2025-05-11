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
                      if (clientUser == null || 
                          clientUser.subscriptionPlan == null || 
                          clientUser.paymentStatus == PaymentStatus.inactive) {
                        AppLogger.logInfo(
                          'Mostrando barra inactiva para usuario ${user.id}',
                          className: 'AcademyUserCard'
                        );
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
                      } else {
                        // Para usuarios activos comprobamos fechas
                        // Verificar fechas de pago
                        if (clientUser.nextPaymentDate == null || 
                            clientUser.lastPaymentDate == null) {
                          AppLogger.logWarning(
                            'Usuario activo sin fechas de pago: ${user.id}',
                            className: 'AcademyUserCard'
                          );
                          return const SizedBox.shrink();
                        }
                        
                        final now = DateTime.now();
                        final nextPayment = clientUser.nextPaymentDate!;
                        
                        // Solo mostramos la barra si hay próximo pago en el futuro
                        if (!nextPayment.isAfter(now)) {
                          AppLogger.logInfo(
                            'Próximo pago en el pasado para usuario ${user.id}',
                            className: 'AcademyUserCard',
                            params: {'nextPayment': nextPayment.toString(), 'now': now.toString()}
                          );
                          return const SizedBox.shrink();
                        }
                        
                        final lastPayment = clientUser.lastPaymentDate!;
                        final totalDays = nextPayment.difference(lastPayment).inDays;
                        final daysElapsed = now.difference(lastPayment).inDays;
                        final daysRemaining = nextPayment.difference(now).inDays;
                        
                        // Evitar división por cero y limitar progreso entre 0 y 1
                        final double progressPercent = totalDays > 0 
                            ? daysElapsed / totalDays 
                            : 0.0;
                        final double clampedProgress = progressPercent.clamp(0.0, 1.0);
                        
                        // Color según días restantes
                        final Color progressColor;
                        if (daysRemaining < 5) {
                          progressColor = AppTheme.bonfireRed;
                        } else if (daysRemaining < 15) {
                          progressColor = AppTheme.goldTrophy;
                        } else {
                          progressColor = AppTheme.courtGreen;
                        }
                        
                        AppLogger.logInfo(
                          'Mostrando barra de progreso para usuario ${user.id}',
                          className: 'AcademyUserCard',
                          params: {
                            'progreso': clampedProgress.toString(), 
                            'días_totales': totalDays.toString(),
                            'días_transcurridos': daysElapsed.toString(),
                            'días_restantes': daysRemaining.toString()
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
                                  value: clampedProgress,
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
                                    'Próximo: ${formatDate(nextPayment)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: daysRemaining < 5 ? AppTheme.bonfireRed : AppTheme.lightGray,
                                    ),
                                  ),
                                  if (daysRemaining < 30)
                                    Text(
                                      '$daysRemaining días',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: daysRemaining < 5 ? AppTheme.bonfireRed : AppTheme.lightGray,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
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
} 