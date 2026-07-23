import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../bloc/campaign_detail_bloc.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignDetailBloc(getIt<CampaignRepository>())
        ..add(CampaignDetailLoaded(campaignId)),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView();

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _platform = deliverablePlatforms.first;
  String _type = deliverableTypes.first;
  final _caption = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/b/campaigns'),
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Deliverables'),
          ],
        ),
      ),
      body: BlocConsumer<CampaignDetailBloc, CampaignDetailState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(
              context,
              message: state.infoMessage!,
              tone: ImToastTone.success,
            );
          }
        },
        builder: (context, state) {
          if (state.phase == CampaignDetailPhase.loading ||
              state.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = state.detail!;
          final c = d.campaign;
          final acting = state.phase == CampaignDetailPhase.acting;

          return TabBarView(
            controller: _tabs,
            children: [
              ListView(
                padding: const EdgeInsets.all(ImSpacing.space24),
                children: [
                  ImCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            ImStatusChip(status: c.statusChip),
                          ],
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        Text('${c.code} · ${c.mode.replaceAll('_', ' ')}'),
                        if (c.objective != null) Text('Objective: ${c.objective}'),
                        if (c.budgetTotalMinor != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: ImSpacing.space8,
                            ),
                            child: ImMoneyText(
                              minorUnits: c.budgetTotalMinor!,
                              currencyCode: c.currency ?? 'INR',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final to in state.allowedTransitions)
                        ImButton(
                          label: to == 'published'
                              ? 'Publish campaign'
                              : to.replaceAll('_', ' '),
                          loading: acting,
                          variant: to == 'cancelled'
                              ? ImButtonVariant.destructive
                              : ImButtonVariant.primary,
                          onPressed: acting
                              ? null
                              : () => context.read<CampaignDetailBloc>().add(
                                    CampaignTransitionRequested(to),
                                  ),
                        ),
                    ],
                  ),
                  if (state.allowedTransitions.isEmpty)
                    Text(
                      'No brand transitions available in this status.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(ImSpacing.space24),
                children: [
                  if (c.status == 'draft' || c.status == 'agency_building')
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Add deliverable',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: ImSpacing.space12),
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _platform,
                            items: deliverablePlatforms
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _platform = v ?? _platform),
                            decoration:
                                const InputDecoration(labelText: 'Platform'),
                          ),
                          const SizedBox(height: ImSpacing.space12),
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _type,
                            items: deliverableTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.replaceAll('_', ' ')),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _type = v ?? _type),
                            decoration: const InputDecoration(
                              labelText: 'Type',
                            ),
                          ),
                          const SizedBox(height: ImSpacing.space12),
                          ImTextField(
                            label: 'Caption guidelines',
                            controller: _caption,
                          ),
                          const SizedBox(height: ImSpacing.space12),
                          ImButton(
                            label: 'Add deliverable',
                            loading: acting,
                            onPressed: acting
                                ? null
                                : () =>
                                    context.read<CampaignDetailBloc>().add(
                                          CampaignDeliverableAdded(
                                            platform: _platform,
                                            deliverableType: _type,
                                            captionGuidelines:
                                                _caption.text.trim().isEmpty
                                                    ? null
                                                    : _caption.text.trim(),
                                          ),
                                        ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: ImSpacing.space16),
                  if (d.deliverables.isEmpty)
                    const ImEmptyState(
                      message: 'Add at least one deliverable before publish.',
                    )
                  else
                    ...d.deliverables.map(
                      (del) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: ImSpacing.space12,
                        ),
                        child: ImCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${del.platform} · ${del.deliverableType.replaceAll('_', ' ')}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: ImSpacing.space8),
                              Text(
                                'Disclosure tags (read-only)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: ImSpacing.space4),
                              Wrap(
                                spacing: 6,
                                children: del.disclosureTags.isEmpty
                                    ? [
                                        Text(
                                          'None yet',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ]
                                    : del.disclosureTags
                                        .map(
                                          (t) => Chip(
                                            label: Text(t),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        )
                                        .toList(),
                              ),
                              if (c.status == 'draft' ||
                                  c.status == 'agency_building')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context
                                        .read<CampaignDetailBloc>()
                                        .add(
                                          CampaignDeliverableRemoved(del.id),
                                        ),
                                    child: const Text('Remove'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
