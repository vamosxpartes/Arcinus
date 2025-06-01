import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_members_providers.dart';
import 'package:arcinus/features/memberships/presentation/widgets/academy_user_card.dart';
import 'package:arcinus/features/memberships/presentation/widgets/academy_payment_avatars_section.dart';
import 'package:arcinus/features/memberships/presentation/screens/add_athlete_screen.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/core/utils/screen_under_development.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  'userIds': users.map((u) => u.id).take(5).toList(), // Solo los primeros 5 IDs
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
              
              return CustomScrollView(
                slivers: [
                  // Scroll horizontal de avatares (solo si no hay búsqueda activa)
                  if (_searchTerm.isEmpty)
                    SliverToBoxAdapter(
                      child: AcademyPaymentAvatarsSection(
                        users: users,
                        academyId: widget.academyId,
                      ),
                    ),
                    
                  // Lista alfabética
                  SliverToBoxAdapter(
                    child: _buildAlphabeticalList(users),
                  ),
                ],
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
    _searchController.dispose();
    super.dispose();
  }
} 