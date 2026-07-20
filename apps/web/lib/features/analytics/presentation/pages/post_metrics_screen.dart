import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/metrics_chart_card.dart';

class PostMetricsScreen extends StatelessWidget {
  const PostMetricsScreen({
    super.key,
    required this.publishedPostId,
  });

  final String publishedPostId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsBloc>()
        ..add(FetchPostAutomatedMetrics(publishedPostId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Automated Metrics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listener: (context, state) {
            if (state.failure != null) {
              ErrorPresenter.show(context, state.failure!);
            }
          },
          builder: (context, state) {
            if (state.status == AnalyticsStatus.loading &&
                state.postMetrics == null) {
              return const Padding(
                padding: EdgeInsets.all(ImSpacing.space16),
                child: Column(
                  children: [
                    ImSkeleton(width: double.infinity, height: 100),
                    SizedBox(height: ImSpacing.space16),
                    ImSkeleton(width: double.infinity, height: 200),
                  ],
                ),
              );
            }

            final metrics = state.postMetrics;

            if (metrics == null) {
              return Center(
                child: ImEmptyState(
                  message:
                      'No automated metrics found. Automated metrics sync periodically once live post ownership is verified.',
                  actionLabel: 'Refresh',
                  onAction: () {
                    context
                        .read<AnalyticsBloc>()
                        .add(FetchPostAutomatedMetrics(publishedPostId));
                  },
                ),
              );
            }

            final engagementRatePct =
                (metrics.engagementRateBps / 100.0).toStringAsFixed(2);

            return ListView(
              padding: const EdgeInsets.all(ImSpacing.space16),
              children: [
                // Overview header card
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _platformIcon(metrics.platform),
                                color: ImColors.teal700,
                              ),
                              const SizedBox(width: ImSpacing.space8),
                              Text(
                                '${metrics.platform.toUpperCase()} Post',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh metrics',
                            onPressed: () {
                              context.read<AnalyticsBloc>().add(
                                    FetchPostAutomatedMetrics(publishedPostId),
                                  );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Post ID: ${metrics.publishedPostId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                      if (metrics.lastSyncedAt != null) ...[
                        const SizedBox(height: ImSpacing.space4),
                        Text(
                          'Last synced: ${_formatDate(metrics.lastSyncedAt!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ImColors.ink600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),

                // KPI Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: ImSpacing.space12,
                  mainAxisSpacing: ImSpacing.space12,
                  childAspectRatio: 1.8,
                  children: [
                    ImKpiCard(
                      label: 'Reach',
                      valueText: _formatNumber(metrics.reach),
                    ),
                    ImKpiCard(
                      label: 'Impressions',
                      valueText: _formatNumber(metrics.impressions),
                    ),
                    ImKpiCard(
                      label: 'Views',
                      valueText: _formatNumber(metrics.views),
                    ),
                    ImKpiCard(
                      label: 'Engagement Rate',
                      valueText: '$engagementRatePct%',
                    ),
                    ImKpiCard(
                      label: 'Likes',
                      valueText: _formatNumber(metrics.likes),
                    ),
                    ImKpiCard(
                      label: 'Comments',
                      valueText: _formatNumber(metrics.comments),
                    ),
                    ImKpiCard(
                      label: 'Shares',
                      valueText: _formatNumber(metrics.shares),
                    ),
                    ImKpiCard(
                      label: 'Clicks',
                      valueText: _formatNumber(metrics.clicks),
                    ),
                  ],
                ),
                const SizedBox(height: ImSpacing.space16),

                // Automated Metrics History Chart (Read-Only)
                MetricsChartCard(
                  title: 'Engagement Trend (Read-only)',
                  subtitle:
                      'Automated sync data points from ${metrics.platform.toUpperCase()} API',
                  dataPoints: metrics.history,
                  isSyncing: metrics.isSyncing,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _platformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle_fill;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.public;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
