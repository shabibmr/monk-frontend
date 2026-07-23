import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.title,
    required this.participantName,
    required this.participantRole,
    required this.lastMessageText,
    required this.lastMessageTime,
    required this.unreadCount,
    this.isVoiceAllowed = true,
  });

  final String id;
  final String title;
  final String participantName;
  final String participantRole;
  final String lastMessageText;
  final String lastMessageTime;
  final int unreadCount;
  final bool isVoiceAllowed;

  ChatThread copyWith({
    String? id,
    String? title,
    String? participantName,
    String? participantRole,
    String? lastMessageText,
    String? lastMessageTime,
    int? unreadCount,
    bool? isVoiceAllowed,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      participantName: participantName ?? this.participantName,
      participantRole: participantRole ?? this.participantRole,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isVoiceAllowed: isVoiceAllowed ?? this.isVoiceAllowed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        participantName,
        participantRole,
        lastMessageText,
        lastMessageTime,
        unreadCount,
        isVoiceAllowed,
      ];
}
