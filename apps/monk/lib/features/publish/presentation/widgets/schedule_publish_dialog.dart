import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/im_button.dart';
import '../../../../core/widgets/im_text_field.dart';
import '../../../../core/widgets/im_toast.dart';
import '../bloc/schedule_publish_bloc.dart';

class SchedulePublishDialog extends StatefulWidget {
  const SchedulePublishDialog({
    super.key,
    required this.deliverableId,
    required this.approvalStatus,
    this.initialPlatform = 'instagram',
  });

  final String deliverableId;
  final String approvalStatus;
  final String initialPlatform;

  static Future<void> show(
    BuildContext context, {
    required SchedulePublishBloc bloc,
    required String deliverableId,
    required String approvalStatus,
    String initialPlatform = 'instagram',
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SchedulePublishDialog(
          deliverableId: deliverableId,
          approvalStatus: approvalStatus,
          initialPlatform: initialPlatform,
        ),
      ),
    );
  }

  @override
  State<SchedulePublishDialog> createState() => _SchedulePublishDialogState();
}

class _SchedulePublishDialogState extends State<SchedulePublishDialog> {
  late String _platform;
  late DateTime _scheduledDate;
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 12, minute: 0);
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _platform = widget.initialPlatform;
    _scheduledDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _isApproved => widget.approvalStatus.toLowerCase() == 'approved';

  DateTime get _combinedDateTime => DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchedulePublishBloc, SchedulePublishState>(
      listener: (context, state) {
        if (state.failure != null) {
          ImToast.show(
            context,
            message: state.failure!.message,
            tone: ImToastTone.danger,
          );
        } else if (state.successMessage != null) {
          ImToast.show(
            context,
            message: state.successMessage!,
            tone: ImToastTone.success,
          );
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<SchedulePublishBloc, SchedulePublishState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Schedule Content Publication'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isApproved) ...[
                      Container(
                        padding: const EdgeInsets.all(ImSpacing.space12),
                        decoration: BoxDecoration(
                          color: ImColors.warning100,
                          borderRadius:
                              BorderRadius.circular(ImRadii.radiusMd),
                          border: Border.all(color: ImColors.warning600),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: ImColors.warning600),
                            SizedBox(width: ImSpacing.space8),
                            Expanded(
                              child: Text(
                                'Content must be approved before scheduling publish action.',
                                style: TextStyle(
                                  color: ImColors.ink900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ImSpacing.space16),
                    ],
                    const Text(
                      'Target Platform',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    DropdownButtonFormField<String>(
                      value: _platform,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ImSpacing.space12,
                          vertical: ImSpacing.space8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'instagram',
                          child: Text('Instagram'),
                        ),
                        DropdownMenuItem(
                          value: 'youtube',
                          child: Text('YouTube'),
                        ),
                        DropdownMenuItem(
                          value: 'tiktok',
                          child: Text('TikTok'),
                        ),
                      ],
                      onChanged: _isApproved
                          ? (val) {
                              if (val != null) {
                                setState(() => _platform = val);
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: ImSpacing.space16),
                    const Text(
                      'Publication Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              '${_scheduledDate.year}-${_scheduledDate.month.toString().padLeft(2, '0')}-${_scheduledDate.day.toString().padLeft(2, '0')}',
                            ),
                            onPressed: _isApproved
                                ? () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _scheduledDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 365)),
                                    );
                                    if (picked != null) {
                                      setState(() => _scheduledDate = picked);
                                    }
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: ImSpacing.space12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 16),
                            label: Text(_scheduledTime.format(context)),
                            onPressed: _isApproved
                                ? () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _scheduledTime,
                                    );
                                    if (picked != null) {
                                      setState(() => _scheduledTime = picked);
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space16),
                    ImTextField(
                      controller: _notesController,
                      label: 'Schedule Notes (Optional)',
                      placeholder: 'Add instructions or captions...',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ImButton(
                label: 'Cancel',
                variant: ImButtonVariant.tertiary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              ImButton(
                label: 'Schedule Publish',
                variant: ImButtonVariant.primary,
                loading: state.isSubmitting,
                onPressed: _isApproved
                    ? () {
                        context.read<SchedulePublishBloc>().add(
                              SubmitScheduleRequested(
                                deliverableId: widget.deliverableId,
                                scheduledAt: _combinedDateTime,
                                platform: _platform,
                                notes: _notesController.text.trim().isEmpty
                                    ? null
                                    : _notesController.text.trim(),
                              ),
                            );
                      }
                    : null, // Disabled when approvalStatus is not approved
              ),
            ],
          );
        },
      ),
    );
  }
}
