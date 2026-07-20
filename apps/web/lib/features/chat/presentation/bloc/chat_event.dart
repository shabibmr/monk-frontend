import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatThreads extends ChatEvent {
  const LoadChatThreads();
}

class SelectThreadEvent extends ChatEvent {
  const SelectThreadEvent(this.threadId);
  final String threadId;

  @override
  List<Object?> get props => [threadId];
}

class SendTextMessageEvent extends ChatEvent {
  const SendTextMessageEvent({
    required this.threadId,
    required this.text,
  });

  final String threadId;
  final String text;

  @override
  List<Object?> get props => [threadId, text];
}

class SendVoiceNoteMessageEvent extends ChatEvent {
  const SendVoiceNoteMessageEvent({
    required this.threadId,
    required this.mediaUrl,
    required this.durationSeconds,
  });

  final String threadId;
  final String mediaUrl;
  final int durationSeconds;

  @override
  List<Object?> get props => [threadId, mediaUrl, durationSeconds];
}

class ToggleVoicePlaybackEvent extends ChatEvent {
  const ToggleVoicePlaybackEvent(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}
