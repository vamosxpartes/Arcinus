// lib/features/academy_users/presentation/screens/academy_users_manage/academy_users_manage_screen.dart

//dependencies
import 'package:arcinus/features/academy_users/presentation/providers/academy_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';

//core
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/core/utils/screen_under_development.dart';

//providers
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/athlete_periods_info_provider.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/period_providers.dart';
import 'package:arcinus/features/academy_users/presentation/providers/academy_users_providers.dart';

//widgets
import 'package:arcinus/features/academy_users/presentation/widgets/avatar_horizontal_scroll_section.dart';
import 'package:arcinus/features/academy_users/presentation/screens/add_athlete_screen.dart';
import 'package:arcinus/features/academy_users/presentation/widgets/academy_user_card.dart';

//models
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';

/// Pantalla de miembros de la academia con actualización automática de datos
/// 
/// MEJORAS IMPLEMENTADAS para actualización después de pagos:
/// 1. Listener de lifecycle de la app para detectar cuando regresa al foreground
/// 2. Refresh automático de providers al regresar de pantallas de pago
/// 3. Pull-to-refresh manual para actualización bajo demanda
/// 4. Invalidación específica de providers de atletas después de pagos
/// 5. Timestamps para evitar refreshes excesivos
class AcademyMembersScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersScreen> createState() => _AcademyMembersScreenState();
}

class _AcademyMembersScreenState extends ConsumerState<AcademyMembersScreen> with WidgetsBindingObserver {
  late TextEditingController _searchController;
  String _searchTerm = '';
  bool _shouldRefreshAfterPayment = false;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    
    // *** NUEVO: Agregar observer para detectar cambios en el lifecycle de la app ***
    WidgetsBinding.instance.addObserver(this);
    
