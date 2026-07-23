import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/content_repository.dart';
import '../cubit/content_submit_cubit.dart';

class ContentSubmitScreen extends StatelessWidget {
  const ContentSubmitScreen({
    super.key,
    required this.collaborationId,
  });

  final String collaborationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentSubmitCubit(
        getIt<ContentRepository>(),
        collaborationId,
      )..load(),
      child: _View(collaborationId: collaborationId),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.collaborationId});
  final String collaborationId;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _deliverableId = TextEditingController();
  final _caption = TextEditingController();
  final _hashtags = TextEditingController();
  final _links = TextEditingController();
  final _mediaIds = TextEditingController();

  @override
  void dispose() {
    _deliverableId.dispose();
    _caption.dispose();
    _hashtags.dispose();
    _links.dispose();
    _mediaIds.dispose();
    super.dispose();
  }

  List<String> _split(String raw) => raw
      .split(RegExp(r'[\s,]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit content'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/c/applications'),
        ),
      ),
      body: BlocConsumer<ContentSubmitCubit, ContentSubmitState>(
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
          if (state.loading && state.submissions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Text(
                'Version history',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space8),
              if (state.submissions.isEmpty)
                const Text('No submissions yet — create a draft below.')
              else
                ...state.submissions.expand((s) {
                  return s.versions.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                      child: ImCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'v${v.versionNumber} · ${v.status} · ${s.campaignDeliverableId}',
                              ),
                            ),
                            ImStatusChip(status: v.statusChip),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: ImSpacing.space24),
              Text(
                'New version',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space8),
              TextField(
                controller: _deliverableId,
                decoration: const InputDecoration(
                  labelText: 'Campaign deliverable UUID *',
                ),
              ),
              const SizedBox(height: ImSpacing.space8),
              TextField(
                controller: _caption,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Caption (include disclosure tags)',
                ),
              ),
              const SizedBox(height: ImSpacing.space8),
              TextField(
                controller: _hashtags,
                decoration: const InputDecoration(
                  labelText: 'Hashtags (space/comma separated)',
                ),
              ),
              const SizedBox(height: ImSpacing.space8),
              TextField(
                controller: _links,
                decoration: const InputDecoration(labelText: 'Links'),
              ),
              const SizedBox(height: ImSpacing.space8),
              TextField(
                controller: _mediaIds,
                decoration: const InputDecoration(
                  labelText: 'Media file UUIDs (optional)',
                ),
              ),
              const SizedBox(height: ImSpacing.space16),
              FilledButton(
                onPressed: state.acting
                    ? null
                    : () {
                        final dId = _deliverableId.text.trim();
                        if (dId.isEmpty) {
                          ImToast.show(
                            context,
                            message: 'Deliverable UUID required',
                            tone: ImToastTone.warning,
                          );
                          return;
                        }
                        context.read<ContentSubmitCubit>().createAndSubmit(
                              deliverableId: dId,
                              caption: _caption.text,
                              hashtags: _split(_hashtags.text),
                              links: _split(_links.text),
                              mediaFileIds: _split(_mediaIds.text),
                            );
                      },
                child: Text(
                  state.acting ? 'Submitting…' : 'Create & submit version',
                ),
              ),
              if (_deliverableId.text.trim().isNotEmpty) ...[
                const SizedBox(height: ImSpacing.space12),
                TextButton(
                  onPressed: () => context.go(
                    '/c/collaborations/${widget.collaborationId}/publish/${_deliverableId.text.trim()}',
                  ),
                  child: const Text('Submit live publish URL'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
