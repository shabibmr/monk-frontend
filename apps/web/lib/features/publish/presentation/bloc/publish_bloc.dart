import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/published_post.dart';
import '../../domain/repositories/publish_repository.dart';

sealed class PublishEvent extends Equatable {
  const PublishEvent();
  @override
  List<Object?> get props => [];
}

class PublishLoaded extends PublishEvent {
  const PublishLoaded();
}

class PublishUrlSubmitted extends PublishEvent {
  const PublishUrlSubmitted(this.liveUrl);
  final String liveUrl;
  @override
  List<Object?> get props => [liveUrl];
}

class PublishPollTick extends PublishEvent {
  const PublishPollTick();
}

class PublishPollingStopped extends PublishEvent {
  const PublishPollingStopped();
}

class PublishState extends Equatable {
  const PublishState({
    this.loading = false,
    this.submitting = false,
    this.polling = false,
    this.post,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool submitting;
  final bool polling;
  final PublishedPost? post;
  final Failure? failure;
  final String? infoMessage;

  PublishState copyWith({
    bool? loading,
    bool? submitting,
    bool? polling,
    PublishedPost? post,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return PublishState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      polling: polling ?? this.polling,
      post: post ?? this.post,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, submitting, polling, post, failure, infoMessage];
}

class PublishBloc extends Bloc<PublishEvent, PublishState> {
  PublishBloc(
    this._repo, {
    required this.collaborationId,
    required this.deliverableId,
    this.pollInterval = const Duration(seconds: 2),
    this.maxPolls = 15,
  }) : super(const PublishState()) {
    on<PublishLoaded>(_onLoad);
    on<PublishUrlSubmitted>(_onSubmit);
    on<PublishPollTick>(_onPollTick);
    on<PublishPollingStopped>(_onStop);
  }

  final PublishRepository _repo;
  final String collaborationId;
  final String deliverableId;
  final Duration pollInterval;
  final int maxPolls;

  Timer? _timer;
  int _pollCount = 0;

  void _schedulePolls(Emitter<PublishState> emit) {
    _timer?.cancel();
    _pollCount = 0;
    emit(state.copyWith(polling: true));
    _timer = Timer.periodic(pollInterval, (_) {
      if (!isClosed) add(const PublishPollTick());
    });
  }

  Future<void> _onLoad(PublishLoaded event, Emitter<PublishState> emit) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final post = await _repo.get(
        collaborationId: collaborationId,
        deliverableId: deliverableId,
      );
      emit(state.copyWith(loading: false, post: post));
      if (post.isPolling) _schedulePolls(emit);
    } on Failure catch (f) {
      if (f is NotFoundFailure) {
        emit(state.copyWith(loading: false));
      } else {
        emit(state.copyWith(loading: false, failure: f));
      }
    }
  }

  Future<void> _onSubmit(
    PublishUrlSubmitted event,
    Emitter<PublishState> emit,
  ) async {
    final url = event.liveUrl.trim();
    if (!looksLikeHttpUrl(url)) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Enter a valid http(s) URL for the live post',
            errorCode: 'INVALID_URL',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final post = await _repo.submit(
        collaborationId: collaborationId,
        deliverableId: deliverableId,
        liveUrl: url,
      );
      emit(
        state.copyWith(
          submitting: false,
          post: post,
          infoMessage: 'URL submitted — verifying ownership',
        ),
      );
      if (!post.isTerminal) {
        _schedulePolls(emit);
      }
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onPollTick(
    PublishPollTick event,
    Emitter<PublishState> emit,
  ) async {
    _pollCount++;
    if (_pollCount > maxPolls) {
      _timer?.cancel();
      emit(
        state.copyWith(
          polling: false,
          infoMessage: 'Verification still pending — refresh later',
        ),
      );
      return;
    }
    try {
      final post = await _repo.get(
        collaborationId: collaborationId,
        deliverableId: deliverableId,
      );
      if (post.isTerminal) {
        _timer?.cancel();
        emit(
          state.copyWith(
            post: post,
            polling: false,
            infoMessage: post.isVerified ? 'Post verified' : null,
            clearInfo: !post.isVerified,
          ),
        );
      } else {
        emit(state.copyWith(post: post, polling: true));
      }
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  void _onStop(PublishPollingStopped event, Emitter<PublishState> emit) {
    _timer?.cancel();
    emit(state.copyWith(polling: false));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
