import 'package:api_client/api_client.dart';

class FraudRemoteDataSource {
  FraudRemoteDataSource(this._client);
  final MonkApiClient _client;

  Future<Map<String, dynamic>> fetchFraudRiskReport(String entityId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.fraudCheckEntity(entityId),
    );
    return response.data ?? {};
  }
}
