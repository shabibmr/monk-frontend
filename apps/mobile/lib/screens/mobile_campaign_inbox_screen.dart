import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';
import '../theme/tokens.dart';

class MobileCampaignItem {
  const MobileCampaignItem({
    required this.id,
    required this.brandName,
    required this.title,
    required this.status,
    required this.rewardAmount,
    required this.deadline,
    required this.platform,
    required this.deliverableType,
    this.requiresAction = false,
  });

  final String id;
  final String brandName;
  final String title;
  final CampaignStatus status;
  final String rewardAmount;
  final String deadline;
  final String platform;
  final String deliverableType;
  final bool requiresAction;
}

class MobileCampaignInboxScreen extends StatefulWidget {
  const MobileCampaignInboxScreen({
    super.key,
    this.onSelectCampaign,
    this.onNavigateToEarnings,
  });

  final ValueChanged<MobileCampaignItem>? onSelectCampaign;
  final VoidCallback? onNavigateToEarnings;

  @override
  State<MobileCampaignInboxScreen> createState() => _MobileCampaignInboxScreenState();
}

class _MobileCampaignInboxScreenState extends State<MobileCampaignInboxScreen> {
  String _activeFilter = 'All';
  String _searchQuery = '';

  final List<MobileCampaignItem> _campaigns = const [
    MobileCampaignItem(
      id: 'cmp_101',
      brandName: 'Aura Skincare',
      title: 'Summer Glow Reels Campaign',
      status: CampaignStatus.active,
      rewardAmount: '\$1,250',
      deadline: '2 days left',
      platform: 'Instagram',
      deliverableType: '1x Reel + 2x Stories',
      requiresAction: true,
    ),
    MobileCampaignItem(
      id: 'cmp_102',
      brandName: 'Pulse Fitness',
      title: 'High-Protein Shake Product Launch',
      status: CampaignStatus.active,
      rewardAmount: '\$800',
      deadline: '5 days left',
      platform: 'TikTok',
      deliverableType: '2x TikTok Videos',
      requiresAction: false,
    ),
    MobileCampaignItem(
      id: 'cmp_103',
      brandName: 'EcoWear Apparel',
      title: 'Sustainable Activewear Haul',
      status: CampaignStatus.inReview,
      rewardAmount: '\$2,100',
      deadline: 'Submitted',
      platform: 'YouTube',
      deliverableType: '1x Dedicated Video',
      requiresAction: false,
    ),
    MobileCampaignItem(
      id: 'cmp_104',
      brandName: 'Nova Gaming Gear',
      title: 'Wireless Headset Unboxing',
      status: CampaignStatus.draft,
      rewardAmount: '\$1,500',
      deadline: 'Invited (Expires in 24h)',
      platform: 'YouTube Shorts',
      deliverableType: '3x Shorts',
      requiresAction: true,
    ),
    MobileCampaignItem(
      id: 'cmp_105',
      brandName: 'Lumina Tech',
      title: 'Smart Home Hub Experience',
      status: CampaignStatus.completed,
      rewardAmount: '\$3,000',
      deadline: 'Completed Jul 15',
      platform: 'Instagram',
      deliverableType: 'Carousel + Story Set',
      requiresAction: false,
    ),
  ];

