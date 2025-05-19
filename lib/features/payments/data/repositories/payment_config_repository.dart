import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Resultado de una operación del repositorio
class RepositoryResult<T> {
  final T? data;
  final Failure? failure;
  
  RepositoryResult._({this.data, this.failure});
  
  factory RepositoryResult.success(T data) => RepositoryResult._(data: data);
  factory RepositoryResult.error(Failure failure) => RepositoryResult._(failure: failure);
  
  bool get isSuccess => failure == null && data != null;
  bool get isError => failure != null;
  
  R fold<R>(R Function(Failure) onError, R Function(T) onSuccess) {
    if (isError) {
      return onError(failure!);
    } else {
      return onSuccess(data as T);
    }
  }
}

/// Interfaz para el repositorio de configuración de pagos
abstract class PaymentConfigRepository {
  /// Obtiene la configuración de pagos de una academia
  Future<RepositoryResult<PaymentConfigModel>> getPaymentConfig(String academyId);
  
  /// Guarda o actualiza la configuración de pagos de una academia
  Future<RepositoryResult<PaymentConfigModel>> savePaymentConfig(PaymentConfigModel config);
}

/// Implementación del repositorio de configuración de pagos con Firestore
class PaymentConfigRepositoryImpl implements PaymentConfigRepository {
  final FirebaseFirestore _firestore;
  
  PaymentConfigRepositoryImpl(this._firestore);
  
  @override
  Future<RepositoryResult<PaymentConfigModel>> getPaymentConfig(String academyId) async {
    try {
      final snapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('payment_configs')
          .where('academyId', isEqualTo: academyId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Si no existe configuración, crear una predeterminada
        final defaultConfig = PaymentConfigModel.defaultConfig(academyId: academyId);
        
        // Guardar configuración predeterminada
        await savePaymentConfig(defaultConfig);
        
        return RepositoryResult.success(defaultConfig);
      }
      
      // Obtener el primer documento (debería ser único)
      final doc = snapshot.docs.first;
      final config = PaymentConfigModel.fromJson(doc.data());
      
      return RepositoryResult.success(config);
    } on FirebaseException catch (e) {
      return RepositoryResult.error(ServerFailure(message: e.message ?? 'Error de Firestore'));
    } catch (e) {
      return RepositoryResult.error(Failure.unexpectedError(error: e));
    }
  }
  
  @override
  Future<RepositoryResult<PaymentConfigModel>> savePaymentConfig(PaymentConfigModel config) async {
    try {
      final docRef = config.id != null
          ? _firestore
              .collection('academies')
              .doc(config.academyId)
              .collection('payment_configs')
              .doc(config.id)
          : _firestore
              .collection('academies')
              .doc(config.academyId)
              .collection('payment_configs')
              .doc();
      
      // Actualizar con la fecha actual
      final updatedConfig = config.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(updatedConfig.toJson());
      
      // Devolver el modelo con el ID actualizado
      return RepositoryResult.success(updatedConfig.copyWith(id: docRef.id));
    } on FirebaseException catch (e) {
      return RepositoryResult.error(ServerFailure(message: e.message ?? 'Error de Firestore'));
    } catch (e) {
      return RepositoryResult.error(Failure.unexpectedError(error: e));
    }
  }
} 