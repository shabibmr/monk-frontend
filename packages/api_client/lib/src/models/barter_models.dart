class BarterFulfillmentDto {
  const BarterFulfillmentDto({
    required this.id,
    required this.collaborationId,
    required this.productDescription,
    required this.status,
    this.declaredValueMinor,
    this.shippingCarrier,
    this.trackingRef,
    this.shippedAt,
    this.receivedConfirmedAt,
    this.evidenceFileIds = const [],
    this.notes,
  });

  final String id;
  final String collaborationId;
  final String productDescription;
  final String status;
  final int? declaredValueMinor;
  final String? shippingCarrier;
  final String? trackingRef;
  final String? shippedAt;
  final String? receivedConfirmedAt;
  final List<String> evidenceFileIds;
  final String? notes;

  factory BarterFulfillmentDto.fromJson(Map<String, dynamic> json) {
    final value = json['declaredValueMinor'];
    final evidence = json['evidenceFileIds'];
    return BarterFulfillmentDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      status: json['status'] as String? ?? 'pending_shipment',
      declaredValueMinor: value is int
          ? value
          : value is num
              ? value.toInt()
              : int.tryParse('$value'),
      shippingCarrier: json['shippingCarrier'] as String?,
      trackingRef: json['trackingRef'] as String?,
      shippedAt: json['shippedAt']?.toString(),
      receivedConfirmedAt: json['receivedConfirmedAt']?.toString(),
      evidenceFileIds: evidence is List
          ? evidence.map((e) => e.toString()).toList()
          : const [],
      notes: json['notes'] as String?,
    );
  }
}

class BarterStatusDto {
  const BarterStatusDto({
    required this.collaborationId,
    required this.collabType,
    required this.collabStatus,
    required this.requiresFulfillment,
    required this.skipsProductStates,
    required this.returnsSupported,
    this.fulfillment,
  });

  final String collaborationId;
  final String collabType;
  final String collabStatus;
  final bool requiresFulfillment;
  final bool skipsProductStates;
  final bool returnsSupported;
  final BarterFulfillmentDto? fulfillment;

  factory BarterStatusDto.fromJson(Map<String, dynamic> json) {
    final f = json['fulfillment'];
    return BarterStatusDto(
      collaborationId: json['collaborationId'] as String? ?? '',
      collabType: json['collabType'] as String? ?? '',
      collabStatus: json['collabStatus'] as String? ?? '',
      requiresFulfillment: json['requiresFulfillment'] as bool? ?? false,
      skipsProductStates: json['skipsProductStates'] as bool? ?? false,
      returnsSupported: json['returnsSupported'] as bool? ?? false,
      fulfillment: f is Map<String, dynamic>
          ? BarterFulfillmentDto.fromJson(f)
          : null,
    );
  }
}
