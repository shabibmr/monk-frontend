import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MarketplaceDetailState extends Equatable {
  const MarketplaceDetailState({
    this.loading = false,
    this.applying = false,
    this.campaign,
    this.application,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool applying;
  final MarketplaceCampaign? campaign;
  final Application? application;
  final Failure? failure;
  final String? infoMessage;

  MarketplaceDetailState copyWith({
    bool? loading,
    bool? applying,
    MarketplaceCampaign? campaign,
    Application? application,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return MarketplaceDetailState(
      loading: loading ?? this.loading,
      applying: applying ?? this.applying,
      campaign: campaign ?? this.campaign,
      application: application ?? this.application,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, applying, campaign, application, failure, infoMessage];
}

class MarketplaceDetailCubit extends Cubit<MarketplaceDetailState> {
  MarketplaceDetailCubit(this._repo, this.campaignId)
      : super(const MarketplaceDetailState());

  final MarketplaceRepository _repo;
  final String campaignId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final c = await _repo.getCampaign(campaignId);
      emit(state.copyWith(loading: false, campaign: c));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> apply({
    required String profileId,
    required String proposedCollabType,
    String? pitch,
  }) async {
    emit(state.copyWith(applying: true, clearFailure: true, clearInfo: true));
    try {
      final app = await _repo.apply(
        campaignId: campaignId,
        profileId: profileId,
        proposedCollabType: proposedCollabType,
        pitch: pitch,
      );
      emit(
        state.copyWith(
          applying: false,
          application: app,
          infoMessage: 'Application submitted',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(applying: false, failure: f));
    }
  }
}
