import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../cubit/shortlist_cubit.dart';

class ShortlistsScreen extends StatefulWidget {
  const ShortlistsScreen({super.key});

  @override
  State<ShortlistsScreen> createState() => _ShortlistsScreenState();
}

class _ShortlistsScreenState extends State<ShortlistsScreen> {
  String? _brandId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      var id = context.read<SessionCubit>().state.activeBrandId;
      if (id == null) {
        final brands = await getIt<BrandRepository>().listMine();
        if (brands.isNotEmpty) {
          id = brands.first.id;
          context.read<SessionCubit>().setActiveBrand(id);
        }
      }
      setState(() {
        _brandId = id;
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
    if (_brandId == null) {
      return const Scaffold(
        body: ImEmptyState(
          message: 'Create a brand before managing shortlists.',
        ),
      );
    }
    return BlocProvider(
      create: (_) =>
          ShortlistCubit(getIt<DiscoveryRepository>(), _brandId!)..load(),
      child: const _ShortlistsView(),
    );
  }
}

class _ShortlistsView extends StatefulWidget {
  const _ShortlistsView();

  @override
  State<_ShortlistsView> createState() => _ShortlistsViewState();
}

class _ShortlistsViewState extends State<_ShortlistsView> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shortlists')),
      body: BlocConsumer<ShortlistCubit, ShortlistState>(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: ImTextField(
                          label: 'New shortlist name',
                          controller: _name,
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space12),
                      ImButton(
                        label: 'Create',
                        loading: state.loading,
                        onPressed: state.loading || _name.text.trim().isEmpty
                            ? null
                            : () {
                                context
                                    .read<ShortlistCubit>()
                                    .create(_name.text.trim());
                                _name.clear();
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),
                if (state.lists.isEmpty)
                  const Expanded(
                    child: ImEmptyState(
                      message: 'No shortlists yet — create one to save creators.',
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.lists.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: ImSpacing.space8),
                      itemBuilder: (context, i) {
                        final s = state.lists[i];
                        final selected = s.id == state.selectedId;
                        return ChoiceChip(
                          label: Text(s.name),
                          selected: selected,
                          onSelected: (_) =>
                              context.read<ShortlistCubit>().select(s.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  Expanded(
                    child: state.loading && state.items.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : state.items.isEmpty
                            ? const ImEmptyState(
                                message:
                                    'This shortlist is empty — add creators from Discover.',
                              )
                            : ListView.separated(
                                itemCount: state.items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: ImSpacing.space12),
                                itemBuilder: (context, i) {
                                  final item = state.items[i];
                                  return ImCard(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.displayName ??
                                                item.influencerProfileId,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        ImButton(
                                          label: 'Remove',
                                          variant:
                                              ImButtonVariant.destructive,
                                          onPressed: () => context
                                              .read<ShortlistCubit>()
                                              .removeItem(item.id),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
