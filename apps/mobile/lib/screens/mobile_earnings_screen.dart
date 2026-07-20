import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class MobileTransactionItem {
  const MobileTransactionItem({
    required this.id,
    required this.sourceName,
    required this.date,
    required this.amount,
    required this.status,
    required this.method,
  });

  final String id;
  final String sourceName;
  final String date;
  final String amount;
  final String status; // 'Paid', 'Pending Escrow', 'Processing'
  final String method;
}

class MobileEarningsScreen extends StatefulWidget {
  const MobileEarningsScreen({
    super.key,
    this.onBackToInbox,
  });

  final VoidCallback? onBackToInbox;

  @override
  State<MobileEarningsScreen> createState() => _MobileEarningsScreenState();
}

class _MobileEarningsScreenState extends State<MobileEarningsScreen> {
  final List<MobileTransactionItem> _transactions = const [
    MobileTransactionItem(
      id: 'tx_901',
      sourceName: 'Lumina Tech — Smart Home Hub',
      date: 'Jul 15, 2026',
      amount: '\$3,000.00',
      status: 'Paid',
      method: 'Stripe Direct Deposit',
    ),
    MobileTransactionItem(
      id: 'tx_902',
      sourceName: 'Aura Skincare — Summer Glow Reels',
      date: 'Jul 18, 2026',
      amount: '\$1,250.00',
      status: 'Pending Escrow',
      method: 'Monk Smart Escrow',
    ),
    MobileTransactionItem(
      id: 'tx_903',
      sourceName: 'EcoWear Apparel — Sustainable Haul',
      date: 'Jul 10, 2026',
      amount: '\$2,100.00',
      status: 'Paid',
      method: 'Stripe Direct Deposit',
    ),
    MobileTransactionItem(
      id: 'tx_904',
      sourceName: 'Pulse Fitness — Shake Launch',
      date: 'Jul 20, 2026',
      amount: '\$800.00',
      status: 'Processing',
      method: 'ACH Wire Transfer',
    ),
  ];

  void _showPayoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instant Payout Request'),
        content: const Text(
          'Available balance: \$5,100.00\n\nTransfer funds directly to your linked Stripe account instantly?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout request of \$5,100.00 submitted successfully!'),
                  backgroundColor: ImColors.success600,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: ImColors.teal700),
            child: const Text('Confirm Transfer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ImColors.cream50,
      appBar: AppBar(
        title: const Text('Earnings & Payouts'),
        leading: widget.onBackToInbox != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackToInbox,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ImSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Balance Card
            Container(
              padding: const EdgeInsets.all(ImSpacing.space24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ImColors.teal800, ImColors.teal700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ImRadii.radiusLg),
                boxShadow: ImShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Total Available Balance',
                        style: TextStyle(
                          color: ImColors.cream100,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.shield_outlined, color: ImColors.coral500, size: 20),
                    ],
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  const Text(
                    '\$5,100.00',
                    style: TextStyle(
                      color: ImColors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  const Divider(color: ImColors.teal700, height: 1),
                  const SizedBox(height: ImSpacing.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBalanceSubItem(
                        label: 'Pending Escrow',
                        amount: '\$4,150.00',
                      ),
                      _buildBalanceSubItem(
                        label: 'Lifetime Earned',
                        amount: '\$18,450.00',
                      ),
                    ],
                  ),
                  const SizedBox(height: ImSpacing.space24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('request_payout_btn'),
                      onPressed: _showPayoutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ImColors.coral500,
                        foregroundColor: ImColors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, size: 20),
                          SizedBox(width: ImSpacing.space8),
                          Text(
                            'Request Instant Payout',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ImSpacing.space24),

            // Revenue Streams Breakdown
            const Text(
              'Earnings Breakdown',
              style: TextStyle(
                color: ImColors.ink900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ImSpacing.space12),
            Row(
              children: [
                _buildBreakdownCard(
                  label: 'Sponsored Posts',
                  amount: '\$14,200',
                  icon: Icons.campaign_outlined,
                  color: ImColors.teal700,
                ),
                const SizedBox(width: ImSpacing.space12),
                _buildBreakdownCard(
                  label: 'Affiliate Rev',
                  amount: '\$4,250',
                  icon: Icons.storefront_outlined,
                  color: ImColors.info600,
                ),
              ],
            ),
            const SizedBox(height: ImSpacing.space24),

            // Recent Transactions Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: ImColors.ink900,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: ImColors.teal700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ImSpacing.space12),

            // Transaction History Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, index) => const SizedBox(height: ImSpacing.space8),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return _buildTransactionTile(tx);
              },
            ),
            const SizedBox(height: ImSpacing.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSubItem({required String label, required String amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ImColors.cream100,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: ImSpacing.space4),
        Text(
          amount,
          style: const TextStyle(
            color: ImColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(ImSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: ImSpacing.space12),
              Text(
                label,
                style: const TextStyle(
                  color: ImColors.ink600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: ImSpacing.space4),
              Text(
                amount,
                style: const TextStyle(
                  color: ImColors.ink900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(MobileTransactionItem tx) {
    Color statusColor;
    Color statusBg;

    switch (tx.status) {
      case 'Paid':
        statusColor = ImColors.success600;
        statusBg = ImColors.success100;
        break;
      case 'Pending Escrow':
        statusColor = ImColors.warning600;
        statusBg = ImColors.warning100;
        break;
      default:
        statusColor = ImColors.info600;
        statusBg = ImColors.info100;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(ImSpacing.space16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                tx.status == 'Paid' ? Icons.check_circle_outline : Icons.schedule,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: ImSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.sourceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ImColors.ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space4),
                  Text(
                    '${tx.date} • ${tx.method}',
                    style: const TextStyle(
                      color: ImColors.ink600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ImSpacing.space8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx.amount,
                  style: const TextStyle(
                    color: ImColors.teal800,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ImSpacing.space4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ImSpacing.space8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(ImRadii.radiusFull),
                  ),
                  child: Text(
                    tx.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
