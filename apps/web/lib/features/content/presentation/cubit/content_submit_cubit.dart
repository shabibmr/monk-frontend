import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/content.dart';
import '../../domain/repositories/content_repository.dart';

class ContentSubmitState extends Equatable {
  const ContentSubmitState({
    this.loading = false,
    this.acting = false,
    this.submissions = const [],
    this.lastVersion,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool acting;
  final List<ContentSubmission> submissions;
  final ContentVersion? lastVersion;
  final Failure? failure;
  final String? infoMessage;

  ContentSubmitState copyWith({
    bool? loading,
    bool? acting,
    List<ContentSubmission>? submissions,
    ContentVersion? lastVersion,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return ContentSubmitState(
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      submissions: submissions ?? this.submissions,
      lastVersion: lastVersion ?? this.lastVersion,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, acting, submissions, lastVersion, failure, infoMessage];
}

class ContentSubmitCubit extends Cubit<ContentSubmitState> {
  ContentSubmitCubit(this._repo, this.collaborationId)
      : super(const ContentSubmitState());

  final ContentRepository _repo;
  final String collaborationId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.listSubmissions(collaborationId);
      emit(state.copyWith(loading: false, submissions: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> createAndSubmit({
    required String deliverableId,
    required String caption,
    List<String> hashtags = const [],
    List<String> links = const [],
    List<String> mediaFileIds = const [],
  }) async {
    emit(state.copyWith(acting: true, clearFailure: true, clearInfo: true));
    try {
      final draft = await _repo.createVersion(
        collaborationId: collaborationId,
        deliverableId: deliverableId,
        body: {
          'caption': caption,
          if (hashtags.isNotEmpty) 'hashtags': hashtags,
          if (links.isNotEmpty) 'links': links,
          if (mediaFileIds.isNotEmpty) 'mediaFileIds': mediaFileIds,
        },
      );
      final submitted = await _repo.submit(draft.id);
      await load();
      emit(
        state.copyWith(
          acting: false,
          lastVersion: submitted,
          infoMessage: 'Version ${submitted.versionNumber} submitted',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, failure: f));
    }
  }
}
