import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.token});

  final String? token;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final TextEditingController _token;

  @override
  void initState() {
    super.initState();
    _token = TextEditingController(text: widget.token ?? '');
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(AuthVerifyEmailRequested(widget.token!));
      });
    }
  }

  @override
  void dispose() {
    _token.dispose();
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
                if (state.status == AuthStatus.message &&
                    state.infoMessage != null) {
                  ImToast.show(
                    context,
                    message: state.infoMessage!,
                    tone: ImToastTone.success,
                  );
                  context.go('/login');
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
                        'Verify email',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Paste the verification token from your email.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImTextField(
                        label: 'Verification token',
                        controller: _token,
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImButton(
                        label: 'Verify email',
                        loading: loading,
                        onPressed: loading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      AuthVerifyEmailRequested(
                                        _token.text.trim(),
                                      ),
                                    );
                              },
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Back to sign in'),
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
