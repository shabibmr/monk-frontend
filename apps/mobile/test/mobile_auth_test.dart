import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_mobile/main.dart';
import 'package:monk_mobile/screens/mobile_auth_screen.dart';
import 'package:monk_mobile/screens/mobile_campaign_inbox_screen.dart';
import 'package:monk_mobile/screens/mobile_earnings_screen.dart';

void main() {
  group('SecureStorageService Unit Tests', () {
    late SecureStorageService storage;

    setUp(() {
      storage = InMemorySecureStorageService();
    });

    test('saves and retrieves access and refresh tokens correctly', () async {
      await storage.saveAuthTokens(
        accessToken: 'test_access_token_123',
        refreshToken: 'test_refresh_token_456',
      );

      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();

      expect(accessToken, equals('test_access_token_123'));
      expect(refreshToken, equals('test_refresh_token_456'));
    });

    test('deletes tokens and clears storage', () async {
      await storage.saveAuthTokens(
        accessToken: 'access_to_delete',
        refreshToken: 'refresh_to_delete',
      );

      await storage.clearTokens();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('containsKey correctly verifies key presence', () async {
      await storage.write(key: 'custom_key', value: 'custom_value');
      expect(await storage.containsKey(key: 'custom_key'), isTrue);
      expect(await storage.containsKey(key: 'non_existent'), isFalse);
    });
  });

  group('MobileAuthScreen Widget Tests', () {
    late SecureStorageService storage;

    setUp(() {
      storage = InMemorySecureStorageService();
    });

    testWidgets('renders all expected auth form fields and security badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileAuthScreen(secureStorage: storage),
        ),
      );

      expect(find.text('Influencers Monk'), findsOneWidget);
      expect(find.text('Creator Mobile Portal'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(
        find.textContaining('Platform Secure Storage Active'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileAuthScreen(secureStorage: storage),
        ),
      );

      final loginBtn = find.byKey(const Key('login_button'));
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('successful login stores tokens and triggers onLoginSuccess', (tester) async {
      bool loginSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MobileAuthScreen(
            secureStorage: storage,
            onLoginSuccess: () {
              loginSuccessCalled = true;
            },
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'creator@monk.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'validpassword');

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // Start async login
      await tester.pump(const Duration(milliseconds: 700)); // Complete timer delay
      await tester.pumpAndSettle();

      expect(loginSuccessCalled, isTrue);
      final storedAccessToken = await storage.getAccessToken();
      expect(storedAccessToken, isNotNull);
      expect(storedAccessToken, contains('stub_mobile_access_token'));
    });

    testWidgets('failed login displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MobileAuthScreen(secureStorage: storage),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'creator@monk.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpass');

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });
  });

  group('Mobile Spine Screens Integration Tests', () {
    testWidgets('MobileCampaignInboxScreen renders campaign cards and stats', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileCampaignInboxScreen(),
        ),
      );

      expect(find.text('Campaign Inbox'), findsOneWidget);
      expect(find.text('Active Briefs'), findsOneWidget);
      expect(find.text('Aura Skincare'), findsOneWidget);
      expect(find.text('Summer Glow Reels Campaign'), findsOneWidget);
      expect(find.text('Pulse Fitness'), findsOneWidget);
    });

    testWidgets('MobileEarningsScreen renders total balance and payout button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileEarningsScreen(),
        ),
      );

      expect(find.text('Earnings & Payouts'), findsOneWidget);
      expect(find.text('Total Available Balance'), findsOneWidget);
      expect(find.text('\$5,100.00'), findsOneWidget);
      expect(find.byKey(const Key('request_payout_btn')), findsOneWidget);
    });

    testWidgets('MonkMobileApp navigates from Auth to Spine Shell after login', (tester) async {
      final storage = InMemorySecureStorageService();
      await tester.pumpWidget(
        MonkMobileApp(secureStorage: storage),
      );

      // Verify on Auth Screen initially
      expect(find.byType(MobileAuthScreen), findsOneWidget);

      // Perform login
      await tester.enterText(find.byKey(const Key('email_field')), 'creator@monk.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'secret123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify transitioned to Campaign Inbox Spine Screen
      expect(find.byType(MobileCampaignInboxScreen), findsOneWidget);
      expect(find.text('Campaign Inbox'), findsOneWidget);

      // Tap Earnings tab in BottomNavigationBar
      await tester.tap(find.text('Earnings'));
      await tester.pumpAndSettle();

      // Verify transitioned to Earnings Screen
      expect(find.byType(MobileEarningsScreen), findsOneWidget);
    });
  });
}
