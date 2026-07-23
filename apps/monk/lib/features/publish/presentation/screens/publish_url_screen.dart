import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/publish_repository.dart';
import '../bloc/publish_bloc.dart';

class PublishUrlScreen extends StatelessWidget {
  const PublishUrlScreen({
    super.key,
    required this.collaborationId,
    required this.deliverableId,
  });

  final String collaborationId;
  final String deliverableId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublishBloc(
        getIt<PublishRepository>(),
        collaborationId: collaborationId,
        deliverableId: deliverableId,
      )..add(const PublishLoaded()),
      child: _View(
        collaborationId: collaborationId,
        deliverableId: deliverableId,
      ),
    );
  }
}

class _View extends StatefulWidget {
  const _View({
    required this.collaborationId,
    required this.deliverableId,
  });

  final String collaborationId;
  final String deliverableId;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _url = TextEditingController();

  @override
  void dispose() {
    // Polling cancelled in bloc.close()
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish live URL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(
            '/c/collaborations/${widget.collaborationId}/content',
          ),
        ),
      ),
      body: BlocConsumer<PublishBloc, PublishState>(
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
          final post = state.post;
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Text(
                'Paste the live post URL after platform publish. '
                'No auto-publish — verification only.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ImSpacing.space16),
              if (post != null) ...[
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.platform,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ImStatusChip(
                            status: post.statusChip,
                            label: post.statusLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      SelectableText(
                        post.liveUrl,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.info600,
                            ),
                      ),
                      if (post.verificationDetail != null) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          post.verificationDetail!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (state.polling)
                        const Padding(
                          padding: EdgeInsets.only(top: ImSpacing.space12),
                          child: LinearProgressIndicator(),
                        ),
                      if (post.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(top: ImSpacing.space12),
                          child: Chip(
                            label: Text('Verified'),
                            backgroundColor: ImColors.success100,
                            avatar: Icon(
                              Icons.verified,
                              color: ImColors.success600,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
              ],
              if (post == null || !post.isVerified) ...[
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Live post URL *',
                    hintText: 'https://www.instagram.com/reel/...',
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),
                FilledButton(
                  onPressed: state.submitting
                      ? null
                      : () => context.read<PublishBloc>().add(
                            PublishUrlSubmitted(_url.text),
                          ),
                  child: Text(
                    state.submitting ? 'Submitting…' : 'Submit URL',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
