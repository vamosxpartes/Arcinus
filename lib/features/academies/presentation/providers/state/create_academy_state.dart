import 'package:arcinus/core/utils/error/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:io';

part 'create_academy_state.freezed.dart';

/// Enum para los pasos del formulario de creación de academia
enum FormStep {
  basicInfo,    // Paso 1: Información básica
  contactInfo,  // Paso 2: Información de contacto
  logoImage     // Paso 3: Logo e imagen
}

/// Enum para el estado de carga de la imagen
enum ImageUploadStatus {
  notStarted,   // Aún no se ha iniciado la carga
  selecting,    // Usuario seleccionando la imagen
  selected,     // Imagen seleccionada, pendiente de cargar
  uploading,    // Cargando la imagen
  success,      // Imagen cargada exitosamente
  error         // Error al cargar la imagen
}

@freezed
sealed class CreateAcademyState with _$CreateAcademyState {
  /// Estado inicial o inactivo.
  const factory CreateAcademyState.initial({
    @Default(FormStep.basicInfo) FormStep currentStep,
    @Default(ImageUploadStatus.notStarted) ImageUploadStatus imageStatus,
    File? logoFile,
    String? nameError,
    String? sportCodeError,
    String? emailError,
    @Default(false) bool formIsValid,
  }) = _Initial;

  /// Estado mientras se navega entre pasos.
  const factory CreateAcademyState.navigating({
    required FormStep currentStep,
    required FormStep previousStep,
    @Default(ImageUploadStatus.notStarted) ImageUploadStatus imageStatus,
    File? logoFile,
    String? nameError,
    String? sportCodeError,
    String? emailError,
    @Default(false) bool formIsValid,
  }) = _Navigating;

  /// Estado mientras se selecciona una imagen
  const factory CreateAcademyState.selectingImage({
    required FormStep currentStep,
    @Default(ImageUploadStatus.selecting) ImageUploadStatus imageStatus,
    File? logoFile,
    @Default(false) bool formIsValid,
  }) = _SelectingImage;

  /// Estado mientras se guarda la academia.
  const factory CreateAcademyState.loading({
    required FormStep currentStep,
    @Default(ImageUploadStatus.uploading) ImageUploadStatus imageStatus,
    File? logoFile,
    @Default(false) bool formIsValid,
  }) = _Loading;

  /// Estado de éxito tras guardar la academia.
  const factory CreateAcademyState.success(
    String academyId, {
    @Default(true) bool formIsValid,
  }) = _Success;

  /// Estado de error al guardar.
  const factory CreateAcademyState.error(
    Failure failure, {
    @Default(FormStep.basicInfo) FormStep currentStep,
    @Default(ImageUploadStatus.notStarted) ImageUploadStatus imageStatus,
    File? logoFile,
    String? nameError,
    String? sportCodeError,
    String? emailError,
    @Default(false) bool formIsValid,
  }) = _Error;
} 