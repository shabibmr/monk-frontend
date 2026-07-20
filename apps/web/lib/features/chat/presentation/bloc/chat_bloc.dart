import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repository) : super(const ChatState()) {
    on<LoadChatThreads>(_onLoadThreads);
    on<SelectThreadEvent>(_onSelectThread);
    on<SendTextMessageEvent>(_onSendTextMessage);
    on<SendVoiceNoteMessageEvent>(_onSendVoiceNoteMessage);
    on<ToggleVoicePlaybackEvent>(_onToggleVoicePlayback);
  }

  final ChatRepository _repository;

  Future<void> _onLoadThreads(
    LoadChatThreads event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(phase: ChatPhase.loading));
    try {
      final threads = await _repository.fetchThreads();
      final initialThreadId = threads.isNotEmpty ? threads.first.id : null;
      List<dynamic> initialMessages = [];
      if (initialThreadId != null) {
        initialMessages = await _repository.fetchMessages(initialThreadId);
      }
      emit(
        state.copyWith(
          phase: ChatPhase.success,
          threads: threads,
          selectedThreadId: initialThreadId,
          messages: initialMessages.cast(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: ChatPhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSelectThread(
    SelectThreadEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedThreadId: event.threadId,
        phase: ChatPhase.loading,
      ),
    );
    try {
      final messages = await _repository.fetchMessages(event.threadId);
      emit(
        state.copyWith(
          phase: ChatPhase.success,
          messages: messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: ChatPhase.failure,
          errorMessage: 'Failed to load messages: $e',
        ),
      );
    }
  }

  Future<void> _onSendTextMessage(
    SendTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.text.trim().isEmpty) return;
    emit(state.copyWith(isSending: true));
    try {
      final msg = await _repository.sendMessage(
        threadId: event.threadId,
        text: event.text,
      );
      final updatedList = [...state.messages, msg];
      emit(
        state.copyWith(
          messages: updatedList,
          isSending: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Failed to send message: $e',
        ),
      );
    }
  }

  Future<void> _onSendVoiceNoteMessage(
    SendVoiceNoteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isSending: true));
    try {
      final msg = await _repository.sendMessage(
        threadId: event.threadId,
        text: 'Voice message (${event.durationSeconds}s)',
        mediaType: 'voice',
        mediaUrl: event.mediaUrl,
        voiceDurationSeconds: event.durationSeconds,
      );
      final updatedList = [...state.messages, msg];
      emit(
        state.copyWith(
          messages: updatedList,
          isSending: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Failed to send voice note: $e',
        ),
      );
    }
  }

  void _onToggleVoicePlayback(
    ToggleVoicePlaybackEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state.playingVoiceMessageId == event.messageId) {
      emit(state.copyWith(playingVoiceMessageId: null));
    } else {
      emit(state.copyWith(playingVoiceMessageId: event.messageId));
    }
  }
}
