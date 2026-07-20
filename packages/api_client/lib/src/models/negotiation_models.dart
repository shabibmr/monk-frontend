class NegotiationOfferDto {
  const NegotiationOfferDto({
    required this.id,
    required this.round,
    required this.offeredBy,
    required this.collabType,
    required this.agreedPriceMinor,
    required this.currency,
    required this.status,
    this.priceLines = const [],
    this.barterProductDescription,
    this.barterDeclaredValueMinor,
    this.message,
    this.createdAt,
  });

  final String id;
  final int round;
  final String offeredBy;
  final String collabType;
  final int agreedPriceMinor;
  final String currency;
  final String status;
  final List<Map<String, dynamic>> priceLines;
  final String? barterProductDescription;
  final int? barterDeclaredValueMinor;
  final String? message;
  final String? createdAt;

  factory NegotiationOfferDto.fromJson(Map<String, dynamic> json) {
    final price = json['agreedPriceMinor'];
    final barter = json['barterDeclaredValueMinor'];
    final lines = json['priceLines'];
    return NegotiationOfferDto(
      id: json['id'] as String,
      round: json['round'] as int? ?? 0,
      offeredBy: json['offeredBy'] as String? ?? 'brand',
      collabType: json['collabType'] as String? ?? 'paid',
      agreedPriceMinor: price is int
          ? price
          : price is num
              ? price.toInt()
              : int.tryParse('$price') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'pending',
      priceLines: lines is List
          ? lines
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
      barterProductDescription: json['barterProductDescription'] as String?,
      barterDeclaredValueMinor: barter is int
          ? barter
          : barter is num
              ? barter.toInt()
              : int.tryParse('$barter'),
      message: json['message'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class NegotiationDto {
  const NegotiationDto({
    required this.id,
    required this.applicationId,
    required this.status,
    required this.roundCount,
    this.maxRounds = 5,
    this.offers = const [],
    this.createdAt,
  });

  final String id;
  final String applicationId;
  final String status;
  final int roundCount;
  final int maxRounds;
  final List<NegotiationOfferDto> offers;
  final String? createdAt;

  factory NegotiationDto.fromJson(Map<String, dynamic> json) {
    final offers = json['offers'] as List<dynamic>? ?? const [];
    return NegotiationDto(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      roundCount: json['roundCount'] as int? ?? 0,
      maxRounds: json['maxRounds'] as int? ?? 5,
      offers: offers
          .map((e) => NegotiationOfferDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class CollaborationSnapshotDto {
  const CollaborationSnapshotDto({
    required this.id,
    required this.collabType,
    required this.status,
    required this.agreedPriceMinor,
    required this.currency,
    required this.commissionPct,
    this.barterDeclaredValueMinor,
    this.barterProductDescription,
  });

  final String id;
  final String collabType;
  final String status;
  final int agreedPriceMinor;
  final String currency;

  /// Frozen server snapshot — never recompute on client.
  final double commissionPct;
  final int? barterDeclaredValueMinor;
  final String? barterProductDescription;

  factory CollaborationSnapshotDto.fromJson(Map<String, dynamic> json) {
    final price = json['agreedPriceMinor'];
    final commission = json['commissionPct'];
    final barter = json['barterDeclaredValueMinor'];
    return CollaborationSnapshotDto(
      id: json['id'] as String,
      collabType: json['collabType'] as String? ?? 'paid',
      status: json['status'] as String? ?? '',
      agreedPriceMinor: price is int
          ? price
          : price is num
              ? price.toInt()
              : int.tryParse('$price') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      commissionPct: commission is num
          ? commission.toDouble()
          : double.tryParse('$commission') ?? 0,
      barterDeclaredValueMinor: barter is int
          ? barter
          : barter is num
              ? barter.toInt()
              : int.tryParse('$barter'),
      barterProductDescription: json['barterProductDescription'] as String?,
    );
  }
}

class AcceptNegotiationResultDto {
  const AcceptNegotiationResultDto({
    required this.negotiationId,
    required this.status,
    this.collaboration,
  });

  final String negotiationId;
  final String status;
  final CollaborationSnapshotDto? collaboration;

  factory AcceptNegotiationResultDto.fromJson(Map<String, dynamic> json) {
    final collab = json['collaboration'];
    return AcceptNegotiationResultDto(
      negotiationId: json['negotiationId'] as String? ?? '',
      status: json['status'] as String? ?? 'accepted',
      collaboration: collab is Map<String, dynamic>
          ? CollaborationSnapshotDto.fromJson(collab)
          : null,
    );
  }
}
