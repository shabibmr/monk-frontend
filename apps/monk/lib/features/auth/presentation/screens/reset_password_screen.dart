import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.token});

  final String? token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _token;
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _token = TextEditingController(text: widget.token ?? '');
  }

  @override
  void dispose() {
    _token.dispose();
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
                        'Reset password',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImTextField(
                        label: 'Reset token',
                        controller: _token,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'New password',
                        controller: _password,
                        obscureText: true,
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImButton(
                        label: 'Update password',
                        loading: loading,
                        onPressed: loading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      AuthResetPasswordRequested(
                                        token: _token.text.trim(),
                                        password: _password.text,
                                      ),
                                    );
                              },
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
