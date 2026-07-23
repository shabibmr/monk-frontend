import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../cubit/team_cubit.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  String? _brandId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveBrand();
  }

  Future<void> _resolveBrand() async {
    try {
      final sessionBrand = context.read<SessionCubit>().state.activeBrandId;
      if (sessionBrand != null) {
        setState(() {
          _brandId = sessionBrand;
          _resolving = false;
        });
        return;
      }
      final brands = await getIt<BrandRepository>().listMine();
      if (brands.isNotEmpty) {
        context.read<SessionCubit>().setActiveBrand(brands.first.id);
        setState(() {
          _brandId = brands.first.id;
          _resolving = false;
        });
      } else {
        setState(() => _resolving = false);
      }
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_brandId == null) {
      return const Scaffold(
        body: ImEmptyState(message: 'Create a brand before managing team.'),
      );
    }
    return BlocProvider(
      create: (_) => TeamCubit(getIt<BrandRepository>(), _brandId!)..load(),
      child: const _TeamView(),
    );
  }
}

class _TeamView extends StatefulWidget {
  const _TeamView();

  @override
  State<_TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<_TeamView> {
  final _email = TextEditingController();
  String _role = brandInviteRoles.first;
  final _perms = <String>{'read', 'write'};

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: BlocConsumer<TeamCubit, TeamState>(
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
                        'Invite member',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      ImTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _role,
                        items: brandInviteRoles
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.replaceAll('_', ' ')),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _role = v ?? _role),
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      Wrap(
                        spacing: 8,
                        children: brandPermissionOptions
                            .map(
                              (p) => FilterChip(
                                label: Text(p),
                                selected: _perms.contains(p),
                                onSelected: (sel) {
                                  setState(() {
                                    if (sel) {
                                      _perms.add(p);
                                    } else {
                                      _perms.remove(p);
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
                            : () => context.read<TeamCubit>().invite(
                                  email: _email.text.trim(),
                                  memberRole: _role,
                                  permissions: _perms.toList(),
                                ),
                      ),
                      if (state.devInviteToken != null) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'Dev token: ${state.devInviteToken}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: ImSpacing.space12),
                Expanded(
                  child: state.loading && state.members.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.members.isEmpty
                          ? const ImEmptyState(
                              message:
                                  'No team members yet — invite your first teammate.',
                            )
                          : ListView.separated(
                              itemCount: state.members.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: ImSpacing.space12),
                              itemBuilder: (context, i) {
                                final m = state.members[i];
                                return ImCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.email,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              '${m.memberRole.replaceAll('_', ' ')} · ${m.inviteStatus}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                              m.permissions.join(', '),
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
                                      if (!m.isOwner)
                                        ImButton(
                                          label: 'Revoke',
                                          variant: ImButtonVariant.destructive,
                                          onPressed: () => context
                                              .read<TeamCubit>()
                                              .revoke(m.id),
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
