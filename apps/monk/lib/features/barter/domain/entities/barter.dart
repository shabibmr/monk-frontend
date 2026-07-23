import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

EntityStatus barterFulfillmentStatusToEntity(String status) {
  switch (status) {
    case 'pending_shipment':
      return EntityStatus.held;
    case 'shipped':
      return EntityStatus.productShipped;
    case 'received':
      return EntityStatus.productReceived;
    default:
      return EntityStatus.inReview;
  }
}

EntityStatus collabStatusToEntity(String status) {
  switch (status) {
    case 'terms_accepted':
      return EntityStatus.termsAccepted;
    case 'product_shipped':
      return EntityStatus.productShipped;
    case 'product_received':
      return EntityStatus.productReceived;
    case 'content_pending':
      return EntityStatus.contentPending;
    default:
      return EntityStatus.inReview;
  }
}

class BarterFulfillment extends Equatable {
  const BarterFulfillment({
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

  bool get isPendingShipment => status == 'pending_shipment';
  bool get isShipped => status == 'shipped';
  bool get isReceived => status == 'received';

  EntityStatus get statusChip => barterFulfillmentStatusToEntity(status);

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        productDescription,
        status,
        declaredValueMinor,
        shippingCarrier,
        trackingRef,
        shippedAt,
        receivedConfirmedAt,
        evidenceFileIds,
        notes,
      ];
}

class BarterStatus extends Equatable {
  const BarterStatus({
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
  final BarterFulfillment? fulfillment;

  /// Pure barter never shows cash charge UI.
  bool get isPureBarter => collabType == 'barter';

  bool get isHybrid => collabType == 'hybrid';

  /// Content submission unlocked only at content_pending (+ later content states).
  bool get contentUnlocked =>
      collabStatus == 'content_pending' ||
      collabStatus == 'revision_requested' ||
      collabStatus == 'content_submitted';

  bool get contentLocked => !contentUnlocked;

  bool get canBrandShip =>
      requiresFulfillment &&
      collabStatus != 'content_pending' &&
      collabStatus != 'product_received' &&
      (fulfillment == null ||
          fulfillment!.isPendingShipment ||
          fulfillment!.isShipped);

  bool get canCreatorReceive =>
      requiresFulfillment &&
      (fulfillment?.isShipped ?? false) &&
      collabStatus == 'product_shipped';

  /// Never invent platform fees for barter panel.
  bool get showCashChargeUi => false;

  EntityStatus get collabStatusChip => collabStatusToEntity(collabStatus);

  String get contentLockMessage {
    if (contentUnlocked) {
      return 'Content submission unlocked.';
    }
    if (requiresFulfillment) {
      return 'Content submission is locked until the product is marked received.';
    }
    return 'Open content when terms are accepted (paid path).';
  }

  @override
  List<Object?> get props => [
        collaborationId,
        collabType,
        collabStatus,
        requiresFulfillment,
        skipsProductStates,
        returnsSupported,
        fulfillment,
      ];
}
