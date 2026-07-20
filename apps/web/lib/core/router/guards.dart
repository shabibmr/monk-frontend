import 'package:monk_shared/monk_shared.dart';

import '../session/session_cubit.dart';

/// Top-level redirect matrix (frontend-plan 03).
String? appRedirect({
  required SessionCubit session,
  required String location,
  required String? matchedLocation,
}) {
  final path = matchedLocation ?? location;
  final authed = session.state.isAuthenticated;
  final role = session.state.role;

  final isPublic = path == '/' ||
      path.startsWith('/login') ||
      path.startsWith('/register') ||
      path.startsWith('/verify-email') ||
      path.startsWith('/password') ||
      path.startsWith('/invites') ||
      path == '/403' ||
      path == '/404';

  if (!session.state.hydrated) {
    return null;
  }

  if (!authed && !isPublic) {
    final from = Uri.encodeComponent(path);
    return '/login?from=$from';
  }

  if (authed &&
      (path.startsWith('/login') || path.startsWith('/register'))) {
    return session.roleHomePath() ?? '/';
  }

  if (authed && session.state.needsEmailVerification) {
    if (!path.startsWith('/verify-email')) {
      return '/verify-email';
    }
  }

  if (authed && role != null) {
    if (path.startsWith('/b') && !role.isBrand) {
      return '/403';
    }
    if (path.startsWith('/c') && !role.isCreator) {
      return '/403';
    }
    if (path.startsWith('/a') && !role.isAdminPortal) {
      return '/403';
    }
  }

  // Influencer incomplete onboarding → wizard (allow settings/onboarding paths).
  if (authed &&
      session.state.needsInfluencerOnboarding &&
      path.startsWith('/c') &&
      !path.startsWith('/c/onboarding') &&
      !path.startsWith('/c/settings') &&
      !path.startsWith('/c/social') &&
      !path.startsWith('/c/referrals')) {
    return '/c/onboarding';
  }

  // Brand without company → onboarding.
  if (authed &&
      session.state.needsBrandOnboarding &&
      path.startsWith('/b') &&
      !path.startsWith('/b/onboarding') &&
      !path.startsWith('/b/settings')) {
    return '/b/onboarding';
  }

  // Manager without selected profile: keep on roster / settings / invites.
  if (authed &&
      role == UserRole.manager &&
      session.state.activeProfileId == null &&
      path.startsWith('/c') &&
      !path.startsWith('/c/roster') &&
      !path.startsWith('/c/settings') &&
      !path.startsWith('/c/earnings') &&
      path != '/c/dashboard') {
    // Allow dashboard; deep tools that need profile stay on roster.
  }

  return null;
}

bool roleCanAccess(UserRole role, String path) {
  if (path.startsWith('/b')) return role.isBrand;
  if (path.startsWith('/c')) return role.isCreator;
  if (path.startsWith('/a')) return role.isAdminPortal;
  return true;
}
