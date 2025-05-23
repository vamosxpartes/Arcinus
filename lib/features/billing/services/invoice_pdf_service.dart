import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:arcinus/features/billing/data/models/invoice_model.dart';
import 'package:arcinus/features/billing/data/models/billing_config_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Servicio para generar facturas en formato PDF
class InvoicePdfService {
  /// Genera un PDF a partir de los datos de una factura
  /// 
  /// [invoice] Datos de la factura
  /// [billingConfig] Configuración de facturación de la academia
  /// [logoBytes] Bytes del logo (opcional)
  Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required BillingConfigModel billingConfig,
    Uint8List? logoBytes,
  }) async {
    try {
      AppLogger.logInfo(
        'Generando PDF de factura',
        className: 'InvoicePdfService',
        functionName: 'generateInvoicePdf',
        params: {
          'invoiceNumber': invoice.invoiceNumber,
          'clientName': invoice.clientName,
          'total': invoice.total,
        },
      );
      
      // Crear documento PDF
      final pdf = pw.Document();
      
      // Definir estilos usando fuentes por defecto del sistema
      final headerStyle = pw.TextStyle(
        fontSize: 14, 
        fontWeight: pw.FontWeight.bold
      );
      
      final normalStyle = pw.TextStyle(
        fontSize: 10
      );
      
      final boldStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold
      );
      
      // Añadir página
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                _buildHeader(billingConfig, logoBytes, headerStyle, normalStyle, boldStyle),
                pw.SizedBox(height: 20),
                
                // Información de factura
                _buildInvoiceInfo(invoice, headerStyle, normalStyle, boldStyle),
                pw.SizedBox(height: 20),
                
                // Información del cliente
                _buildClientInfo(invoice, headerStyle, normalStyle, boldStyle),
                pw.SizedBox(height: 20),
                
                // Tabla de items
                _buildItemsTable(invoice, headerStyle, normalStyle, boldStyle),
                pw.SizedBox(height: 20),
                
                // Totales
                _buildTotals(invoice, headerStyle, normalStyle, boldStyle),
                pw.SizedBox(height: 20),
                
                // Pie de página
                _buildFooter(billingConfig, invoice, normalStyle, boldStyle),
              ],
            );
          },
        ),
      );
      
      final pdfBytes = await pdf.save();
      
      AppLogger.logInfo(
        'PDF generado exitosamente',
        className: 'InvoicePdfService',
        functionName: 'generateInvoicePdf',
        params: {
          'pdfSize': '${pdfBytes.length} bytes',
        },
      );
      
      return pdfBytes;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al generar PDF de factura',
        error: e,
        stackTrace: s,
        className: 'InvoicePdfService',
        functionName: 'generateInvoicePdf',
      );
      rethrow;
    }
  }
  
  /// Construye el encabezado del PDF con el logo y la información de la empresa
  pw.Widget _buildHeader(BillingConfigModel config, Uint8List? logoBytes, pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    final hasLogo = logoBytes != null && logoBytes.isNotEmpty;
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Logo e información de la empresa
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (hasLogo)
                pw.Container(
                  height: 80,
                  width: 180,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              pw.Text(
                _sanitizeText(config.legalName),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'NIT: ${config.nit}-${config.nitDv}',
                style: normalStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                config.address,
                style: normalStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${config.city}, ${config.state}',
                style: normalStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Tel: ${config.phone}',
                style: normalStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Email: ${config.email}',
                style: normalStyle,
              ),
            ],
          ),
        ),
        
        // Información de la factura
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FACTURA ELECTRÓNICA',
                  style: boldStyle,
                ),
                pw.SizedBox(height: 5),
                                 pw.Text(
                   'No. ${config.invoicePrefix}-${config.currentConsecutive.toString().padLeft(6, '0')}',
                   style: boldStyle,
                 ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Resolución DIAN:',
                  style: normalStyle,
                ),
                pw.Text(
                  config.invoiceResolution,
                  style: normalStyle,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Fecha Resolución: ${config.resolutionDate != null ? DateFormat('dd/MM/yyyy').format(config.resolutionDate!) : ""}',
                  style: normalStyle,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Rango: ${config.resolutionRangeFrom} - ${config.resolutionRangeTo}',
                  style: normalStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Construye la sección de información de la factura
  pw.Widget _buildInvoiceInfo(InvoiceModel invoice, pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fecha de emisión:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(invoice.issueDate),
                  style: normalStyle,
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fecha de vencimiento:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(invoice.dueDate),
                  style: normalStyle,
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Estado:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Text(
                  invoice.status.displayName,
                  style: normalStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye la sección de información del cliente
  pw.Widget _buildClientInfo(InvoiceModel invoice, pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL CLIENTE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nombre/Razón Social:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      _sanitizeText(invoice.clientName),
                      style: normalStyle,
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Documento:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      invoice.clientDocument,
                      style: normalStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Dirección:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      invoice.clientAddress,
                      style: normalStyle,
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Teléfono:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      invoice.clientPhone,
                      style: normalStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Email:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.Text(
                      invoice.clientEmail,
                      style: normalStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Construye la tabla de items de la factura
  pw.Widget _buildItemsTable(InvoiceModel invoice, pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    final headers = ['Descripción', 'Cantidad', 'Precio Unitario', 'IVA', 'Subtotal'];
    
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Cabecera de la tabla
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: List.generate(
            headers.length,
            (index) => pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: index == 0 
                ? pw.Alignment.centerLeft 
                : pw.Alignment.center,
              child: pw.Text(
                headers[index],
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        
        // Filas de items
        ...invoice.items.map((item) {
          final subtotal = item.quantity * item.unitPrice;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  _sanitizeText(item.description),
                  style: normalStyle,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  item.quantity.toString(),
                  textAlign: pw.TextAlign.center,
                  style: normalStyle,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  formatCurrency(item.unitPrice),
                  textAlign: pw.TextAlign.right,
                  style: normalStyle,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${item.vat}%',
                  textAlign: pw.TextAlign.center,
                  style: normalStyle,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  formatCurrency(subtotal),
                  textAlign: pw.TextAlign.right,
                  style: normalStyle,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
  
  /// Construye la sección de totales de la factura
  pw.Widget _buildTotals(InvoiceModel invoice, pw.TextStyle headerStyle, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(width: 0.5),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text(
                    formatCurrency(invoice.subtotal),
                    style: normalStyle,
                  ),
                ],
              ),
            ),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(4),
                  bottomRight: pw.Radius.circular(4),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'IVA:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text(
                    formatCurrency(invoice.vatTotal),
                    style: normalStyle,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(width: 0.5),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.Text(
                    formatCurrency(invoice.total),
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construye el pie de página de la factura
  pw.Widget _buildFooter(BillingConfigModel config, InvoiceModel invoice, pw.TextStyle normalStyle, pw.TextStyle boldStyle) {
    String notes = invoice.notes.isNotEmpty 
        ? invoice.notes 
        : config.additionalNotes;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (notes.isNotEmpty) ...[
          pw.Text(
            'Notas:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.Text(
            notes,
            style: normalStyle,
          ),
          pw.SizedBox(height: 15),
        ],
        
        if (config.bankName.isNotEmpty) ...[
          pw.Text(
            'Información Bancaria:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.Text(
            'Banco: ${config.bankName}',
            style: normalStyle,
          ),
          pw.Text(
            'Tipo de Cuenta: ${config.accountType}',
            style: normalStyle,
          ),
          pw.Text(
            'Número: ${config.accountNumber}',
            style: normalStyle,
          ),
          pw.Text(
            'Titular: ${config.accountHolder}',
            style: normalStyle,
          ),
          pw.SizedBox(height: 15),
        ],
        
        pw.Text(
          'Esta factura es un título valor según el artículo 774 del código de comercio',
          style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
          textAlign: pw.TextAlign.center,
        ),
        
        if (invoice.cufe.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'CUFE: ${invoice.cufe}',
            style: normalStyle,
          ),
        ],
        
        pw.SizedBox(height: 20),
        
        pw.Divider(),
        pw.SizedBox(height: 5),
        pw.Text(
          'Factura generada por Arcinus - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: normalStyle,
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
  
  // Método para formatear moneda en pesos colombianos
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Sanitiza el texto para evitar problemas de codificación UTF-8 en PDF
  String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    
    try {
      // Asegurar que el texto sea válido UTF-8
      final bytes = text.codeUnits;
      final validText = String.fromCharCodes(bytes);
      return validText;
    } catch (e) {
      AppLogger.logWarning(
        'Problema de codificación detectado en texto: $text',
        className: 'InvoicePdfService',
        functionName: '_sanitizeText',
      );
      
      // Fallback: limpiar caracteres problemáticos
      return text
          .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // Remover caracteres no ASCII si es necesario
          .replaceAll(RegExp(r'\x00'), ''); // Remover caracteres nulos
    }
  }
} 