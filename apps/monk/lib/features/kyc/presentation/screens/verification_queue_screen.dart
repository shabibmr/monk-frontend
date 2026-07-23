import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../bloc/verification_bloc.dart';

class VerificationQueueScreen extends StatelessWidget {
  const VerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationBloc(getIt<KycRepository>())
        ..add(const VerificationQueueLoaded()),
      child: const _QueueView(),
    );
  }
}

class _QueueView extends StatelessWidget {
  const _QueueView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification queue')),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(
              context,
              message: state.infoMessage!,
              tone: ImToastTone.success,
            );
          }
        },
        builder: (context, state) {
          if (state.phase == VerificationPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.kyc.isEmpty && state.influencers.isEmpty) {
            return const ImEmptyState(
              message: 'No pending verifications right now.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            children: [
              Text(
                'Pending KYC',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space12),
              if (state.kyc.isEmpty)
                Text(
                  'No pending KYC records',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                ...state.kyc.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(bottom: ImSpacing.space12),
                    child: ImCard(
                      onTap: () =>
                          context.go('/a/verification/${k.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  k.id,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Profile ${k.influencerProfileId ?? "—"}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          ImStatusChip(status: k.statusChip),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Pending influencer profiles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space12),
              ...state.influencers.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: ImSpacing.space12),
                  child: ImCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.displayName ?? i.id,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Country ${i.country ?? "—"} · ${i.verificationStatus ?? ""}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
