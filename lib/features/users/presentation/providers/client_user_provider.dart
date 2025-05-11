import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que obtiene información del usuario cliente (atleta o padre) por su ID
final clientUserProvider = FutureProvider.family<ClientUserModel?, String>(
  (ref, userId) async {
    final repository = ref.watch(clientUserRepositoryProvider);
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null || currentAcademy.id == null) {
      return null;
    }
    
    final result = await repository.getClientUser(currentAcademy.id!, userId);
    
    return result.fold(
      (failure) => null,
      (clientUser) => clientUser,
    );
  }
);

/// Provider que obtiene la lista de usuarios cliente (atletas y padres) filtrados por rol
final clientUsersByRoleProvider = FutureProvider.family<List<ClientUserModel>, (String, AppRole)>(
  (ref, params) async {
    final repository = ref.watch(clientUserRepositoryProvider);
    final academyId = params.$1;
    final role = params.$2;
    
    final result = await repository.getClientUsers(
      academyId,
      clientType: role,
    );
    
    return result.fold(
      (failure) => [],
      (clients) => clients,
    );
  }
);

/// Provider que obtiene la lista de usuarios cliente (atletas y padres) filtrados por estado de pago
final clientUsersByPaymentStatusProvider = FutureProvider.family<List<ClientUserModel>, (String, PaymentStatus)>(
  (ref, params) async {
    final repository = ref.watch(clientUserRepositoryProvider);
    final academyId = params.$1;
    final status = params.$2;
    
    final result = await repository.getClientUsers(
      academyId,
      paymentStatus: status,
    );
    
    return result.fold(
      (failure) => [],
      (clients) => clients,
    );
  }
); 