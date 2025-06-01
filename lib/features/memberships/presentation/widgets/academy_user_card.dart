import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/memberships/presentation/utils/role_utils.dart';
import 'package:arcinus/features/memberships/presentation/widgets/payment_progress_bar.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyUserCard extends ConsumerStatefulWidget {
  final AcademyUserModel user;
  final String academyId;

  const AcademyUserCard({
    super.key,
    required this.user,
    required this.academyId,
  });

  @override
  ConsumerState<AcademyUserCard> createState() => _AcademyUserCardState();
}

class _AcademyUserCardState extends ConsumerState<AcademyUserCard> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'AcademyUserCard initState',
      className: 'AcademyUserCard',
      params: {
        'userId': widget.user.id,
        'userName': widget.user.fullName,
        'academyId': widget.academyId,
      }
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo(
      'AcademyUserCard dispose',
      className: 'AcademyUserCard',
      params: {
        'userId': widget.user.id,
        'userName': widget.user.fullName,
        'academyId': widget.academyId,
      }
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logInfo(
      'Construyendo AcademyUserCard',
      className: 'AcademyUserCard',
      params: {
        'userId': widget.user.id,
        'userName': widget.user.fullName,
        'academyId': widget.academyId,
        'widget_hashCode': widget.hashCode,
        'state_hashCode': hashCode,
      }
    );
    
    // Determinamos el rol del usuario (memoizado para evitar recálculos)
    final userRole = widget.user.role != null
        ? AppRole.values.firstWhere(
            (r) => r.name == widget.user.role,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
    
    final isAthlete = userRole == AppRole.atleta;
    
    // Usar el provider optimizado solo para atletas
    final clientUserAsyncValue = isAthlete 
        ? ref.watch(clientUserCachedProvider(widget.user.id)) 
        : null;
    
    if (isAthlete && clientUserAsyncValue != null) {
      AppLogger.logInfo(
        'Estado del clientUserCachedProvider en AcademyUserCard',
        className: 'AcademyUserCard',
        params: {
          'userId': widget.user.id,
          'isLoading': clientUserAsyncValue.isLoading,
          'hasValue': clientUserAsyncValue.hasValue,
          'hasError': clientUserAsyncValue.hasError,
          'paymentStatus': clientUserAsyncValue.hasValue 
              ? clientUserAsyncValue.value?.paymentStatus.toString() 
              : null,
          'subscriptionPlan_exists': clientUserAsyncValue.hasValue 
              ? (clientUserAsyncValue.value?.subscriptionPlan != null).toString()
              : null,
        }
      );
    }
    
    // Usar constantes para textos estáticos (optimización)
    const String defaultGroupText = 'Sin asignar grupo';
    const String parentGroupText = 'Padre/Tutor';
    const String staffGroupText = 'Staff';
    
    // Placeholder para grupos (memoizado)
    final String groupPlaceholder = isAthlete 
        ? defaultGroupText
        : (userRole == AppRole.padre ? parentGroupText : staffGroupText);
    
    return _buildOptimizedCard(
      context: context,
      userRole: userRole,
      isAthlete: isAthlete,
      clientUserAsyncValue: clientUserAsyncValue,
      groupPlaceholder: groupPlaceholder,
    );
  }

  /// Construye la tarjeta optimizada para evitar reconstrucciones innecesarias
  Widget _buildOptimizedCard({
    required BuildContext context,
    required AppRole userRole,
    required bool isAthlete,
    required AsyncValue<ClientUserModel?>? clientUserAsyncValue,
    required String groupPlaceholder,
  }) {
    // Contenido de la tarjeta (memoizado)
    final cardContent = _buildCardContent(
      userRole: userRole,
      isAthlete: isAthlete,
      clientUserAsyncValue: clientUserAsyncValue,
      groupPlaceholder: groupPlaceholder,
    );
    
    // Acciones para el Dismissible (memoizadas)
    final slideActions = _buildSlideActions(isAthlete);
    
    // Construimos el dismissible con el card
    return Dismissible(
      key: Key('user_dismiss_${widget.user.id}'),
      background: slideActions[0], // Acción al deslizar a la derecha (detalles)
      secondaryBackground: isAthlete && slideActions.length > 1 
          ? slideActions[1] 
          : slideActions[0], // Acción al deslizar a la izquierda (pagos)
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Deslizar a la derecha: ir a detalles
          _navigateToDetails(context);
        } else if (direction == DismissDirection.endToStart && isAthlete) {
          // Deslizar a la izquierda: ir a pagos (solo atletas)
          _navigateToPayments(context);
        }
        return false; // No eliminar el item
      },
      child: Card(
        elevation: AppTheme.elevationLow,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: InkWell(
          onTap: () => _navigateToDetails(context),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: cardContent,
        ),
      ),
    );
  }

  /// Construye el contenido de la tarjeta
  Widget _buildCardContent({
    required AppRole userRole,
    required bool isAthlete,
    required AsyncValue<ClientUserModel?>? clientUserAsyncValue,
    required String groupPlaceholder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Avatar (optimizado con Hero widget)
          _buildAvatarSection(userRole),
          
          const SizedBox(width: 16),
          
          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del usuario y estado de pago para atletas
                _buildNameAndStatusRow(isAthlete, clientUserAsyncValue),
                
                const SizedBox(height: 2),
                
                // Grupo y rol
                _buildGroupAndRoleRow(groupPlaceholder, userRole),
                
                // Barra de progreso (solo para atletas con información de pago)
                if (isAthlete && clientUserAsyncValue != null)
                  PaymentProgressBar(
                    userId: widget.user.id,
                    userName: widget.user.fullName,
                  ),
              ],
            ),
          ),
          
          // Flecha para indicar que se puede navegar
          Icon(
            Icons.chevron_right,
            color: AppTheme.lightGray,
            size: 18,
          ),
        ],
      ),
    );
  }

  /// Construye la sección del avatar
  Widget _buildAvatarSection(AppRole userRole) {
    return Hero(
      tag: 'user_avatar_${widget.user.id}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: RoleUtils.getRoleColor(userRole),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.darkGray,
          backgroundImage: widget.user.profileImageUrl != null
              ? NetworkImage(widget.user.profileImageUrl!)
              : null,
          child: widget.user.profileImageUrl == null
              ? Text(
                  widget.user.firstName.isNotEmpty 
                      ? widget.user.firstName[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// Construye la fila con nombre y estado de pago
  Widget _buildNameAndStatusRow(
    bool isAthlete, 
    AsyncValue<ClientUserModel?>? clientUserAsyncValue,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.user.fullName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Indicador de estado de pago para atletas
        if (isAthlete && clientUserAsyncValue != null)
          _buildPaymentStatusIndicator(clientUserAsyncValue),
      ],
    );
  }

  /// Construye el indicador de estado de pago
  Widget _buildPaymentStatusIndicator(AsyncValue<ClientUserModel?> clientUserAsyncValue) {
    return clientUserAsyncValue.when(
      data: (clientUser) {
        if (clientUser == null) {
          return const SizedBox.shrink();
        }
        
        // Determinar color y etiqueta según estado de pago
        final (statusColor, statusText, statusIcon) = switch (clientUser.paymentStatus) {
          PaymentStatus.active => (AppTheme.courtGreen, 'Activo', Icons.check_circle),
          PaymentStatus.overdue => (AppTheme.bonfireRed, 'En mora', Icons.warning_amber),
          PaymentStatus.inactive || _ => (Colors.grey, 'Inactivo', Icons.cancel),
        };
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withAlpha(100), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Construye la fila con grupo y rol
  Widget _buildGroupAndRoleRow(String groupPlaceholder, AppRole userRole) {
    return Row(
      children: [
        // Placeholder del grupo
        Flexible(
          child: Text(
            groupPlaceholder,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.lightGray,
              letterSpacing: 0.4,
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
            fontSize: 11,
            color: AppTheme.lightGray,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Posición/rol
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: RoleUtils.getRoleColor(userRole).withAlpha(45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            RoleUtils.getRoleName(userRole),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: RoleUtils.getRoleColor(userRole),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye las acciones deslizables
  List<Widget> _buildSlideActions(bool isAthlete) {
    final List<Widget> slideActions = [
      // Acción de ver detalles (deslizar izquierda)
      Container(
        decoration: BoxDecoration(
          color: AppTheme.mediumGray,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(height: 4),
                Text(
                  'Detalles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
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
          decoration: BoxDecoration(
            color: AppTheme.mediumGray,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payments_outlined, color: Colors.white, size: 20),
                  SizedBox(height: 4),
                  Text(
                    'Pagos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return slideActions;
  }

  /// Navega a la pantalla de detalles
  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AcademyUserDetailsScreen(
          academyId: widget.academyId,
          userId: widget.user.id,
          initialUserData: widget.user,
        ),
      ),
    );
  }

  /// Navega a la pantalla de pagos
  void _navigateToPayments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterPaymentScreen(
          athleteId: widget.user.id,
        ),
      ),
    );
  }
} 