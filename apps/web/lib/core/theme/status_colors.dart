import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import 'tokens.dart';

/// Semantic colors for status chips — **only** mapping site (design.md §2.3).
enum StatusSemantic { ink, info, warning, success, danger }

StatusSemantic statusSemanticFor(EntityStatus status) {
  switch (status) {
    case EntityStatus.draft:
    case EntityStatus.briefSubmitted:
    case EntityStatus.contentPending:
    case EntityStatus.agencyBuilding:
      return StatusSemantic.ink;
    case EntityStatus.published:
    case EntityStatus.applicationsOpen:
    case EntityStatus.applied:
    case EntityStatus.invited:
    case EntityStatus.assigned:
    case EntityStatus.shortlisted:
    case EntityStatus.negotiating:
    case EntityStatus.inReview:
    case EntityStatus.submitted:
    case EntityStatus.contentSubmitted:
    case EntityStatus.syncing:
      return StatusSemantic.info;
    case EntityStatus.termsAccepted:
    case EntityStatus.productShipped:
    case EntityStatus.revisionRequested:
    case EntityStatus.held:
    case EntityStatus.pendingPayout:
    case EntityStatus.licenseExpiring:
    case EntityStatus.shortlisting:
    case EntityStatus.inProgress:
    case EntityStatus.needsReauth:
      return StatusSemantic.warning;
    case EntityStatus.approved:
    case EntityStatus.verified:
    case EntityStatus.settled:
    case EntityStatus.completed:
    case EntityStatus.funded:
    case EntityStatus.paidOut:
    case EntityStatus.activeLicense:
    case EntityStatus.productReceived:
      return StatusSemantic.success;
    case EntityStatus.rejected:
    case EntityStatus.cancelled:
    case EntityStatus.disputed:
    case EntityStatus.withdrawn:
    case EntityStatus.refunded:
    case EntityStatus.failed:
    case EntityStatus.unlicensedBlocked:
    case EntityStatus.partiallyRefunded:
      return StatusSemantic.danger;
  }
}

({Color bg, Color fg}) statusChipColors(StatusSemantic semantic) {
  switch (semantic) {
    case StatusSemantic.ink:
      return (bg: ImColors.cream100, fg: ImColors.ink600);
    case StatusSemantic.info:
      return (bg: ImColors.info100, fg: ImColors.info600);
    case StatusSemantic.warning:
      return (bg: ImColors.warning100, fg: ImColors.warning600);
    case StatusSemantic.success:
      return (bg: ImColors.success100, fg: ImColors.success600);
    case StatusSemantic.danger:
      return (bg: ImColors.danger100, fg: ImColors.danger600);
  }
}

String entityStatusLabel(EntityStatus status) {
  final name = status.name;
  final buffer = StringBuffer();
  for (var i = 0; i < name.length; i++) {
    final ch = name[i];
    if (i > 0 && ch.toUpperCase() == ch) {
      buffer.write(' ');
      buffer.write(ch.toLowerCase());
    } else {
      buffer.write(i == 0 ? ch.toUpperCase() : ch);
    }
  }
  return buffer.toString().replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]!.toLowerCase()}',
  );
}
