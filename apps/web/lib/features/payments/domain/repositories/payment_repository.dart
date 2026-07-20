import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Payment> fund(String collaborationId);
  Future<List<Payment>> listPayments(String collaborationId);
  Future<Payment> release(String paymentId);
  Future<Payment> refund(String paymentId, {int? amountMinor});
  Future<Earnings> earnings(String profileId);
  Future<PayoutRequest> requestPayout(String profileId, {required int amountMinor});
  Future<void> confirmPayout(String payoutId, {String? token});
  Future<List<Invoice>> listInvoices();
  Future<Invoice> getInvoice(String id);
}
