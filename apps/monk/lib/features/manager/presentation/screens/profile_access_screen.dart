import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/manager_repository.dart';
import '../cubit/access_cubit.dart';

const _managerScopes = [
  'edit_profile',
  'set_pricing',
  'apply',
  'negotiate',
  'submit_content',
  'view_earnings',
];

class ProfileAccessScreen extends StatefulWidget {
  const ProfileAccessScreen({super.key});

  @override
  State<ProfileAccessScreen> createState() => _ProfileAccessScreenState();
}

class _ProfileAccessScreenState extends State<ProfileAccessScreen> {
  String? _profileId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final session = context.read<SessionCubit>().state;
      if (session.activeProfileId != null) {
        setState(() {
          _profileId = session.activeProfileId;
          _loading = false;
        });
        return;
      }
      // Owner path: own influencer profile
      final onboarding =
          await getIt<InfluencerRepository>().loadOnboarding();
      setState(() {
        _profileId = onboarding.profileId;
        _loading = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profileId == null) {
      return const Scaffold(
        body: ImEmptyState(
          message: 'No profile available for access management.',
        ),
      );
    }
    return BlocProvider(
      create: (_) =>
          AccessCubit(getIt<ManagerRepository>(), _profileId!)..load(),
      child: const _AccessView(),
    );
  }
}

class _AccessView extends StatefulWidget {
  const _AccessView();

  @override
  State<_AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends State<_AccessView> {
  final _email = TextEditingController();
  final _perms = <String>{'view_earnings', 'edit_profile'};

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared access')),
      body: BlocConsumer<AccessCubit, AccessState>(
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
          return Padding(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Invite manager',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      ImTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      Wrap(
                        spacing: 8,
                        children: _managerScopes
                            .map(
                              (s) => FilterChip(
                                label: Text(s.replaceAll('_', ' ')),
                                selected: _perms.contains(s),
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _perms.add(s);
                                    } else {
                                      _perms.remove(s);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImButton(
                        label: 'Send invite',
                        loading: state.loading,
                        onPressed: state.loading ||
                                _email.text.trim().isEmpty ||
                                _perms.isEmpty
                            ? null
                            : () => context.read<AccessCubit>().invite(
                                  email: _email.text.trim(),
                                  permissions: _perms.toList(),
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
                Text('Access list',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: ImSpacing.space12),
                Expanded(
                  child: state.loading && state.rows.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.rows.isEmpty
                          ? const ImEmptyState(
                              message: 'No managers yet — invite one above.',
                            )
                          : ListView.separated(
                              itemCount: state.rows.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: ImSpacing.space12),
                              itemBuilder: (context, i) {
                                final r = state.rows[i];
                                return ImCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.accessRole,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              'User ${r.userId ?? "pending"} · ${r.inviteStatus}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                              r.permissions.join(', '),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: ImColors.ink600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (r.isManager)
                                        ImButton(
                                          label: 'Revoke',
                                          variant: ImButtonVariant.destructive,
                                          onPressed: () => context
                                              .read<AccessCubit>()
                                              .revoke(r.id),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
