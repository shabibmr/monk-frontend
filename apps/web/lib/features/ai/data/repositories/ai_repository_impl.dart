import '../../../../core/network/api_client_factory.dart';
import '../../domain/entities/ai_assist_result.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    required this.remote,
    required this.config,
  });

  final AiRemoteDataSource remote;
  final AppConfig config;

  @override
  bool isAiEnabled() => config.enableAi;

  @override
  Future<AiAssistResult> requestAiAssist({
    required String assistType,
    required Map<String, dynamic> context,
  }) async {
    if (!isAiEnabled()) {
      throw Exception('AI feature is currently disabled by configuration.');
    }
    final rawJson = await remote.generateAiAssist(
      assistType: assistType,
      context: context,
    );
    return AiAssistResult.fromJson(rawJson, assistType);
  }
}
