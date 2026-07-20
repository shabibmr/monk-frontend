import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/payment_models.dart';

class PaymentsApi {
  PaymentsApi(this._dio);
  final Dio _dio;

  Future<PaymentDto> fund(String collaborationId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationFunding(collaborationId),
    );
    return PaymentDto.fromJson(res.data!);
  }

  Future<List<PaymentDto>> listPayments(String collaborationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationPayments(collaborationId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => PaymentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentDto> release(String paymentId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.paymentRelease(paymentId),
    );
    return PaymentDto.fromJson(res.data!);
  }

  Future<PaymentDto> refund(String paymentId, {int? amountMinor}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.paymentRefund(paymentId),
      data: {
        if (amountMinor != null) 'amountMinor': amountMinor,
      },
    );
    return PaymentDto.fromJson(res.data!);
  }

  Future<EarningsDto> earnings(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileEarnings(profileId),
    );
    return EarningsDto.fromJson(res.data!);
  }

  Future<PayoutRequestDto> requestPayout(
    String profileId, {
    required int amountMinor,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.profilePayouts(profileId),
      data: {'amountMinor': amountMinor},
    );
    return PayoutRequestDto.fromJson(res.data!);
  }

  Future<Map<String, dynamic>> confirmPayout(
    String payoutId, {
    String? token,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.payoutConfirm(payoutId),
      data: {
        if (token != null) 'token': token,
      },
    );
    return res.data ?? const {};
  }

  Future<List<InvoiceDto>> listInvoices() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.invoices);
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => InvoiceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InvoiceDto> getInvoice(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.invoice(id));
    return InvoiceDto.fromJson(res.data!);
  }
}
