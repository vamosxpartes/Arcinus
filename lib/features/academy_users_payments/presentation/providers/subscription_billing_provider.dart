import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academy_users_payments/domain/services/subscription_billing_service.dart';

/// Provider para el servicio de facturación de suscripciones
final subscriptionBillingServiceProvider = Provider<SubscriptionBillingService>((ref) {
  return SubscriptionBillingService();
}); 