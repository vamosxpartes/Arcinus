import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/billing/data/models/invoice_model.dart';
import 'package:arcinus/features/billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/billing/services/invoice_pdf_service.dart';
import 'package:arcinus/features/billing/services/invoice_xml_service.dart';
import 'package:arcinus/features/billing/services/share_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

/// Servicio para integrar facturas con pagos
class InvoicePaymentService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final InvoicePdfService _pdfService;
  final ShareService _shareService;
  
  /// Constructor
  InvoicePaymentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    InvoicePdfService? pdfService,
    InvoiceXmlService? xmlService,
    ShareService? shareService,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance,
    _pdfService = pdfService ?? InvoicePdfService(),
    _shareService = shareService ?? ShareService();
  
  /// Genera una factura a partir de un pago
  /// 
  /// [payment] El pago para el que se generará la factura
  /// [academyId] ID de la academia
  Future<Either<Failure, InvoiceModel>> generateInvoiceFromPayment({
    required PaymentModel payment,
    required BillingConfigModel billingConfig,
    Uint8List? logoBytes,
  }) async {
    try {
      AppLogger.logInfo(
        'Generando factura a partir de pago',
        className: 'InvoicePaymentService',
        functionName: 'generateInvoiceFromPayment',
        params: {
          'paymentId': payment.id,
          'athleteId': payment.athleteId,
          'amount': payment.amount,
        },
      );
      
      // Obtener información del cliente
      final athleteSnapshot = await _firestore
          .collection('academies')
          .doc(payment.academyId)
          .collection('athletes')
          .doc(payment.athleteId)
          .get();
          
      if (!athleteSnapshot.exists) {
        return left(const Failure.notFound(message: 'Atleta no encontrado'));
      }
      
      final athleteData = athleteSnapshot.data()!;
      
      // Obtener datos del atleta con conversiones de tipos seguras
      final athleteName = athleteData['name'] as String? ?? '';
      final athleteDocument = athleteData['document'] as String? ?? '';
      final athleteAddress = athleteData['address'] as String? ?? '';
      final athleteEmail = athleteData['email'] as String? ?? '';
      final athletePhone = athleteData['phone'] as String? ?? '';
      
      // Incrementar consecutivo de factura
      final updatedConfig = billingConfig.copyWith(
        currentConsecutive: billingConfig.currentConsecutive + 1,
        updatedAt: DateTime.now(),
      );
      
      // Guardar nuevo consecutivo
      await _firestore
          .collection('academies')
          .doc(payment.academyId)
          .collection('billing_config')
          .doc(billingConfig.id)
          .update({
        'currentConsecutive': updatedConfig.currentConsecutive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Crear número de factura con prefijo y consecutivo
      final invoiceNumber = billingConfig.invoicePrefix.isNotEmpty
          ? '${billingConfig.invoicePrefix}-${billingConfig.currentConsecutive.toString().padLeft(6, '0')}'
          : billingConfig.currentConsecutive.toString().padLeft(6, '0');
      
      // Crear ítem de factura a partir del concepto de pago
      final concept = payment.concept ?? 'Pago de mensualidad';
      final invoiceItem = InvoiceItemModel(
        description: concept,
        quantity: 1,
        unitPrice: payment.amount,
        vat: billingConfig.defaultVAT,
      );
      
      // Calcular montos
      final subtotal = payment.amount;
      final vatAmount = payment.amount * billingConfig.defaultVAT / 100;
      final total = subtotal + vatAmount;
      
      // Crear modelo de factura
      final invoice = InvoiceModel(
        academyId: payment.academyId,
        clientId: payment.athleteId,
        clientName: athleteName,
        clientDocument: athleteDocument,
        clientAddress: athleteAddress,
        clientEmail: athleteEmail,
        clientPhone: athletePhone,
        invoiceNumber: invoiceNumber,
        consecutive: billingConfig.currentConsecutive,
        prefix: billingConfig.invoicePrefix,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [invoiceItem],
        notes: 'Factura generada automáticamente a partir del pago.',
        subtotal: subtotal,
        vatTotal: vatAmount,
        total: total,
        paymentId: payment.id,
        status: InvoiceStatus.paid,
        currency: payment.currency,
        createdBy: payment.registeredBy,
        createdAt: DateTime.now(),
      );
      
      // Generar PDF
      final pdfBytes = await _pdfService.generateInvoicePdf(
        invoice: invoice,
        billingConfig: billingConfig,
        logoBytes: logoBytes,
      );
            
      // Subir archivos a Firebase Storage
      final pdfUrl = await _uploadPdf(invoice, pdfBytes);
      
      // Actualizar factura con URLs
      final updatedInvoice = invoice.copyWith(
        pdfUrl: pdfUrl,
        updatedAt: DateTime.now(),
      );
      
      // Guardar factura en Firestore
      final docRef = _firestore
          .collection('academies')
          .doc(payment.academyId)
          .collection('invoices')
          .doc();
          
      await docRef.set({
        ...updatedInvoice.toJson(),
        'id': docRef.id,
      });
      
      // Actualizar pago con referencia a la factura
      await _firestore
          .collection('academies')
          .doc(payment.academyId)
          .collection('payments')
          .doc(payment.id)
          .update({
        'invoiceId': docRef.id,
      });
      
      return right(updatedInvoice.copyWith(id: docRef.id));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al generar factura a partir de pago',
        error: e,
        stackTrace: s,
        className: 'InvoicePaymentService',
        functionName: 'generateInvoiceFromPayment',
      );
      return left(Failure.serverError(message: e.toString()));
    }
  }
  
  /// Sube un PDF de factura a Firebase Storage
  Future<String> _uploadPdf(InvoiceModel invoice, Uint8List pdfBytes) async {
    try {
      // Generar nombre de archivo con fecha para evitar colisiones
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'invoice_${invoice.invoiceNumber}_$timestamp.pdf';
      final path = 'academies/${invoice.academyId}/invoices/$fileName';
      
      // Referencia al archivo en Storage
      final ref = _storage.ref().child(path);
      
      // Subir archivo
      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      
      // Obtener URL de descarga
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al subir PDF de factura',
        error: e,
        stackTrace: s,
        className: 'InvoicePaymentService',
        functionName: '_uploadPdf',
      );
      rethrow;
    }
  }
    
  /// Comparte una factura por correo electrónico
  Future<Either<Failure, bool>> shareInvoice({
    required InvoiceModel invoice,
    required BillingConfigModel billingConfig,
    Uint8List? logoBytes,
  }) async {
    try {
      // Si la factura ya tiene URL de PDF, usarla; de lo contrario, generar PDF
      Uint8List? pdfBytes;
      String pdfUrl = invoice.pdfUrl;
      
      if (pdfUrl.isEmpty) {
        // Generar PDF
        pdfBytes = await _pdfService.generateInvoicePdf(
          invoice: invoice,
          billingConfig: billingConfig,
          logoBytes: logoBytes,
        );
        
        // Subir a Storage
        pdfUrl = await _uploadPdf(invoice, pdfBytes);
        
        // Actualizar factura en Firestore
        await _firestore
            .collection('academies')
            .doc(invoice.academyId)
            .collection('invoices')
            .doc(invoice.id)
            .update({'pdfUrl': pdfUrl});
      }
      
      // Compartir PDF
      if (pdfBytes != null) {
        // Si tenemos los bytes, compartir directamente el PDF
        await _shareService.sharePdf(
          pdfBytes: pdfBytes,
          fileName: 'Factura_${invoice.invoiceNumber}.pdf',
          subject: 'Factura ${invoice.invoiceNumber} - ${invoice.clientName}',
        );
      } else {
        // Si sólo tenemos la URL, compartir enlace
        await _shareService.shareUrl(
          url: pdfUrl,
          subject: 'Factura ${invoice.invoiceNumber} - ${invoice.clientName}',
        );
      }
      
      // Consideramos éxito si llegamos hasta aquí
      final success = true;
      
      return right(success);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al compartir factura',
        error: e,
        stackTrace: s,
        className: 'InvoicePaymentService',
        functionName: 'shareInvoice',
      );
      return left(Failure.serverError(message: e.toString()));
    }
  }
  
} 