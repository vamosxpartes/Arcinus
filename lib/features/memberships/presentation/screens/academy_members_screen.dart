import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_members_providers.dart';
import 'package:arcinus/features/memberships/presentation/widgets/academy_user_card.dart';
import 'package:arcinus/features/memberships/presentation/utils/role_utils.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/memberships/presentation/screens/add_athlete_screen.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/core/utils/screen_under_development.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';

class AcademyMembersScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersScreen> createState() => _AcademyMembersScreenState();
}

class _AcademyMembersScreenState extends ConsumerState<AcademyMembersScreen> {
  late TextEditingController _searchController;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Establecer el título de la pantalla
      ref.read(currentScreenTitleProvider.notifier).state = 'Miembros';
    });
  }

  void _clearSearch() {
    _searchController.clear();
     if (mounted) {
      setState(() {
        _searchTerm = '';
      });
    }
  }
  
  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Añadir miembro'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a pantalla de añadir atleta
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddAthleteScreen(academyId: widget.academyId),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.sports, color: AppTheme.courtGreen),
                  SizedBox(width: 16),
                  Text('Añadir Atleta'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              // Mostrar pantalla en desarrollo para añadir padre
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ScreenUnderDevelopment(
                  title: 'Añadir Padre/Tutor',
                  message: 'Próximamente podrás añadir padres o tutores para los atletas.',
                ),
              ));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.family_restroom, color: AppTheme.goldTrophy),
                  SizedBox(width: 16),
                  Text('Añadir Padre/Tutor'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              // Mostrar pantalla en desarrollo para añadir colaborador
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ScreenUnderDevelopment(
                  title: 'Añadir Colaborador',
                  message: 'Próximamente podrás añadir colaboradores a esta academia.',
                ),
              ));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.badge, color: AppTheme.bonfireRed),
                  SizedBox(width: 16),
                  Text('Añadir Colaborador'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir la lista horizontal de avatares con indicadores de pago
  Widget _buildAvatarList(List<AcademyUserModel> users) {
    // Filtramos atletas y ordenamos por próxima fecha de pago
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: athleteUsers.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final athlete = athleteUsers[index];
                return _buildAvatarItem(athlete);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir cada avatar con sus indicadores de estado de pago
  Widget _buildAvatarItem(AcademyUserModel athlete) {
    return Consumer(
      builder: (context, ref, _) {
        final paymentConfigAsync = ref.watch(paymentConfigProvider(widget.academyId));
        final clientUserAsync = ref.watch(clientUserProvider(athlete.id));
        
        return clientUserAsync.when(
          data: (clientUser) {
            final bool hasPlan = clientUser?.subscriptionPlan != null;
            
            return paymentConfigAsync.when(
              data: (paymentConfig) {
                final now = DateTime.now();
                // final gracePeriodDuration = Duration(days: paymentConfig.gracePeriodDays); // No se usa directamente si usamos clientUser.paymentStatus

                // Usar clientUser.paymentStatus para determinar el estado
                final bool needsPaymentAttention = clientUser == null || // Si no hay datos del cliente
                                                 !hasPlan || // Si no tiene plan asignado
                                                 clientUser.paymentStatus == PaymentStatus.overdue || // Si está en mora
                                                 (clientUser.paymentStatus == PaymentStatus.inactive && hasPlan); // Si está inactivo pero TIENE plan (implica que debería pagar)

                final bool isInGracePeriod = clientUser?.paymentStatus == PaymentStatus.overdue && 
                                             clientUser?.nextPaymentDate != null &&
                                             now.isBefore(clientUser!.nextPaymentDate!.add(Duration(days: paymentConfig.gracePeriodDays))) &&
                                             now.isAfter(clientUser.nextPaymentDate!);


                // Determinar si mostrar alerta visual (borde e icono superior)
                final bool showVisualAlert = needsPaymentAttention || 
                                           isInGracePeriod ||
                                           (hasPlan && clientUser.remainingDays != null && clientUser.remainingDays! < 5 && clientUser.paymentStatus == PaymentStatus.active);


                Color borderColor = Colors.transparent;
                if (needsPaymentAttention && clientUser?.paymentStatus == PaymentStatus.overdue) { // Específicamente rojo para 'overdue'
                  borderColor = AppTheme.bonfireRed; 
                } else if (needsPaymentAttention && !hasPlan) { // Naranja si no tiene plan
                  borderColor = AppTheme.goldTrophy;
                } else if (isInGracePeriod) {
                  borderColor = AppTheme.goldTrophy;
                }


                return GestureDetector(
                  onTap: () {
                    // Navegar directamente a la pantalla de pagos al tocar el avatar
                    // Esto facilita la gestión de pagos para los atletas que lo requieren
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RegisterPaymentScreen(
                          athleteId: athlete.id,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    // Mostrar menú contextual con opciones al mantener presionado
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
                                    academyId: widget.academyId,
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RegisterPaymentScreen(
                                    athleteId: athlete.id,
                                  ),
                                ),
                              );
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
                  },
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Aplicar borde rojo si el pago está vencido, naranja si está en período de gracia
                            // Esto proporciona indicación visual clara del estado de pago del atleta
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor, width: borderColor == Colors.transparent ? 0 : 3),
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
                                  child: Builder(
                                    builder: (context) {
                                      if (clientUser == null || !hasPlan) { // No hay datos de cliente o no tiene plan
                                        return const Icon(
                                          Icons.playlist_add_check, // Icono para asignar plan
                                          size: 12,
                                          color: AppTheme.goldTrophy, // Naranja para "acción requerida"
                                        );
                                      }
                                      switch (clientUser.paymentStatus) {
                                        case PaymentStatus.overdue:
                                          return const Text(
                                            '!',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.bonfireRed,
                                            ),
                                          );
                                        case PaymentStatus.inactive: // Inactivo pero con plan implica que necesita pagar para activar
                                           return const Icon(
                                            Icons.attach_money, 
                                            size: 12,
                                            color: AppTheme.bonfireRed,
                                          );
                                        case PaymentStatus.active:
                                          if (clientUser.nextPaymentDate != null) {
                                            final daysRemaining = clientUser.nextPaymentDate!.difference(now).inDays;
                                            if (daysRemaining < 0 && !isInGracePeriod) { // Vencido y no en gracia (aunque overdue deberia cubrirlo)
                                               return const Text(
                                                '!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.bonfireRed,
                                                ),
                                              );
                                            }
                                            return Text(
                                              '$daysRemaining',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: daysRemaining < 5 
                                                    ? AppTheme.bonfireRed 
                                                    : (daysRemaining < 15 
                                                        ? AppTheme.goldTrophy 
                                                        : Colors.black),
                                              ),
                                            );
                                          } else {
                                            // Activo pero sin fecha de próximo pago (podría ser plan vitalicio o error)
                                            return const Icon(
                                              Icons.check_circle_outline,
                                              size: 12,
                                              color: Colors.green,
                                            );
                                          }
                                      }
                                    }
                                  ),
                                ),
                              ),
                            ),
                            // Indicador de color en la esquina superior para alertar sobre pago
                            if (showVisualAlert)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: (clientUser?.paymentStatus == PaymentStatus.overdue)
                                        ? AppTheme.bonfireRed
                                        : (!hasPlan || clientUser?.paymentStatus == PaymentStatus.inactive) // Sin plan o inactivo con plan
                                            ? AppTheme.goldTrophy // Naranja para "atención requerida"
                                            : (isInGracePeriod 
                                                ? AppTheme.goldTrophy
                                                : (clientUser != null && clientUser.remainingDays != null && clientUser.remainingDays! < 5 // Chequeo más robusto
                                                    ? AppTheme.bonfireRed
                                                    : AppTheme.goldTrophy)),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.blackSwarm,
                                      width: 1,
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
              },
              loading: () => _buildLoadingAvatarItem(athlete),
              error: (_, __) => _buildErrorAvatarItem(athlete),
            );
          },
          loading: () => _buildLoadingAvatarItem(athlete),
          error: (_, __) => _buildErrorAvatarItem(athlete),
        );
      },
    );
  }
  
  // Widget para mostrar avatar en estado de carga
  Widget _buildLoadingAvatarItem(AcademyUserModel athlete) {
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
  
  // Widget para mostrar avatar en estado de error
  Widget _buildErrorAvatarItem(AcademyUserModel athlete) {
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

  Widget _buildAlphabeticalList(List<AcademyUserModel> users) {
    // Ordenamos los usuarios alfabéticamente por nombre
    final sortedUsers = [...users];
    sortedUsers.sort((a, b) => a.fullName.compareTo(b.fullName));
    
    // Agrupamos por primera letra
    final Map<String, List<AcademyUserModel>> groupedUsers = {};
    
    for (var user in sortedUsers) {
      final firstLetter = user.fullName.substring(0, 1).toUpperCase();
      if (!groupedUsers.containsKey(firstLetter)) {
        groupedUsers[firstLetter] = [];
      }
      groupedUsers[firstLetter]!.add(user);
    }

    // Ordenamos las letras
    final sortedLetters = groupedUsers.keys.toList()..sort();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedLetters.length,
      itemBuilder: (context, index) {
        final letter = sortedLetters[index];
        final letterUsers = groupedUsers[letter]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightGray,
                ),
              ),
            ),
            ...letterUsers.map((user) => AcademyUserCard(
              user: user,
              academyId: widget.academyId,
            )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AcademyUserModel>> usersAsyncValue;
    
    if (_searchTerm.isNotEmpty) {
      usersAsyncValue = ref.watch(membersScreenSearchProvider((
        academyId: widget.academyId,
        searchTerm: _searchTerm,
        role: null,
      )));
    } else {
      usersAsyncValue = ref.watch(academyUsersProvider(widget.academyId));
    }
    
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar miembro...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.mediumGray.withAlpha(170),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: _showAddOptionsDialog,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: AppTheme.embers,
                  ),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
            ],
          ),
        ),
        
        // Contenido principal
        Expanded(
          child: usersAsyncValue.when(
            data: (users) {
              if (users.isEmpty) {
                if (_searchTerm.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No se encontraron resultados para "$_searchTerm"'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearSearch,
                          child: const Text('Limpiar búsqueda'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No hay miembros en esta academia'));
              }
              
              return CustomScrollView(
                slivers: [
                  // Scroll horizontal de avatares (solo si no hay búsqueda activa)
                  if (_searchTerm.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildAvatarList(users),
                    ),
                    
                  // Lista alfabética
                  SliverToBoxAdapter(
                    child: _buildAlphabeticalList(users),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error al cargar usuarios: $error'),
            ),
          ),
        ),
      ],
    );
  }
} 