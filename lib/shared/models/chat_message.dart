import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatMessageType {
  text,
  image,
  file,
  system
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String chatId,
    required String content,
    required DateTime timestamp,
    @Default(false) bool isRead,
    @Default(ChatMessageType.text) ChatMessageType type,
    String? attachmentUrl,
  }) = _ChatMessage;
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String name,
    required List<String> participantIds,
    required DateTime createdAt,
    required DateTime lastMessageAt,
    String? lastMessageContent,
    @Default(false) bool isGroup,
    String? avatarUrl,
  }) = _Chat;
  
  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
} 