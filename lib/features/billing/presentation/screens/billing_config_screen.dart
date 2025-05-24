import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/billing/data/models/invoice_model.dart';
import 'package:arcinus/features/billing/services/invoice_pdf_service.dart';
import 'package:arcinus/features/billing/services/share_service.dart';
import 'package:arcinus/features/billing/presentation/providers/billing_config_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';

/// Pantalla para configurar los datos de facturación
class BillingConfigScreen extends ConsumerStatefulWidget {
  /// ID de la academia
  final String academyId;

  /// Constructor
  const BillingConfigScreen({required this.academyId, super.key});

  @override
  ConsumerState<BillingConfigScreen> createState() => _BillingConfigScreenState();
}

class _BillingConfigScreenState extends ConsumerState<BillingConfigScreen> {
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
        if (logoUrlToUse.isNotEmpty && !logoUrlToUse.contains('example.com') && _isValidImageUrl(logoUrlToUse)) {
          _logoUrl = logoUrlToUse;
          _hasInvalidLogo = false;
        } else {
          // Marcar URL como inválida pero no guardar automáticamente
          _logoUrl = '';
          _hasInvalidLogo = logoUrlToUse.isNotEmpty && (logoUrlToUse.contains('example.com') || !_isValidImageUrl(logoUrlToUse));
          
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

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final File imageFile = File(image.path);
        
        try {
          // Generar nombre único para el archivo
          final String fileExtension = image.path.split('.').last;
          final String fileName = '${const Uuid().v4()}.$fileExtension';
          final String storagePath = 'academies/${widget.academyId}/billing/logos/$fileName';
          
          // Subir imagen a Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          await storageRef.putFile(imageFile);
          
          // Obtener URL de descarga
          final String downloadUrl = await storageRef.getDownloadURL();
          
          setState(() {
            _logoFile = imageFile;
            _logoUrl = downloadUrl;
            _hasInvalidLogo = false;
            _isLoading = false;
          });

          AppLogger.logInfo(
            'Logo subido exitosamente para facturación',
            className: '_BillingConfigScreenState',
            functionName: '_pickLogo',
            params: {
              'academyId': widget.academyId, 
              'logoUrl': downloadUrl,
              'logoFileExists': imageFile.existsSync().toString(),
              'logoFilePath': imageFile.path,
              '_logoFile_set': (_logoFile?.path ?? 'null'),
              '_logoUrl_set': _logoUrl ?? 'null',
            },
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logo subido correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (storageError) {
          setState(() {
            _isLoading = false;
          });
          
          AppLogger.logError(
            message: 'Error al subir logo a Firebase Storage',
            error: storageError,
            className: '_BillingConfigScreenState',
            functionName: '_pickLogo',
            params: {'academyId': widget.academyId},
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir logo: ${storageError.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      AppLogger.logError(
        message: 'Error al seleccionar logo',
        error: e,
        className: '_BillingConfigScreenState',
        functionName: '_pickLogo',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar la imagen'),
            backgroundColor: Colors.red,
          ),
        );
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

  /// Valida si una URL es válida para imágenes
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      
      // Verificar que sea una URL válida
      if (!uri.hasScheme || (!uri.scheme.startsWith('http') && !uri.scheme.startsWith('https'))) {
        return false;
      }
      
      // Verificar que no sea una URL de ejemplo
      if (url.contains('example.com') || url.contains('placeholder') || url.contains('dummy')) {
        return false;
      }
      
      // Verificar extensiones de imagen comunes (opcional, Firebase Storage puede no tenerlas)
      final commonImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      final hasImageExtension = commonImageExtensions.any((ext) => url.toLowerCase().contains(ext));
      
      // Para Firebase Storage, también verificar el dominio
      final isFirebaseStorage = url.contains('firebasestorage.googleapis.com') || url.contains('firebase.googleapis.com');
      
      return isFirebaseStorage || hasImageExtension;
    } catch (e) {
      return false;
    }
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
                  // Título y sección de logo
                  _buildLogoSection(),
                  const SizedBox(height: 24),
                  
                  // Datos fiscales
                  _buildFiscalDataSection(),
                  const SizedBox(height: 24),
                  
                  // Configuración de facturación
                  _buildInvoiceConfigSection(),
                  const SizedBox(height: 24),
                  
                  // Notas adicionales
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  
                  // Botones de acción
                  _buildActionButtons(),
                ],
              ),
            ),
          );
  }

  Widget _buildLogoSection() {
    // Logs de diagnóstico para el estado del logo
    AppLogger.logInfo(
      'Construyendo sección de logo - Estado actual',
      className: '_BillingConfigScreenState',
      functionName: '_buildLogoSection',
      params: {
        '_isLoading': _isLoading.toString(),
        '_logoFile': (_logoFile?.path ?? 'null'),
        '_logoUrl': _logoUrl ?? 'null',
        '_logoUrlIsEmpty': (_logoUrl?.isEmpty ?? true).toString(),
        '_hasInvalidLogo': _hasInvalidLogo.toString(),
        'condicion_isLoading': (_isLoading && _logoFile == null).toString(),
        'condicion_logoFile': (_logoFile != null).toString(),
        'condicion_logoUrl': (_logoUrl != null && _logoUrl!.isNotEmpty).toString(),
      },
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo para Facturas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mostrar alerta si hay logo inválido
            if (_hasInvalidLogo)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se detectó un logo inválido. Sube un nuevo logo para facturas.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasInvalidLogo = false;
                        });
                      },
                      child: Text(
                        'Ocultar',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading && _logoFile == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _logoFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _logoFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _logoUrl != null && _logoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _logoUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        AppLogger.logError(
                                          message: 'Error al cargar imagen desde URL',
                                          error: error,
                                          className: '_BillingConfigScreenState',
                                          functionName: '_buildLogoSection',
                                          params: {
                                            'logoUrl': _logoUrl ?? 'null',
                                            'errorType': error.runtimeType.toString(),
                                          },
                                        );
                                        
                                        // Marcar como logo inválido al fallar la carga
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              _hasInvalidLogo = true;
                                              _logoUrl = '';
                                            });
                                          }
                                        });
                                        
                                        return const Icon(
                                          Icons.image,
                                          size: 64,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickLogo,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_isLoading ? 'Subiendo...' : 'Subir Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.embers,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if ((_logoUrl != null && _logoUrl!.isNotEmpty) || _logoFile != null)
                    TextButton(
                      onPressed: _isLoading ? null : () async {
                        // Si hay una URL, intentar eliminar de Firebase Storage
                        if (_logoUrl != null && _logoUrl!.isNotEmpty && !_logoUrl!.contains('example.com')) {
                          try {
                            await FirebaseStorage.instance.refFromURL(_logoUrl!).delete();
                            AppLogger.logInfo(
                              'Logo eliminado de Firebase Storage',
                              className: '_BillingConfigScreenState',
                              functionName: 'deleteLogo',
                              params: {'logoUrl': _logoUrl},
                            );
                          } catch (e) {
                            AppLogger.logWarning(
                              'No se pudo eliminar el logo de Storage (puede que ya no exista)',
                              className: '_BillingConfigScreenState',
                              functionName: 'deleteLogo',
                              params: {'error': e.toString()},
                            );
                          }
                        }
                        
                        setState(() {
                          _logoFile = null;
                          _logoUrl = '';
                          _hasInvalidLogo = false;
                        });
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logo eliminado'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: const Text('Eliminar logo'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiscalDataSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos Fiscales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre legal
            TextFormField(
              controller: _legalNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Razón Social',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nombre legal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // NIT y DV
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _nitController,
                    decoration: const InputDecoration(
                      labelText: 'NIT',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el NIT';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _nitDvController,
                    decoration: const InputDecoration(
                      labelText: 'DV',
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'DV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Régimen tributario
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Régimen Tributario',
                border: OutlineInputBorder(),
              ),
              value: _taxRegimeOptions.contains(_taxRegime) ? _taxRegime : null,
              items: _taxRegimeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _taxRegime = newValue;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione un régimen tributario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Responsabilidad fiscal
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Responsabilidad Fiscal',
                border: OutlineInputBorder(),
              ),
              value: _fiscalResponsibilityOptions.contains(_fiscalResponsibility) ? _fiscalResponsibility : null,
              items: _fiscalResponsibilityOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _fiscalResponsibility = newValue;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione una responsabilidad fiscal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // IVA predeterminado
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'IVA Predeterminado',
                border: OutlineInputBorder(),
              ),
              value: _vatOptions.contains(_defaultVAT) ? _defaultVAT : null,
              items: _vatOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value%'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _defaultVAT = newValue;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Seleccione un porcentaje de IVA';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Dirección, ciudad y departamento
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la ciudad';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el departamento';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Teléfono y email
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email de Facturación',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el email de facturación';
                }
                if (!value.contains('@')) {
                  return 'Ingrese un email válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceConfigSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Facturación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Prefijo y consecutivo
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _prefixController,
                    decoration: const InputDecoration(
                      labelText: 'Prefijo de Factura',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: FC',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el prefijo';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _consecutiveController,
                    decoration: const InputDecoration(
                      labelText: 'Consecutivo Actual',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 1001',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el consecutivo actual';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Resolución DIAN
            TextFormField(
              controller: _resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolución DIAN',
                border: OutlineInputBorder(),
                hintText: 'Ej: 18764000001234',
              ),
            ),
            const SizedBox(height: 16),
            
            // Fecha de resolución
            InkWell(
              onTap: () => _selectResolutionDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Resolución DIAN',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _resolutionDate != null
                          ? '${_resolutionDate!.day}/${_resolutionDate!.month}/${_resolutionDate!.year}'
                          : 'Seleccionar fecha',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas y Términos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _additionalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                border: OutlineInputBorder(),
                hintText: 'Ej: Esta factura se asimila en todos sus efectos a una letra de cambio según Art. 774 Código de Comercio',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _previewInvoice,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Vista Previa'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveBillingConfig,
            icon: const Icon(Icons.save),
            label: _isLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.embers,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
} 