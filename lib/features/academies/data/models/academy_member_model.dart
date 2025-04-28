import 'package:arcinus/core/auth/app_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_member_model.freezed.dart';
part 'academy_member_model.g.dart';

// Helper function for Firestore Timestamps
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

@freezed
class AcademyMemberModel with _$AcademyMemberModel {
  @JsonSerializable(explicitToJson: true)
  const factory AcademyMemberModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id, // Document ID from Firestore
    required String academyId,
    String? firebaseUserId, // Null if not an authenticated user
    required AppRole role,
    String? name, // Name stored here if not an authenticated user, or for display
    String? email, // Email stored here if not an authenticated user
    // Permissions specific to collaborators
    List<String>? permissions, // e.g., ['manage_groups', 'record_attendance']
    @JsonKey(
      fromJson: _dateTimeFromTimestamp,
      toJson: _dateTimeToTimestamp,
    )
    DateTime? joinedAt,
  }) = _AcademyMemberModel;

  factory AcademyMemberModel.fromJson(Map<String, dynamic> json) =>
      _$AcademyMemberModelFromJson(json);
} 