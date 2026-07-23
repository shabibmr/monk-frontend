import '../../domain/entities/fraud_risk_report.dart';
import '../../domain/repositories/fraud_repository.dart';
import '../datasources/fraud_remote_datasource.dart';

class FraudRepositoryImpl implements FraudRepository {
  FraudRepositoryImpl(this.remote);

  final FraudRemoteDataSource remote;

  @override
  Future<FraudRiskReport> getFraudRiskReport(String entityId) async {
    final json = await remote.fetchFraudRiskReport(entityId);
    return FraudRiskReport.fromJson(json, entityId);
  }
}
