import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/auth/domain/usecases/manage_academy_members_usecase.dart';
import 'package:arcinus/core/auth/presentation/providers/repository_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_members_providers.g.dart';
part 'academy_members_providers.freezed.dart';

// === Provider del caso de uso ===
@riverpod
ManageAcademyMembersUseCase manageAcademyMembersUseCase(Ref ref) {
  return ManageAcademyMembersUseCase(
    ref.watch(baseUserRepositoryProvider),
    ref.watch(academyUserContextRepositoryProvider),
  );
}

// === Providers de estado ===

/// Estado para la gestión de miembros
@freezed
class AcademyMembersState with _$AcademyMembersState {
  const factory AcademyMembersState({
    @Default([]) List<AcademyUserContext> members,
    @Default([]) List<AcademyUserContext> athletes,
    @Default([]) List<AcademyUserContext> parents,
    @Default(false) bool isLoading,
    @Default(false) bool isAdding,
    @Default(false) bool isUpdating,
    @Default(false) bool isLinking,
    String? error,
  }) = _AcademyMembersState;
}

/// Provider para gestionar el estado de miembros de una academia
@riverpod
class AcademyMembersNotifier extends _$AcademyMembersNotifier {
  @override
  AcademyMembersState build(String academyId) {
    // Cargar miembros inicialmente
    _loadMembers();
    return const AcademyMembersState();
  }

  // === Métodos públicos para atletas ===

  /// Carga la lista de miembros
  Future<void> loadMembers({
    MemberType? typeFilter,
    PaymentStatus? paymentStatusFilter,
  }) async {
    await _loadMembers(typeFilter: typeFilter, paymentStatusFilter: paymentStatusFilter);
  }

