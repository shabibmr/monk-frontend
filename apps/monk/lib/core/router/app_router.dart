import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import 'deferred_loader.dart';
import '../../features/agency/presentation/pages/agency_kanban_screen.dart' deferred as agency_kanban;
import '../../features/billing/presentation/pages/billing_portal_screen.dart' deferred as billing_portal;
import '../../features/disputes/presentation/screens/admin_dispute_resolution_panel.dart' deferred as admin_dispute;
import '../../features/referrals/presentation/pages/admin_referrals_screen.dart' deferred as admin_referrals;
import '../../features/kyc/presentation/screens/verification_queue_screen.dart' deferred as verification_queue;
import '../../features/auth/presentation/screens/error_screens.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sessions_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/chat/presentation/pages/chat_thread_screen.dart';
import '../../features/notifications/presentation/pages/notification_preferences_screen.dart';
import '../../features/barter/presentation/screens/barter_screen.dart';
import '../../features/briefs/presentation/screens/agency_briefs_screen.dart';
import '../../features/briefs/presentation/screens/brief_create_screen.dart';
import '../../features/briefs/presentation/screens/brief_list_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_create_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_detail_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_list_screen.dart';
import '../../features/content/presentation/screens/content_review_screen.dart';
import '../../features/content/presentation/screens/content_submit_screen.dart';
import '../../features/contracts/presentation/screens/contract_screen.dart';
import '../../features/contracts/presentation/screens/contract_templates_screen.dart';
import '../../features/dashboards/presentation/screens/manual_metrics_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/discovery/presentation/screens/shortlists_screen.dart';
import '../../features/disputes/presentation/screens/data_erasure_status_screen.dart';
import '../../features/disputes/presentation/screens/dispute_filing_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/kyc/presentation/screens/verification_detail_screen.dart';
import '../../features/licensing/presentation/screens/licensing_deal_wizard_screen.dart';
import '../../features/licensing/presentation/screens/licensing_grant_delivery_screen.dart';
import '../../features/manager/presentation/screens/manager_earnings_screen.dart';
import '../../features/payments/presentation/screens/collab_payments_screen.dart';
import '../../features/payments/presentation/screens/earnings_screen.dart';
import '../../features/payments/presentation/screens/invoices_screen.dart';
import '../../features/publish/presentation/screens/publish_url_screen.dart';
import '../../features/reviews/presentation/screens/leave_review_screen.dart';
import '../../features/manager/presentation/screens/manager_invite_accept_screen.dart';
import '../../features/manager/presentation/screens/manager_roster_screen.dart';
import '../../features/manager/presentation/screens/profile_access_screen.dart';
import '../../features/marketplace/presentation/screens/brand_applications_screen.dart';
import '../../features/marketplace/presentation/screens/creator_applications_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_detail_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/negotiations/presentation/screens/negotiation_screen.dart';
import '../../features/onboarding_brand/presentation/screens/brand_invite_accept_screen.dart';
import '../../features/onboarding_brand/presentation/screens/brand_onboarding_screen.dart';
import '../../features/onboarding_brand/presentation/screens/company_profile_screen.dart';
import '../../features/onboarding_brand/presentation/screens/team_members_screen.dart';
import '../../features/onboarding_influencer/presentation/screens/connected_accounts_screen.dart';
import '../../features/onboarding_influencer/presentation/screens/onboarding_wizard_screen.dart';
import '../../features/onboarding_influencer/presentation/screens/profile_edit_screen.dart';
import '../../features/onboarding_influencer/presentation/screens/referrals_screen.dart';
import '../../features/referrals/presentation/pages/referral_rewards_screen.dart';
import '../../features/shell_homes/presentation/screens/dashboard_stubs.dart';
import '../session/session_cubit.dart';
import 'guards.dart';
import 'shells/portal_shell.dart';

