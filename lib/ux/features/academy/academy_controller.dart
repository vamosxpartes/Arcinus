import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/academy/academy_repository.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
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
    String? logo,
    String? location,
    String? taxId,
    String? description,
    Map<String, dynamic>? sportCharacteristics,
    String subscription = 'free',
  }) async {
    final user = _ref.read(authStateProvider).asData?.value;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    // Verificar si el usuario ya tiene academias
    final existingAcademies = await _academyRepository.getAcademiesByOwner(user.id);
    if (existingAcademies.isNotEmpty) {
      throw Exception('El propietario ya tiene una academia creada. No se permite crear múltiples academias.');
    }

    final academy = await _academyRepository.createAcademy(
      name: name,
      ownerId: user.id,
      sport: sport,
      logo: logo,
      location: location,
      taxId: taxId,
      description: description,
      sportCharacteristics: sportCharacteristics,
      subscription: subscription,
    );

    // Actualizar la lista de academias
    _ref.invalidate(userAcademiesProvider);
    _ref.invalidate(needsAcademyCreationProvider);
    
    // Establecer como academia actual si es la primera
    final academies = await _ref.read(userAcademiesProvider.future);
    if (academies.length == 1) {
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
    if (currentAcademy?.id == academy.id) {
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
    
    final currentAcademy = _ref.read(currentAcademyProvider);
    if (currentAcademy?.id == academyId) {
      final updatedAcademy = currentAcademy!.copyWith(logo: downloadUrl);
      _ref.read(currentAcademyProvider.notifier).state = updatedAcademy;
    }
    
    return downloadUrl;
  }
  
  // Eliminar academia
  Future<void> deleteAcademy(String academyId) async {
    await _academyRepository.deleteAcademy(academyId);
    
    // Si es la academia actual, establecer a null
    final currentAcademy = _ref.read(currentAcademyProvider);
    if (currentAcademy?.id == academyId) {
      _ref.read(currentAcademyProvider.notifier).state = null;
    }
    
    // Refrescar la lista de academias
    _ref.invalidate(userAcademiesProvider);
    _ref.invalidate(needsAcademyCreationProvider);
  }
} 