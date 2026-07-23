import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

EntityStatus contractStatusToEntity(String status) {
  switch (status) {
    case 'generated':
      return EntityStatus.inReview;
    case 'accepted':
      return EntityStatus.termsAccepted;
    case 'void':
      return EntityStatus.cancelled;
    default:
      return EntityStatus.draft;
  }
}

class UsageRights extends Equatable {
  const UsageRights({
    required this.organicReuse,
    required this.paidAmplification,
    required this.durationDays,
    required this.territory,
    this.channels = const [],
    this.exclusivityCategory,
    this.exclusivityDays,
  });

  final bool organicReuse;
  final bool paidAmplification;
  final int durationDays;
  final String territory;
  final List<String> channels;
  final String? exclusivityCategory;
  final int? exclusivityDays;

  @override
  List<Object?> get props => [
        organicReuse,
        paidAmplification,
        durationDays,
        territory,
        channels,
        exclusivityCategory,
        exclusivityDays,
      ];
}

class ContractAcceptance extends Equatable {
  const ContractAcceptance({
    required this.party,
    required this.acceptedByUserId,
    required this.contentHash,
    this.acceptedAt,
  });

  final String party;
  final String acceptedByUserId;
  final String contentHash;
  final String? acceptedAt;

  @override
  List<Object?> get props => [party, acceptedByUserId, contentHash, acceptedAt];
}

class Contract extends Equatable {
  const Contract({
    required this.id,
    required this.collaborationId,
    required this.status,
    required this.contentHash,
    this.templateKey,
    this.templateVersion,
    this.pdfUrl,
    this.usageRights,
    this.acceptances = const [],
    this.bothPartiesAccepted = false,
  });

  final String id;
  final String collaborationId;
  final String status;
  final String contentHash;
  final String? templateKey;
  final String? templateVersion;
  final String? pdfUrl;
  final UsageRights? usageRights;
  final List<ContractAcceptance> acceptances;
  final bool bothPartiesAccepted;

  bool get isAccepted => status == 'accepted' || bothPartiesAccepted;
  bool get isReadOnly => isAccepted || status == 'void';

  EntityStatus get statusChip => contractStatusToEntity(status);

  bool hasPartyAccepted(String party) =>
      acceptances.any((a) => a.party == party);

  /// Receipt fields for last acceptance (hash + timestamp from API only).
  ContractAcceptance? get latestAcceptance {
    if (acceptances.isEmpty) return null;
    return acceptances.last;
  }

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        status,
        contentHash,
        templateKey,
        templateVersion,
        pdfUrl,
        usageRights,
        acceptances,
        bothPartiesAccepted,
      ];
}
