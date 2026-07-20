import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._client);
  final MonkApiClient _client;

  Payment _mapPayment(PaymentDto d) => Payment(
        id: d.id,
        collaborationId: d.collaborationId,
        brandId: d.brandId,
        amountMinor: d.amountMinor,
        currency: d.currency,
        status: d.status,
        commissionPct: d.commissionPct,
        commissionMinor: d.commissionMinor,
        payoutMinor: d.payoutMinor,
        gatewayOrderId: d.gatewayOrderId,
        checkout: d.checkout,
      );

  @override
  Future<Payment> fund(String collaborationId) async {
    try {
      return _mapPayment(await _client.payments.fund(collaborationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Payment>> listPayments(String collaborationId) async {
    try {
      final list = await _client.payments.listPayments(collaborationId);
      return list.map(_mapPayment).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Payment> release(String paymentId) async {
    try {
      return _mapPayment(await _client.payments.release(paymentId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Payment> refund(String paymentId, {int? amountMinor}) async {
    try {
      return _mapPayment(
        await _client.payments.refund(paymentId, amountMinor: amountMinor),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Earnings> earnings(String profileId) async {
    try {
      final d = await _client.payments.earnings(profileId);
      return Earnings(
        profileId: d.profileId,
        pendingMinor: d.pendingMinor,
        availableMinor: d.availableMinor,
        withdrawnMinor: d.withdrawnMinor,
        currency: d.currency,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<PayoutRequest> requestPayout(
    String profileId, {
    required int amountMinor,
  }) async {
    try {
      final d = await _client.payments.requestPayout(
        profileId,
        amountMinor: amountMinor,
      );
      return PayoutRequest(
        id: d.id,
        status: d.status,
        amountMinor: d.amountMinor,
        currency: d.currency,
        requiresOwnerConfirmation: d.requiresOwnerConfirmation,
        confirmationToken: d.confirmationToken,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> confirmPayout(String payoutId, {String? token}) async {
    try {
      await _client.payments.confirmPayout(payoutId, token: token);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Invoice>> listInvoices() async {
    try {
      final list = await _client.payments.listInvoices();
      return list
          .map(
            (d) => Invoice(
              id: d.id,
              number: d.number,
              type: d.type,
              totalMinor: d.totalMinor,
              currency: d.currency,
              taxTotalMinor: d.taxTotalMinor,
              lineItems: d.lineItems,
              createdAt: d.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Invoice> getInvoice(String id) async {
    try {
      final d = await _client.payments.getInvoice(id);
      return Invoice(
        id: d.id,
        number: d.number,
        type: d.type,
        totalMinor: d.totalMinor,
        currency: d.currency,
        taxTotalMinor: d.taxTotalMinor,
        lineItems: d.lineItems,
        createdAt: d.createdAt,
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}
