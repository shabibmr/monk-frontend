class ErrorEnvelope {
  const ErrorEnvelope({
    required this.statusCode,
    required this.errorCode,
    required this.message,
    this.details,
    this.requestId,
  });

  final int statusCode;
  final String errorCode;
  final String message;
  final Object? details;
  final String? requestId;

  factory ErrorEnvelope.fromJson(Map<String, dynamic> json) {
    return ErrorEnvelope(
      statusCode: json['statusCode'] as int? ?? 500,
      errorCode: json['errorCode'] as String? ?? 'INTERNAL_ERROR',
      message: json['message'] as String? ?? 'Error',
      details: json['details'],
      requestId: json['requestId'] as String?,
    );
  }
}

class ApiException implements Exception {
  ApiException(this.envelope);
  final ErrorEnvelope envelope;

  int get statusCode => envelope.statusCode;
  String get errorCode => envelope.errorCode;
  String get message => envelope.message;

  @override
  String toString() =>
      'ApiException(${envelope.statusCode} ${envelope.errorCode}: ${envelope.message})';
}
