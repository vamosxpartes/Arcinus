import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

/// Modelo que representa un ítem de factura
@freezed
class InvoiceItemModel with _$InvoiceItemModel {
  const factory InvoiceItemModel({
    required String description,
    required int quantity,
    required double unitPrice,
    @Default(19) int vat, // IVA en porcentaje (19%, 5%, 0%)
    double? discount,
  }) = _InvoiceItemModel;

  /// Crea una instancia de [InvoiceItemModel] a partir de un JSON
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemModelFromJson(json);
}

/// Estado de la factura
enum InvoiceStatus {
  /// Borrador (no emitida)
  draft,
  
  /// Emitida (pendiente de pago)
  issued,
  
  /// Pagada (completamente)
  paid,
  
  /// Vencida (no pagada en fecha)
  overdue,
  
  /// Anulada
  cancelled,
}

/// Extensión para obtener nombre amigable del estado
extension InvoiceStatusExtension on InvoiceStatus {
  String toJson() => name;
  
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Borrador';
      case InvoiceStatus.issued:
        return 'Emitida';
      case InvoiceStatus.paid:
        return 'Pagada';
      case InvoiceStatus.overdue:
        return 'Vencida';
      case InvoiceStatus.cancelled:
        return 'Anulada';
    }
  }
}

/// Modelo que representa una factura
@freezed
class InvoiceModel with _$InvoiceModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory InvoiceModel({
    @JsonKey(includeFromJson: true, includeToJson: false) String? id,
    required String academyId,
    
    /// Número completo de factura (con prefijo)
    required String invoiceNumber,
    
    /// Número consecutivo (sin prefijo)
    required int consecutive,
    
    /// Prefijo utilizado
    required String prefix,
    
    /// ID del cliente (atleta)
    required String clientId,
    
    /// Nombre del cliente
    required String clientName,
    
    /// Documento del cliente (cédula, etc)
    @Default('') String clientDocument,
    
    /// Dirección del cliente
    @Default('') String clientAddress,
    
    /// Email del cliente
    @Default('') String clientEmail,
    
    /// Teléfono del cliente
    @Default('') String clientPhone,
    
    /// Fecha de emisión
    required DateTime issueDate,
    
    /// Fecha de vencimiento
    required DateTime dueDate,
    
    /// Ítems de la factura
    required List<InvoiceItemModel> items,
    
    /// Notas o términos
    @Default('') String notes,
    
    /// CUFE (Código Único de Facturación Electrónica) si aplica
    @Default('') String cufe,
    
    /// Estado de la factura
    @Default(InvoiceStatus.draft) InvoiceStatus status,
    
    /// ID del pago asociado (si existe)
    String? paymentId,
    
    /// URL del PDF generado
    @Default('') String pdfUrl,
    
    /// Subtotal (antes de impuestos)
    required double subtotal,
    
    /// Total IVA
    required double vatTotal,
    
    /// Total de la factura
    required double total,
    
    /// Moneda (COP por defecto)
    @Default('COP') String currency,
    
    /// Usuario que creó la factura
    String? createdBy,
    
    /// Fecha de creación
    DateTime? createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
    
    /// Indica si la factura ha sido eliminada
    @Default(false) bool isDeleted,
  }) = _InvoiceModel;

  /// Crea una instancia de [InvoiceModel] a partir de un JSON
  factory InvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceModelFromJson(json);
} 