import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../cubit/brand_applications_cubit.dart';

class BrandApplicationsScreen extends StatefulWidget {
  const BrandApplicationsScreen({super.key});

  @override
  State<BrandApplicationsScreen> createState() =>
      _BrandApplicationsScreenState();
}

class _BrandApplicationsScreenState extends State<BrandApplicationsScreen> {
  String? _brandId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      var id = context.read<SessionCubit>().state.activeBrandId;
      if (id == null) {
        final brands = await getIt<BrandRepository>().listMine();
        if (brands.isNotEmpty) {
          id = brands.first.id;
          context.read<SessionCubit>().setActiveBrand(id);
        }
      }
      setState(() {
        _brandId = id;
        _loading = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_brandId == null) {
      return const Scaffold(
        body: ImEmptyState(message: 'Create a brand to review applications.'),
      );
    }
    return BlocProvider(
      create: (_) => BrandApplicationsCubit(
        getIt<MarketplaceRepository>(),
        _brandId!,
      )..load(),
      child: const _InboxView(),
    );
  }
}

class _InboxView extends StatelessWidget {
  const _InboxView();

  String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  Future<void> _rejectDialog(BuildContext context, String id) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject application'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason (required)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty && context.mounted) {
      await context.read<BrandApplicationsCubit>().reject(id, reason: reason);
    }
  }

  Future<void> _inviteDialog(BuildContext context) async {
    final campaignCtrl = TextEditingController();
    final profileCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Direct invite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: campaignCtrl,
              decoration: const InputDecoration(labelText: 'Campaign UUID'),
            ),
            TextField(
              controller: profileCtrl,
              decoration:
                  const InputDecoration(labelText: 'Influencer profile UUID'),
            ),
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(labelText: 'Message (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send invite'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<BrandApplicationsCubit>().invite(
            campaignId: campaignCtrl.text.trim(),
            profileId: profileCtrl.text.trim(),
            message: messageCtrl.text.trim().isEmpty
                ? null
                : messageCtrl.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications inbox'),
        actions: [
          TextButton(
            onPressed: () => _inviteDialog(context),
            child: const Text('Invite'),
          ),
        ],
      ),
      body: BlocConsumer<BrandApplicationsCubit, BrandApplicationsState>(
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
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return ImEmptyState(
              message: 'No applications yet. Open campaigns attract creators.',
              actionLabel: 'Campaigns',
              onAction: () => context.go('/b/campaigns'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.items.length,
            separatorBuilder: (c, i) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final a = state.items[i];
              return ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profile ${_shortId(a.influencerProfileId)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        ImStatusChip(status: a.statusChip),
                      ],
                    ),
                    Text(
                      'Campaign ${_shortId(a.campaignId)} · ${a.origin}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (a.pitch != null && a.pitch!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space8),
                        child: Text(a.pitch!),
                      ),
                    if (a.proposedCollabType != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space4),
                        child: Chip(label: Text(a.proposedCollabType!)),
                      ),
                    const SizedBox(height: ImSpacing.space8),
                    Wrap(
                      spacing: ImSpacing.space8,
                      children: [
                        if (a.canBrandShortlist)
                          FilledButton(
                            onPressed: () => context
                                .read<BrandApplicationsCubit>()
                                .shortlist(a.id),
                            child: const Text('Shortlist'),
                          ),
                        if (a.canBrandReject)
                          OutlinedButton(
                            onPressed: () => _rejectDialog(context, a.id),
                            child: const Text('Reject'),
                          ),
                        if (a.status == 'shortlisted')
                          FilledButton.tonal(
                            onPressed: () => context.go(
                              '/b/applications/${a.id}/negotiate',
                            ),
                            child: const Text('Start negotiation'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
