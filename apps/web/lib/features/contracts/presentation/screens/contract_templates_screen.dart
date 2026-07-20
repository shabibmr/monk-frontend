import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/contract_repository.dart';
import '../bloc/contracts_v2_bloc.dart';

class ContractTemplatesScreen extends StatelessWidget {
  const ContractTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractsV2Bloc(getIt<ContractRepository>())
        ..add(const LoadContractTemplatesRequested()),
      child: const _ContractTemplatesView(),
    );
  }
}

class _ContractTemplatesView extends StatefulWidget {
  const _ContractTemplatesView();

  @override
  State<_ContractTemplatesView> createState() => _ContractTemplatesViewState();
}

class _ContractTemplatesViewState extends State<_ContractTemplatesView> {
  final _keyController = TextEditingController();
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();
  final _paramController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _nameController.dispose();
    _bodyController.dispose();
    _paramController.dispose();
    super.dispose();
  }

  void _showCreateDialog(BuildContext context) {
    _keyController.clear();
    _nameController.clear();
    _bodyController.clear();
    _paramController.clear();

    final bloc = context.read<ContractsV2Bloc>();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('New Contract Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImTextField(
                  label: 'Template Key (e.g. barter_standard)',
                  controller: _keyController,
                ),
                const SizedBox(height: ImSpacing.space12),
                ImTextField(
                  label: 'Template Name',
                  controller: _nameController,
                ),
                const SizedBox(height: ImSpacing.space12),
                ImTextField(
                  label: 'Template Body (Markdown / Text)',
                  controller: _bodyController,
                  maxLines: 5,
                ),
                const SizedBox(height: ImSpacing.space12),
                ImTextField(
                  label: 'Parameters (comma-separated)',
                  controller: _paramController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ImButton(
              label: 'Create Template',
              onPressed: () {
                final key = _keyController.text.trim();
                final name = _nameController.text.trim();
                final body = _bodyController.text.trim();
                final params = _paramController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                if (key.isNotEmpty && name.isNotEmpty && body.isNotEmpty) {
                  bloc.add(CreateContractTemplateSubmitted(
                    key: key,
                    name: name,
                    body: body,
                    parameters: params,
                  ));
                  Navigator.of(dialogCtx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Templates CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Template',
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ContractsV2Bloc, ContractsV2State>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(context, message: state.infoMessage!);
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.templates.isEmpty) {
            return ImEmptyState(
              message: 'No Contract Templates. Create a new template for contract generation.',
              actionLabel: 'Create Template',
              onAction: () => _showCreateDialog(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.templates.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, index) {
              final template = state.templates[index];
              return ImCard(
                child: Padding(
                  padding: const EdgeInsets.all(ImSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Key: ${template.key} · v${template.version}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: ImColors.ink600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              context.read<ContractsV2Bloc>().add(
                                    DeleteContractTemplateSubmitted(
                                        template.id),
                                  );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        template.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (template.parameters.isNotEmpty) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Wrap(
                          spacing: ImSpacing.space8,
                          children: template.parameters
                              .map(
                                (p) => Chip(
                                  label: Text('{$p}'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
