import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  String _role = UserRole.influencer.apiValue;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.status == AuthStatus.failure &&
                    state.failure != null) {
                  ErrorPresenter.show(context, state.failure!);
                }
                if (state.status == AuthStatus.message &&
                    state.infoMessage != null) {
                  ImToast.show(
                    context,
                    message: state.infoMessage!,
                    tone: ImToastTone.success,
                  );
                  context.go('/verify-email');
                }
              },
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;
                return ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create account',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      Text(
                        'Account type',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ImColors.ink900,
                            ),
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'influencer',
                            label: Text('Creator'),
                          ),
                          ButtonSegment(
                            value: 'brand_user',
                            label: Text('Brand'),
                          ),
                          ButtonSegment(
                            value: 'manager',
                            label: Text('Manager'),
                          ),
                        ],
                        selected: {_role},
                        onSelectionChanged: (s) =>
                            setState(() => _role = s.first),
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'Full name',
                        controller: _fullName,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'Password',
                        controller: _password,
                        obscureText: true,
                        helperText: 'At least 8 characters',
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        title: Text(
                          'I accept the terms and conditions',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImButton(
                        label: 'Create account',
                        loading: loading,
                        onPressed: loading || !_acceptTerms
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      AuthRegisterRequested(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                        role: _role,
                                        acceptTerms: _acceptTerms,
                                        fullName: _fullName.text.trim().isEmpty
                                            ? null
                                            : _fullName.text.trim(),
                                      ),
                                    );
                              },
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Already have an account? Sign in'),
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
