import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/manager_repository.dart';
import '../cubit/manager_invite_cubit.dart';

class ManagerInviteAcceptScreen extends StatelessWidget {
  const ManagerInviteAcceptScreen({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ManagerInviteCubit(getIt<ManagerRepository>());
        if (token != null && token!.isNotEmpty) {
          cubit.accept(token!);
        }
        return cubit;
      },
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(ImSpacing.space24),
              child: BlocConsumer<ManagerInviteCubit, ManagerInviteState>(
                listener: (context, state) {
                  if (state.failure != null) {
                    ErrorPresenter.show(context, state.failure!);
                  }
                  if (state.success) {
                    ImToast.show(
                      context,
                      message: 'Manager invite accepted',
                      tone: ImToastTone.success,
                    );
                    context.go('/c/roster');
                  }
                },
                builder: (context, state) {
                  if (token == null || token!.isEmpty) {
                    return ImEmptyState(
                      message: 'Missing invite token.',
                      actionLabel: 'Home',
                      onAction: () => context.go('/'),
                    );
                  }
                  if (state.loading) {
                    return const CircularProgressIndicator();
                  }
                  return ImCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Accept manager invite',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        ImButton(
                          label: 'Accept invite',
                          onPressed: () => context
                              .read<ManagerInviteCubit>()
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
