import 'package:flutter/material.dart';

import '../../../dashboards/presentation/screens/brand_dashboard_screen.dart'
    as dash;
import '../../../dashboards/presentation/screens/creator_dashboard_screen.dart'
    as dash;
import 'admin_dashboard_screen.dart';

export 'admin_dashboard_screen.dart';

/// Brand dashboard — live KPIs from analytics API (T1.15).
class BrandDashboardScreen extends StatelessWidget {
  const BrandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const dash.BrandDashboardScreen();
}

/// Creator/manager dashboard — live KPIs (T1.15).
class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const dash.CreatorDashboardScreen();
}
