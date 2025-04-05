import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  info,
  payment,
  event,
  message,
  attendance,
  invitation,
  system
}

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime timestamp,
    @Default(false) bool isRead,
    Map<String, dynamic>? data,
  }) = _Notification;
  
  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
} 