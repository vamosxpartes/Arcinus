import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academy_billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/academy_billing/data/models/invoice_model.dart';

/// Repositorio para gestionar la facturación
abstract class BillingRepository {
  /// Obtiene la configuración de facturación de una academia
  Future<Either<Failure, BillingConfigModel>> getBillingConfig(String academyId);
  
  /// Guarda la configuración de facturación de una academia
  Future<Either<Failure, BillingConfigModel>> saveBillingConfig(BillingConfigModel config);
  
  /// Obtiene las facturas de una academia, con filtros opcionales
  Future<Either<Failure, List<InvoiceModel>>> getInvoicesByAcademy(
    String academyId, {
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });
  
  /// Obtiene las facturas de un cliente en una academia
  Future<Either<Failure, List<InvoiceModel>>> getInvoicesByClient(
    String academyId,
    String clientId,
  );
  
  /// Obtiene una factura por su ID
  Future<Either<Failure, InvoiceModel>> getInvoiceById(
    String academyId,
    String invoiceId,
  );
  
  /// Crea una nueva factura
  Future<Either<Failure, InvoiceModel>> createInvoice(InvoiceModel invoice);
  
  /// Actualiza una factura existente
  Future<Either<Failure, InvoiceModel>> updateInvoice(InvoiceModel invoice);
  
  /// Elimina una factura (marcándola como eliminada)
  Future<Either<Failure, void>> deleteInvoice(
    String academyId,
    String invoiceId,
  );
} 