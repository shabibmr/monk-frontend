import '../entities/chat_message.dart';
import '../entities/chat_thread.dart';

abstract class ChatRepository {
  Future<List<ChatThread>> fetchThreads();
  Future<List<ChatMessage>> fetchMessages(String threadId);
  Future<ChatMessage> sendMessage({
    required String threadId,
    required String text,
    String? mediaType,
    String? mediaUrl,
    int? voiceDurationSeconds,
  });
}
