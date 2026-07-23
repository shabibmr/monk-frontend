import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../session/session_cubit.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../utils/breakpoints.dart';
import '../../widgets/widgets.dart';


class _NavItem {
  const _NavItem(this.label, this.path, this.icon);
  final String label;
  final String path;
  final IconData icon;
}

class BrandShell extends StatelessWidget {
  const BrandShell({super.key, required this.child});
  final Widget child;

  static const _nav = [
    _NavItem('Dashboard', '/b/dashboard', Icons.dashboard_outlined),
    _NavItem('Discover', '/b/discover', Icons.search),
    _NavItem('Shortlists', '/b/shortlists', Icons.bookmark_outline),
    _NavItem('Campaigns', '/b/campaigns', Icons.campaign_outlined),
    _NavItem('Applications', '/b/applications', Icons.inbox_outlined),
    _NavItem('Briefs', '/b/briefs', Icons.description_outlined),
    _NavItem('Invoices', '/b/invoices', Icons.receipt_long_outlined),
    _NavItem('Team', '/b/settings/team', Icons.group_outlined),
    _NavItem('Company', '/b/settings/company', Icons.business_outlined),
    _NavItem('Settings', '/b/settings/sessions', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.brand(),
      child: _PortalChrome(
        title: 'Brand',
        items: _nav,
        child: child,
      ),
    );
  }
}

class CreatorShell extends StatelessWidget {
  const CreatorShell({super.key, required this.child});
  final Widget child;

  static const _creatorNav = [
    _NavItem('Dashboard', '/c/dashboard', Icons.dashboard_outlined),
    _NavItem('Onboarding', '/c/onboarding', Icons.flag_outlined),
    _NavItem('Marketplace', '/c/marketplace', Icons.storefront_outlined),
    _NavItem('Applications', '/c/applications', Icons.assignment_outlined),
    _NavItem('Earnings', '/c/earnings', Icons.payments_outlined),
    _NavItem('Referrals', '/c/referrals', Icons.card_giftcard_outlined),
    _NavItem('KYC', '/c/settings/kyc', Icons.verified_user_outlined),
    _NavItem('Access', '/c/settings/access', Icons.manage_accounts_outlined),
    _NavItem('Settings', '/c/settings/sessions', Icons.settings_outlined),
  ];

  static const _managerNav = [
    _NavItem('Roster', '/c/roster', Icons.group_outlined),
    _NavItem('Dashboard', '/c/dashboard', Icons.dashboard_outlined),
    _NavItem('Earnings', '/c/earnings', Icons.payments_outlined),
    _NavItem('Access', '/c/settings/access', Icons.manage_accounts_outlined),
    _NavItem('Settings', '/c/settings/sessions', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final isManager = session.role == UserRole.manager;
    return Theme(
      data: AppTheme.influencer(),
      child: _PortalChrome(
        title: isManager || session.isManagerContext ? 'Manager' : 'Creator',
        items: isManager ? _managerNav : _creatorNav,
        showManagerBar: session.isManagerContext,
        child: child,
      ),
    );
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  static const _nav = [
    _NavItem('Dashboard', '/a/dashboard', Icons.dashboard_outlined),
    _NavItem('Verification', '/a/verification', Icons.fact_check_outlined),
    _NavItem('Agency', '/a/agency/briefs', Icons.work_outline),
    _NavItem('Settings', '/a/settings/sessions', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.admin(),
      child: _PortalChrome(
        title: 'Admin',
        items: _nav,
        darkSidebar: true,
        child: child,
      ),
    );
  }
}

class _PortalChrome extends StatelessWidget {
  const _PortalChrome({
    required this.title,
    required this.items,
    required this.child,
    this.darkSidebar = false,
    this.showManagerBar = false,
  });

  final String title;
  final List<_NavItem> items;
  final Widget child;
  final bool darkSidebar;
  final bool showManagerBar;

  @override
  Widget build(BuildContext context) {
    final bp = breakpointOf(context);
    final location = GoRouterState.of(context).uri.toString();
    final selected = items.indexWhere((e) => location.startsWith(e.path));
    final index = selected < 0 ? 0 : selected;
    final unread = context.watch<NotificationsCubit>().state.unreadCount;
    final portal = context.portalTheme;

    if (bp == ImBreakpoint.compact) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MonkLogo(height: 28),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),

          actions: [
            Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (showManagerBar) const _ManagerContextBar(),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index.clamp(0, items.length - 1),
          onDestinationSelected: (i) => context.go(items[i].path),
          destinations: items
              .map(
                (e) => NavigationDestination(
                  icon: Icon(e.icon),
                  label: e.label,
                ),
              )
              .toList(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: ImLayout.sidebarWidth,
            child: Material(
              color: portal.sidebarBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ImSpacing.space16,
                      vertical: ImSpacing.space24,
                    ),

                    child: Row(
                      children: [
                        const MonkLogo(height: 34),
                        const SizedBox(width: ImSpacing.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: portal.sidebarActive.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: portal.sidebarActive,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...items.map((e) {
                    final active = location.startsWith(e.path);
                    return ListTile(
                      leading: Icon(
                        e.icon,
                        color: active
                            ? portal.sidebarActive
                            : portal.sidebarFg.withValues(alpha: 0.7),
                      ),
                      title: Text(
                        e.label,
                        style: TextStyle(
                          color: active
                              ? portal.sidebarActive
                              : portal.sidebarFg,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      selected: active,
                      onTap: () => context.go(e.path),
                    );
                  }),
                  const Spacer(),
                  if (darkSidebar)
                    Padding(
                      padding: const EdgeInsets.all(ImSpacing.space16),
                      child: Text(
                        'Admin portal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.white.withValues(alpha: 0.7),
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (showManagerBar) const _ManagerContextBar(),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ImLayout.contentMaxWidth,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Design.md §8 — coral100 manager context bar (golden-tested).
class ManagerContextBar extends StatelessWidget {
  const ManagerContextBar({
    super.key,
    this.profileName,
    this.onExit,
  });

  final String? profileName;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final name = profileName ??
        context.watch<SessionCubit>().state.activeProfileName ??
        'Profile';
    return Material(
      color: ImColors.coral100,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ImSpacing.space16,
          vertical: ImSpacing.space12,
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
            const SizedBox(width: ImSpacing.space12),
            Expanded(
              child: Text(
                '$name · Acting as manager',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: onExit ??
                  () {
                    context.read<SessionCubit>().setActiveProfile(
                          profileId: null,
                          isManagerContext: false,
                        );
                    context.go('/c/roster');
                  },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerContextBar extends StatelessWidget {
  const _ManagerContextBar();

  @override
  Widget build(BuildContext context) => const ManagerContextBar();
}