    AppLogger.logProcessStart(
      'Inicializando AcademyMembersScreen',
      className: 'AcademyMembersScreen',
      params: {
        'academyId': widget.academyId,
        'timestamp': DateTime.now().toString(),
      }
    );
    
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) {
        AppLogger.logInfo(
          'Término de búsqueda actualizado',
          className: 'AcademyMembersScreen',
          params: {
            'searchTerm': _searchController.text,
            'academyId': widget.academyId,
          }
        );
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Establecer el título de la pantalla usando TitleManager
        ref.read(titleManagerProvider.notifier).updateCurrentTitle('Miembros');
        
        AppLogger.logProcessEnd(
          'AcademyMembersScreen inicializado completamente',
          className: 'AcademyMembersScreen',
          params: {'academyId': widget.academyId}
        );
      }
    });
  }

  // *** NUEVO: Detectar cambios en el lifecycle de la app ***
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // La app regresó al foreground
      final now = DateTime.now();
      
      // Si han pasado más de 5 segundos desde el último refresh, ejecutar uno nuevo
      if (_lastRefreshTime == null || 
          now.difference(_lastRefreshTime!).inSeconds > 5) {
        
        AppLogger.logInfo(
          'App regresó al foreground, ejecutando refresh de datos',
          className: 'AcademyMembersScreen',
          params: {
            'academyId': widget.academyId,
            'lastRefreshTime': _lastRefreshTime?.toString(),
            'timeSinceLastRefresh': _lastRefreshTime != null 
                ? now.difference(_lastRefreshTime!).inSeconds.toString()
                : 'null',
          }
        );
        
        _refreshDataAfterPaymentUpdate();
        _lastRefreshTime = now;
      }
    }
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

  void _refreshDataAfterPaymentUpdate() {
    AppLogger.logInfo(
      'Refrescando datos después de actualización de pagos',
      className: 'AcademyMembersScreen',
      params: {
        'academyId': widget.academyId,
        'timestamp': DateTime.now().toIso8601String(),
      }
    );
    
    // Refrescar el provider principal de usuarios de la academia
    // ignore: unused_result
    ref.refresh(academyUsersProvider(widget.academyId));
    
    // CRÍTICO: Refrescar también todos los providers de información completa de atletas
    // Esto es importante porque los widgets como AcademyUserCard y AcademyPaymentAvatarsSection 
    // dependen de athleteCompleteInfoProvider
    final usersAsyncValue = ref.read(academyUsersProvider(widget.academyId));
    usersAsyncValue.whenData((users) {
      // Refrescar información completa para cada atleta
      for (final user in users) {
        if (user.appRole == AppRole.atleta) {
          // ignore: unused_result
          ref.refresh(athleteCompleteInfoProvider((
            academyId: widget.academyId,
            athleteId: user.id ?? '',
          )));
          
          // También refrescar los providers de períodos individuales
          // ignore: unused_result
          ref.refresh(athleteActivePeriodsProvider((
            academyId: widget.academyId,
            athleteId: user.id ?? '',
          )));
        }
      }
    });
    
    setState(() {
      _shouldRefreshAfterPayment = false;
      _lastRefreshTime = DateTime.now();
    });
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
    // *** NUEVO: Listener para detectar cuando se regresa a la pantalla ***
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _shouldRefreshAfterPayment) {
        _refreshDataAfterPaymentUpdate();
      }
    });
    
    AppLogger.logInfo(
      'Construyendo AcademyMembersScreen',
      className: 'AcademyMembersScreen',
      params: {
        'academyId': widget.academyId,
        'searchTerm': _searchTerm,
        'searchActive': _searchTerm.isNotEmpty,
        'timestamp': DateTime.now().toString(),
      }
    );
    
    final AsyncValue<List<AcademyUserModel>> usersAsyncValue;
    
    if (_searchTerm.isNotEmpty) {
      AppLogger.logInfo(
        'Usando provider de búsqueda',
        className: 'AcademyMembersScreen',
        params: {
          'academyId': widget.academyId,
          'searchTerm': _searchTerm,
        }
      );
      usersAsyncValue = ref.watch(membersScreenSearchProvider((
        academyId: widget.academyId,
        searchTerm: _searchTerm,
        role: null,
      )));
    } else {
      AppLogger.logInfo(
        'Usando provider principal de usuarios',
        className: 'AcademyMembersScreen',
        params: {
          'academyId': widget.academyId,
        }
      );
      usersAsyncValue = ref.watch(academyUsersProvider(widget.academyId));
    }
    
    AppLogger.logInfo(
      'Estado del provider de usuarios',
      className: 'AcademyMembersScreen',
      params: {
        'academyId': widget.academyId,
        'isLoading': usersAsyncValue.isLoading,
        'hasValue': usersAsyncValue.hasValue,
        'hasError': usersAsyncValue.hasError,
        'userCount': usersAsyncValue.hasValue ? usersAsyncValue.value?.length : null,
        'error': usersAsyncValue.hasError ? usersAsyncValue.error.toString() : null,
      }
    );
    
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
              AppLogger.logInfo(
                'Datos de usuarios recibidos en AcademyMembersScreen',
                className: 'AcademyMembersScreen',
                params: {
                  'academyId': widget.academyId,
                  'userCount': users.length,
                  'searchTerm': _searchTerm,
                  'userIds': users.map((u) => u.id ?? '').take(5).toList(), // Solo los primeros 5 IDs
                  'timestamp': DateTime.now().toString(),
                }
              );
              
              if (users.isEmpty) {
                AppLogger.logInfo(
                  'Lista de usuarios vacía',
                  className: 'AcademyMembersScreen',
                  params: {
                    'academyId': widget.academyId,
                    'searchActive': _searchTerm.isNotEmpty,
                    'searchTerm': _searchTerm,
                  }
                );
                
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
              
              AppLogger.logInfo(
                'Construyendo lista de usuarios',
                className: 'AcademyMembersScreen',
                params: {
                  'academyId': widget.academyId,
                  'userCount': users.length,
                  'showAvatarsSection': _searchTerm.isEmpty,
                }
              );
              
              return RefreshIndicator(
                onRefresh: () async {
                  AppLogger.logInfo(
                    'Ejecutando pull-to-refresh manual',
                    className: 'AcademyMembersScreen',
                    params: {
                      'academyId': widget.academyId,
                      'userCount': users.length,
                    }
                  );
                  _refreshDataAfterPaymentUpdate();
                },
                child: CustomScrollView(
                  slivers: [
                    // Scroll horizontal de avatares (solo si no hay búsqueda activa)
                    if (_searchTerm.isEmpty)
                      SliverToBoxAdapter(
                        child: AvatarHorizontalScrollSection(
                          users: users,
                          academyId: widget.academyId,
                        ),
                      ),
                      
                    // Lista alfabética
                    SliverToBoxAdapter(
                      child: _buildAlphabeticalList(users),
                    ),
                  ],
                ),
              );
            },
            loading: () {
              AppLogger.logInfo(
                'AcademyMembersScreen en estado de carga',
                className: 'AcademyMembersScreen',
                params: {
                  'academyId': widget.academyId,
                  'searchTerm': _searchTerm,
                }
              );
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stack) {
              AppLogger.logError(
                message: 'Error al cargar usuarios en AcademyMembersScreen',
                error: error,
                stackTrace: stack,
                className: 'AcademyMembersScreen',
                params: {
                  'academyId': widget.academyId,
                  'searchTerm': _searchTerm,
                  'error_type': error.runtimeType.toString(),
                }
              );
              return Center(
                child: Text('Error al cargar usuarios: $error'),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo(
      'Destruyendo AcademyMembersScreen',
      className: 'AcademyMembersScreen',
      params: {
        'academyId': widget.academyId,
        'searchTerm': _searchTerm,
        'timestamp': DateTime.now().toString(),
      }
    );
    
    // *** NUEVO: Remover observer ***
    WidgetsBinding.instance.removeObserver(this);
    
    _searchController.dispose();
    super.dispose();
  }
} 