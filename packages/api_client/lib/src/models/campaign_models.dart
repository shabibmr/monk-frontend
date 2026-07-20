class CampaignDto {
  const CampaignDto({
    required this.id,
    required this.brandId,
    required this.name,
    required this.code,
    required this.status,
    required this.mode,
    this.objective,
    this.visibility,
    this.currency,
    this.budgetTotalMinor,
    this.deliverableCount,
    this.permittedCollabTypes = const [],
  });

  final String id;
  final String brandId;
  final String name;
  final String code;
  final String status;
  final String mode;
  final String? objective;
  final String? visibility;
  final String? currency;
  final int? budgetTotalMinor;
  final int? deliverableCount;
  final List<String> permittedCollabTypes;

  factory CampaignDto.fromJson(Map<String, dynamic> json) {
    final collab = json['permittedCollabTypes'];
    final budget = json['budgetTotalMinor'];
    return CampaignDto(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      mode: json['mode'] as String? ?? 'self_serve',
      objective: json['objective'] as String?,
      visibility: json['visibility'] as String?,
      currency: json['currency'] as String?,
      budgetTotalMinor: budget is int
          ? budget
          : budget is num
              ? budget.toInt()
              : int.tryParse('$budget'),
      deliverableCount: json['deliverableCount'] as int?,
      permittedCollabTypes: collab is List
          ? collab.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

class CampaignDetailDto {
  const CampaignDetailDto({
    required this.campaign,
    required this.deliverables,
  });

  final CampaignDto campaign;
  final List<DeliverableDto> deliverables;

  factory CampaignDetailDto.fromJson(Map<String, dynamic> json) {
    final dels = json['deliverables'] as List<dynamic>? ?? const [];
    return CampaignDetailDto(
      campaign: CampaignDto.fromJson(json),
      deliverables: dels
          .map((e) => DeliverableDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DeliverableDto {
  const DeliverableDto({
    required this.id,
    required this.platform,
    required this.deliverableType,
    this.disclosureTags = const [],
    this.captionGuidelines,
    this.hashtags = const [],
  });

  final String id;
  final String platform;
  final String deliverableType;
  final List<String> disclosureTags;
  final String? captionGuidelines;
  final List<String> hashtags;

  factory DeliverableDto.fromJson(Map<String, dynamic> json) {
    final tags = json['disclosureTags'];
    final hashes = json['hashtags'];
    return DeliverableDto(
      id: json['id'] as String,
      platform: json['platform'] as String? ?? '',
      deliverableType: json['deliverableType'] as String? ?? '',
      disclosureTags:
          tags is List ? tags.map((e) => e.toString()).toList() : const [],
      captionGuidelines: json['captionGuidelines'] as String?,
      hashtags:
          hashes is List ? hashes.map((e) => e.toString()).toList() : const [],
    );
  }
}
