import '../../domain/entities/billing_invoice.dart';
import '../../domain/entities/subscription_details.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(this._remoteDataSource);

  final BillingRemoteDataSource _remoteDataSource;

  @override
  Future<SubscriptionDetails> getCurrentSubscription() {
    return _remoteDataSource.getCurrentSubscription();
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() {
    return _remoteDataSource.getAvailablePlans();
  }

  @override
  Future<List<BillingInvoice>> getInvoiceHistory() {
    return _remoteDataSource.getInvoiceHistory();
  }

  @override
  Future<SubscriptionDetails> subscribeToPlan(String planId) {
    return _remoteDataSource.subscribeToPlan(planId);
  }
}
