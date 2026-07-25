import '../../../features/chat/domain/entities/chat_message.dart';
import '../../../features/chat/domain/entities/chat_thread.dart';
import '../../../features/chat/domain/repositories/chat_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [ChatRepository].
class MockChatRepository implements ChatRepository {
  MockChatRepository(this.store);

  final MockSeedStore store;

  static const _threadsKey = 'chat_threads';
  static const _messagesKey = 'chat_messages';

  void _ensureSeeded() {
    if (store.list<ChatThread>(_threadsKey).isNotEmpty) return;
    store.putAll(_threadsKey, [
      ChatThread(
        id: MockIds.chatThread1,
        title: 'Summer Skincare Brief Discussion',
        participantName: 'Arjun Creates',
        participantRole: 'Influencer',
        lastMessageText:
            'Here is the voice note summarizing the campaign deliverables.',
        lastMessageTime: '10:30 AM',
        unreadCount: 1,
        isVoiceAllowed: true,
      ),
      const ChatThread(
        id: 'chat-demo-2',
        title: 'Tech Review Deliverables',
        participantName: 'Priya Brand',
        participantRole: 'Brand',
        lastMessageText: 'I uploaded the video preview link in the assets tab.',
        lastMessageTime: 'Yesterday',
        unreadCount: 0,
        isVoiceAllowed: true,
      ),
      const ChatThread(
        id: 'chat-demo-3',
        title: 'Agency operator coordination',
        participantName: 'Alex Agency',
        participantRole: 'Agency Operator',
        lastMessageText: 'Kanban card moved to content review — please approve assets.',
        lastMessageTime: 'Mon',
        unreadCount: 2,
        isVoiceAllowed: true,
      ),
    ]);

    store.putAll(_messagesKey, [
      ChatMessage(
        id: 'msg-demo-1',
        threadId: MockIds.chatThread1,
        senderId: MockIds.creator1,
        senderName: 'Arjun Creates',
        text: 'Hi! Let us confirm the posting schedule for next week.',
        createdAt: '10:15 AM',
        isMine: false,
      ),
      ChatMessage(
        id: 'msg-demo-2',
        threadId: MockIds.chatThread1,
        senderId: MockIds.brand1,
        senderName: 'Priya Brand',
        text: 'Sure! I have prepared the initial draft and script.',
        createdAt: '10:20 AM',
        isMine: true,
      ),
      ChatMessage(
        id: 'msg-demo-3',
        threadId: MockIds.chatThread1,
        senderId: MockIds.creator1,
        senderName: 'Arjun Creates',
        text: 'Voice note briefing:',
        createdAt: '10:30 AM',
        isMine: false,
        mediaType: 'voice',
        mediaUrl: 'https://cdn.monk.local/audio/voice_note_01.mp3',
        voiceDurationSeconds: 42,
      ),
      ChatMessage(
        id: 'msg-demo-4',
        threadId: 'chat-demo-2',
        senderId: MockIds.brand1,
        senderName: 'Priya Brand',
        text: 'Looking forward to the first cut of the tech review.',
        createdAt: 'Yesterday',
        isMine: true,
      ),
      ChatMessage(
        id: 'msg-demo-5',
        threadId: 'chat-demo-2',
        senderId: MockIds.creator1,
        senderName: 'Arjun Creates',
        text: 'I uploaded the video preview link in the assets tab.',
        createdAt: 'Yesterday',
        isMine: false,
      ),
      ChatMessage(
        id: 'msg-demo-6',
        threadId: 'chat-demo-3',
        senderId: MockIds.agency1,
        senderName: 'Alex Agency',
        text: 'Kanban card moved to content review — please approve assets.',
        createdAt: 'Mon',
        isMine: false,
      ),
    ]);
  }

  String get _meId => store.currentUserId ?? MockIds.brand1;

  String get _meName {
    final account = store.findAccountById(_meId);
    return account?.user.fullName ??
        account?.profileName ??
        'Me';
  }

  ChatMessage _withMine(ChatMessage m) => ChatMessage(
        id: m.id,
        threadId: m.threadId,
        senderId: m.senderId,
        senderName: m.senderName,
        text: m.text,
        createdAt: m.createdAt,
        isMine: m.senderId == _meId,
        mediaType: m.mediaType,
        mediaUrl: m.mediaUrl,
        voiceDurationSeconds: m.voiceDurationSeconds,
      );

  @override
  Future<List<ChatThread>> fetchThreads() async {
    await store.delay();
    _ensureSeeded();
    return store.list<ChatThread>(_threadsKey);
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    await store.delay();
    _ensureSeeded();
    final thread =
        store.findWhere<ChatThread>(_threadsKey, (t) => t.id == threadId);
    if (thread == null) {
      throw NotFoundFailure('Chat thread not found: $threadId');
    }
    // Mark thread as read when opened.
    if (thread.unreadCount > 0) {
      store.replaceWhere<ChatThread>(
        _threadsKey,
        (t) => t.id == threadId,
        thread.copyWith(unreadCount: 0),
      );
    }
    return store
        .list<ChatMessage>(_messagesKey)
        .where((m) => m.threadId == threadId)
        .map(_withMine)
        .toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String threadId,
    required String text,
    String? mediaType,
    String? mediaUrl,
    int? voiceDurationSeconds,
  }) async {
    await store.delay();
    _ensureSeeded();
    final thread =
        store.findWhere<ChatThread>(_threadsKey, (t) => t.id == threadId);
    if (thread == null) {
      throw NotFoundFailure('Chat thread not found: $threadId');
    }
    final trimmed = text.trim();
    final type = mediaType ?? 'text';
    if (type == 'text' && trimmed.isEmpty) {
      throw const ValidationFailure('Message text cannot be empty.');
    }
    final now = DateTime.now();
    final message = ChatMessage(
      id: 'msg-mock-${now.millisecondsSinceEpoch}',
      threadId: threadId,
      senderId: _meId,
      senderName: _meName,
      text: trimmed.isEmpty ? (type == 'voice' ? 'Voice note' : 'Attachment') : trimmed,
      createdAt: 'Just now',
      isMine: true,
      mediaType: type,
      mediaUrl: mediaUrl,
      voiceDurationSeconds: voiceDurationSeconds,
    );
    store.add(_messagesKey, message);
    store.replaceWhere<ChatThread>(
      _threadsKey,
      (t) => t.id == threadId,
      thread.copyWith(
        lastMessageText: message.text,
        lastMessageTime: 'Just now',
        unreadCount: 0,
      ),
    );
    return message;
  }
}
