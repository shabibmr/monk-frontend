import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_thread.dart';

enum ChatPhase { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.phase = ChatPhase.initial,
    this.threads = const [],
    this.selectedThreadId,
    this.messages = const [],
    this.isSending = false,
    this.playingVoiceMessageId,
    this.errorMessage,
  });

  final ChatPhase phase;
  final List<ChatThread> threads;
  final String? selectedThreadId;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? playingVoiceMessageId;
  final String? errorMessage;

  ChatThread? get selectedThread {
    if (selectedThreadId == null) return null;
    try {
      return threads.firstWhere((t) => t.id == selectedThreadId);
    } catch (_) {
      return null;
    }
  }

  ChatState copyWith({
    ChatPhase? phase,
    List<ChatThread>? threads,
    String? selectedThreadId,
    List<ChatMessage>? messages,
    bool? isSending,
    String? playingVoiceMessageId,
    String? errorMessage,
  }) {
    return ChatState(
      phase: phase ?? this.phase,
      threads: threads ?? this.threads,
      selectedThreadId: selectedThreadId ?? this.selectedThreadId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      playingVoiceMessageId: playingVoiceMessageId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        threads,
        selectedThreadId,
        messages,
        isSending,
        playingVoiceMessageId,
        errorMessage,
      ];
}
