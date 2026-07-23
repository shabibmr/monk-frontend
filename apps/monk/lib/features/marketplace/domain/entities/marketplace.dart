import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

/// MVP collab types shown in apply UI (licensing hidden until T2.8).
const applyCollabTypes = ['paid', 'barter', 'hybrid'];

EntityStatus applicationStatusToEntity(String status) {
  switch (status) {
    case 'submitted':
      return EntityStatus.submitted;
    case 'shortlisted':
      return EntityStatus.shortlisted;
    case 'rejected':
      return EntityStatus.rejected;
    case 'withdrawn':
      return EntityStatus.withdrawn;
    case 'converted':
      return EntityStatus.completed;
    default:
      return EntityStatus.inReview;
  }
}

EntityStatus applicationOriginToEntity(String origin) {
  switch (origin) {
    case 'applied':
      return EntityStatus.applied;
    case 'invited':
      return EntityStatus.invited;
    case 'assigned':
      return EntityStatus.assigned;
    default:
      return EntityStatus.inReview;
  }
}

class MarketplaceBrand extends Equatable {
  const MarketplaceBrand({
    required this.id,
    required this.companyName,
    this.country,
    this.industry,
  });

  final String id;
  final String companyName;
  final String? country;
  final String? industry;

  @override
  List<Object?> get props => [id, companyName, country, industry];
}

class MarketplaceDeliverable extends Equatable {
  const MarketplaceDeliverable({
    required this.id,
    required this.platform,
    required this.deliverableType,
    this.disclosureTags = const [],
    this.captionGuidelines,
  });

  final String id;
  final String platform;
  final String deliverableType;
  final List<String> disclosureTags;
  final String? captionGuidelines;

  @override
  List<Object?> get props =>
      [id, platform, deliverableType, disclosureTags, captionGuidelines];
}

class MarketplaceCampaign extends Equatable {
  const MarketplaceCampaign({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.mode,
    this.objective,
    this.currency,
    this.budgetTotalMinor,
    this.permittedCollabTypes = const [],
    this.brand,
    this.deliverables = const [],
  });

  final String id;
  final String name;
  final String code;
  final String status;
  final String mode;
  final String? objective;
  final String? currency;
  final int? budgetTotalMinor;
  final List<String> permittedCollabTypes;
  final MarketplaceBrand? brand;
  final List<MarketplaceDeliverable> deliverables;

  /// Collab options for apply form — never expose licensing in P1 UI.
  List<String> get applyCollabOptions {
    final allowed = permittedCollabTypes
        .where((t) => t != 'licensing' && applyCollabTypes.contains(t))
        .toList();
    if (allowed.isEmpty) return const ['paid'];
    return allowed;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        status,
        mode,
        objective,
        currency,
        budgetTotalMinor,
        permittedCollabTypes,
        brand,
        deliverables,
      ];
}

class Application extends Equatable {
  const Application({
    required this.id,
    required this.campaignId,
    required this.influencerProfileId,
    required this.origin,
    required this.status,
    this.pitch,
    this.proposedCollabType,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String campaignId;
  final String influencerProfileId;
  final String origin;
  final String status;
  final String? pitch;
  final String? proposedCollabType;
  final String? rejectionReason;
  final String? createdAt;

  EntityStatus get statusChip => applicationStatusToEntity(status);
  EntityStatus get originChip => applicationOriginToEntity(origin);

  bool get canBrandShortlist => status == 'submitted';
  bool get canBrandReject =>
      status == 'submitted' || status == 'shortlisted';
  bool get canWithdraw =>
      status != 'rejected' &&
      status != 'withdrawn' &&
      status != 'converted';
  bool get isPendingInvite =>
      origin == 'invited' && status == 'submitted';

  @override
  List<Object?> get props => [
        id,
        campaignId,
        influencerProfileId,
        origin,
        status,
        pitch,
        proposedCollabType,
        rejectionReason,
        createdAt,
      ];
}
