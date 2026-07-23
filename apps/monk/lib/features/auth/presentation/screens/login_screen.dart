import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_presenter.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      const Center(
                        child: MonkLogo(
                          height: 56,
                          heroTag: 'monk-brand-logo',
                        ),
                      ),
                      const SizedBox(height: ImSpacing.space16),


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
