import 'package:arcinus/features/super_admin/data/models/owner_data_model.dart';
import 'package:arcinus/features/super_admin/presentation/providers/owners_management_provider.dart';

/// Adapter para convertir entre modelos de datos y modelos de UI
class OwnerDataAdapter {
  
  /// Convierte OwnerDataModel a OwnerData (para UI)
  static OwnerData toOwnerData(
    OwnerDataModel ownerModel,
    AcademyBasicInfoModel? academy,
    OwnerMetricsModel metrics,
  ) {
    return OwnerData(
      id: ownerModel.id,
      firstName: ownerModel.firstName,
      lastName: ownerModel.lastName,
      email: ownerModel.email,
      phoneNumber: ownerModel.phoneNumber,
      profileImageUrl: ownerModel.photoUrl,
      status: _mapOwnerStatus(ownerModel.status),
      createdAt: ownerModel.createdAt ?? DateTime.now(),
      lastLoginAt: ownerModel.lastLoginAt,
      academy: academy != null ? _toAcademyBasicInfo(academy) : null,
      totalUsers: metrics.totalUsers,
      activeUsers: metrics.activeUsers,
      monthlyRevenue: metrics.monthlyRevenue,
      lastActivityAt: metrics.lastActivityAt,
    );
  }

  /// Convierte múltiples OwnerDataModel a lista de OwnerData
  static Future<List<OwnerData>> toOwnerDataList(
    List<OwnerDataModel> ownerModels,
    Map<String, List<AcademyBasicInfoModel>> ownersAcademies,
    Map<String, OwnerMetricsModel> ownersMetrics,
  ) async {
    final result = <OwnerData>[];

    for (final ownerModel in ownerModels) {
      final academies = ownersAcademies[ownerModel.id] ?? [];
      final academy = academies.isNotEmpty ? academies.first : null;
      final metrics = ownersMetrics[ownerModel.id] ?? const OwnerMetricsModel();

      final ownerData = toOwnerData(ownerModel, academy, metrics);
      result.add(ownerData);
    }

    return result;
  }

  /// Mapea OwnerStatusModel a OwnerStatus
  static OwnerStatus _mapOwnerStatus(OwnerStatusModel status) {
    switch (status) {
      case OwnerStatusModel.active:
        return OwnerStatus.active;
      case OwnerStatusModel.inactive:
        return OwnerStatus.inactive;
      case OwnerStatusModel.suspended:
        return OwnerStatus.suspended;
      case OwnerStatusModel.pending:
        return OwnerStatus.pending;
    }
  }

  /// Mapea OwnerStatus a OwnerStatusModel
  static OwnerStatusModel mapOwnerStatusToModel(OwnerStatus status) {
    switch (status) {
      case OwnerStatus.active:
        return OwnerStatusModel.active;
      case OwnerStatus.inactive:
        return OwnerStatusModel.inactive;
      case OwnerStatus.suspended:
        return OwnerStatusModel.suspended;
      case OwnerStatus.pending:
        return OwnerStatusModel.pending;
    }
  }

  /// Convierte AcademyBasicInfoModel a AcademyBasicInfo
  static AcademyBasicInfo _toAcademyBasicInfo(AcademyBasicInfoModel model) {
    return AcademyBasicInfo(
      id: model.id,
      name: model.name,
      logoUrl: model.logoUrl,
      sport: model.sportCode,
      country: 'Colombia', // Default - esto se podría mejorar
      city: model.location.isNotEmpty ? model.location : 'Sin ubicación',
      status: _mapAcademyStatus(model.status),
    );
  }

  /// Mapea AcademyStatusModel a AcademyStatus
  static AcademyStatus _mapAcademyStatus(AcademyStatusModel status) {
    switch (status) {
      case AcademyStatusModel.active:
        return AcademyStatus.active;
      case AcademyStatusModel.inactive:
        return AcademyStatus.inactive;
      case AcademyStatusModel.suspended:
        return AcademyStatus.suspended;
    }
  }
} 