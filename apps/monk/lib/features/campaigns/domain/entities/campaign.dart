import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

/// Campaign modes including licensing deal type (T2.8).
const campaignModes = ['self_serve', 'managed', 'licensing'];

const campaignObjectives = [
  'awareness',
  'consideration',
  'conversion',
  'engagement',
  'traffic',
];

const deliverablePlatforms = [
  'instagram',
  'youtube',
  'facebook',
  'x',
  'linkedin',
  'blog',
];

const deliverableTypes = [
  'instagram_reel',
  'instagram_story',
  'instagram_post',
  'youtube_video',
  'youtube_short',
  'blog_post',
];

/// Client-side allowed brand transitions (must match backend SM for UX).
List<String> allowedBrandTransitions({
  required String status,
  required String mode,
  required int deliverableCount,
}) {
  switch (status) {
    case 'draft':
      if (mode == 'self_serve' && deliverableCount >= 1) {
        return ['published', 'cancelled'];
      }
      if (mode == 'managed' || mode == 'licensing') {
        return ['brief_submitted', 'cancelled'];
      }
      return ['cancelled'];
    case 'published':
      return ['applications_open', 'cancelled'];
    case 'applications_open':
      return ['shortlisting', 'cancelled'];
    case 'shortlisting':
      return ['cancelled'];
    case 'in_progress':
      return ['completed'];
    default:
      return [];
  }
}

EntityStatus campaignStatusToEntity(String status) {
  switch (status) {
    case 'draft':
      return EntityStatus.draft;
    case 'brief_submitted':
      return EntityStatus.briefSubmitted;
    case 'agency_building':
      return EntityStatus.agencyBuilding;
    case 'published':
      return EntityStatus.published;
    case 'applications_open':
      return EntityStatus.applicationsOpen;
    case 'shortlisting':
      return EntityStatus.shortlisting;
    case 'in_progress':
      return EntityStatus.inProgress;
    case 'completed':
      return EntityStatus.completed;
    case 'cancelled':
      return EntityStatus.cancelled;
    default:
      return EntityStatus.inReview;
  }
}

/// Unhidden licensing UI for Phase 2 (T2.8).
bool isLicensingUiHidden() => false;

class Campaign extends Equatable {
  const Campaign({
    required this.id,
    required this.brandId,
    required this.name,
    required this.code,
    required this.status,
    required this.mode,
    this.objective,
    this.currency,
    this.budgetTotalMinor,
    this.deliverableCount = 0,
  });

  final String id;
  final String brandId;
  final String name;
  final String code;
  final String status;
  final String mode;
  final String? objective;
  final String? currency;
  final int? budgetTotalMinor;
  final int deliverableCount;

  EntityStatus get statusChip => campaignStatusToEntity(status);

  @override
  List<Object?> get props => [
        id,
        brandId,
        name,
        code,
        status,
        mode,
        objective,
        currency,
        budgetTotalMinor,
        deliverableCount,
      ];
}

class Deliverable extends Equatable {
  const Deliverable({
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

class CampaignDetail extends Equatable {
  const CampaignDetail({
    required this.campaign,
    required this.deliverables,
  });

  final Campaign campaign;
  final List<Deliverable> deliverables;

  @override
  List<Object?> get props => [campaign, deliverables];
}
