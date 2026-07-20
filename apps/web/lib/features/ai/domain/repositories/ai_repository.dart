import '../entities/ai_assist_result.dart';

abstract class AiRepository {
  Future<AiAssistResult> requestAiAssist({
    required String assistType,
    required Map<String, dynamic> context,
  });

  bool isAiEnabled();
}
