import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  String role; // Almacenamos el enum como String

  @HiveField(4)
  Map<String, bool> permissions;

  @HiveField(5)
  List<String> academyIds;

  @HiveField(6)
  List<String> customRoleIds;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? profileImageUrl;

  @HiveField(9)
  DateTime lastUpdated; // Para sincronización

  UserHiveModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.academyIds,
    required this.customRoleIds,
    required this.createdAt,
    this.profileImageUrl,
    required this.lastUpdated,
  });

  // Convertir de User a UserHiveModel
  factory UserHiveModel.fromUser(User user) {
    return UserHiveModel(
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role.toString(),
      permissions: Map<String, bool>.from(user.permissions),
      academyIds: List<String>.from(user.academyIds),
      customRoleIds: List<String>.from(user.customRoleIds),
      createdAt: user.createdAt,
      profileImageUrl: user.profileImageUrl,
      lastUpdated: DateTime.now(),
    );
  }

  // Convertir UserHiveModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email, 
      'name': name,
      'role': role,
      'permissions': permissions,
      'academyIds': academyIds,
      'customRoleIds': customRoleIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
  
  // Convertir JSON a UserHiveModel
  factory UserHiveModel.fromJson(Map<dynamic, dynamic> json) {
    return UserHiveModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      academyIds: List<String>.from(json['academyIds'] as List),
      customRoleIds: List<String>.from(json['customRoleIds'] as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      profileImageUrl: json['profileImageUrl'] as String?,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
    );
  }

  // Convertir de UserHiveModel a User
  User toUser() {
    return User(
      id: id,
      email: email,
      name: name,
      role: _parseUserRole(role),
      permissions: permissions,
      academyIds: academyIds,
      customRoleIds: customRoleIds,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl,
    );
  }

  // Método para convertir String a UserRole
  UserRole _parseUserRole(String roleStr) {
    return UserRole.values.firstWhere(
      (role) => role.toString() == roleStr,
      orElse: () => UserRole.guest,
    );
  }
} 