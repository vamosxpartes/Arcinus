import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:crypto/crypto.dart';
import 'package:arcinus/features/academy_billing/data/models/invoice_model.dart';
import 'package:arcinus/features/academy_billing/data/models/billing_config_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Servicio para generar XML de facturación electrónica según estándares DIAN
class InvoiceXmlService {
  /// Genera un XML para factura electrónica con el estándar UBL 2.1 de la DIAN
  /// 
  /// [invoice] Datos de la factura
  /// [billingConfig] Configuración de facturación de la academia
  Future<String> generateInvoiceXml({
    required InvoiceModel invoice,
    required BillingConfigModel billingConfig,
  }) async {
    try {
      AppLogger.logInfo(
        'Generando XML de factura electrónica',
        className: 'InvoiceXmlService',
        functionName: 'generateInvoiceXml',
        params: {
          'invoiceNumber': invoice.invoiceNumber,
          'clientName': invoice.clientName,
          'total': invoice.total,
        },
      );
      
      // Crear builder XML
      final builder = XmlBuilder();
      
      // Generar CUFE si no existe
      final cufeValue = invoice.cufe.isNotEmpty 
          ? invoice.cufe 
          : _generateCUFE(invoice, billingConfig);
      
      // Crear elemento raíz con namespaces UBL 2.1
      builder.declaration(
        version: '1.0',
        encoding: 'UTF-8',
      );
      
      builder.element('Invoice', nest: () {
        // Añadir namespaces según UBL 2.1 y DIAN
        builder.namespace('urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', '');
        builder.namespace('urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', 'cbc');
        builder.namespace('urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', 'cac');
        builder.namespace('urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2', 'ext');
        builder.namespace('http://www.dian.gov.co/contratos/facturaelectronica/v1', 'sts');
        
        // UBL Extensions (requerido por DIAN)
        _buildUBLExtensions(builder, cufeValue, invoice, billingConfig);
        
        // Componentes básicos requeridos
        _buildBasicComponents(builder, invoice, billingConfig);
        
        // Información del proveedor (academia)
        _buildSupplierParty(builder, billingConfig);
        
        // Información del cliente
        _buildCustomerParty(builder, invoice);
        
        // Información de entrega
        _buildDelivery(builder, invoice);
        
        // Información de pago
        _buildPaymentMeans(builder, billingConfig);
        
        // Información tributaria
        _buildTaxTotal(builder, invoice);
        
        // Información de montos legales
        _buildLegalMonetaryTotal(builder, invoice);
        
        // Líneas de factura (ítems)
        _buildInvoiceLines(builder, invoice);
      });
      
      // Generar documento XML formateado
      final document = builder.buildDocument();
      final formattedXml = document.toXmlString(pretty: true, indent: '  ');
      
      return formattedXml;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al generar XML de factura electrónica',
        error: e,
        stackTrace: s,
        className: 'InvoiceXmlService',
        functionName: 'generateInvoiceXml',
      );
      rethrow;
    }
  }
  
  /// Genera el CUFE (Código Único de Facturación Electrónica)
  /// 
  /// El CUFE es un hash SHA-384 de la concatenación de datos clave de la factura
  String _generateCUFE(InvoiceModel invoice, BillingConfigModel config) {
    // Formato fecha DIAN: AñoMesDia (AAAAMMDD)
    final issueDateFormatted = DateFormat('yyyyMMdd').format(invoice.issueDate);
    final issueTimeFormatted = DateFormat('HHmmss').format(invoice.issueDate);
    
    // Convertir montos a string con 2 decimales sin separadores
    final invoiceAmountStr = invoice.total.toStringAsFixed(2).replaceAll('.', '');
    final vatAmountStr = invoice.vatTotal.toStringAsFixed(2).replaceAll('.', '');
    
    // Concatenar valores según especificación DIAN
    final cufeInput = invoice.invoiceNumber +
        issueDateFormatted +
        issueTimeFormatted +
        invoiceAmountStr +
        vatAmountStr +
        config.nit +
        invoice.clientDocument +
        config.invoiceResolution;
    
    // Generar hash SHA-384
    final cufeBytes = utf8.encode(cufeInput);
    final cufeDigest = sha384.convert(cufeBytes);
    
    return cufeDigest.toString();
  }
  
  /// Construye las extensiones UBL requeridas por DIAN
  void _buildUBLExtensions(
    XmlBuilder builder,
    String cufe,
    InvoiceModel invoice,
    BillingConfigModel config,
  ) {
    builder.element('ext:UBLExtensions', nest: () {
      builder.element('ext:UBLExtension', nest: () {
        builder.element('ext:ExtensionContent', nest: () {
          builder.element('sts:DianExtensions', nest: () {
            builder.element('sts:InvoiceControl', nest: () {
              builder.element('sts:InvoiceAuthorization', nest: config.invoiceResolution);
              builder.element('sts:AuthorizationPeriod', nest: () {
                builder.element('cbc:StartDate', nest: config.resolutionDate != null 
                  ? DateFormat('yyyy-MM-dd').format(config.resolutionDate!) 
                  : DateFormat('yyyy-MM-dd').format(DateTime.now()));
                // Fecha fin típicamente es un año después
                final endDate = config.resolutionDate != null 
                  ? DateTime(config.resolutionDate!.year + 1, config.resolutionDate!.month, config.resolutionDate!.day)
                  : DateTime.now().add(const Duration(days: 365));
                builder.element('cbc:EndDate', nest: DateFormat('yyyy-MM-dd').format(endDate));
              });
              builder.element('sts:AuthorizedInvoices', nest: () {
                builder.element('sts:Prefix', nest: config.invoicePrefix);
                builder.element('sts:From', nest: config.resolutionRangeFrom.toString());
                builder.element('sts:To', nest: config.resolutionRangeTo.toString());
              });
            });
            builder.element('sts:InvoiceSource', nest: () {
              builder.element('cbc:IdentificationCode', nest: 'CO');
            });
            builder.element('sts:SoftwareProvider', nest: () {
              builder.element('sts:ProviderID', nest: '900800225');
              builder.element('sts:SoftwareID', nest: 'ArcInvoice1.0');
            });
            builder.element('sts:SoftwareSecurityCode', nest: 'Arcinus1234567890');
            builder.element('sts:AuthorizationProvider', nest: () {
              builder.element('sts:AuthorizationProviderID', nest: '800197268');
            });
            builder.element('sts:QRCode', nest: 'https://factura-electronica.dian.gov.co/document/check?cufe=$cufe');
          });
        });
      });
    });
  }
  
  /// Construye los componentes básicos de la factura
  void _buildBasicComponents(
    XmlBuilder builder,
    InvoiceModel invoice,
    BillingConfigModel config,
  ) {
    final issueDate = DateFormat('yyyy-MM-dd').format(invoice.issueDate);
    final issueTime = DateFormat('HH:mm:ss').format(invoice.issueDate);
    final dueDate = DateFormat('yyyy-MM-dd').format(invoice.dueDate);
    
    builder.element('cbc:UBLVersionID', nest: '2.1');
    builder.element('cbc:CustomizationID', nest: '05');
    builder.element('cbc:ProfileID', nest: 'DIAN 2.1');
    builder.element('cbc:ProfileExecutionID', nest: '1');
    builder.element('cbc:ID', nest: invoice.invoiceNumber);
    builder.element('cbc:UUID', nest: () {
      builder.attribute('schemeID', '1');
      builder.attribute('schemeName', 'CUFE-SHA384');
      builder.text(invoice.cufe.isNotEmpty ? invoice.cufe : '');
    });
    builder.element('cbc:IssueDate', nest: issueDate);
    builder.element('cbc:IssueTime', nest: issueTime);
    builder.element('cbc:DueDate', nest: dueDate);
    builder.element('cbc:InvoiceTypeCode', nest: '01'); // 01 = Factura de venta
    builder.element('cbc:Note', nest: invoice.notes);
    builder.element('cbc:DocumentCurrencyCode', nest: invoice.currency);
    builder.element('cbc:LineCountNumeric', nest: invoice.items.length.toString());
  }
  
  /// Construye la información del proveedor (academia)
  void _buildSupplierParty(XmlBuilder builder, BillingConfigModel config) {
    builder.element('cac:AccountingSupplierParty', nest: () {
      builder.element('cbc:AdditionalAccountID', nest: '1'); // 1 = Persona jurídica
      builder.element('cac:Party', nest: () {
        // Ubicación
        builder.element('cac:PartyLocation', nest: () {
          builder.element('cac:Address', nest: () {
            builder.element('cbc:ID', nest: '11001'); // Código DANE Bogotá
            builder.element('cbc:CityName', nest: config.city);
            builder.element('cbc:CountrySubentity', nest: config.state);
            builder.element('cbc:CountrySubentityCode', nest: '11'); // Código DANE Bogotá
            builder.element('cac:AddressLine', nest: () {
              builder.element('cbc:Line', nest: config.address);
            });
            builder.element('cac:Country', nest: () {
              builder.element('cbc:IdentificationCode', nest: 'CO');
              builder.element('cbc:Name', nest: 'Colombia');
            });
          });
        });
        
        // Información tributaria
        builder.element('cac:PartyTaxScheme', nest: () {
          builder.element('cbc:RegistrationName', nest: config.legalName);
          builder.element('cbc:CompanyID', nest: () {
            builder.attribute('schemeID', config.nitDv);
            builder.attribute('schemeName', '31');
            builder.attribute('schemeAgencyID', '195');
            builder.attribute('schemeAgencyName', 'CO, DIAN (Dirección de Impuestos y Aduanas Nacionales)');
            builder.text(config.nit);
          });
          builder.element('cbc:TaxLevelCode', nest: () {
            builder.attribute('listName', 'No aplica');
            builder.text(config.fiscalResponsibility.isNotEmpty ? config.fiscalResponsibility : 'O-13');
          });
          builder.element('cac:RegistrationAddress', nest: () {
            builder.element('cbc:ID', nest: '11001');
            builder.element('cbc:CityName', nest: config.city);
            builder.element('cbc:CountrySubentity', nest: config.state);
            builder.element('cbc:CountrySubentityCode', nest: '11');
            builder.element('cac:AddressLine', nest: () {
              builder.element('cbc:Line', nest: config.address);
            });
            builder.element('cac:Country', nest: () {
              builder.element('cbc:IdentificationCode', nest: 'CO');
              builder.element('cbc:Name', nest: () {
                builder.attribute('languageID', 'es');
                builder.text('Colombia');
              });
            });
          });
          builder.element('cac:TaxScheme', nest: () {
            builder.element('cbc:ID', nest: '01');
            builder.element('cbc:Name', nest: 'IVA');
          });
        });
        
        // Información legal
        builder.element('cac:PartyLegalEntity', nest: () {
          builder.element('cbc:RegistrationName', nest: config.legalName);
          builder.element('cbc:CompanyID', nest: () {
            builder.attribute('schemeID', config.nitDv);
            builder.attribute('schemeName', '31');
            builder.attribute('schemeAgencyID', '195');
            builder.attribute('schemeAgencyName', 'CO, DIAN (Dirección de Impuestos y Aduanas Nacionales)');
            builder.text(config.nit);
          });
          builder.element('cac:CorporateRegistrationScheme', nest: () {
            builder.element('cbc:ID', nest: config.invoicePrefix);
          });
        });
        
        // Información de contacto
        builder.element('cac:Contact', nest: () {
          builder.element('cbc:ElectronicMail', nest: config.email);
        });
      });
    });
  }
  
  /// Construye la información del cliente
  void _buildCustomerParty(XmlBuilder builder, InvoiceModel invoice) {
    builder.element('cac:AccountingCustomerParty', nest: () {
      builder.element('cbc:AdditionalAccountID', nest: '1'); // 1 = Persona Jurídica, 2 = Persona Natural
      builder.element('cac:Party', nest: () {
        builder.element('cac:PartyIdentification', nest: () {
          builder.element('cbc:ID', nest: () {
            builder.attribute('schemeID', '3');
            builder.attribute('schemeName', '13');
            builder.attribute('schemeAgencyID', '195');
            builder.attribute('schemeAgencyName', 'CO, DIAN (Dirección de Impuestos y Aduanas Nacionales)');
            builder.text(invoice.clientDocument);
          });
        });
        builder.element('cac:PartyName', nest: () {
          builder.element('cbc:Name', nest: invoice.clientName);
        });
        builder.element('cac:PhysicalLocation', nest: () {
          builder.element('cac:Address', nest: () {
            builder.element('cbc:ID', nest: '11001');
            builder.element('cbc:CityName', nest: 'BOGOTÁ');
            builder.element('cbc:CountrySubentity', nest: 'Bogotá');
            builder.element('cbc:CountrySubentityCode', nest: '11');
            builder.element('cac:AddressLine', nest: () {
              builder.element('cbc:Line', nest: invoice.clientAddress);
            });
            builder.element('cac:Country', nest: () {
              builder.element('cbc:IdentificationCode', nest: 'CO');
              builder.element('cbc:Name', nest: () {
                builder.attribute('languageID', 'es');
                builder.text('Colombia');
              });
            });
          });
        });
        builder.element('cac:PartyTaxScheme', nest: () {
          builder.element('cbc:RegistrationName', nest: invoice.clientName);
          builder.element('cbc:CompanyID', nest: () {
            builder.attribute('schemeID', '3');
            builder.attribute('schemeName', '13');
            builder.attribute('schemeAgencyID', '195');
            builder.attribute('schemeAgencyName', 'CO, DIAN (Dirección de Impuestos y Aduanas Nacionales)');
            builder.text(invoice.clientDocument);
          });
          builder.element('cbc:TaxLevelCode', nest: 'R-99-PN');
          builder.element('cac:TaxScheme', nest: () {
            builder.element('cbc:ID', nest: '01');
            builder.element('cbc:Name', nest: 'IVA');
          });
        });
        builder.element('cac:PartyLegalEntity', nest: () {
          builder.element('cbc:RegistrationName', nest: invoice.clientName);
          builder.element('cbc:CompanyID', nest: () {
            builder.attribute('schemeID', '3');
            builder.attribute('schemeName', '13');
            builder.attribute('schemeAgencyID', '195');
            builder.attribute('schemeAgencyName', 'CO, DIAN (Dirección de Impuestos y Aduanas Nacionales)');
            builder.text(invoice.clientDocument);
          });
        });
        builder.element('cac:Contact', nest: () {
          builder.element('cbc:Telephone', nest: invoice.clientPhone);
          builder.element('cbc:ElectronicMail', nest: invoice.clientEmail);
        });
        builder.element('cac:Person', nest: () {
          final nameParts = invoice.clientName.split(' ');
          if (nameParts.length >= 4) {
            builder.element('cbc:FirstName', nest: '${nameParts[0]} ${nameParts[1]}');
            builder.element('cbc:FamilyName', nest: '${nameParts[2]} ${nameParts[3]}');
          } else if (nameParts.length >= 3) {
            builder.element('cbc:FirstName', nest: nameParts[0]);
            builder.element('cbc:FamilyName', nest: '${nameParts[1]} ${nameParts[2]}');
          } else if (nameParts.length >= 2) {
            builder.element('cbc:FirstName', nest: nameParts[0]);
            builder.element('cbc:FamilyName', nest: nameParts[1]);
          } else {
            builder.element('cbc:FirstName', nest: invoice.clientName);
            builder.element('cbc:FamilyName', nest: '');
          }
        });
      });
    });
  }
  
  /// Construye la información de entrega
  void _buildDelivery(XmlBuilder builder, InvoiceModel invoice) {
    builder.element('cac:Delivery', nest: () {
      builder.element('cac:DeliveryLocation', nest: () {
        builder.element('cac:Address', nest: () {
          builder.element('cbc:ID', nest: '11001');
          builder.element('cbc:CityName', nest: 'BOGOTÁ');
          builder.element('cbc:CountrySubentity', nest: 'Bogotá');
          builder.element('cbc:CountrySubentityCode', nest: '11');
          builder.element('cac:AddressLine', nest: () {
            builder.element('cbc:Line', nest: invoice.clientAddress);
          });
          builder.element('cac:Country', nest: () {
            builder.element('cbc:IdentificationCode', nest: 'CO');
            builder.element('cbc:Name', nest: () {
              builder.attribute('languageID', 'es');
              builder.text('Colombia');
            });
          });
        });
      });
    });
  }
  
  /// Construye la información de pago
  void _buildPaymentMeans(XmlBuilder builder, BillingConfigModel config) {
    builder.element('cac:PaymentMeans', nest: () {
      builder.element('cbc:ID', nest: '1');
      builder.element('cbc:PaymentMeansCode', nest: '10'); // Efectivo
      builder.element('cbc:PaymentDueDate', nest: () {
        // Usar fecha de vencimiento +30 días típicamente
        final dueDate = DateTime.now().add(const Duration(days: 30));
        builder.text(DateFormat('yyyy-MM-dd').format(dueDate));
      });
      builder.element('cbc:PaymentID', nest: '1');
    });
  }
  
  /// Construye la información tributaria
  void _buildTaxTotal(XmlBuilder builder, InvoiceModel invoice) {
    // Agrupar por tasa de IVA
    final vatRates = <int, double>{};
    for (final item in invoice.items) {
      vatRates[item.vat] = (vatRates[item.vat] ?? 0) + 
          (item.unitPrice * item.quantity * item.vat / 100);
    }
    
    // Crear un TaxTotal para el total
    builder.element('cac:TaxTotal', nest: () {
      builder.element('cbc:TaxAmount', nest: () {
        builder.attribute('currencyID', invoice.currency);
        builder.text(invoice.vatTotal.toStringAsFixed(2));
      });
      
      // Subtotales por tasa de IVA
      vatRates.forEach((rate, amount) {
        final baseAmount = invoice.items
            .where((item) => item.vat == rate)
            .map((item) => item.unitPrice * item.quantity)
            .fold(0.0, (a, b) => a + b);
            
        builder.element('cac:TaxSubtotal', nest: () {
          builder.element('cbc:TaxableAmount', nest: () {
            builder.attribute('currencyID', invoice.currency);
            builder.text(baseAmount.toStringAsFixed(2));
          });
          builder.element('cbc:TaxAmount', nest: () {
            builder.attribute('currencyID', invoice.currency);
            builder.text(amount.toStringAsFixed(2));
          });
          builder.element('cac:TaxCategory', nest: () {
            builder.element('cbc:Percent', nest: rate.toString());
            builder.element('cac:TaxScheme', nest: () {
              builder.element('cbc:ID', nest: '01');
              builder.element('cbc:Name', nest: 'IVA');
            });
          });
        });
      });
    });
  }
  
  /// Construye la información de montos legales
  void _buildLegalMonetaryTotal(XmlBuilder builder, InvoiceModel invoice) {
    builder.element('cac:LegalMonetaryTotal', nest: () {
      builder.element('cbc:LineExtensionAmount', nest: () {
        builder.attribute('currencyID', invoice.currency);
        builder.text(invoice.subtotal.toStringAsFixed(2));
      });
      builder.element('cbc:TaxExclusiveAmount', nest: () {
        builder.attribute('currencyID', invoice.currency);
        builder.text(invoice.subtotal.toStringAsFixed(2));
      });
      builder.element('cbc:TaxInclusiveAmount', nest: () {
        builder.attribute('currencyID', invoice.currency);
        builder.text(invoice.total.toStringAsFixed(2));
      });
      builder.element('cbc:PayableAmount', nest: () {
        builder.attribute('currencyID', invoice.currency);
        builder.text(invoice.total.toStringAsFixed(2));
      });
    });
  }
  
  /// Construye las líneas de factura (ítems)
  void _buildInvoiceLines(XmlBuilder builder, InvoiceModel invoice) {
    for (var i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      final lineNumber = i + 1;
      
      builder.element('cac:InvoiceLine', nest: () {
        builder.element('cbc:ID', nest: lineNumber.toString());
        builder.element('cbc:InvoicedQuantity', nest: () {
          builder.attribute('unitCode', 'EA'); // Each (Unidad)
          builder.text(item.quantity.toString());
        });
        
        final lineExtensionAmount = item.quantity * item.unitPrice;
        builder.element('cbc:LineExtensionAmount', nest: () {
          builder.attribute('currencyID', invoice.currency);
          builder.text(lineExtensionAmount.toStringAsFixed(2));
        });
        
        // Información de impuestos por ítem
        builder.element('cac:TaxTotal', nest: () {
          final taxAmount = lineExtensionAmount * item.vat / 100;
          builder.element('cbc:TaxAmount', nest: () {
            builder.attribute('currencyID', invoice.currency);
            builder.text(taxAmount.toStringAsFixed(2));
          });
          
          builder.element('cac:TaxSubtotal', nest: () {
            builder.element('cbc:TaxableAmount', nest: () {
              builder.attribute('currencyID', invoice.currency);
              builder.text(lineExtensionAmount.toStringAsFixed(2));
            });
            builder.element('cbc:TaxAmount', nest: () {
              builder.attribute('currencyID', invoice.currency);
              builder.text(taxAmount.toStringAsFixed(2));
            });
            builder.element('cac:TaxCategory', nest: () {
              builder.element('cbc:Percent', nest: item.vat.toString());
              builder.element('cac:TaxScheme', nest: () {
                builder.element('cbc:ID', nest: '01');
                builder.element('cbc:Name', nest: 'IVA');
              });
            });
          });
        });
        
        // Descripción del ítem
        builder.element('cac:Item', nest: () {
          builder.element('cbc:Description', nest: item.description);
        });
        
        // Precio unitario
        builder.element('cac:Price', nest: () {
          builder.element('cbc:PriceAmount', nest: () {
            builder.attribute('currencyID', invoice.currency);
            builder.text(item.unitPrice.toStringAsFixed(2));
          });
          builder.element('cbc:BaseQuantity', nest: () {
            builder.attribute('unitCode', 'EA'); // Each (Unidad)
            builder.text('1');
          });
        });
      });
    }
  }
} 