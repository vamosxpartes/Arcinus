import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/providers/firebase_providers.dart';
import 'package:arcinus/features/super_admin/data/repositories/super_admin_dashboard_repository.dart';

/// Provider para el repositorio del dashboard del SuperAdmin
final superAdminDashboardRepositoryProvider = Provider<SuperAdminDashboardRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SuperAdminDashboardRepositoryImpl(firestore: firestore);
}); 