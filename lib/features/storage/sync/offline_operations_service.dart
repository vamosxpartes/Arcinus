import 'dart:async';
import 'package:arcinus/features/storage/hive/hive_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

enum OperationType {
  create,
  update,
  delete,
}

class OfflineOperation {
  final String id;
  final String entity; // El tipo de entidad (user, academy, etc.)
  final String entityId; // El ID de la entidad afectada
  final OperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isCompleted;

  OfflineOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': entity,
      'entityId': entityId,
      'type': type.toString(),
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  factory OfflineOperation.fromJson(Map<dynamic, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      entity: json['entity'] as String,
      entityId: json['entityId'] as String,
      type: _parseOperationType(json['type'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static OperationType _parseOperationType(String typeStr) {
    return OperationType.values.firstWhere(
      (type) => type.toString() == typeStr,
      orElse: () => OperationType.create,
    );
  }
}

/// Proveedor para el servicio de operaciones offline
final offlineOperationsServiceProvider = Provider<OfflineOperationsService>((ref) {
  return OfflineOperationsService();
});

/// Servicio para gestionar operaciones offline
class OfflineOperationsService {
  Box<dynamic>? _operationsBox;
  final StreamController<OfflineOperation> _operationController = StreamController<OfflineOperation>.broadcast();
  Stream<OfflineOperation> get operationStream => _operationController.stream;

  OfflineOperationsService() {
    _init();
  }

  Future<void> _init() async {
    _operationsBox = Hive.box(HiveConfig.operationsQueueBox);
  }

  /// Registra una operación para ser sincronizada cuando haya conexión
  Future<void> enqueueOperation(
    String entity,
    String entityId,
    OperationType type,
    Map<String, dynamic> data,
  ) async {
    try {
      final operation = OfflineOperation(
        id: const Uuid().v4(),
        entity: entity,
        entityId: entityId,
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );

      // Guardar en Hive
      await _operationsBox?.put(operation.id, operation.toJson());

      // Notificar a través del stream
      _operationController.add(operation);

      debugPrint('Operación offline encolada: ${operation.id} - ${operation.entity} - ${operation.type}');
    } catch (e) {
      debugPrint('Error al encolar operación offline: $e');
      rethrow;
    }
  }

  /// Marca una operación como completada
  Future<void> markOperationAsCompleted(String operationId) async {
    try {
      final operationData = _operationsBox?.get(operationId);
      if (operationData != null) {
        final operation = OfflineOperation.fromJson(
          Map<dynamic, dynamic>.from(operationData as Map),
        );
        final updatedOperation = OfflineOperation(
          id: operation.id,
          entity: operation.entity,
          entityId: operation.entityId,
          type: operation.type,
          data: operation.data,
          createdAt: operation.createdAt,
          isCompleted: true,
        );

        await _operationsBox?.put(operationId, updatedOperation.toJson());
      }
    } catch (e) {
      debugPrint('Error al marcar operación como completada: $e');
      rethrow;
    }
  }

  /// Elimina una operación de la cola
  Future<void> removeOperation(String operationId) async {
    try {
      await _operationsBox?.delete(operationId);
    } catch (e) {
      debugPrint('Error al eliminar operación: $e');
      rethrow;
    }
  }

  /// Obtiene todas las operaciones pendientes
  List<OfflineOperation> getPendingOperations() {
    try {
      final operations = <OfflineOperation>[];
      
      _operationsBox?.values.forEach((operationData) {
        final operation = OfflineOperation.fromJson(
          Map<dynamic, dynamic>.from(operationData as Map),
        );
        if (!operation.isCompleted) {
          operations.add(operation);
        }
      });
      
      // Ordenar por fecha de creación
      operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return operations;
    } catch (e) {
      debugPrint('Error al obtener operaciones pendientes: $e');
      return [];
    }
  }

  /// Elimina todas las operaciones completadas
  Future<void> clearCompletedOperations() async {
    try {
      final completedIds = <String>[];
      
      _operationsBox?.values.forEach((operationData) {
        final operation = OfflineOperation.fromJson(
          Map<dynamic, dynamic>.from(operationData as Map),
        );
        if (operation.isCompleted) {
          completedIds.add(operation.id);
        }
      });
      
      for (final id in completedIds) {
        await _operationsBox?.delete(id);
      }
      
      debugPrint('Se eliminaron ${completedIds.length} operaciones completadas');
    } catch (e) {
      debugPrint('Error al limpiar operaciones completadas: $e');
      rethrow;
    }
  }

  /// Cierra el servicio y libera recursos
  void dispose() {
    _operationController.close();
  }
} 