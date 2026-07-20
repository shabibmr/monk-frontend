import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/content.dart';
import '../../domain/repositories/content_repository.dart';

class ContentReviewState extends Equatable {
  const ContentReviewState({
    this.loading = false,
    this.acting = false,
    this.submissions = const [],
    this.selectedVersion,
    this.comments = const [],
    this.overrideReason = '',
    this.comment = '',
    this.failure,
    this.infoMessage,
    this.disclosureFromError,
  });

  final bool loading;
  final bool acting;
  final List<ContentSubmission> submissions;
  final ContentVersion? selectedVersion;
  final List<ContentComment> comments;
  final String overrideReason;
  final String comment;
  final Failure? failure;
  final String? infoMessage;

  /// Populated from 422 DISCLOSURE_OVERRIDE_REQUIRED details.
  final DisclosureInfo? disclosureFromError;

  DisclosureInfo? get effectiveDisclosure =>
      disclosureFromError ?? selectedVersion?.disclosure;

  bool get disclosurePassed => effectiveDisclosure?.passed ?? true;

  bool get canApprove => canApproveWithDisclosure(
        disclosurePassed: disclosurePassed,
        overrideReason: overrideReason,
      );

  ContentReviewState copyWith({
    bool? loading,
    bool? acting,
    List<ContentSubmission>? submissions,
    ContentVersion? selectedVersion,
    List<ContentComment>? comments,
    String? overrideReason,
    String? comment,
    Failure? failure,
    String? infoMessage,
    DisclosureInfo? disclosureFromError,
    bool clearFailure = false,
    bool clearInfo = false,
    bool clearDisclosureError = false,
  }) {
    return ContentReviewState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      submissions: submissions ?? this.submissions,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      comments: comments ?? this.comments,
      overrideReason: overrideReason ?? this.overrideReason,
      comment: comment ?? this.comment,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      disclosureFromError: clearDisclosureError
          ? null
          : (disclosureFromError ?? this.disclosureFromError),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        acting,
        submissions,
        selectedVersion,
        comments,
        overrideReason,
        comment,
        failure,
        infoMessage,
        disclosureFromError,
      ];
}

class ContentReviewCubit extends Cubit<ContentReviewState> {
  ContentReviewCubit(this._repo, this.collaborationId)
      : super(const ContentReviewState());

  final ContentRepository _repo;
  final String collaborationId;

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        clearFailure: true,
        clearInfo: true,
        clearDisclosureError: true,
      ),
    );
    try {
      final list = await _repo.listSubmissions(collaborationId);
      emit(state.copyWith(loading: false, submissions: list));
      // Auto-select first submitted version.
      for (final s in list) {
        final v = s.latestSubmitted;
        if (v != null) {
          await selectVersion(v.id);
          break;
        }
      }
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> selectVersion(String versionId) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearDisclosureError: true));
    try {
      final v = await _repo.getVersion(versionId);
      final comments = await _repo.listComments(versionId);
      emit(
        state.copyWith(
          loading: false,
          selectedVersion: v,
          comments: comments,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void setOverrideReason(String value) {
    emit(state.copyWith(overrideReason: value, clearFailure: true));
  }

  void setComment(String value) {
    emit(state.copyWith(comment: value));
  }

  Future<void> approve() async {
    final v = state.selectedVersion;
    if (v == null) return;
    if (!state.canApprove) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Disclosure failed — override reason required to approve',
            errorCode: 'DISCLOSURE_OVERRIDE_REQUIRED',
          ),
          disclosureFromError: state.effectiveDisclosure ??
              const DisclosureInfo(
                passed: false,
                overrideRequired: true,
              ),
        ),
      );
      return;
    }
    await _decide(
      decision: 'approve',
      overrideReason:
          state.disclosurePassed ? null : state.overrideReason.trim(),
    );
  }

  Future<void> reject() async {
    if (state.comment.trim().isEmpty) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Comment required for reject',
          ),
        ),
      );
      return;
    }
    await _decide(decision: 'reject', comment: state.comment.trim());
  }

  Future<void> requestRevision() async {
    if (state.comment.trim().isEmpty) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Comment required for revision request',
          ),
        ),
      );
      return;
    }
    await _decide(
      decision: 'request_revision',
      comment: state.comment.trim(),
    );
  }

  Future<void> _decide({
    required String decision,
    String? comment,
    String? overrideReason,
  }) async {
    final v = state.selectedVersion;
    if (v == null) return;
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.review(
        versionId: v.id,
        decision: decision,
        comment: comment,
        overrideReason: overrideReason,
      );
      emit(
        state.copyWith(
          acting: false,
          selectedVersion: updated,
          infoMessage: 'Review recorded: $decision',
          clearDisclosureError: true,
        ),
      );
      await load();
    } on Failure catch (f) {
      DisclosureInfo? disc;
      if (f.errorCode == 'DISCLOSURE_OVERRIDE_REQUIRED' && f.details is Map) {
        final details = f.details as Map;
        final d = details['disclosure'];
        if (d is Map) {
          disc = DisclosureInfo(
            passed: d['passed'] as bool? ?? false,
            requiredTags: (d['requiredTags'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [],
            missingTags: (d['missingTags'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [],
            overrideRequired: true,
          );
        }
      }
      emit(
        state.copyWith(
          acting: false,
          failure: f,
          disclosureFromError: disc,
        ),
      );
    }
  }

  Future<void> addComment(String body) async {
    final v = state.selectedVersion;
    if (v == null || body.trim().isEmpty) return;
    emit(state.copyWith(acting: true, clearFailure: true));
    try {
      await _repo.addComment(versionId: v.id, body: body.trim());
      final comments = await _repo.listComments(v.id);
      emit(state.copyWith(acting: false, comments: comments));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
