import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/academy_billing/data/models/invoice_model.dart';
import 'package:arcinus/features/academy_billing/domain/repositories/billing_repository.dart';

/// Implementación del repositorio para la facturación
class BillingRepositoryImpl implements BillingRepository {
  /// Constructor
  BillingRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _className = 'BillingRepositoryImpl';

  // Referencia a la subcolección de configuraciones de facturación
  CollectionReference<Map<String, dynamic>> _getBillingConfigCollection(
    String academyId,
  ) {
    return _firestore
        .collection('academies')
        .doc(academyId)
        .collection('billing_config');
  }

  // Referencia a la subcolección de facturas
  CollectionReference<Map<String, dynamic>> _getInvoicesCollection(
    String academyId,
  ) {
    return _firestore
        .collection('academies')
        .doc(academyId)
        .collection('invoices');
  }

  @override
  Future<Either<Failure, BillingConfigModel>> getBillingConfig(
    String academyId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo configuración de facturación',
        className: _className,
        functionName: 'getBillingConfig',
        params: {'academyId': academyId},
      );

      final snapshot = await _getBillingConfigCollection(academyId).limit(1).get();

      if (snapshot.docs.isEmpty) {
        // No hay configuración, devolver error
        return left(
          const Failure.notFound(message: 'No se encontró configuración de facturación'),
        );
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final config = BillingConfigModel.fromJson({...data, 'id': doc.id});

      AppLogger.logInfo(
        'Configuración de facturación obtenida',
        className: _className,
        functionName: 'getBillingConfig',
        params: {'academyId': academyId, 'configId': config.id},
      );

      return right(config);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener configuración de facturación',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getBillingConfig',
        params: {'academyId': academyId},
      );
      return left(
        const Failure.serverError(message: 'Error al obtener la configuración de facturación'),
      );
    }
  }

  @override
  Future<Either<Failure, BillingConfigModel>> saveBillingConfig(
    BillingConfigModel config,
  ) async {
    try {
      AppLogger.logInfo(
        'Guardando configuración de facturación',
        className: _className,
        functionName: 'saveBillingConfig',
        params: {'academyId': config.academyId},
      );

      final academyId = config.academyId;
      final collection = _getBillingConfigCollection(academyId);

      // Verificar si ya existe una configuración
      final existingDocs = await collection.limit(1).get();

      late DocumentReference<Map<String, dynamic>> docRef;
      // Actualizar datos o crear nueva configuración
      if (existingDocs.docs.isNotEmpty && config.id != null) {
        // Actualizar documento existente
        docRef = collection.doc(config.id);
        await docRef.update(config.toJson());
      } else {
        // Crear nuevo documento
        docRef = await collection.add(config.toJson());
      }

      // Obtener la configuración actualizada
      final updatedDoc = await docRef.get();
      final updatedConfig = BillingConfigModel.fromJson({
        ...updatedDoc.data()!,
        'id': updatedDoc.id,
      });

      AppLogger.logInfo(
        'Configuración de facturación guardada',
        className: _className,
        functionName: 'saveBillingConfig',
        params: {'academyId': config.academyId, 'configId': updatedConfig.id},
      );

      return right(updatedConfig);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al guardar configuración de facturación',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'saveBillingConfig',
        params: {'academyId': config.academyId},
      );
      return left(
        const Failure.serverError(message: 'Error al guardar la configuración de facturación'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InvoiceModel>>> getInvoicesByAcademy(
    String academyId, {
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo facturas por academia',
        className: _className,
        functionName: 'getInvoicesByAcademy',
        params: {
          'academyId': academyId,
          'startDate': startDate?.toString(),
          'endDate': endDate?.toString(),
          'status': status,
        },
      );

      Query<Map<String, dynamic>> query = _getInvoicesCollection(academyId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('issueDate', descending: true);

      // Aplicar filtros si se proporcionan
      if (startDate != null) {
        query = query.where('issueDate', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('issueDate', isLessThanOrEqualTo: endDate);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();

      final invoices = snapshot.docs.map((doc) {
        final data = doc.data();
        return InvoiceModel.fromJson({...data, 'id': doc.id});
      }).toList();

      AppLogger.logInfo(
        'Facturas obtenidas exitosamente',
        className: _className,
        functionName: 'getInvoicesByAcademy',
        params: {'academyId': academyId, 'count': invoices.length},
      );

      return right(invoices);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener facturas por academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getInvoicesByAcademy',
        params: {'academyId': academyId},
      );
      return left(
        const Failure.serverError(message: 'Error al obtener las facturas'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InvoiceModel>>> getInvoicesByClient(
    String academyId,
    String clientId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo facturas por cliente',
        className: _className,
        functionName: 'getInvoicesByClient',
        params: {'academyId': academyId, 'clientId': clientId},
      );

      final snapshot = await _getInvoicesCollection(academyId)
          .where('clientId', isEqualTo: clientId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('issueDate', descending: true)
          .get();

      final invoices = snapshot.docs.map((doc) {
        final data = doc.data();
        return InvoiceModel.fromJson({...data, 'id': doc.id});
      }).toList();

      AppLogger.logInfo(
        'Facturas por cliente obtenidas exitosamente',
        className: _className,
        functionName: 'getInvoicesByClient',
        params: {
          'academyId': academyId,
          'clientId': clientId,
          'count': invoices.length,
        },
      );

      return right(invoices);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener facturas por cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getInvoicesByClient',
        params: {'academyId': academyId, 'clientId': clientId},
      );
      return left(
        const Failure.serverError(
          message: 'Error al obtener las facturas del cliente',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> getInvoiceById(
    String academyId,
    String invoiceId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo factura por ID',
        className: _className,
        functionName: 'getInvoiceById',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );

      final docSnapshot = await _getInvoicesCollection(academyId).doc(invoiceId).get();

      if (!docSnapshot.exists) {
        return left(
          const Failure.notFound(message: 'No se encontró la factura'),
        );
      }

      final data = docSnapshot.data();
      final invoice = InvoiceModel.fromJson({...data!, 'id': docSnapshot.id});

      AppLogger.logInfo(
        'Factura obtenida exitosamente',
        className: _className,
        functionName: 'getInvoiceById',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );

      return right(invoice);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener factura por ID',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getInvoiceById',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );
      return left(
        const Failure.serverError(message: 'Error al obtener la factura'),
      );
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> createInvoice(
    InvoiceModel invoice,
  ) async {
    try {
      AppLogger.logInfo(
        'Creando nueva factura',
        className: _className,
        functionName: 'createInvoice',
        params: {
          'academyId': invoice.academyId,
          'clientId': invoice.clientId,
          'amount': invoice.total,
        },
      );

      final academyId = invoice.academyId;
      
      // Obtener configuración de facturación para asignar consecutivo
      final configEither = await getBillingConfig(academyId);
      late final BillingConfigModel config;
      
      // Si no hay configuración, usar valores predeterminados
      if (configEither.isLeft()) {
        config = BillingConfigModel.defaultConfig(
          academyId: academyId, 
          academyName: 'Default', 
          phone: '', 
          email: '', 
          address: '',
        );
      } else {
        config = configEither.getRight().toNullable()!;
      }
      
      // Asignar nuevo consecutivo
      final int consecutive = config.currentConsecutive;
      final prefix = config.invoicePrefix.isNotEmpty ? config.invoicePrefix : 'FC';
      final invoiceNumber = '$prefix-$consecutive';
      
      // Crear factura con datos actualizados
      final updatedInvoice = invoice.copyWith(
        consecutive: consecutive,
        prefix: prefix,
        invoiceNumber: invoiceNumber,
        createdAt: DateTime.now(),
      );
      
      // Guardar factura
      final docRef = await _getInvoicesCollection(academyId).add(updatedInvoice.toJson());
      
      // Incrementar consecutivo en la configuración
      if (configEither.isRight()) {
        await saveBillingConfig(config.copyWith(
          currentConsecutive: consecutive + 1,
        ));
      }
      
      // Obtener factura guardada
      final snapshot = await docRef.get();
      final createdInvoice = InvoiceModel.fromJson({
        ...snapshot.data()!,
        'id': snapshot.id,
      });

      AppLogger.logInfo(
        'Factura creada exitosamente',
        className: _className,
        functionName: 'createInvoice',
        params: {
          'academyId': invoice.academyId,
          'invoiceId': createdInvoice.id,
          'invoiceNumber': createdInvoice.invoiceNumber,
        },
      );

      return right(createdInvoice);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear factura',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createInvoice',
        params: {'academyId': invoice.academyId},
      );
      return left(
        const Failure.serverError(message: 'Error al crear la factura'),
      );
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> updateInvoice(
    InvoiceModel invoice,
  ) async {
    try {
      if (invoice.id == null) {
        return left(
          const Failure.serverError(message: 'La factura no tiene un ID válido'),
        );
      }

      AppLogger.logInfo(
        'Actualizando factura',
        className: _className,
        functionName: 'updateInvoice',
        params: {
          'academyId': invoice.academyId,
          'invoiceId': invoice.id,
        },
      );

      final updatedInvoice = invoice.copyWith(
        updatedAt: DateTime.now(),
      );

      await _getInvoicesCollection(invoice.academyId)
          .doc(invoice.id)
          .update(updatedInvoice.toJson());

      AppLogger.logInfo(
        'Factura actualizada exitosamente',
        className: _className,
        functionName: 'updateInvoice',
        params: {
          'academyId': invoice.academyId,
          'invoiceId': invoice.id,
        },
      );

      return right(updatedInvoice);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar factura',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateInvoice',
        params: {'academyId': invoice.academyId, 'invoiceId': invoice.id},
      );
      return left(
        const Failure.serverError(message: 'Error al actualizar la factura'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(
    String academyId,
    String invoiceId,
  ) async {
    try {
      AppLogger.logInfo(
        'Eliminando factura',
        className: _className,
        functionName: 'deleteInvoice',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );

      // Marcar como eliminado en lugar de borrar
      await _getInvoicesCollection(academyId).doc(invoiceId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logInfo(
        'Factura eliminada exitosamente',
        className: _className,
        functionName: 'deleteInvoice',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );

      return right(null);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al eliminar factura',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'deleteInvoice',
        params: {'academyId': academyId, 'invoiceId': invoiceId},
      );
      return left(
        const Failure.serverError(message: 'Error al eliminar la factura'),
      );
    }
  }
} 