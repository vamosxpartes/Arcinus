import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/academy_billing/data/models/invoice_model.dart';
import 'package:arcinus/features/academy_billing/services/invoice_pdf_service.dart';
import 'package:arcinus/features/academy_billing/services/share_service.dart';
import 'package:arcinus/features/academy_billing/presentation/providers/billing_config_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academy_billing/presentation/widgets/widgets.dart';
import 'package:arcinus/features/academy_billing/presentation/mixins/image_validation_mixin.dart';

/// Pantalla para configurar los datos de facturación
class BillingConfigScreen extends ConsumerStatefulWidget {
  /// ID de la academia
  final String academyId;

  /// Constructor
  const BillingConfigScreen({required this.academyId, super.key});

  @override
  ConsumerState<BillingConfigScreen> createState() => _BillingConfigScreenState();
}

class _BillingConfigScreenState extends ConsumerState<BillingConfigScreen> with ImageValidationMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _nitDvController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _consecutiveController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  // Valores predeterminados
  String _taxRegime = 'Ordinario';
  String _fiscalResponsibility = 'Responsable de IVA';
  int _defaultVAT = 19;
  DateTime? _resolutionDate;
  File? _logoFile;
  String? _logoUrl;
  bool _hasInvalidLogo = false; // Nueva variable para tracking de logos inválidos

  final List<String> _taxRegimeOptions = ['Ordinario', 'Simple'];
  final List<String> _fiscalResponsibilityOptions = [
    'Responsable de IVA',
    'No responsable de IVA',
    'Gran contribuyente',
    'Autorretenedor',
  ];
  final List<int> _vatOptions = [19, 5, 0];

  @override
  void initState() {
    super.initState();
    // Asegurar que los valores iniciales estén en las opciones disponibles
    if (!_taxRegimeOptions.contains(_taxRegime)) {
      _taxRegime = _taxRegimeOptions.first;
    }
    if (!_fiscalResponsibilityOptions.contains(_fiscalResponsibility)) {
      _fiscalResponsibility = _fiscalResponsibilityOptions.first;
    }
    if (!_vatOptions.contains(_defaultVAT)) {
      _defaultVAT = _vatOptions.first;
    }
    _loadBillingConfig();
  }

  Future<void> _loadBillingConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar cargar la configuración existente
      final BillingConfigModel config = await ref.read(billingConfigProvider(widget.academyId).future);
      
      // Llenar los campos con la configuración existente
      _legalNameController.text = config.legalName;
      _nitController.text = config.nit;
      _nitDvController.text = config.nitDv;
      _addressController.text = config.address;
      _cityController.text = config.city;
      _stateController.text = config.state;
      _phoneController.text = config.phone;
      _emailController.text = config.email;
      _prefixController.text = config.invoicePrefix;
      _consecutiveController.text = config.currentConsecutive.toString();
      _resolutionController.text = config.invoiceResolution;
      _additionalNotesController.text = config.additionalNotes;
      
      // Determinar el logoUrl a usar
      String logoUrlToUse = config.logoUrl;
      
      // Si no hay logoUrl en la configuración de billing, intentar usar el de la academia
      if (logoUrlToUse.isEmpty) {
        try {
          final academyData = await ref.read(academyProvider(widget.academyId).future);
          if (academyData != null && academyData.logoUrl.isNotEmpty) {
            logoUrlToUse = academyData.logoUrl;
            AppLogger.logInfo(
              'Usando logoUrl de la academia como fallback para facturación',
              className: '_BillingConfigScreenState',
              functionName: '_loadBillingConfig',
              params: {
                'academyId': widget.academyId,
                'academyLogoUrl': academyData.logoUrl,
              },
            );
          }
        } catch (e) {
          AppLogger.logWarning(
            'No se pudo obtener logoUrl de la academia',
            className: '_BillingConfigScreenState',
            functionName: '_loadBillingConfig',
            params: {'error': e.toString()},
          );
        }
      }
      
      setState(() {
        // Validar que los valores del dropdown estén en las opciones disponibles
        _taxRegime = _taxRegimeOptions.contains(config.taxRegime) 
            ? config.taxRegime 
            : _taxRegimeOptions.first;
            
        _fiscalResponsibility = _fiscalResponsibilityOptions.contains(config.fiscalResponsibility) 
            ? config.fiscalResponsibility 
            : _fiscalResponsibilityOptions.first;
            
        _defaultVAT = _vatOptions.contains(config.defaultVAT) 
            ? config.defaultVAT 
            : _vatOptions.first;
            
        _resolutionDate = config.resolutionDate;
        
        // Limpiar archivo local y usar solo la URL de la base de datos
        _logoFile = null;
        
        // Verificar si la URL es válida (no es de ejemplo)
        if (logoUrlToUse.isNotEmpty && !logoUrlToUse.contains('example.com') && isValidImageUrl(logoUrlToUse)) {
          _logoUrl = logoUrlToUse;
          _hasInvalidLogo = false;
        } else {
          // Marcar URL como inválida pero no guardar automáticamente
          _logoUrl = '';
          _hasInvalidLogo = logoUrlToUse.isNotEmpty && (logoUrlToUse.contains('example.com') || !isValidImageUrl(logoUrlToUse));
          
          if (_hasInvalidLogo) {
            AppLogger.logWarning(
              'URL de logo inválida detectada',
              className: '_BillingConfigScreenState',
              functionName: '_loadBillingConfig',
              params: {'invalidUrl': logoUrlToUse},
            );
          }
        }
        
        _isLoading = false;
      });

      AppLogger.logInfo(
        'Configuración de facturación cargada exitosamente',
        className: '_BillingConfigScreenState',
        functionName: '_loadBillingConfig',
        params: {
          'academyId': widget.academyId,
          'hasLogo': (config.logoUrl.isNotEmpty).toString(),
          'logoUrl': config.logoUrl,
          'logoUrlUsed': logoUrlToUse,
          'logoUrlLength': config.logoUrl.length.toString(),
          '_logoFile': (_logoFile?.path ?? 'null'),
          '_logoUrl': _logoUrl ?? 'null',
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error al cargar configuración de facturación',
        error: e,
        className: '_BillingConfigScreenState',
        functionName: '_loadBillingConfig',
        params: {'academyId': widget.academyId},
      );

      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar la configuración de facturación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveBillingConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear modelo de configuración
      final config = BillingConfigModel(
        academyId: widget.academyId,
        legalName: _legalNameController.text,
        nit: _nitController.text,
        nitDv: _nitDvController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        taxRegime: _taxRegime,
        fiscalResponsibility: _fiscalResponsibility,
        logoUrl: _logoUrl ?? '',
        invoicePrefix: _prefixController.text,
        currentConsecutive: int.tryParse(_consecutiveController.text) ?? 1,
        invoiceResolution: _resolutionController.text,
        resolutionDate: _resolutionDate,
        additionalNotes: _additionalNotesController.text,
        defaultVAT: _defaultVAT,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Guardar configuración usando el provider
      await ref.read(billingConfigNotifierProvider(widget.academyId).notifier).saveBillingConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al guardar configuración de facturación',
        error: e,
        className: '_BillingConfigScreenState',
        functionName: '_saveBillingConfig',
        params: {'academyId': widget.academyId},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _selectResolutionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _resolutionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _resolutionDate) {
      setState(() {
        _resolutionDate = picked;
      });
    }
  }

  Future<void> _previewInvoice() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos los campos requeridos primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear configuración temporal para la vista previa
      final tempConfig = BillingConfigModel(
        academyId: widget.academyId,
        legalName: _legalNameController.text,
        nit: _nitController.text,
        nitDv: _nitDvController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        taxRegime: _taxRegime,
        fiscalResponsibility: _fiscalResponsibility,
        logoUrl: _logoUrl ?? '',
        invoicePrefix: _prefixController.text,
        currentConsecutive: int.tryParse(_consecutiveController.text) ?? 1,
        invoiceResolution: _resolutionController.text,
        resolutionDate: _resolutionDate,
        additionalNotes: _additionalNotesController.text,
        defaultVAT: _defaultVAT,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Crear factura de ejemplo
      final sampleInvoice = InvoiceModel(
        academyId: widget.academyId,
        clientId: 'sample-client',
        clientName: 'Juan Carlos García Mendoza',
        clientDocument: '12345678',
        clientAddress: 'Calle 85 # 14-32, Bogotá',
        clientEmail: 'juan.garcia@email.com',
        clientPhone: '601 555 1234',
        invoiceNumber: '${tempConfig.invoicePrefix}-${tempConfig.currentConsecutive.toString().padLeft(6, '0')}',
        consecutive: tempConfig.currentConsecutive,
        prefix: tempConfig.invoicePrefix,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [
          const InvoiceItemModel(
            description: 'Mensualidad - Plan Premium',
            quantity: 1,
            unitPrice: 150000,
            vat: 19,
          ),
          const InvoiceItemModel(
            description: 'Entrenamiento personal',
            quantity: 4,
            unitPrice: 50000,
            vat: 19,
          ),
        ],
        notes: 'Factura de ejemplo generada para vista previa.',
        subtotal: 350000,
        vatTotal: 66500,
        total: 416500,
        status: InvoiceStatus.draft,
        currency: 'COP',
        createdBy: 'admin',
        createdAt: DateTime.now(),
      );

      // Generar y compartir PDF de vista previa
      final pdfService = InvoicePdfService();
      
      // Obtener bytes del logo, ya sea del archivo local o descargando desde la URL
      Uint8List? logoBytes;
      if (_logoFile != null) {
        logoBytes = await _logoFile!.readAsBytes();
      } else if (_logoUrl != null && _logoUrl!.isNotEmpty && !_logoUrl!.contains('example.com')) {
        try {
          // Descargar logo desde la URL de Firebase Storage
          final ref = FirebaseStorage.instance.refFromURL(_logoUrl!);
          logoBytes = await ref.getData();
          
          AppLogger.logInfo(
            'Logo descargado desde URL para vista previa',
            className: '_BillingConfigScreenState',
            functionName: '_previewInvoice',
            params: {'logoUrl': _logoUrl},
          );
        } catch (e) {
          AppLogger.logWarning(
            'No se pudo descargar el logo para la vista previa',
            className: '_BillingConfigScreenState',
            functionName: '_previewInvoice',
            params: {'logoUrl': _logoUrl, 'error': e.toString()},
          );
          // Continuar sin logo si no se puede descargar
          logoBytes = null;
        }
      }
      
      final pdfBytes = await pdfService.generateInvoicePdf(
        invoice: sampleInvoice,
        billingConfig: tempConfig,
        logoBytes: logoBytes,
      );

      // Usar el servicio de compartir para mostrar el PDF
      final shareService = ShareService();
      await shareService.sharePdf(
        pdfBytes: pdfBytes,
        fileName: 'Vista_Previa_Factura.pdf',
        subject: 'Vista previa de factura - ${tempConfig.legalName}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vista previa generada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al generar vista previa de factura',
        error: e,
        className: '_BillingConfigScreenState',
        functionName: '_previewInvoice',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar vista previa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _nitController.dispose();
    _nitDvController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _prefixController.dispose();
    _consecutiveController.dispose();
    _resolutionController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return _isLoading && _legalNameController.text.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de logo
                  BillingLogoSection(
                    academyId: widget.academyId,
                    logoFile: _logoFile,
                    logoUrl: _logoUrl,
                    hasInvalidLogo: _hasInvalidLogo,
                    isLoading: _isLoading,
                    onLogoUpdated: (logoFile, logoUrl, hasInvalidLogo) {
                      setState(() {
                        _logoFile = logoFile;
                        _logoUrl = logoUrl;
                        _hasInvalidLogo = hasInvalidLogo;
                      });
                    },
                    onLoadingChanged: (isLoading) {
                      setState(() {
                        _isLoading = isLoading;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Datos fiscales
                  BillingFiscalDataSection(
                    legalNameController: _legalNameController,
                    nitController: _nitController,
                    nitDvController: _nitDvController,
                    addressController: _addressController,
                    cityController: _cityController,
                    stateController: _stateController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    taxRegime: _taxRegime,
                    fiscalResponsibility: _fiscalResponsibility,
                    defaultVAT: _defaultVAT,
                    taxRegimeOptions: _taxRegimeOptions,
                    fiscalResponsibilityOptions: _fiscalResponsibilityOptions,
                    vatOptions: _vatOptions,
                    onTaxRegimeChanged: (value) {
                      setState(() {
                        _taxRegime = value;
                      });
                    },
                    onFiscalResponsibilityChanged: (value) {
                      setState(() {
                        _fiscalResponsibility = value;
                      });
                    },
                    onVATChanged: (value) {
                      setState(() {
                        _defaultVAT = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Configuración de facturación
                  BillingInvoiceConfigSection(
                    prefixController: _prefixController,
                    consecutiveController: _consecutiveController,
                    resolutionController: _resolutionController,
                    resolutionDate: _resolutionDate,
                    onSelectResolutionDate: () => _selectResolutionDate(context),
                  ),
                  const SizedBox(height: 24),
                  
                  // Notas adicionales
                  BillingNotesSection(
                    additionalNotesController: _additionalNotesController,
                  ),
                  const SizedBox(height: 32),
                  
                  // Botones de acción
                  BillingActionButtons(
                    isLoading: _isLoading,
                    onPreviewInvoice: _previewInvoice,
                    onSaveBillingConfig: _saveBillingConfig,
                  ),
                ],
              ),
            ),
          );
  }




} 