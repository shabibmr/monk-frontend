import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/widgets/widgets.dart';

enum EsignStatus {
  draft,
  pendingSignatures,
  fullySigned,
  amended,
  cancelled,
}

class EsignStatusChip extends StatelessWidget {
  const EsignStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  EntityStatus _toEntityStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return EntityStatus.draft;
      case 'pending':
      case 'pending_signatures':
        return EntityStatus.inReview;
      case 'accepted':
      case 'fully_signed':
      case 'signed':
        return EntityStatus.termsAccepted;
      case 'amended':
        return EntityStatus.inProgress;
      case 'cancelled':
      case 'void':
        return EntityStatus.cancelled;
      default:
        return EntityStatus.draft;
    }
  }

  String _formatLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'pending':
      case 'pending_signatures':
        return 'Pending Signatures';
      case 'accepted':
      case 'fully_signed':
      case 'signed':
        return 'Fully Signed';
      case 'amended':
        return 'Amended';
      case 'cancelled':
      case 'void':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImStatusChip(
      status: _toEntityStatus(status),
      label: _formatLabel(status),
    );
  }
}
