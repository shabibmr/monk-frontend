import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/agency_kanban_card.dart';
import '../../domain/entities/agency_kanban_column.dart';
import '../bloc/agency_console_bloc.dart';
import '../bloc/agency_console_event.dart';
import '../bloc/agency_console_state.dart';
import '../widgets/agency_asset_drawer.dart';

class AgencyKanbanScreen extends StatelessWidget {
  const AgencyKanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AgencyConsoleBloc>()..add(const LoadAgencyConsole()),
      child: const _AgencyKanbanView(),
    );
  }
}

class _AgencyKanbanView extends StatelessWidget {
  const _AgencyKanbanView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AgencyConsoleBloc, AgencyConsoleState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ImToast.show(
              context,
              message: state.errorMessage!,
              tone: ImToastTone.danger,
            );
          }
        },
        builder: (context, state) {
          if (state.phase == AgencyConsolePhase.loading && state.columns.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context, state),
                  Expanded(
                    child: state.activeTab == 0
                        ? _buildKanbanBoard(context, state)
                        : _buildOperatorReports(context, state),
                  ),
                ],
              ),
              if (state.isAssetDrawerOpen && state.selectedCardId != null)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: AgencyAssetDrawer(
                    cardId: state.selectedCardId!,
                    assets: state.selectedCardAssets,
                    isLoading: state.isAssetActionLoading,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AgencyConsoleState state) {
    final report = state.operatorReport;
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Managed-Service Agency Console',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage end-to-end delivery pipeline, asset approvals, and operator bandwidth.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  ImButton(
                    label: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    variant: ImButtonVariant.secondary,
                    onPressed: () {
                      context.read<AgencyConsoleBloc>().add(const LoadAgencyConsole());
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (report != null)
            Row(
              children: [
                Expanded(
                  child: ImKpiCard(
                    label: 'Active Briefs',
                    valueText: '${report.totalActiveBriefs}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImKpiCard(
                    label: 'On-Time Deliveries',
                    valueText: '${report.deliveredOnTimeCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImKpiCard(
                    label: 'Pending Asset Approvals',
                    valueText: '${report.pendingApprovalAssetsCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImKpiCard(
                    label: 'Avg Turnaround',
                    valueText: '${report.avgTurnaroundDays} days',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Delivery Kanban Board'),
                selected: state.activeTab == 0,
                onSelected: (_) {
                  context.read<AgencyConsoleBloc>().add(const ChangeTabEvent(0));
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Operator Reports'),
                selected: state.activeTab == 1,
                onSelected: (_) {
                  context.read<AgencyConsoleBloc>().add(const ChangeTabEvent(1));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, AgencyConsoleState state) {
    if (state.columns.isEmpty) {
      return const ImEmptyState(
        message: 'Agency kanban board is currently empty.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: state.columns.map((col) {
          return Container(
            width: 320,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      col.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ImStatusChip(
                      status: EntityStatus.inProgress,
                      label: '${col.cards.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: col.cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final card = col.cards[idx];
                      return _buildKanbanCardItem(context, card, state.columns);
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKanbanCardItem(
    BuildContext context,
    AgencyKanbanCard card,
    List<AgencyKanbanColumn> columns,
  ) {
    return ImCard(
      child: InkWell(
        onTap: () {
          context.read<AgencyConsoleBloc>().add(SelectCardForAssetsEvent(card.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (card.pendingApprovalsCount > 0)
                    ImStatusChip(
                      status: EntityStatus.inProgress,
                      label: '${card.pendingApprovalsCount} Pending',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business, size: 14),
                  const SizedBox(width: 4),
                  Text(card.brandName, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 12),
                  const Icon(Icons.person_outline, size: 14),
                  const SizedBox(width: 4),
                  Text(card.creatorName, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImMoneyText(
                    minorUnits: card.budgetMinor,
                    currencyCode: card.currency,
                  ),
                  Text(
                    'Due: ${card.dueDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ImButton(
                      label: 'Assets (${card.assetCount})',
                      icon: const Icon(Icons.attach_file),
                      variant: ImButtonVariant.secondary,
                      onPressed: () {
                        context
                            .read<AgencyConsoleBloc>()
                            .add(SelectCardForAssetsEvent(card.id));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.drive_file_move_outlined),
                    tooltip: 'Move Stage',
                    onSelected: (targetColId) {
                      context.read<AgencyConsoleBloc>().add(
                            MoveKanbanCardEvent(
                              cardId: card.id,
                              targetColumnId: targetColId,
                            ),
                          );
                    },
                    itemBuilder: (context) => columns
                        .map(
                          (c) => PopupMenuItem(
                            value: c.id,
                            child: Text('Move to: ${c.title}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorReports(BuildContext context, AgencyConsoleState state) {
    final report = state.operatorReport;
    if (report == null || report.operators.isEmpty) {
      return const ImEmptyState(
        message: 'No operator performance metrics available.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operator Performance Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: report.operators.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final op = report.operators[idx];
              return ImCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(op.name.substring(0, 1)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              op.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Operator ID: ${op.operatorId}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${op.activeBriefs} Active Briefs',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${op.completedCampaigns} Completed • ${op.onTimeDeliveryRatePct}% On-time',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
