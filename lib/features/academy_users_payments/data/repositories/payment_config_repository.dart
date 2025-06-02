import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_config_repository.g.dart';

/// Repositorio para gestionar la configuración de pagos de una academia
abstract class PaymentConfigRepository {
  /// Obtiene la configuración de pagos de una academia
  Future<Either<Failure, PaymentConfigModel>> getPaymentConfig(
    String academyId,
  );

  /// Actualiza la configuración de pagos de una academia
  Future<Either<Failure, PaymentConfigModel>> updatePaymentConfig(
    PaymentConfigModel config,
  );

  /// Crea la configuración de pagos para una academia
  Future<Either<Failure, PaymentConfigModel>> createPaymentConfig(
    PaymentConfigModel config,
  );
}

/// Implementación del repositorio para configuración de pagos
class PaymentConfigRepositoryImpl implements PaymentConfigRepository {
  final FirebaseFirestore _firestore;

  /// Constructor
  PaymentConfigRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, PaymentConfigModel>> getPaymentConfig(
    String academyId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo configuración de pagos para academia: $academyId',
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'getPaymentConfig',
      );

      final snapshot =
          await _firestore
              .collection('academies')
              .doc(academyId)
              .collection('payment_configs')
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        AppLogger.logInfo(
          'No se encontró configuración de pagos para academia: $academyId, creando configuración por defecto',
          className: 'PaymentConfigRepositoryImpl',
          functionName: 'getPaymentConfig',
        );

        // Si no existe configuración, crear una por defecto
        final defaultConfig = PaymentConfigModel.defaultConfig(
          academyId: academyId,
        );
        return await createPaymentConfig(defaultConfig);
      }

      final docData = snapshot.docs.first.data();
      final configId = snapshot.docs.first.id;

      final config = PaymentConfigModel.fromJson({...docData, 'id': configId});

      return Right(config);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener configuración de pagos',
        error: e,
        stackTrace: s,
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'getPaymentConfig',
        params: {'academyId': academyId},
      );
      return Left(
        ServerFailure(message: 'Error al obtener configuración de pagos: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentConfigModel>> updatePaymentConfig(
    PaymentConfigModel config,
  ) async {
    try {
      if (config.id == null) {
        return Left(
          ValidationFailure(message: 'ID de configuración de pagos no válido'),
        );
      }

      AppLogger.logInfo(
        'Actualizando configuración de pagos para academia: ${config.academyId}',
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'updatePaymentConfig',
      );

      final updatedConfig = config.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('academies')
          .doc(config.academyId)
          .collection('payment_configs')
          .doc(config.id)
          .update(updatedConfig.toJson());

      return Right(updatedConfig);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar configuración de pagos',
        error: e,
        stackTrace: s,
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'updatePaymentConfig',
        params: {'academyId': config.academyId, 'configId': config.id},
      );
      return Left(
        ServerFailure(
          message: 'Error al actualizar configuración de pagos: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentConfigModel>> createPaymentConfig(
    PaymentConfigModel config,
  ) async {
    try {
      AppLogger.logInfo(
        'Creando configuración de pagos para academia: ${config.academyId}',
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'createPaymentConfig',
      );

      final newConfig = config.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('academies')
          .doc(config.academyId)
          .collection('payment_configs')
          .add(newConfig.toJson());

      return Right(newConfig.copyWith(id: docRef.id));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear configuración de pagos',
        error: e,
        stackTrace: s,
        className: 'PaymentConfigRepositoryImpl',
        functionName: 'createPaymentConfig',
        params: {'academyId': config.academyId},
      );
      return Left(
        ServerFailure(message: 'Error al crear configuración de pagos: $e'),
      );
    }
  }
}

/// Provider para el repositorio de configuración de pagos
@Riverpod(keepAlive: true)
PaymentConfigRepository paymentConfigRepository(
  Ref ref,
) {
  return PaymentConfigRepositoryImpl();
}
