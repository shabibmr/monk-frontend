import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

const maxNegotiationRounds = 5;

/// UI collab types for offer form (licensing hidden until T2.8).
const offerCollabTypes = ['paid', 'barter', 'hybrid'];

EntityStatus negotiationStatusToEntity(String status) {
  switch (status) {
    case 'open':
      return EntityStatus.negotiating;
    case 'accepted':
      return EntityStatus.termsAccepted;
    case 'cancelled':
    case 'declined':
      return EntityStatus.cancelled;
    default:
      return EntityStatus.inReview;
  }
}

class OfferPriceLine extends Equatable {
  const OfferPriceLine({
    required this.deliverableId,
    required this.priceMinor,
  });

  final String deliverableId;
  final int priceMinor;

  Map<String, dynamic> toJson() => {
        'deliverableId': deliverableId,
        'priceMinor': priceMinor,
      };

  @override
  List<Object?> get props => [deliverableId, priceMinor];
}

/// Client-side structure check only — server remains source of truth.
class OfferDraftValidation {
  const OfferDraftValidation._(this.ok, {this.message});
  final bool ok;
  final String? message;

  static OfferDraftValidation validate({
    required String collabType,
    required List<OfferPriceLine> priceLines,
    String? barterProductDescription,
    int? barterDeclaredValueMinor,
  }) {
    if (priceLines.isEmpty) {
      return const OfferDraftValidation._(
        false,
        message: 'At least one price line (deliverable + amount) is required',
      );
    }
    for (final line in priceLines) {
      if (line.deliverableId.trim().isEmpty) {
        return const OfferDraftValidation._(
          false,
          message: 'Each price line needs a deliverable id',
        );
      }
      if (line.priceMinor < 0) {
        return const OfferDraftValidation._(
          false,
          message: 'Amounts must be non-negative',
        );
      }
    }
    final cash = priceLines.fold<int>(0, (s, l) => s + l.priceMinor);
    final barterDesc = barterProductDescription?.trim() ?? '';
    final needsBarter = collabType == 'barter' || collabType == 'hybrid';
    if (needsBarter) {
      if (barterDesc.isEmpty) {
        return const OfferDraftValidation._(
          false,
          message: 'Barter product description is required',
        );
      }
      if (barterDeclaredValueMinor == null || barterDeclaredValueMinor < 0) {
        return const OfferDraftValidation._(
          false,
          message: 'Barter declared value is required',
        );
      }
    }
    if (collabType == 'barter' && cash != 0) {
      return const OfferDraftValidation._(
        false,
        message: 'Barter offers must have zero cash price lines',
      );
    }
    if ((collabType == 'paid' || collabType == 'hybrid') && cash <= 0) {
      return const OfferDraftValidation._(
        false,
        message: 'Cash total must be greater than zero',
      );
    }
    return const OfferDraftValidation._(true);
  }
}

class NegotiationOffer extends Equatable {
  const NegotiationOffer({
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
  });

  final String id;
  final int round;
  final String offeredBy;
  final String collabType;
  final int agreedPriceMinor;
  final String currency;
  final String status;
  final List<OfferPriceLine> priceLines;
  final String? barterProductDescription;
  final int? barterDeclaredValueMinor;
  final String? message;

  bool get isPending => status == 'pending';
  bool get isBrand => offeredBy == 'brand';

  @override
  List<Object?> get props => [
        id,
        round,
        offeredBy,
        collabType,
        agreedPriceMinor,
        currency,
        status,
        priceLines,
        barterProductDescription,
        barterDeclaredValueMinor,
        message,
      ];
}

class CollaborationSnapshot extends Equatable {
  const CollaborationSnapshot({
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

  /// API-frozen commission — display only, never recompute.
  final double commissionPct;
  final int? barterDeclaredValueMinor;
  final String? barterProductDescription;

  @override
  List<Object?> get props => [
        id,
        collabType,
        status,
        agreedPriceMinor,
        currency,
        commissionPct,
        barterDeclaredValueMinor,
        barterProductDescription,
      ];
}

class Negotiation extends Equatable {
  const Negotiation({
    required this.id,
    required this.applicationId,
    required this.status,
    required this.roundCount,
    this.maxRounds = maxNegotiationRounds,
    this.offers = const [],
  });

  final String id;
  final String applicationId;
  final String status;
  final int roundCount;
  final int maxRounds;
  final List<NegotiationOffer> offers;

  bool get isOpen => status == 'open';
  bool get isAccepted => status == 'accepted';
  bool get isLocked => !isOpen;
  bool get canCounter => isOpen && roundCount < maxRounds;
  NegotiationOffer? get pendingOffer {
    for (final o in offers.reversed) {
      if (o.isPending) return o;
    }
    return null;
  }

  EntityStatus get statusChip => negotiationStatusToEntity(status);

  @override
  List<Object?> get props =>
      [id, applicationId, status, roundCount, maxRounds, offers];
}

class AcceptNegotiationResult extends Equatable {
  const AcceptNegotiationResult({
    required this.negotiationId,
    required this.status,
    this.collaboration,
  });

  final String negotiationId;
  final String status;
  final CollaborationSnapshot? collaboration;

  @override
  List<Object?> get props => [negotiationId, status, collaboration];
}
