// import 'package:arcinus/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/subscription_repository.dart';// Necesario para el tipo
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Asumiendo que tienes un provider global para Firestore
import 'package:arcinus/core/providers/firebase_providers.dart'; // Usar el provider centralizado
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/subscription_repository_impl.dart'; // Nueva importación

part 'subscription_repository_provider.g.dart';

/// Provider para la instancia de [SubscriptionRepository].
///
/// Utiliza este provider para acceder al repositorio desde otros providers o widgets.
@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  // Usar el provider centralizado de Firestore
  final firestore = ref.watch(firestoreProvider);

  // Devolver la implementación concreta con el nombre correcto
  return SubscriptionRepositoryImpl(firestore: firestore);
}
