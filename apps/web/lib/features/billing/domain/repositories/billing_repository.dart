import '../entities/billing_invoice.dart';
import '../entities/subscription_details.dart';
import '../entities/subscription_plan.dart';

abstract class BillingRepository {
  Future<SubscriptionDetails> getCurrentSubscription();
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<List<BillingInvoice>> getInvoiceHistory();
  Future<SubscriptionDetails> subscribeToPlan(String planId);
}
