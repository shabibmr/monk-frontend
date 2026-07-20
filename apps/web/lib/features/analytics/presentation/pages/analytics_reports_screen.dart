import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/export_status_dialog.dart';
import '../widgets/metrics_chart_card.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({
    super.key,
    this.campaignId,
  });

  final String? campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsBloc>()
        ..add(FetchComparisonReport(campaignId: campaignId))
        ..add(FetchUtmLinks(campaignId: campaignId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics & Reports'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            Builder(
              builder: (innerContext) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export Report',
                  onSelected: (format) {
                    innerContext.read<AnalyticsBloc>().add(
                          TriggerExportJob(
                            reportType: 'campaign_performance',
                            format: format,
                            params: {'campaignId': campaignId},
                          ),
                        );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'csv',
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, size: 18),
                          SizedBox(width: ImSpacing.space8),
                          Text('Export as CSV'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, size: 18),
                          SizedBox(width: ImSpacing.space8),
                          Text('Export as PDF'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'xlsx',
                      child: Row(
                        children: [
                          Icon(Icons.grid_on, size: 18),
                          SizedBox(width: ImSpacing.space8),
                          Text('Export as XLSX'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listener: (context, state) {
            if (state.failure != null) {
              ErrorPresenter.show(context, state.failure!);
            }
            if (state.exportJobStatus != null) {
              ExportStatusDialog.show(
                context,
                jobStatus: state.exportJobStatus!,
                onDismiss: () {
                  context.read<AnalyticsBloc>().add(const ResetExportStatus());
                },
                onRetry: () {
                  context.read<AnalyticsBloc>().add(
                        TriggerExportJob(
                          reportType: state.exportJobStatus!.reportType,
                          format: state.exportJobStatus!.format,
                          params: {'campaignId': campaignId},
                        ),
                      );
                },
              );
            }
          },
          builder: (context, state) {
            if (state.status == AnalyticsStatus.loading &&
                state.comparisonReport == null) {
              return const Padding(
                padding: EdgeInsets.all(ImSpacing.space16),
                child: Column(
                  children: [
                    ImSkeleton(width: double.infinity, height: 120),
                    SizedBox(height: ImSpacing.space16),
                    ImSkeleton(width: double.infinity, height: 220),
                  ],
                ),
              );
            }

            final report = state.comparisonReport;

            return ListView(
              padding: const EdgeInsets.all(ImSpacing.space16),
              children: [
                // Top Summary Header Card
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            report?.title ?? 'Campaign Performance Analytics',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              ImButton(
                                label: 'Export CSV',
                                variant: ImButtonVariant.secondary,
                                icon: const Icon(Icons.file_download, size: 16),
                                loading: state.isExporting,
                                onPressed: () {
                                  context.read<AnalyticsBloc>().add(
                                        TriggerExportJob(
                                          reportType: 'campaign_performance',
                                          format: 'csv',
                                          params: {'campaignId': campaignId},
                                        ),
                                      );
                                },
                              ),
                              const SizedBox(width: ImSpacing.space8),
                              ImButton(
                                label: 'Managed Report',
                                icon: const Icon(Icons.picture_as_pdf, size: 16),
                                loading: state.isExporting,
                                onPressed: () {
                                  context.read<AnalyticsBloc>().add(
                                        TriggerExportJob(
                                          reportType: 'managed_report',
                                          format: 'pdf',
                                          params: {'campaignId': campaignId},
                                        ),
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space16),

                      // Metric Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: ImKpiCard(
                              label: 'Total Reach',
                              valueText:
                                  _formatNumber(report?.totalReach ?? 0),
                            ),
                          ),
                          const SizedBox(width: ImSpacing.space12),
                          Expanded(
                            child: ImKpiCard(
                              label: 'Total Impressions',
                              valueText:
                                  _formatNumber(report?.totalImpressions ?? 0),
                            ),
                          ),
                          const SizedBox(width: ImSpacing.space12),
                          Expanded(
                            child: ImKpiCard(
                              label: 'Total Engagement',
                              valueText:
                                  _formatNumber(report?.totalEngagement ?? 0),
                            ),
                          ),
                          const SizedBox(width: ImSpacing.space12),
                          Expanded(
                            child: ImKpiCard(
                              label: 'Total Spend',
                              moneyMinor: report?.totalSpendMinor ?? 0,
                              currencyCode: report?.currency ?? 'USD',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),

                // Time Series Chart Card
                MetricsChartCard(
                  title: 'Performance Comparison',
                  subtitle:
                      'Period-over-period campaign reach and engagement metrics',
                  dataPoints: report?.chartSeries ?? const [],
                ),
                const SizedBox(height: ImSpacing.space16),

                // Comparison Metrics Section
                if (report != null && report.metricsComparison.isNotEmpty) ...[
                  Text(
                    'Period-over-Period Comparisons',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ...report.metricsComparison.map((comp) {
                    final isPos = comp.isPositive;
                    final pctText =
                        '${isPos ? '+' : ''}${comp.changePercentage.toStringAsFixed(1)}%';
                    final color = isPos ? ImColors.success600 : ImColors.danger600;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                      child: ImCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comp.metricName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Current: ${comp.currentValue.toStringAsFixed(0)} (Prev: ${comp.previousValue.toStringAsFixed(0)})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: ImColors.ink600),
                                ),
                                const SizedBox(width: ImSpacing.space16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: ImSpacing.space8,
                                    vertical: ImSpacing.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPos
                                        ? ImColors.success100
                                        : ImColors.danger100,
                                    borderRadius: BorderRadius.circular(
                                      ImRadii.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isPos
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color: color,
                                        size: 16,
                                      ),
                                      const SizedBox(width: ImSpacing.space4),
                                      Text(
                                        pctText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: ImSpacing.space16),
                ],

                // UTM Link Tracking & Display Section
                Text(
                  'UTM Links & Conversions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: ImSpacing.space12),
                if (state.utmLinks.isEmpty)
                  ImCard(
                    child: Padding(
                      padding: const EdgeInsets.all(ImSpacing.space16),
                      child: Text(
                        'No UTM tracking links configured for this campaign.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                    ),
                  )
                else
                  ...state.utmLinks.map((utm) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                      child: ImCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(ImSpacing.space8),
                              decoration: BoxDecoration(
                                color: ImColors.teal100,
                                borderRadius:
                                    BorderRadius.circular(ImRadii.radiusSm),
                              ),
                              child: const Icon(
                                Icons.link,
                                color: ImColors.teal700,
                              ),
                            ),
                            const SizedBox(width: ImSpacing.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Code: ${utm.code}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: ImSpacing.space4),
                                  Text(
                                    utm.fullUtmUrl,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: ImColors.ink600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: ImSpacing.space16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${utm.clicks} clicks · ${utm.conversions} conv.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: ImSpacing.space4),
                                ImMoneyText(
                                  minorUnits: utm.revenueMinor,
                                  currencyCode: report?.currency ?? 'USD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: ImColors.success600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
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
}
