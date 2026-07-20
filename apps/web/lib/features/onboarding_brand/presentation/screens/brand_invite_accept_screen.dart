import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/brand_repository.dart';
import '../cubit/brand_invite_cubit.dart';

class BrandInviteAcceptScreen extends StatelessWidget {
  const BrandInviteAcceptScreen({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = BrandInviteCubit(getIt<BrandRepository>());
        final t = token;
        if (t != null && t.isNotEmpty) {
          cubit.accept(t);
        }
        return cubit;
      },
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(ImSpacing.space24),
              child: BlocConsumer<BrandInviteCubit, BrandInviteState>(
                listener: (context, state) {
                  if (state.failure != null) {
                    ErrorPresenter.show(context, state.failure!);
                  }
                  if (state.success) {
                    ImToast.show(
                      context,
                      message: 'Invite accepted — welcome to the brand team.',
                      tone: ImToastTone.success,
                    );
                    context.go('/b/dashboard');
                  }
                },
                builder: (context, state) {
                  if (token == null || token!.isEmpty) {
                    return ImEmptyState(
                      message: 'Missing invite token.',
                      actionLabel: 'Go home',
                      onAction: () => context.go('/'),
                    );
                  }
                  if (state.loading) {
                    return const CircularProgressIndicator();
                  }
                  if (state.failure != null) {
                    return ImEmptyState(
                      message: state.failure!.message,
                      actionLabel: 'Retry',
                      onAction: () =>
                          context.read<BrandInviteCubit>().accept(token!),
                    );
                  }
                  return ImCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Accepting brand invite…',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        ImButton(
                          label: 'Accept invite',
                          onPressed: () => context
                              .read<BrandInviteCubit>()
                              .accept(token!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
