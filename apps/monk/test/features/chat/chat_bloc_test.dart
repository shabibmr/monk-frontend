import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/chat/domain/entities/chat_message.dart';
import 'package:monk_web/features/chat/domain/entities/chat_thread.dart';
import 'package:monk_web/features/chat/domain/repositories/chat_repository.dart';
import 'package:monk_web/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:monk_web/features/chat/presentation/bloc/chat_event.dart';
import 'package:monk_web/features/chat/presentation/bloc/chat_state.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository repo;

  const thread1 = ChatThread(
    id: 't1',
    title: 'Skincare Brief Thread',
    participantName: 'Sarah Manager',
    participantRole: 'Agency Lead',
    lastMessageText: 'Hello',
    lastMessageTime: '10:00 AM',
    unreadCount: 0,
    isVoiceAllowed: true,
  );

  const msg1 = ChatMessage(
    id: 'm1',
    threadId: 't1',
    senderId: 'sarah',
    senderName: 'Sarah Manager',
    text: 'Hello',
    createdAt: '10:00 AM',
    isMine: false,
  );

  setUp(() {
    repo = _MockChatRepository();
  });

  group('ChatBloc', () {
    blocTest<ChatBloc, ChatState>(
      'loads threads and initial thread messages successfully',
      build: () {
        when(() => repo.fetchThreads()).thenAnswer((_) async => [thread1]);
        when(() => repo.fetchMessages('t1')).thenAnswer((_) async => [msg1]);
        return ChatBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadChatThreads()),
      expect: () => [
        const ChatState(phase: ChatPhase.loading),
        const ChatState(
          phase: ChatPhase.success,
          threads: [thread1],
          selectedThreadId: 't1',
          messages: [msg1],
        ),
      ],
      verify: (_) {
        verify(() => repo.fetchThreads()).called(1);
        verify(() => repo.fetchMessages('t1')).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'selects thread and loads messages',
      build: () {
        when(() => repo.fetchMessages('t2')).thenAnswer(
          (_) async => [
            const ChatMessage(
              id: 'm2',
              threadId: 't2',
              senderId: 'me',
              senderName: 'Me',
              text: 'Thread 2 message',
              createdAt: '11:00 AM',
              isMine: true,
            ),
          ],
        );
        return ChatBloc(repo);
      },
      act: (bloc) => bloc.add(const SelectThreadEvent('t2')),
      expect: () => [
        const ChatState(
          selectedThreadId: 't2',
          phase: ChatPhase.loading,
        ),
        const ChatState(
          selectedThreadId: 't2',
          phase: ChatPhase.success,
          messages: [
            ChatMessage(
              id: 'm2',
              threadId: 't2',
              senderId: 'me',
              senderName: 'Me',
              text: 'Thread 2 message',
              createdAt: '11:00 AM',
              isMine: true,
            ),
          ],
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'sends text message successfully',
      seed: () => const ChatState(
        selectedThreadId: 't1',
        messages: [msg1],
      ),
      build: () {
        when(
          () => repo.sendMessage(
            threadId: 't1',
            text: 'I accept',
          ),
        ).thenAnswer(
          (_) async => const ChatMessage(
            id: 'm-new',
            threadId: 't1',
            senderId: 'me',
            senderName: 'Me',
            text: 'I accept',
            createdAt: '10:05 AM',
            isMine: true,
          ),
        );
        return ChatBloc(repo);
      },
      act: (bloc) => bloc.add(
        const SendTextMessageEvent(
          threadId: 't1',
          text: 'I accept',
        ),
      ),
      expect: () => [
        const ChatState(
          selectedThreadId: 't1',
          messages: [msg1],
          isSending: true,
        ),
        const ChatState(
          selectedThreadId: 't1',
          isSending: false,
          messages: [
            msg1,
            ChatMessage(
              id: 'm-new',
              threadId: 't1',
              senderId: 'me',
              senderName: 'Me',
              text: 'I accept',
              createdAt: '10:05 AM',
              isMine: true,
            ),
          ],
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'toggles voice note playback state',
      build: () => ChatBloc(repo),
      act: (bloc) => bloc.add(const ToggleVoicePlaybackEvent('m-voice-1')),
      expect: () => [
        const ChatState(playingVoiceMessageId: 'm-voice-1'),
      ],
    );
  });
}