  List<MobileCampaignItem> get _filteredCampaigns {
    return _campaigns.where((campaign) {
      if (_activeFilter == 'Action Required' && !campaign.requiresAction) {
        return false;
      }
      if (_activeFilter == 'In Progress' &&
          campaign.status != CampaignStatus.active &&
          campaign.status != CampaignStatus.inReview) {
        return false;
      }
      if (_activeFilter == 'Completed' && campaign.status != CampaignStatus.completed) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesBrand = campaign.brandName.toLowerCase().contains(query);
        final matchesTitle = campaign.title.toLowerCase().contains(query);
        if (!matchesBrand && !matchesTitle) return false;
      }

      return true;
    }).toList();
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return ImColors.info600;
      case CampaignStatus.inReview:
        return ImColors.warning600;
      case CampaignStatus.completed:
        return ImColors.success600;
      case CampaignStatus.draft:
      case CampaignStatus.cancelled:
        return ImColors.ink600;
    }
  }

  Color _getStatusBgColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return ImColors.info100;
      case CampaignStatus.inReview:
        return ImColors.warning100;
      case CampaignStatus.completed:
        return ImColors.success100;
      case CampaignStatus.draft:
      case CampaignStatus.cancelled:
        return ImColors.cream100;
    }
  }

  String _formatStatusLabel(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return 'IN PROGRESS';
      case CampaignStatus.inReview:
        return 'IN REVIEW';
      case CampaignStatus.completed:
        return 'COMPLETED';
      case CampaignStatus.draft:
        return 'OFFER PENDING';
      case CampaignStatus.cancelled:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCampaigns;
    final actionItemCount = _campaigns.where((c) => c.requiresAction).length;

    return Scaffold(
      backgroundColor: ImColors.cream50,
      appBar: AppBar(
        title: const Text('Campaign Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'View Earnings',
            onPressed: widget.onNavigateToEarnings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Creator Summary Stats Bar
          Container(
            padding: const EdgeInsets.all(ImSpacing.space16),
            color: ImColors.teal800,
            child: Row(
              children: [
                _buildHeaderStatCard(
                  title: 'Active Briefs',
                  value: '3',
                  icon: Icons.campaign,
                ),
                const SizedBox(width: ImSpacing.space12),
                _buildHeaderStatCard(
                  title: 'Action Needed',
                  value: '$actionItemCount',
                  icon: Icons.notifications_active,
                  highlight: actionItemCount > 0,
                ),
                const SizedBox(width: ImSpacing.space12),
                _buildHeaderStatCard(
                  title: 'Pending Escrow',
                  value: '\$4,150',
                  icon: Icons.lock_clock,
                ),
              ],
            ),
          ),

          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(ImSpacing.space16),
            child: Column(
              children: [
                TextField(
                  key: const Key('campaign_search_input'),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search campaigns or brands...',
                    prefixIcon: const Icon(Icons.search, color: ImColors.ink600),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ImSpacing.space16,
                      vertical: ImSpacing.space12,
                    ),
                    filled: true,
                    fillColor: ImColors.white,
                  ),
                ),
                const SizedBox(height: ImSpacing.space12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Action Required', 'In Progress', 'Completed']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: ImSpacing.space8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: _activeFilter == filter,
                                selectedColor: ImColors.teal700,
                                labelStyle: TextStyle(
                                  color: _activeFilter == filter
                                      ? ImColors.white
                                      : ImColors.ink900,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                backgroundColor: ImColors.white,
                                side: BorderSide(
                                  color: _activeFilter == filter
                                      ? ImColors.teal700
                                      : ImColors.cream100,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _activeFilter = filter;
                                    });
                                  }
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Campaign List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox_outlined, size: 48, color: ImColors.ink300),
                        SizedBox(height: ImSpacing.space12),
                        Text(
                          'No campaigns match your filter',
                          style: TextStyle(
                            color: ImColors.ink600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: ImSpacing.space16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, index) => const SizedBox(height: ImSpacing.space12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildCampaignCard(context, item);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatCard({
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(ImSpacing.space12),
        decoration: BoxDecoration(
          color: highlight ? ImColors.coral500 : ImColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: highlight ? ImColors.white : ImColors.cream100,
                ),
                const SizedBox(width: ImSpacing.space4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: highlight ? ImColors.white : ImColors.cream100,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ImSpacing.space4),
            Text(
              value,
              style: TextStyle(
                color: ImColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, MobileCampaignItem item) {
    final statusColor = _getStatusColor(item.status);
    final statusBgColor = _getStatusBgColor(item.status);

    return Card(
      key: Key('campaign_card_${item.id}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        side: BorderSide(
          color: item.requiresAction ? ImColors.coral500 : ImColors.cream100,
          width: item.requiresAction ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        onTap: () => widget.onSelectCampaign?.call(item),
        child: Padding(
          padding: const EdgeInsets.all(ImSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Row: Brand & Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ImColors.teal100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item.brandName.substring(0, 1),
                            style: const TextStyle(
                              color: ImColors.teal800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space8),
                      Text(
                        item.brandName,
                        style: const TextStyle(
                          color: ImColors.ink600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ImSpacing.space8,
                      vertical: ImSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(ImRadii.radiusFull),
                    ),
                    child: Text(
                      _formatStatusLabel(item.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ImSpacing.space12),

              // Title
              Text(
                item.title,
                style: const TextStyle(
                  color: ImColors.ink900,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ImSpacing.space8),

              // Deliverable & Platform details
              Row(
                children: [
                  const Icon(Icons.video_library_outlined, size: 16, color: ImColors.ink600),
                  const SizedBox(width: ImSpacing.space4),
                  Text(
                    '${item.platform} • ${item.deliverableType}',
                    style: const TextStyle(
                      color: ImColors.ink600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Divider(height: ImSpacing.space24),

              // Card Bottom Row: Reward Amount & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payout Reward',
                        style: TextStyle(
                          color: ImColors.ink600,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        item.rewardAmount,
                        style: const TextStyle(
                          color: ImColors.teal800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => widget.onSelectCampaign?.call(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.requiresAction
                          ? ImColors.coral500
                          : ImColors.teal700,
                      minimumSize: const Size(120, 38),
                      padding: const EdgeInsets.symmetric(horizontal: ImSpacing.space12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                      ),
                    ),
                    child: Text(
                      item.requiresAction ? 'Respond Now' : 'View Details',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
