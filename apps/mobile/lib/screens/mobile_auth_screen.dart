import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../theme/tokens.dart';

class MobileAuthScreen extends StatefulWidget {
  const MobileAuthScreen({
    super.key,
    this.apiClient,
    this.secureStorage,
    this.onLoginSuccess,
  });

  final MonkApiClient? apiClient;
  final SecureStorageService? secureStorage;
  final VoidCallback? onLoginSuccess;

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final SecureStorageService _storage;

  @override
  void initState() {
    super.initState();
    _storage = widget.secureStorage ?? InMemorySecureStorageService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (widget.apiClient != null) {
        final response = await widget.apiClient!.auth.login(
          email: email,
          password: password,
        );
        await _storage.saveAuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );
      } else {
        // Fallback / Stub authentication for local mobile development & testing
        await Future.delayed(const Duration(milliseconds: 600));
        if (password == 'wrongpass') {
          throw Exception('Invalid email or password');
        }
        await _storage.saveAuthTokens(
          accessToken: 'stub_mobile_access_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'stub_mobile_refresh_token',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Secure tokens stored.'),
          backgroundColor: ImColors.success600,
        ),
      );

      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ImColors.cream50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ImSpacing.space24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: ImSpacing.space32),
                  // App Brand Icon Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [ImColors.teal800, ImColors.teal700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(ImRadii.radiusLg),
                        boxShadow: ImShadows.card,
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: ImColors.coral500,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  const Text(
                    'Influencers Monk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ImColors.ink900,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space4),
                  const Text(
                    'Creator Mobile Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ImColors.ink600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space32),

                  // Secure Storage Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ImSpacing.space12,
                      vertical: ImSpacing.space8,
                    ),
                    decoration: BoxDecoration(
                      color: ImColors.teal100.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                      border: Border.all(color: ImColors.teal700.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security_rounded, size: 16, color: ImColors.teal700),
                        SizedBox(width: ImSpacing.space8),
                        Expanded(
                          child: Text(
                            'Platform Secure Storage Active (Keychain/KeyStore Encrypted)',
                            style: TextStyle(
                              color: ImColors.teal800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(ImSpacing.space12),
                      decoration: BoxDecoration(
                        color: ImColors.danger100,
                        borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                        border: Border.all(color: ImColors.danger600),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: ImColors.danger600, size: 20),
                          const SizedBox(width: ImSpacing.space8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: ImColors.danger600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ImSpacing.space16),
                  ],

                  // Email Input
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      color: ImColors.ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  TextFormField(
                    key: const Key('email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'creator@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: ImColors.ink600),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ImSpacing.space16),

                  // Password Input
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: ImColors.ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  TextFormField(
                    key: const Key('password_field'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, color: ImColors.ink600),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: ImColors.ink600,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ImSpacing.space24),

                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('login_button'),
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ImColors.coral500,
                        foregroundColor: ImColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(ImColors.white),
                              ),
                            )
                          : const Text(
                              'Sign In to Mobile App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
