import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  superAdmin, // Supervisor de la aplicación (equipo de Arcinus)
  owner,      // Propietario de la academia
  manager,    // Gerente administrativo
  coach,      // Entrenador
  athlete,    // Atleta
  parent,     // Padre/responsable
  guest       // Usuario no registrado
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required Map<String, bool> permissions,
    @Default([]) List<String> academyIds,
    required DateTime createdAt,
    String? profileImageUrl,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  factory User.empty() => User(
    id: '',
    email: '',
    name: '',
    role: UserRole.guest,
    permissions: {},
    academyIds: [],
    createdAt: DateTime.now(),
  );
} 