import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../domain/entities/creator_demographics.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../bloc/discovery_bloc.dart';
import '../bloc/discovery_score_bloc.dart';
import '../cubit/shortlist_cubit.dart';
import '../widgets/creator_demographics_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  String? _brandId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveBrand();
  }

  Future<void> _resolveBrand() async {
    try {
      final sessionBrand = context.read<SessionCubit>().state.activeBrandId;
      if (sessionBrand != null) {
        setState(() {
          _brandId = sessionBrand;
          _resolving = false;
        });
        return;
      }
      final brands = await getIt<BrandRepository>().listMine();
      if (brands.isNotEmpty) {
        context.read<SessionCubit>().setActiveBrand(brands.first.id);
        setState(() {
          _brandId = brands.first.id;
          _resolving = false;
        });
      } else {
        setState(() => _resolving = false);
      }
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              DiscoveryBloc(getIt<DiscoveryRepository>())
                ..add(const DiscoveryStarted()),
        ),
        BlocProvider(
          create: (_) => DiscoveryScoreBloc(getIt<DiscoveryRepository>()),
        ),
        if (_brandId != null)
          BlocProvider(
            create: (_) =>
                ShortlistCubit(getIt<DiscoveryRepository>(), _brandId!)
                  ..load(),
          ),
      ],
      child: _DiscoveryView(brandId: _brandId),
    );
  }
}

class _DiscoveryView extends StatefulWidget {
  const _DiscoveryView({this.brandId});
  final String? brandId;