  /// Añade un nuevo atleta
  Future<bool> addAthlete({
    required String userId,
    required String addedBy,
    AthleteInfo? athleteInfo,
    List<String>? parentIds,
  }) async {
    state = state.copyWith(isAdding: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.addAthlete(
        userId: userId,
        academyId: academyId,
        addedBy: addedBy,
        athleteInfo: athleteInfo,
        parentIds: parentIds,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isAdding: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isAdding: false);
          // Recargar lista
          _loadMembers();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Actualiza información de un atleta
  Future<bool> updateAthleteInfo({
    required String athleteId,
    required String updatedBy,
    required AthleteInfo newInfo,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.updateAthleteInfo(
        athleteId: athleteId,
        academyId: academyId,
        updatedBy: updatedBy,
        newInfo: newInfo,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isUpdating: false);
          // Actualizar atleta específico en la lista
          _updateAthleteInList(athleteId, newInfo);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  // === Métodos públicos para padres ===

  /// Añade un padre/responsable
  Future<bool> addParent({
    required String userId,
    required String addedBy,
    required List<String> athleteIds,
    ParentInfo? parentInfo,
  }) async {
    state = state.copyWith(isAdding: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.addParent(
        userId: userId,
        academyId: academyId,
        addedBy: addedBy,
        athleteIds: athleteIds,
        parentInfo: parentInfo,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isAdding: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isAdding: false);
          // Recargar lista
          _loadMembers();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Actualiza información de un padre
  Future<bool> updateParentInfo({
    required String parentId,
    required String updatedBy,
    required ParentInfo newInfo,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.updateParentInfo(
        parentId: parentId,
        academyId: academyId,
        updatedBy: updatedBy,
        newInfo: newInfo,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isUpdating: false);
          // Actualizar padre específico en la lista
          _updateParentInList(parentId, newInfo);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  // === Métodos públicos para relaciones ===

  /// Vincula un padre con un atleta
  Future<bool> linkParentToAthlete({
    required String parentId,
    required String athleteId,
    required String linkedBy,
  }) async {
    state = state.copyWith(isLinking: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.linkParentToAthlete(
        parentId: parentId,
        athleteId: athleteId,
        academyId: academyId,
        linkedBy: linkedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLinking: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLinking: false);
          // Recargar para actualizar relaciones
          _loadMembers();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLinking: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Desvincula un padre de un atleta
  Future<bool> unlinkParentFromAthlete({
    required String parentId,
    required String athleteId,
    required String unlinkedBy,
  }) async {
    state = state.copyWith(isLinking: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.unlinkParentFromAthlete(
        parentId: parentId,
        athleteId: athleteId,
        academyId: academyId,
        unlinkedBy: unlinkedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLinking: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLinking: false);
          // Recargar para actualizar relaciones
          _loadMembers();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLinking: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  // === Métodos públicos para pagos ===

  /// Actualiza el estado de pago de un miembro
  Future<bool> updatePaymentStatus({
    required String memberId,
    required String updatedBy,
    required PaymentStatus status,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    DateTime? nextPaymentDue,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.updatePaymentStatus(
        memberId: memberId,
        academyId: academyId,
        updatedBy: updatedBy,
        status: status,
        lastPaymentDate: lastPaymentDate,
        lastPaymentAmount: lastPaymentAmount,
        nextPaymentDue: nextPaymentDue,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isUpdating: false);
          // Actualizar estado de pago en la lista
          _updatePaymentStatusInList(memberId, status);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // === Métodos privados ===

  Future<void> _loadMembers({
    MemberType? typeFilter,
    PaymentStatus? paymentStatusFilter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(manageAcademyMembersUseCaseProvider);
      final result = await useCase.getAcademyMembers(
        academyId: academyId,
        typeFilter: typeFilter,
        paymentStatusFilter: paymentStatusFilter,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (members) {
          final athletes = members.where((m) => m.isAthlete).toList();
          final parents = members.where((m) => m.isParent).toList();
          
          state = state.copyWith(
            isLoading: false,
            members: members,
            athletes: athletes,
            parents: parents,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  void _updateAthleteInList(String athleteId, AthleteInfo newInfo) {
    final updatedMembers = state.members.map((member) {
      if (member.userId == athleteId && member.isAthlete) {
        return member.copyWith(
          memberData: member.memberData?.copyWith(athleteInfo: newInfo),
          updatedAt: DateTime.now(),
        );
      }
      return member;
    }).toList();

    final updatedAthletes = updatedMembers.where((m) => m.isAthlete).toList();

    state = state.copyWith(
      members: updatedMembers,
      athletes: updatedAthletes,
    );
  }

  void _updateParentInList(String parentId, ParentInfo newInfo) {
    final updatedMembers = state.members.map((member) {
      if (member.userId == parentId && member.isParent) {
        return member.copyWith(
          memberData: member.memberData?.copyWith(parentInfo: newInfo),
          updatedAt: DateTime.now(),
        );
      }
      return member;
    }).toList();

    final updatedParents = updatedMembers.where((m) => m.isParent).toList();

    state = state.copyWith(
      members: updatedMembers,
      parents: updatedParents,
    );
  }

  void _updatePaymentStatusInList(String memberId, PaymentStatus status) {
    final updatedMembers = state.members.map((member) {
      if (member.userId == memberId && member.memberData != null) {
        return member.copyWith(
          memberData: member.memberData!.copyWith(paymentStatus: status),
          updatedAt: DateTime.now(),
        );
      }
      return member;
    }).toList();

    state = state.copyWith(members: updatedMembers);
  }
}

// === Providers utilitarios ===

/// Provider para obtener atletas de una academia
@riverpod
Future<List<AcademyUserContext>> academyAthletes(
  Ref ref,
  String academyId,
) async {
  final useCase = ref.watch(manageAcademyMembersUseCaseProvider);
  final result = await useCase.getAcademyMembers(
    academyId: academyId,
    typeFilter: MemberType.athlete,
  );

  return result.fold((failure) => [], (members) => members);
}

/// Provider para obtener padres de una academia
@riverpod
Future<List<AcademyUserContext>> academyParents(
  Ref ref,
  String academyId,
) async {
  final useCase = ref.watch(manageAcademyMembersUseCaseProvider);
  final result = await useCase.getAcademyMembers(
    academyId: academyId,
    typeFilter: MemberType.parent,
  );

  return result.fold((failure) => [], (members) => members);
}

/// Provider para obtener atletas asociados a un padre
@riverpod
Future<List<AcademyUserContext>> parentAthletes(
  Ref ref,
  String parentId,
  String academyId,
) async {
  final useCase = ref.watch(manageAcademyMembersUseCaseProvider);
  final result = await useCase.getParentAthletes(
    parentId: parentId,
    academyId: academyId,
  );

  return result.fold((failure) => [], (athletes) => athletes);
}

/// Provider para obtener padres asociados a un atleta
@riverpod
Future<List<AcademyUserContext>> athleteParents(
  Ref ref,
  String athleteId,
  String academyId,
) async {
  final useCase = ref.watch(manageAcademyMembersUseCaseProvider);
  final result = await useCase.getAthleteParents(
    athleteId: athleteId,
    academyId: academyId,
  );

  return result.fold((failure) => [], (parents) => parents);
}

/// Provider para obtener miembros con problemas de pago
@riverpod
Future<List<AcademyUserContext>> membersWithPaymentIssues(
  Ref ref,
  String academyId,
) async {
  final useCase = ref.watch(manageAcademyMembersUseCaseProvider);
  final result = await useCase.getMembersWithPaymentIssues(
    academyId: academyId,
  );

  return result.fold((failure) => [], (members) => members);
}

// === Extensiones útiles ===

extension AcademyMembersStateX on AcademyMembersState {
  /// Obtiene miembros con pagos al día
  List<AcademyUserContext> get membersUpToDate => 
      members.where((m) => m.isPaymentUpToDate).toList();

  /// Obtiene miembros con problemas de pago
  List<AcademyUserContext> get membersWithPaymentProblems => 
      members.where((m) => m.memberData?.hasPaymentIssues == true).toList();

  /// Obtiene atletas menores de edad
  List<AcademyUserContext> get minorAthletes =>
      athletes.where((athlete) => 
          athlete.athleteInfo?.isMinor == true).toList();

  /// Verifica si hay alguna operación en curso
  bool get hasOperationInProgress => 
      isLoading || isAdding || isUpdating || isLinking;

  /// Verifica si hay errores
  bool get hasError => error != null;

  /// Número total de miembros
  int get totalMembers => members.length;

  /// Número de atletas
  int get totalAthletes => athletes.length;

  /// Número de padres
  int get totalParents => parents.length;
} 