import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.isMine,
    this.mediaType = 'text', // 'text', 'voice', 'file'
    this.mediaUrl,
    this.voiceDurationSeconds,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String text;
  final String createdAt;
  final bool isMine;
  final String mediaType;
  final String? mediaUrl;
  final int? voiceDurationSeconds;

  @override
  List<Object?> get props => [
        id,
        threadId,
        senderId,
        senderName,
        text,
        createdAt,
        isMine,
        mediaType,
        mediaUrl,
        voiceDurationSeconds,
      ];
}
