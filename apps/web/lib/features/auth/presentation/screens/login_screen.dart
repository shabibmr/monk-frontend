import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/mock/mock_ids.dart';
import '../../../../core/network/api_client_factory.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _selectedDemoEmail;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _buildMockSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: ImSpacing.space16),
      padding: const EdgeInsets.all(ImSpacing.space12),
      decoration: BoxDecoration(
        color: ImColors.coral100.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(ImRadii.radiusSm),
        border: Border.all(color: ImColors.coral500.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.science_outlined, size: 16, color: ImColors.coral600),
              SizedBox(width: ImSpacing.space4),
              Text(
                'Mock Mode Demo Selector',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: ImColors.coral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space8),
          DropdownButtonFormField<String>(
            initialValue: _selectedDemoEmail,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Demo User',
              isDense: true,
            ),
            hint: const Text('Choose persona to auto-fill credentials'),
            items: const [
              DropdownMenuItem(
                value: MockIds.emailCreator1,
                child: Text('Creator (Arjun)'),
              ),
              DropdownMenuItem(
                value: MockIds.emailBrand1,
                child: Text('Brand User (Priya)'),
              ),
              DropdownMenuItem(
                value: MockIds.emailManager1,
                child: Text('Manager (Meera)'),
              ),
              DropdownMenuItem(
                value: MockIds.emailAdmin,
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: MockIds.emailAgency1,
                child: Text('Agency (Alex)'),
              ),
              DropdownMenuItem(
                value: MockIds.emailBrandFresh,
                child: Text('Fresh Brand (Onboarding)'),
              ),
              DropdownMenuItem(
                value: MockIds.emailCreatorFresh,
                child: Text('Fresh Creator (Onboarding)'),
              ),
            ],
            onChanged: (email) {
              if (email != null) {
                setState(() {
                  _selectedDemoEmail = email;
                  _email.text = email;
                  _password.text = MockIds.demoPassword;
                });
              }
            },
          ),
          const SizedBox(height: ImSpacing.space8),
          const Text(
            'Sign in with a short name — creator, brand, manager, admin, '
            'agency, newbrand, newcreator. Password for every persona: '
            '${MockIds.demoPassword}',
            style: TextStyle(fontSize: 11, color: ImColors.ink600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useMocks = getIt<AppConfig>().useMocks;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.status == AuthStatus.failure &&
                    state.failure != null) {
                  ErrorPresenter.show(context, state.failure!);
                }
                if (state.status == AuthStatus.authenticated) {
                  final session = context.read<SessionCubit>();
                  final home = session.state.needsInfluencerOnboarding
                      ? '/c/onboarding'
                      : session.state.needsBrandOnboarding
                          ? '/b/onboarding'
                          : (session.roleHomePath() ?? '/');
                  context.go(home);
                }
              },
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;
                return ImCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Welcome back to Influencers Monk.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      if (useMocks) _buildMockSelector(),
                      ImTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'Password',
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/password/forgot'),
                          child: const Text('Forgot password'),
                        ),
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImButton(
                        label: 'Sign in',
                        loading: loading,
                        onPressed: loading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                      ),
                                    );
                              },
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Create an account'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
