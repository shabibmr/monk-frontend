import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../cubit/metrics_form_cubit.dart';

class ManualMetricsScreen extends StatefulWidget {
  const ManualMetricsScreen({super.key, this.publishedPostId});

  final String? publishedPostId;

  @override
  State<ManualMetricsScreen> createState() => _ManualMetricsScreenState();
}

class _ManualMetricsScreenState extends State<ManualMetricsScreen> {
  final _postId = TextEditingController();
  final _reach = TextEditingController();
  final _impressions = TextEditingController();
  final _views = TextEditingController();
  final _likes = TextEditingController();
  final _comments = TextEditingController();
  final _shares = TextEditingController();
  final _clicks = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.publishedPostId != null) {
      _postId.text = widget.publishedPostId!;
    }
  }

  @override
  void dispose() {
    _postId.dispose();
    _reach.dispose();
    _impressions.dispose();
    _views.dispose();
    _likes.dispose();
    _comments.dispose();
    _shares.dispose();
    _clicks.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MetricsFormCubit(getIt<DashboardRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manual post metrics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/c/dashboard'),
          ),
        ),
        body: BlocConsumer<MetricsFormCubit, MetricsFormState>(
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
            return ListView(
              padding: const EdgeInsets.all(ImSpacing.space16),
              children: [
                Text(
                  'Enter platform stats for a published post. '
                  'Server stores latest entry for rollups — no automated sync in P1.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: ImSpacing.space16),
                TextField(
                  controller: _postId,
                  decoration: const InputDecoration(
                    labelText: 'Published post UUID *',
                  ),
                ),
                TextField(
                  controller: _reach,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reach'),
                ),
                TextField(
                  controller: _impressions,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Impressions'),
                ),
                TextField(
                  controller: _views,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Views'),
                ),
                TextField(
                  controller: _likes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Likes'),
                ),
                TextField(
                  controller: _comments,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Comments'),
                ),
                TextField(
                  controller: _shares,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Shares'),
                ),
                TextField(
                  controller: _clicks,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Clicks'),
                ),
                const SizedBox(height: ImSpacing.space16),
                FilledButton(
                  onPressed: state.saving
                      ? null
                      : () {
                          final body = <String, dynamic>{
                            if (_parse(_reach) != null) 'reach': _parse(_reach),
                            if (_parse(_impressions) != null)
                              'impressions': _parse(_impressions),
                            if (_parse(_views) != null) 'views': _parse(_views),
                            if (_parse(_likes) != null) 'likes': _parse(_likes),
                            if (_parse(_comments) != null)
                              'comments': _parse(_comments),
                            if (_parse(_shares) != null)
                              'shares': _parse(_shares),
                            if (_parse(_clicks) != null)
                              'clicks': _parse(_clicks),
                          };
                          context.read<MetricsFormCubit>().save(
                                publishedPostId: _postId.text,
                                body: body,
                              );
                        },
                  child: Text(state.saving ? 'Saving…' : 'Save metrics'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
