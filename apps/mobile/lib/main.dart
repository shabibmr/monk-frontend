import 'package:flutter/material.dart';
import 'screens/mobile_auth_screen.dart';
import 'screens/mobile_campaign_inbox_screen.dart';
import 'screens/mobile_earnings_screen.dart';
import 'services/secure_storage_service.dart';
import 'theme/mobile_theme.dart';
import 'theme/tokens.dart';

export 'services/secure_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonkMobileApp());
}

class MonkMobileApp extends StatefulWidget {
  const MonkMobileApp({
    super.key,
    this.secureStorage,
  });

  final SecureStorageService? secureStorage;

  @override
  State<MonkMobileApp> createState() => _MonkMobileAppState();
}

class _MonkMobileAppState extends State<MonkMobileApp> {
  late final SecureStorageService _storage;
  bool _isAuthenticated = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _storage = widget.secureStorage ?? InMemorySecureStorageService();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  Future<void> handleLogout() async {
    await _storage.clearTokens();
    setState(() {
      _isAuthenticated = false;
      _selectedTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monk Mobile',
      debugShowCheckedModeBanner: false,
      theme: MobileTheme.lightTheme,
      home: !_isAuthenticated
          ? MobileAuthScreen(
              secureStorage: _storage,
              onLoginSuccess: _onLoginSuccess,
            )
          : Scaffold(
              body: IndexedStack(
                index: _selectedTab,
                children: [
                  MobileCampaignInboxScreen(
                    onNavigateToEarnings: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                  ),
                  MobileEarningsScreen(
                    onBackToInbox: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedTab,
                selectedItemColor: ImColors.teal700,
                unselectedItemColor: ImColors.ink600,
                onTap: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inbox_outlined),
                    activeIcon: Icon(Icons.inbox),
                    label: 'Inbox',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet),
                    label: 'Earnings',
                  ),
                ],
              ),
            ),
    );
  }
}
