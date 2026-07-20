import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';

class CampaignListState extends Equatable {
  const CampaignListState({
    this.loading = false,
    this.items = const [],
    this.failure,
  });

  final bool loading;
  final List<Campaign> items;
  final Failure? failure;

  @override
  List<Object?> get props => [loading, items, failure];
}

class CampaignListCubit extends Cubit<CampaignListState> {
  CampaignListCubit(this._repo, this.brandId)
      : super(const CampaignListState());

  final CampaignRepository _repo;
  final String brandId;

  Future<void> load() async {
    emit(const CampaignListState(loading: true));
    try {
      final items = await _repo.list(brandId);
      emit(CampaignListState(items: items));
    } on Failure catch (f) {
      emit(CampaignListState(failure: f));
    }
  }
}