  @override
  State<_DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<_DiscoveryView> {
  final _q = TextEditingController();
  final _country = TextEditingController();
  String? _platform;
  bool? _barter;
  double _minScore = 0.0;
  String _sort = 'relevant';

  @override
  void dispose() {
    _q.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover creators')),
      body: BlocConsumer<DiscoveryBloc, DiscoveryState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(ImSpacing.space16),
                child: Column(
                  children: [
                    ImTextField(
                      label: 'Search',
                      controller: _q,
                      hint: 'Name, city, bio…',
                      onChanged: (v) => context
                          .read<DiscoveryBloc>()
                          .add(DiscoveryQueryChanged(v)),
                    ),
                    const SizedBox(height: ImSpacing.space12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            // ignore: deprecated_member_use
                            value: _platform,
                            decoration:
                                const InputDecoration(labelText: 'Platform'),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Any Platform'),
                              ),
                              DropdownMenuItem(
                                value: 'instagram',
                                child: Text('Instagram'),
                              ),
                              DropdownMenuItem(
                                value: 'youtube',
                                child: Text('YouTube'),
                              ),
                              DropdownMenuItem(
                                value: 'facebook',
                                child: Text('Facebook'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _platform = v);
                              _applyFilters(context);
                            },
                          ),
                        ),
                        const SizedBox(width: ImSpacing.space12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _sort,
                            decoration:
                                const InputDecoration(labelText: 'Sort By'),
                            items: const [
                              DropdownMenuItem(
                                value: 'relevant',
                                child: Text('Most Relevant'),
                              ),
                              DropdownMenuItem(
                                value: 'creator_score',
                                child: Text('Creator Score'),
                              ),
                              DropdownMenuItem(
                                value: 'trending',
                                child: Text('Trending'),
                              ),
                              DropdownMenuItem(
                                value: 'highest_engagement',
                                child: Text('Highest Engagement'),
                              ),
                              DropdownMenuItem(
                                value: 'lowest_cost',
                                child: Text('Lowest Price'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _sort = v);
                                _applyFilters(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Min Algorithmic Creator Score: ${_minScore.toInt()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Slider(
                                value: _minScore,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                label: _minScore.toInt().toString(),
                                onChanged: (val) {
                                  setState(() => _minScore = val);
                                },
                                onChangeEnd: (_) => _applyFilters(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: ImSpacing.space12),
                        Expanded(
                          child: ImTextField(
                            label: 'Country',
                            controller: _country,
                            onChanged: (_) => _applyFilters(context),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Open to barter only'),
                      value: _barter == true,
                      onChanged: (v) {
                        setState(() => _barter = v ? true : null);
                        _applyFilters(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: _body(context, state)),
            ],
          );
        },
      ),
    );
  }

  void _applyFilters(BuildContext context) {
    final c = _country.text.trim();
    context.read<DiscoveryBloc>().add(
          DiscoveryFiltersChanged(
            DiscoveryFilters(
              q: _q.text,
              platform: _platform,
              country: c.isEmpty ? null : c,
              openToBarter: _barter,
              minCreatorScore: _minScore > 0 ? _minScore : null,
              sort: _sort,
            ),
          ),
        );
  }

  Widget _body(BuildContext context, DiscoveryState state) {
    if (state.phase == DiscoveryPhase.loading ||
        state.phase == DiscoveryPhase.initial) {
      return ListView.separated(
        padding: const EdgeInsets.all(ImSpacing.space16),
        itemCount: 6,
        separatorBuilder: (context, index) =>
            const SizedBox(height: ImSpacing.space12),
        itemBuilder: (context, index) => const ImSkeletonCard(),
      );
    }
    if (state.phase == DiscoveryPhase.failure && state.items.isEmpty) {
      return ImEmptyState(
        message: state.failure?.message ?? 'Discovery failed',
        actionLabel: 'Retry',
        onAction: () =>
            context.read<DiscoveryBloc>().add(const DiscoveryRefreshed()),
      );
    }
    if (state.items.isEmpty) {
      return const ImEmptyState(
        message: 'No creators match these filters — try broadening search.',
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
          context.read<DiscoveryBloc>().add(const DiscoveryLoadMore());
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(ImSpacing.space16),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) =>
            const SizedBox(height: ImSpacing.space12),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(ImSpacing.space16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[i];
          final score = item.creatorScore ?? 85.0;
          final fakeScore = item.fakeFollowerScore ?? 12.0;

          return ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: ImSpacing.space4),
                          Wrap(
                            spacing: ImSpacing.space8,
                            children: [
                              ImStatusChip(
                                status: EntityStatus.verified,
                                label: 'Score ${score.toStringAsFixed(0)}/100',
                              ),
                              ImStatusChip(
                                status: fakeScore < 20
                                    ? EntityStatus.verified
                                    : (fakeScore < 40
                                        ? EntityStatus.inProgress
                                        : EntityStatus.rejected),
                                label: fakeScore < 20
                                    ? 'Authentic (${fakeScore.toStringAsFixed(0)}% fake)'
                                    : 'Fake Risk ${fakeScore.toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ImButton(
                          label: 'Demographics',
                          variant: ImButtonVariant.tertiary,
                          onPressed: () => _showDemographicsModal(context, item),
                        ),
                        if (widget.brandId != null) ...[
                          const SizedBox(width: ImSpacing.space8),
                          ImButton(
                            label: 'Shortlist',
                            variant: ImButtonVariant.secondary,
                            onPressed: () {
                              try {
                                context
                                    .read<ShortlistCubit>()
                                    .addInfluencer(item.id);
                                ImToast.show(
                                  context,
                                  message: 'Added ${item.label}',
                                  tone: ImToastTone.success,
                                );
                              } catch (_) {
                                ImToast.show(
                                  context,
                                  message: 'Create a shortlist first',
                                  tone: ImToastTone.warning,
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: ImSpacing.space8),
                Text(
                  [
                    if (item.primaryPlatform != null) item.primaryPlatform!,
                    if (item.city != null) item.city!,
                    if (item.country != null) item.country!,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.biography != null) ...[
                  const SizedBox(height: ImSpacing.space8),
                  Text(
                    item.biography!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: ImSpacing.space8),
                Wrap(
                  spacing: 12,
                  children: [
                    if (item.followersCount != null)
                      Text(
                        '${item.followersCount} followers',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (item.minPriceMinor != null)
                      ImMoneyText(
                        minorUnits: item.minPriceMinor!,
                        currencyCode: item.currency,
                      ),
                    if (item.openToBarter == true)
                      Text(
                        'Open to barter',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.success600,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDemographicsModal(BuildContext context, DiscoveryInfluencer item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider(
          create: (_) => DiscoveryScoreBloc(getIt<DiscoveryRepository>())
            ..add(FetchCreatorDemographics(item.id)),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(ImSpacing.space16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      '${item.label} — Audience Demographics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: ImSpacing.space16),
                    BlocBuilder<DiscoveryScoreBloc, DiscoveryScoreState>(
                      builder: (context, state) {
                        if (state.phase == DiscoveryScorePhase.loading) {
                          return const ImSkeletonCard();
                        }
                        final demo = state.demographics ??
                            CreatorDemographics(
                              influencerId: item.id,
                              creatorScore: item.creatorScore ?? 85.0,
                              fakeFollowerScore: item.fakeFollowerScore ?? 12.0,
                              credibilityGrade: item.credibilityGrade ?? 'A',
                            );
                        return CreatorDemographicsCard(demographics: demo);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
