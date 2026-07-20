import 'package:api_client/api_client.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final MonkApiClient _client;

  @override
  Future<List<ChatThread>> fetchThreads() async {
    try {
      final response = await _client.dio.get(ApiPaths.chatThreads);
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return data.map((t) => _mapThread(t as Map<String, dynamic>)).toList();
      }
      return _defaultMockThreads();
    } catch (e) {
      return _defaultMockThreads();
    }
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    try {
      final response = await _client.dio.get(ApiPaths.chatThreadMessages(threadId));
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return data.map((m) => _mapMessage(m as Map<String, dynamic>)).toList();
      }
      return _defaultMockMessages(threadId);
    } catch (e) {
      return _defaultMockMessages(threadId);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String threadId,
    required String text,
    String? mediaType,
    String? mediaUrl,
    int? voiceDurationSeconds,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiPaths.chatThreadMessages(threadId),
        data: {
          'text': text,
          'mediaType': mediaType ?? 'text',
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (voiceDurationSeconds != null) 'voiceDurationSeconds': voiceDurationSeconds,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapMessage(data);
      }
      return ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        threadId: threadId,
        senderId: 'me',
        senderName: 'Me',
        text: text,
        createdAt: 'Just now',
        isMine: true,
        mediaType: mediaType ?? 'text',
        mediaUrl: mediaUrl,
        voiceDurationSeconds: voiceDurationSeconds,
      );
    } catch (e) {
      return ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        threadId: threadId,
        senderId: 'me',
        senderName: 'Me',
        text: text,
        createdAt: 'Just now',
        isMine: true,
        mediaType: mediaType ?? 'text',
        mediaUrl: mediaUrl,
        voiceDurationSeconds: voiceDurationSeconds,
      );
    }
  }

  ChatThread _mapThread(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String? ?? 'thread-1',
      title: json['title'] as String? ?? 'Campaign Discussion',
      participantName: json['participantName'] as String? ?? 'John Manager',
      participantRole: json['participantRole'] as String? ?? 'Agency Manager',
      lastMessageText: json['lastMessageText'] as String? ?? 'Sounds great, let us proceed!',
      lastMessageTime: json['lastMessageTime'] as String? ?? '10:45 AM',
      unreadCount: json['unreadCount'] as int? ?? 0,
      isVoiceAllowed: json['isVoiceAllowed'] as bool? ?? true,
    );
  }

  ChatMessage _mapMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? 'msg-1',
      threadId: json['threadId'] as String? ?? 'thread-1',
      senderId: json['senderId'] as String? ?? 'user-1',
      senderName: json['senderName'] as String? ?? 'Sender',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '10:00 AM',
      isMine: json['isMine'] as bool? ?? false,
      mediaType: json['mediaType'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      voiceDurationSeconds: json['voiceDurationSeconds'] as int?,
    );
  }

  List<ChatThread> _defaultMockThreads() {
    return const [
      ChatThread(
        id: 'thread-1',
        title: 'Summer Skincare Brief Discussion',
        participantName: 'Sarah Jenkins',
        participantRole: 'Agency Lead',
        lastMessageText: 'Here is the voice note summarizing the campaign deliverables.',
        lastMessageTime: '10:30 AM',
        unreadCount: 1,
        isVoiceAllowed: true,
      ),
      ChatThread(
        id: 'thread-2',
        title: 'Tech Review Deliverables',
        participantName: 'Alex Rivera',
        participantRole: 'Influencer',
        lastMessageText: 'I uploaded the video preview link in the assets tab.',
        lastMessageTime: 'Yesterday',
        unreadCount: 0,
        isVoiceAllowed: true,
      ),
    ];
  }

  List<ChatMessage> _defaultMockMessages(String threadId) {
    return [
      ChatMessage(
        id: 'msg-1',
        threadId: threadId,
        senderId: 'other-1',
        senderName: 'Sarah Jenkins',
        text: 'Hi! Let us confirm the posting schedule for next week.',
        createdAt: '10:15 AM',
        isMine: false,
      ),
      ChatMessage(
        id: 'msg-2',
        threadId: threadId,
        senderId: 'me',
        senderName: 'Me',
        text: 'Sure! I have prepared the initial draft and script.',
        createdAt: '10:20 AM',
        isMine: true,
      ),
      ChatMessage(
        id: 'msg-3',
        threadId: threadId,
        senderId: 'other-1',
        senderName: 'Sarah Jenkins',
        text: 'Voice note briefing:',
        createdAt: '10:30 AM',
        isMine: false,
        mediaType: 'voice',
        mediaUrl: 'https://cdn.monk.com/audio/voice_note_01.mp3',
        voiceDurationSeconds: 42,
      ),
    ];
  }
}
