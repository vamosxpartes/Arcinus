import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'billing_config_model.freezed.dart';
part 'billing_config_model.g.dart';

/// Modelo que representa la configuración de facturación de una academia
@freezed
class BillingConfigModel with _$BillingConfigModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory BillingConfigModel({
    @JsonKey(includeFromJson: true, includeToJson: false) String? id,
    required String academyId,
    
    /// Nombre legal de la empresa para facturación
    required String legalName,
    
    /// NIT de la empresa
    required String nit,
    
    /// Dígito de verificación del NIT
    required String nitDv,
    
    /// Dirección fiscal
    required String address,
    
    /// Ciudad
    required String city,
    
    /// Departamento
    required String state,
    
    /// Teléfono de contacto
    required String phone,
    
    /// Email de contacto para facturación
    required String email,
    
    /// Régimen tributario (Ordinario, Simple)
    @Default('Ordinario') String taxRegime,
    
    /// Responsabilidad fiscal según DIAN
    @Default('Responsable de IVA') String fiscalResponsibility,
    
    /// URL del logo para facturas
    @Default('') String logoUrl,
    
    /// Resolución de facturación DIAN
    @Default('') String invoiceResolution,
    
    /// Fecha de resolución DIAN
    DateTime? resolutionDate,
    
    /// Rango desde de la resolución
    @Default(0) int resolutionRangeFrom,
    
    /// Rango hasta de la resolución
    @Default(0) int resolutionRangeTo,
    
    /// Prefijo de factura
    @Default('') String invoicePrefix,
    
    /// Consecutivo actual
    @Default(1) int currentConsecutive,
    
    /// Nombre del banco
    @Default('') String bankName,
    
    /// Tipo de cuenta (Ahorros, Corriente)
    @Default('') String accountType,
    
    /// Número de cuenta
    @Default('') String accountNumber,
    
    /// Titular de la cuenta
    @Default('') String accountHolder,
    
    /// Notas adicionales para la factura
    @Default('') String additionalNotes,
    
    /// IVA predeterminado (19%, 5%, 0%)
    @Default(19) int defaultVAT,
    
    /// Fecha de creación
    DateTime? createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
  }) = _BillingConfigModel;

  /// Crea una instancia de [BillingConfigModel] a partir de un JSON
  factory BillingConfigModel.fromJson(Map<String, dynamic> json) =>
      _$BillingConfigModelFromJson(json);

  /// Constructor para crear una configuración predeterminada
  factory BillingConfigModel.defaultConfig({
    required String academyId,
    required String academyName,
    required String phone,
    required String email,
    required String address,
  }) {
    return BillingConfigModel(
      academyId: academyId,
      legalName: 'Academia $academyName',
      nit: '',
      nitDv: '',
      address: address,
      city: 'Bogotá',
      state: 'Cundinamarca',
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
  }
} 