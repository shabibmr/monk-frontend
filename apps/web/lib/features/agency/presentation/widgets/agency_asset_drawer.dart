import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/agency_asset.dart';
import '../bloc/agency_console_bloc.dart';
import '../bloc/agency_console_event.dart';

class AgencyAssetDrawer extends StatefulWidget {
  const AgencyAssetDrawer({
    super.key,
    required this.cardId,
    required this.assets,
    required this.isLoading,
  });

  final String cardId;
  final List<AgencyAsset> assets;
  final bool isLoading;

  @override
  State<AgencyAssetDrawer> createState() => _AgencyAssetDrawerState();
}

class _AgencyAssetDrawerState extends State<AgencyAssetDrawer> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  String _fileType = 'video/mp4';
  bool _showUploadForm = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitAttachment() {
    if (_titleController.text.trim().isEmpty || _urlController.text.trim().isEmpty) {
      ImToast.show(
        context,
        message: 'Please enter asset title and file URL',
        tone: ImToastTone.warning,
      );
      return;
    }

    context.read<AgencyConsoleBloc>().add(
          AttachAssetEvent(
            cardId: widget.cardId,
            title: _titleController.text.trim(),
            fileUrl: _urlController.text.trim(),
            fileType: _fileType,
          ),
        );

    _titleController.clear();
    _urlController.clear();
    setState(() {
      _showUploadForm = false;
    });
    ImToast.show(
      context,
      message: 'Asset uploaded successfully',
      tone: ImToastTone.success,
    );
  }

  void _updateStatus(AgencyAsset asset, String newStatus) {
    context.read<AgencyConsoleBloc>().add(
          UpdateAssetStatusEvent(
            assetId: asset.id,
            status: newStatus,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          ),
        );
    _notesController.clear();
    ImToast.show(
      context,
      message: 'Asset marked as $newStatus',
      tone: ImToastTone.info,
    );
  }

  EntityStatus _parseStatus(String status) {
    if (status == 'approved') return EntityStatus.approved;
    if (status == 'rejected') return EntityStatus.rejected;
    return EntityStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asset Attachments & Approvals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<AgencyConsoleBloc>().add(const CloseAssetDrawerEvent());
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Card ID: ${widget.cardId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attached Assets (${widget.assets.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              ImButton(
                label: _showUploadForm ? 'Cancel' : 'Upload Asset',
                icon: Icon(_showUploadForm ? Icons.close : Icons.upload_file),
                variant: ImButtonVariant.secondary,
                onPressed: () {
                  setState(() {
                    _showUploadForm = !_showUploadForm;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showUploadForm) ...[
            ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attach New Asset',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ImTextField(
                    label: 'Asset Title',
                    hint: 'e.g. Reel Draft v2.mp4',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 8),
                  ImTextField(
                    label: 'File URL',
                    hint: 'https://...',
                    controller: _urlController,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _fileType,
                    decoration: const InputDecoration(
                      labelText: 'File Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'video/mp4', child: Text('Video (MP4)')),
                      DropdownMenuItem(value: 'image/png', child: Text('Image (PNG)')),
                      DropdownMenuItem(value: 'application/pdf', child: Text('Document (PDF)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _fileType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  ImButton(
                    label: 'Submit Asset',
                    icon: const Icon(Icons.check),
                    loading: widget.isLoading,
                    onPressed: _submitAttachment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : widget.assets.isEmpty
                    ? const ImEmptyState(
                        message: 'No deliverable assets attached yet for review.',
                      )
                    : ListView.separated(
                        itemCount: widget.assets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final asset = widget.assets[index];
                          return _buildAssetItem(asset);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(AgencyAsset asset) {
    return ImCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  asset.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ImStatusChip(
                status: _parseStatus(asset.status),
                label: asset.status.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Uploaded by ${asset.uploadedBy} • ${asset.uploadedAt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (asset.notes != null) ...[
            const SizedBox(height: 6),
            Text(
              'Notes: ${asset.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ImButton(
                  label: 'Approve',
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => _updateStatus(asset, 'approved'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ImButton(
                  label: 'Reject',
                  icon: const Icon(Icons.cancel_outlined),
                  variant: ImButtonVariant.destructive,
                  onPressed: () => _updateStatus(asset, 'rejected'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
