import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/academy/core/services/academy_repository.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definir el provider para el controlador
final academyControllerProvider = Provider((ref) => AcademyController(ref));

class AcademyController {
  final Ref _ref;
  late final AcademyRepository _academyRepository;

  AcademyController(this._ref) {
    _academyRepository = _ref.read(academyRepositoryProvider);
  }

  // Crear una nueva academia
  Future<Academy> createAcademy({
    required String name,
    required String sport,
    String? academyFormattedAddress,
    double? academyLatitude,
    double? academyLongitude,
    String? academyGooglePlaceId,
    String? taxId,
    String? description,
    Map<String, dynamic>? sportConfig,
    String subscription = 'free',
  }) async {
    developer.log('DEBUG: AcademyController.createAcademy - Iniciando con name=$name, sport=$sport');
    
    final user = _ref.read(authStateProvider).asData?.value;
    if (user == null) {
      developer.log('ERROR: AcademyController.createAcademy - Usuario no autenticado');
      throw Exception('Usuario no autenticado');
    }
    
    developer.log('DEBUG: AcademyController.createAcademy - Usuario autenticado: ${user.id}, role=${user.role}');

    // Verificar si el usuario ya tiene academias
    developer.log('DEBUG: AcademyController.createAcademy - Verificando academias existentes para usuario ${user.id}');
    final existingAcademies = await _academyRepository.getAcademiesByOwner(user.id);
    developer.log('DEBUG: AcademyController.createAcademy - Academias encontradas: ${existingAcademies.length}');
    
    if (existingAcademies.isNotEmpty) {
      developer.log('DEBUG: AcademyController.createAcademy - El usuario ya tiene ${existingAcademies.length} academias');
      throw Exception('El propietario ya tiene una academia creada. No se permite crear múltiples academias.');
    }

    developer.log('DEBUG: AcademyController.createAcademy - Llamando al repositorio para crear academia');
    final academy = await _academyRepository.createAcademy(
      name: name,
      ownerId: user.id,
      sport: sport,
      academyFormattedAddress: academyFormattedAddress,
      academyLatitude: academyLatitude,
      academyLongitude: academyLongitude,
      academyGooglePlaceId: academyGooglePlaceId,
      taxId: taxId,
      description: description,
      sportConfig: sportConfig,
      subscription: subscription,
    );
    
    developer.log('DEBUG: AcademyController.createAcademy - Academia creada exitosamente: ${academy.academyId}');

    // Actualizar la lista de academias
    developer.log('DEBUG: AcademyController.createAcademy - Invalidando providers');
    _ref.invalidate(userAcademiesProvider);
    _ref.invalidate(needsAcademyCreationProvider);
    
    // Establecer como academia actual si es la primera
    developer.log('DEBUG: AcademyController.createAcademy - Obteniendo academias actualizadas');
    final academies = await _ref.read(userAcademiesProvider.future);
    developer.log('DEBUG: AcademyController.createAcademy - Academias actualizadas: ${academies.length}');
    
    if (academies.length == 1) {
      developer.log('DEBUG: AcademyController.createAcademy - Estableciendo como academia actual: ${academy.academyId}');
      _ref.read(currentAcademyProvider.notifier).state = academy;
    }

    return academy;
  }
  
  // Seleccionar una academia
  void selectAcademy(Academy academy) {
    _ref.read(currentAcademyProvider.notifier).state = academy;
  }
  
  // Actualizar una academia
  Future<void> updateAcademy(Academy academy) async {
    await _academyRepository.updateAcademy(academy);
    
    // Actualizar la academia actual si es la misma
    final currentAcademy = _ref.read(currentAcademyProvider);
    if (currentAcademy?.academyId == academy.academyId) {
      _ref.read(currentAcademyProvider.notifier).state = academy;
    }
    
    // Refrescar la lista de academias
    _ref.invalidate(userAcademiesProvider);
  }
  
  // Subir logo de la academia
  Future<String> uploadAcademyLogo(String academyId, String filePath) async {
    final downloadUrl = await _academyRepository.uploadAcademyLogo(academyId, filePath);
    
    // Refrescar la academia actual y la lista
    _ref.invalidate(userAcademiesProvider);
    
    // Obtener la academia actualizada desde el repositorio para asegurar que tenemos todos los campos
    // Esto es importante si la subida del logo se hace inmediatamente después de crear
    final updatedAcademyFromRepo = await _academyRepository.getAcademy(academyId);

    if (updatedAcademyFromRepo != null) {
      developer.log('DEBUG: AcademyController.uploadAcademyLogo - Academia encontrada después de subir logo: ${updatedAcademyFromRepo.academyId}');
      // Actualizar el estado del provider con la academia completa
      _ref.read(currentAcademyProvider.notifier).state = updatedAcademyFromRepo.copyWith(academyLogo: downloadUrl);
    } else {
      developer.log('WARN: AcademyController.uploadAcademyLogo - No se pudo encontrar la academia $academyId después de subir el logo.');
      // Intentar actualizar solo el logo en el estado actual si existe
      final currentAcademy = _ref.read(currentAcademyProvider);
      if (currentAcademy?.academyId == academyId) {
        _ref.read(currentAcademyProvider.notifier).state = currentAcademy!.copyWith(academyLogo: downloadUrl);
      }
    }
    
    return downloadUrl;
  }
  
  // Eliminar academia
  Future<void> deleteAcademy(String academyId) async {
    await _academyRepository.deleteAcademy(academyId);
    
    // Si es la academia actual, establecer a null
    final currentAcademy = _ref.read(currentAcademyProvider);
    if (currentAcademy?.academyId == academyId) {
      _ref.read(currentAcademyProvider.notifier).state = null;
    }
    
    // Refrescar la lista de academias
    _ref.invalidate(userAcademiesProvider);
    _ref.invalidate(needsAcademyCreationProvider);
  }
} 