GoRouter createAppRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      return appRedirect(
        session: session,
        location: state.uri.toString(),
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingStubScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/password/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/password/reset',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/403',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      GoRoute(
        path: '/404',
        builder: (context, state) => const NotFoundScreen(),
      ),
      GoRoute(
        path: '/invites/brand',
        builder: (context, state) => BrandInviteAcceptScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: '/invites/manager',
        builder: (context, state) => ManagerInviteAcceptScreen(
          token: state.uri.queryParameters['token'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => BrandShell(child: child),
        routes: [
          GoRoute(
            path: '/b/dashboard',
            builder: (context, state) => const BrandDashboardScreen(),
          ),
          GoRoute(
            path: '/b/onboarding',
            builder: (context, state) => const BrandOnboardingScreen(),
          ),
          GoRoute(
            path: '/b/discover',
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: '/b/shortlists',
            builder: (context, state) => const ShortlistsScreen(),
          ),
          GoRoute(
            path: '/b/campaigns',
            builder: (context, state) => const CampaignListScreen(),
          ),
          GoRoute(
            path: '/b/campaigns/new',
            builder: (context, state) => const CampaignCreateScreen(),
          ),
          GoRoute(
            path: '/b/campaigns/:id',
            builder: (context, state) => CampaignDetailScreen(
              campaignId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/b/applications',
            builder: (context, state) => const BrandApplicationsScreen(),
          ),
          GoRoute(
            path: '/b/applications/:applicationId/negotiate',
            builder: (context, state) => OpenNegotiationScreen(
              applicationId: state.pathParameters['applicationId']!,
            ),
          ),
          GoRoute(
            path: '/b/negotiations/:id',
            builder: (context, state) => NegotiationScreen(
              negotiationId: state.pathParameters['id']!,
              portalHome: '/b/applications',
            ),
          ),
          GoRoute(
            path: '/b/collaborations/:id/contract',
            builder: (context, state) => ContractScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/b/applications',
            ),
          ),
          GoRoute(
            path: '/b/contracts/templates',
            builder: (context, state) => const ContractTemplatesScreen(),
          ),
          GoRoute(
            path: '/b/licensing/wizard/:collabId',
            builder: (context, state) => LicensingDealWizardScreen(
              collaborationId: state.pathParameters['collabId']!,
            ),
          ),
          GoRoute(
            path: '/b/licensing/grants/:id',
            builder: (context, state) => LicensingGrantDeliveryScreen(
              grantId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/b/disputes/file/:collabId',
            builder: (context, state) => DisputeFilingScreen(
              collaborationId: state.pathParameters['collabId']!,
              paymentId: state.uri.queryParameters['paymentId'],
            ),
          ),
          GoRoute(
            path: '/b/collaborations/:id/barter',
            builder: (context, state) => BarterScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/b/applications',
            ),
          ),
          GoRoute(
            path: '/b/collaborations/:id/review',
            builder: (context, state) => ContentReviewScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/b/applications',
            ),
          ),
          GoRoute(
            path: '/b/collaborations/:id/review-rating',
            builder: (context, state) => LeaveReviewScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/b/applications',
            ),
          ),
          GoRoute(
            path: '/b/collaborations/:id/payments',
            builder: (context, state) => CollabPaymentsScreen(
              collaborationId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/b/invoices',
            builder: (context, state) => const InvoicesScreen(
              portalHome: '/b/dashboard',
            ),
          ),
          GoRoute(
            path: '/b/billing',
            builder: (context, state) => DeferredLoader(
              loader: billing_portal.loadLibrary,
              builder: () => billing_portal.BillingPortalScreen(),
            ),
          ),
          GoRoute(
            path: '/b/briefs',
            builder: (context, state) => const BriefListScreen(),
          ),
          GoRoute(
            path: '/b/briefs/new',
            builder: (context, state) => const BriefCreateScreen(),
          ),
          GoRoute(
            path: '/b/settings/company',
            builder: (context, state) => const CompanyProfileScreen(),
          ),
          GoRoute(
            path: '/b/settings/team',
            builder: (context, state) => const TeamMembersScreen(),
          ),
          GoRoute(
            path: '/b/settings/data-erasure',
            builder: (context, state) => const DataErasureStatusScreen(),
          ),
          GoRoute(
            path: '/b/settings/sessions',
            builder: (context, state) => const SessionsScreen(),
          ),
          GoRoute(
            path: '/b/chat',
            builder: (context, state) => const ChatThreadScreen(),
          ),
          GoRoute(
            path: '/b/settings/notifications',
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => CreatorShell(child: child),
        routes: [
          GoRoute(
            path: '/c/dashboard',
            builder: (context, state) => const CreatorDashboardScreen(),
          ),
          GoRoute(
            path: '/c/metrics',
            builder: (context, state) => ManualMetricsScreen(
              publishedPostId: state.uri.queryParameters['postId'],
            ),
          ),
          GoRoute(
            path: '/c/onboarding',
            builder: (context, state) => const InfluencerOnboardingWizardScreen(),
          ),
          GoRoute(
            path: '/c/onboarding/:step',
            builder: (context, state) {
              final stepName = state.pathParameters['step'];
              final map = {
                'account': 1,
                'platforms': 2,
                'social': 3,
                'categories': 4,
                'team': 5,
                'kyc': 6,
              };
              return InfluencerOnboardingWizardScreen(
                initialStep: map[stepName],
              );
            },
          ),
          GoRoute(
            path: '/c/social',
            builder: (context, state) => const ConnectedAccountsScreen(),
          ),
          GoRoute(
            path: '/c/referrals',
            builder: (context, state) => const ReferralsScreen(),
          ),
          GoRoute(
            path: '/c/referrals/rewards',
            builder: (context, state) => const ReferralRewardsScreen(),
          ),
          GoRoute(
            path: '/c/settings/profile',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: '/c/settings/kyc',
            builder: (context, state) => const KycScreen(),
          ),
          GoRoute(
            path: '/c/roster',
            builder: (context, state) => const ManagerRosterScreen(),
          ),
          GoRoute(
            path: '/c/marketplace',
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/c/marketplace/:id',
            builder: (context, state) => MarketplaceDetailScreen(
              campaignId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/c/applications',
            builder: (context, state) => const CreatorApplicationsScreen(),
          ),
          GoRoute(
            path: '/c/negotiations/:id',
            builder: (context, state) => NegotiationScreen(
              negotiationId: state.pathParameters['id']!,
              portalHome: '/c/applications',
            ),
          ),
          GoRoute(
            path: '/c/collaborations/:id/contract',
            builder: (context, state) => ContractScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/c/applications',
            ),
          ),
          GoRoute(
            path: '/c/licensing/grants/:id',
            builder: (context, state) => LicensingGrantDeliveryScreen(
              grantId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/c/disputes/file/:collabId',
            builder: (context, state) => DisputeFilingScreen(
              collaborationId: state.pathParameters['collabId']!,
              paymentId: state.uri.queryParameters['paymentId'],
            ),
          ),
          GoRoute(
            path: '/c/collaborations/:id/barter',
            builder: (context, state) => BarterScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/c/applications',
              isCreator: true,
            ),
          ),
          GoRoute(
            path: '/c/collaborations/:id/content',
            builder: (context, state) => ContentSubmitScreen(
              collaborationId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/c/collaborations/:id/publish/:dId',
            builder: (context, state) => PublishUrlScreen(
              collaborationId: state.pathParameters['id']!,
              deliverableId: state.pathParameters['dId']!,
            ),
          ),
          GoRoute(
            path: '/c/collaborations/:id/review-rating',
            builder: (context, state) => LeaveReviewScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/c/applications',
            ),
          ),
          GoRoute(
            path: '/c/earnings',
            builder: (context, state) {
              final session = context.read<SessionCubit>().state;
              if (session.role == UserRole.manager) {
                return const ManagerEarningsScreen();
              }
              return const EarningsScreen();
            },
          ),
          GoRoute(
            path: '/c/invoices',
            builder: (context, state) => const InvoicesScreen(
              portalHome: '/c/earnings',
            ),
          ),
          GoRoute(
            path: '/c/billing',
            builder: (context, state) => DeferredLoader(
              loader: billing_portal.loadLibrary,
              builder: () => billing_portal.BillingPortalScreen(),
            ),
          ),
          GoRoute(
            path: '/c/settings/access',
            builder: (context, state) => const ProfileAccessScreen(),
          ),
          GoRoute(
            path: '/c/settings/data-erasure',
            builder: (context, state) => const DataErasureStatusScreen(),
          ),
          GoRoute(
            path: '/c/settings/sessions',
            builder: (context, state) => const SessionsScreen(),
          ),
          GoRoute(
            path: '/c/chat',
            builder: (context, state) => const ChatThreadScreen(),
          ),
          GoRoute(
            path: '/c/settings/notifications',
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/a/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/a/verification',
            builder: (context, state) => DeferredLoader(
              loader: verification_queue.loadLibrary,
              builder: () => verification_queue.VerificationQueueScreen(),
            ),
          ),
          GoRoute(
            path: '/a/verification/:id',
            builder: (context, state) => VerificationDetailScreen(
              kycId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/a/agency/briefs',
            builder: (context, state) => const AgencyBriefsScreen(),
          ),
          GoRoute(
            path: '/a/referrals',
            builder: (context, state) => DeferredLoader(
              loader: admin_referrals.loadLibrary,
              builder: () => admin_referrals.AdminReferralsScreen(),
            ),
          ),
          GoRoute(
            path: '/a/agency/briefs/:id',
            builder: (context, state) => AgencyBriefDetailScreen(
              briefId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/a/contracts/templates',
            builder: (context, state) => const ContractTemplatesScreen(),
          ),
          GoRoute(
            path: '/a/disputes',
            builder: (context, state) => DeferredLoader(
              loader: admin_dispute.loadLibrary,
              builder: () => admin_dispute.AdminDisputeResolutionPanel(),
            ),
          ),
          GoRoute(
            path: '/a/collaborations/:id/review',
            builder: (context, state) => ContentReviewScreen(
              collaborationId: state.pathParameters['id']!,
              portalHome: '/a/agency/briefs',
            ),
          ),
          GoRoute(
            path: '/a/agency/kanban',
            builder: (context, state) => DeferredLoader(
              loader: agency_kanban.loadLibrary,
              builder: () => agency_kanban.AgencyKanbanScreen(),
            ),
          ),
          GoRoute(
            path: '/a/chat',
            builder: (context, state) => const ChatThreadScreen(),
          ),
          GoRoute(
            path: '/a/settings/notifications',
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
          GoRoute(
            path: '/a/settings/sessions',
            builder: (context, state) => const SessionsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
