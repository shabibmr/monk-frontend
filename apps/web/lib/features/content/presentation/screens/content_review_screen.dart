import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/content_repository.dart';
import '../cubit/content_review_cubit.dart';
import '../widgets/disclosure_banner.dart';

// wide layout uses breakpointOf

class ContentReviewScreen extends StatelessWidget {
  const ContentReviewScreen({
    super.key,
    required this.collaborationId,
    this.portalHome = '/b/applications',
  });

  final String collaborationId;
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentReviewCubit(
        getIt<ContentRepository>(),
        collaborationId,
      )..load(),
      child: _View(portalHome: portalHome),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.portalHome});
  final String portalHome;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _overrideCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _threadCtrl = TextEditingController();

  @override
  void dispose() {
    _overrideCtrl.dispose();
    _commentCtrl.dispose();
    _threadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = breakpointOf(context) != ImBreakpoint.compact;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.portalHome),
        ),
      ),
      body: BlocConsumer<ContentReviewCubit, ContentReviewState>(
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
          if (state.loading && state.selectedVersion == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final left = _LeftPane(state: state);
          final right = _RightPane(
            state: state,
            overrideCtrl: _overrideCtrl,
            commentCtrl: _commentCtrl,
            threadCtrl: _threadCtrl,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: left),
                const VerticalDivider(width: 1),
                Expanded(flex: 4, child: right),
              ],
            );
          }
          return ListView(
            children: [
              left,
              const Divider(),
              right,
            ],
          );
        },
      ),
    );
  }
}

class _LeftPane extends StatelessWidget {
  const _LeftPane({required this.state});
  final ContentReviewState state;

  @override
  Widget build(BuildContext context) {
    final v = state.selectedVersion;
    return ListView(
      padding: const EdgeInsets.all(ImSpacing.space16),
      shrinkWrap: true,
      children: [
        Text('Versions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ImSpacing.space8),
        if (state.submissions.isEmpty)
          const ImEmptyState(message: 'No content submissions yet.')
        else
          ...state.submissions.expand((s) {
            return s.versions.map(
              (ver) => Padding(
                padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                child: ImCard(
                  onTap: () => context
                      .read<ContentReviewCubit>()
                      .selectVersion(ver.id),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'v${ver.versionNumber} · ${ver.status}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: state.selectedVersion?.id == ver.id
                                    ? FontWeight.w700
                                    : null,
                              ),
                        ),
                      ),
                      ImStatusChip(status: ver.statusChip),
                    ],
                  ),
                ),
              ),
            );
          }),
        if (v != null) ...[
          const SizedBox(height: ImSpacing.space16),
          Text('Preview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: ImSpacing.space8),
          ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.caption.isEmpty ? '(empty caption)' : v.caption),
                if (v.hashtags.isNotEmpty) ...[
                  const SizedBox(height: ImSpacing.space8),
                  Wrap(
                    spacing: 4,
                    children: v.hashtags
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                ],
                if (v.mediaFileIds.isNotEmpty) ...[
                  const SizedBox(height: ImSpacing.space8),
                  Text(
                    'Media files: ${v.mediaFileIds.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RightPane extends StatelessWidget {
  const _RightPane({
    required this.state,
    required this.overrideCtrl,
    required this.commentCtrl,
    required this.threadCtrl,
  });

  final ContentReviewState state;
  final TextEditingController overrideCtrl;
  final TextEditingController commentCtrl;
  final TextEditingController threadCtrl;

  @override
  Widget build(BuildContext context) {
    final disc = state.effectiveDisclosure;
    final cubit = context.read<ContentReviewCubit>();
    return ListView(
      padding: const EdgeInsets.all(ImSpacing.space16),
      shrinkWrap: true,
      children: [
        if (disc != null) ...[
          DisclosureBanner(disclosure: disc),
          const SizedBox(height: ImSpacing.space16),
        ] else
          Text(
            'Disclosure check runs on approve (server).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (!state.disclosurePassed ||
            state.disclosureFromError != null) ...[
          const SizedBox(height: ImSpacing.space8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: ImColors.danger600,
              side: const BorderSide(color: ImColors.danger600, width: 1.5),
            ),
            onPressed: () {},
            child: const Text('Override path (reason required)'),
          ),
          const SizedBox(height: ImSpacing.space8),
          TextField(
            controller: overrideCtrl,
            onChanged: cubit.setOverrideReason,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Override reason *',
              helperText: 'Required when disclosure fails and you approve',
            ),
          ),
        ],
        const SizedBox(height: ImSpacing.space16),
        TextField(
          controller: commentCtrl,
          onChanged: cubit.setComment,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Review comment (required for reject/revision)',
          ),
        ),
        const SizedBox(height: ImSpacing.space16),
        Wrap(
          spacing: ImSpacing.space8,
          runSpacing: ImSpacing.space8,
          children: [
            FilledButton(
              onPressed: state.acting || !state.canApprove
                  ? null
                  : () => cubit.approve(),
              child: const Text('Approve'),
            ),
            OutlinedButton(
              onPressed: state.acting ? null : () => cubit.requestRevision(),
              child: const Text('Request revision'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: ImColors.danger600,
              ),
              onPressed: state.acting ? null : () => cubit.reject(),
              child: const Text('Reject'),
            ),
          ],
        ),
        if (!state.canApprove && !state.disclosurePassed)
          Padding(
            padding: const EdgeInsets.only(top: ImSpacing.space8),
            child: Text(
              'Approve disabled until override reason is provided.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ImColors.danger600,
                  ),
            ),
          ),
        const SizedBox(height: ImSpacing.space24),
        Text('Comments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ImSpacing.space8),
        ...state.comments.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: ImSpacing.space8),
            child: ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.body),
                  Text(
                    c.createdAt ?? c.authorUserId,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        TextField(
          controller: threadCtrl,
          decoration: const InputDecoration(labelText: 'Add comment'),
        ),
        TextButton(
          onPressed: state.acting
              ? null
              : () {
                  cubit.addComment(threadCtrl.text);
                  threadCtrl.clear();
                },
          child: const Text('Post comment'),
        ),
      ],
    );
  }
}
