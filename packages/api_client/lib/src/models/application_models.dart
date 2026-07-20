class MarketplaceBrandDto {
  const MarketplaceBrandDto({
    required this.id,
    required this.companyName,
    this.country,
    this.industry,
  });

  final String id;
  final String companyName;
  final String? country;
  final String? industry;

  factory MarketplaceBrandDto.fromJson(Map<String, dynamic> json) {
    return MarketplaceBrandDto(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      country: json['country'] as String?,
      industry: json['industry'] as String?,
    );
  }
}

class MarketplaceDeliverableDto {
  const MarketplaceDeliverableDto({
    required this.id,
    required this.platform,
    required this.deliverableType,
    this.disclosureTags = const [],
    this.captionGuidelines,
    this.hashtags = const [],
    this.wordCountMin,
    this.backlinkRequired,
    this.dueDate,
  });

  final String id;
  final String platform;
  final String deliverableType;
  final List<String> disclosureTags;
  final String? captionGuidelines;
  final List<String> hashtags;
  final int? wordCountMin;
  final bool? backlinkRequired;
  final String? dueDate;

  factory MarketplaceDeliverableDto.fromJson(Map<String, dynamic> json) {
    final tags = json['disclosureTags'];
    final hashes = json['hashtags'];
    return MarketplaceDeliverableDto(
      id: json['id'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      deliverableType: json['deliverableType'] as String? ?? '',
      disclosureTags: tags is List
          ? tags.map((e) => e.toString()).toList()
          : const [],
      captionGuidelines: json['captionGuidelines'] as String?,
      hashtags: hashes is List
          ? hashes.map((e) => e.toString()).toList()
          : const [],
      wordCountMin: json['wordCountMin'] as int?,
      backlinkRequired: json['backlinkRequired'] as bool?,
      dueDate: json['dueDate']?.toString(),
    );
  }
}

class MarketplaceCampaignDto {
  const MarketplaceCampaignDto({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.mode,
    this.objective,
    this.visibility,
    this.currency,
    this.budgetTotalMinor,
    this.permittedCollabTypes = const [],
    this.startsOn,
    this.endsOn,
    this.brand,
    this.deliverables = const [],
  });

  final String id;
  final String name;
  final String code;
  final String status;
  final String mode;
  final String? objective;
  final String? visibility;
  final String? currency;
  final int? budgetTotalMinor;
  final List<String> permittedCollabTypes;
  final String? startsOn;
  final String? endsOn;
  final MarketplaceBrandDto? brand;
  final List<MarketplaceDeliverableDto> deliverables;

  factory MarketplaceCampaignDto.fromJson(Map<String, dynamic> json) {
    final collab = json['permittedCollabTypes'];
    final budget = json['budgetTotalMinor'];
    final dels = json['deliverables'] as List<dynamic>? ?? const [];
    final brandJson = json['brand'];
    return MarketplaceCampaignDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? '',
      mode: json['mode'] as String? ?? 'self_serve',
      objective: json['objective'] as String?,
      visibility: json['visibility'] as String?,
      currency: json['currency'] as String?,
      budgetTotalMinor: budget is int
          ? budget
          : budget is num
              ? budget.toInt()
              : int.tryParse('$budget'),
      permittedCollabTypes: collab is List
          ? collab.map((e) => e.toString()).toList()
          : const [],
      startsOn: json['startsOn']?.toString(),
      endsOn: json['endsOn']?.toString(),
      brand: brandJson is Map<String, dynamic>
          ? MarketplaceBrandDto.fromJson(brandJson)
          : null,
      deliverables: dels
          .map(
            (e) =>
                MarketplaceDeliverableDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class MarketplacePageDto {
  const MarketplacePageDto({
    required this.data,
    this.nextCursor,
  });

  final List<MarketplaceCampaignDto> data;
  final String? nextCursor;

  factory MarketplacePageDto.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? const [];
    return MarketplacePageDto(
      data: list
          .map(
            (e) => MarketplaceCampaignDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

class ApplicationDto {
  const ApplicationDto({
    required this.id,
    required this.campaignId,
    required this.influencerProfileId,
    required this.origin,
    required this.status,
    this.submittedByUserId,
    this.pitch,
    this.proposedPrices,
    this.proposedCollabType,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String campaignId;
  final String influencerProfileId;
  final String origin;
  final String status;
  final String? submittedByUserId;
  final String? pitch;
  final Object? proposedPrices;
  final String? proposedCollabType;
  final String? rejectionReason;
  final String? createdAt;

  factory ApplicationDto.fromJson(Map<String, dynamic> json) {
    return ApplicationDto(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String? ?? '',
      influencerProfileId: json['influencerProfileId'] as String? ?? '',
      origin: json['origin'] as String? ?? 'applied',
      status: json['status'] as String? ?? 'submitted',
      submittedByUserId: json['submittedByUserId'] as String?,
      pitch: json['pitch'] as String?,
      proposedPrices: json['proposedPrices'],
      proposedCollabType: json['proposedCollabType'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
