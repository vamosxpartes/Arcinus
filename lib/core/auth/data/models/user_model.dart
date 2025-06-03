import 'package:arcinus/core/auth/roles.dart'; // Para AppRole
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart'; // Para fechas

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Representa un usuario de la aplicación.
@freezed
class UserModel with _$UserModel {
  @JsonSerializable(
    explicitToJson: true, 
    converters: [NullableTimestampConverter()]
  )
  const factory UserModel({
    // Usar el UID de Firebase Auth como ID del documento en Firestore
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    // Rol principal del usuario en la app (obtenido de Custom Claims o Firestore)
    // Podría ser útil tenerlo aquí para acceso rápido.
    @JsonKey(name: 'role')
    @Default(AppRole.desconocido) AppRole appRole,
    // Indica si el perfil inicial se ha completado
    @Default(false) bool profileCompleted,
    // Fecha de creación del usuario (registro inicial)
    DateTime? createdAt,
    // Última actualización del perfil
    DateTime? updatedAt,
    // Otros campos específicos de la app podrían ir aquí
    // String? phoneNumber,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
} 