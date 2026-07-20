import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/notification_preferences.dart';
import '../bloc/notification_preferences_bloc.dart';
import '../bloc/notification_preferences_event.dart';
import '../bloc/notification_preferences_state.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<NotificationPreferencesBloc>()..add(const LoadNotificationPreferences()),
      child: const _NotificationPreferencesView(),
    );
  }
}

class _NotificationPreferencesView extends StatefulWidget {
  const _NotificationPreferencesView();

  @override
  State<_NotificationPreferencesView> createState() =>
      _NotificationPreferencesViewState();
}

class _NotificationPreferencesViewState
    extends State<_NotificationPreferencesView> {
  late NotificationPreferences _currentPrefs;
  final _phoneController = TextEditingController();
  final _quietStartController = TextEditingController();
  final _quietEndController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _quietStartController.dispose();
    _quietEndController.dispose();
    super.dispose();
  }

  void _initForm(NotificationPreferences prefs) {
    if (!_initialized) {
      _currentPrefs = prefs;
      _phoneController.text = prefs.smsPhoneNumber;
      _quietStartController.text = prefs.quietHoursStart;
      _quietEndController.text = prefs.quietHoursEnd;
      _initialized = true;
    }
  }

  void _save(BuildContext context) {
    final updated = _currentPrefs.copyWith(
      smsPhoneNumber: _phoneController.text.trim(),
      quietHoursStart: _quietStartController.text.trim(),
      quietHoursEnd: _quietEndController.text.trim(),
    );

    context
        .read<NotificationPreferencesBloc>()
        .add(SaveNotificationPreferences(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preference Center'),
      ),
      body: BlocConsumer<NotificationPreferencesBloc, NotificationPreferencesState>(
        listener: (context, state) {
          if (state.saveSuccessMessage != null) {
            ImToast.show(
              context,
              message: state.saveSuccessMessage!,
              tone: ImToastTone.success,
            );
          }
          if (state.errorMessage != null) {
            ImToast.show(
              context,
              message: state.errorMessage!,
              tone: ImToastTone.danger,
            );
          }
        },
        builder: (context, state) {
          if (state.phase == NotificationPreferencesPhase.loading &&
              state.preferences == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final prefs = state.preferences;
          if (prefs == null) {
            return const ImEmptyState(
              message: 'Unable to load preferences. Please try again later.',
            );
          }

          _initForm(prefs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push, SMS & Channel Preferences',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Control how and when Influencers Monk sends you campaign updates, real-time alerts, and financial notifications.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Section 1: FCM Web Push
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FCM Web Push Notifications',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Browser push notifications for instant alerts',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: _currentPrefs.fcmWebPushEnabled,
                                onChanged: (val) {
                                  setState(() {
                                    _currentPrefs =
                                        _currentPrefs.copyWith(fcmWebPushEnabled: val);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_currentPrefs.fcmWebPushEnabled) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const ImStatusChip(
                                  status: EntityStatus.verified,
                                  label: 'Browser Permission Granted',
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Web push token active.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 2: SMS Opt-in
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sms_outlined),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SMS Opt-in Notifications',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Receive urgent campaign milestone alerts via SMS',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: _currentPrefs.smsOptIn,
                                onChanged: (val) {
                                  setState(() {
                                    _currentPrefs = _currentPrefs.copyWith(smsOptIn: val);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_currentPrefs.smsOptIn) ...[
                            const SizedBox(height: 16),
                            ImTextField(
                              label: 'Mobile Phone Number for SMS',
                              hint: '+1 (555) 000-0000',
                              controller: _phoneController,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 3: Topic Preferences
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Topics',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            title: const Text('Campaign Updates & Submissions'),
                            subtitle: const Text('Notify when content is reviewed or status changes'),
                            value: _currentPrefs.campaignUpdates,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _currentPrefs =
                                      _currentPrefs.copyWith(campaignUpdates: val);
                                });
                              }
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Payment & Escrow Release Alerts'),
                            subtitle: const Text('Notify on milestone funding, payouts, and invoices'),
                            value: _currentPrefs.paymentAlerts,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _currentPrefs =
                                      _currentPrefs.copyWith(paymentAlerts: val);
                                });
                              }
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Real-Time Chat Messages'),
                            subtitle: const Text('Notify on incoming messages from brands/creators'),
                            value: _currentPrefs.chatMessagesAlert,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _currentPrefs =
                                      _currentPrefs.copyWith(chatMessagesAlert: val);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 4: Quiet Hours
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bedtime_outlined),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Quiet Hours',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Pause push & SMS notifications during set hours',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: _currentPrefs.quietHoursEnabled,
                                onChanged: (val) {
                                  setState(() {
                                    _currentPrefs =
                                        _currentPrefs.copyWith(quietHoursEnabled: val);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_currentPrefs.quietHoursEnabled) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ImTextField(
                                    label: 'Start Time',
                                    hint: '22:00',
                                    controller: _quietStartController,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ImTextField(
                                    label: 'End Time',
                                    hint: '08:00',
                                    controller: _quietEndController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ImButton(
                          label: 'Save Preferences',
                          onPressed: state.isSaving ? null : () => _save(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
