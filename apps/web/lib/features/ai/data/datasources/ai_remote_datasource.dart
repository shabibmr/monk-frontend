import 'package:api_client/api_client.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._client);
  final MonkApiClient _client;

  Future<Map<String, dynamic>> generateAiAssist({
    required String assistType,
    required Map<String, dynamic> context,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiPaths.aiAssist,
      data: {
        'assistType': assistType,
        'context': context,
      },
    );
    return response.data ?? {};
  }
}
