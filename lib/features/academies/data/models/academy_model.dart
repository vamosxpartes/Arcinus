import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

/// Modelo de academia deportiva
class AcademyModel extends Equatable {
  final String? id;
  final String ownerId;
  final String name;
  final String sportCode;
  final String? description;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String location;

  const AcademyModel({
    this.id,
    required this.ownerId,
    required this.name,
    required this.sportCode,
    this.description,
    this.logoUrl,
    this.address,
    this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
    required this.location,
  });

  @override
  List<Object?> get props => [
    id, ownerId, name, sportCode, description, 
    logoUrl, address, phone, email, 
    createdAt, updatedAt, location
  ];

  AcademyModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? sportCode,
    String? description,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
  }) {
    return AcademyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      sportCode: sportCode ?? this.sportCode,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
    );
  }

  /// Crea un AcademyModel desde un Map de Firestore
  factory AcademyModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return AcademyModel(
      id: docId,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      sportCode: json['sportCode'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      location: json['location'] as String,
    );
  }

  /// Convierte la academia a un Map para Firestore
  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'sportCode': sportCode,
      'description': description,
      'logoUrl': logoUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'location': location,
    };
  }
}
