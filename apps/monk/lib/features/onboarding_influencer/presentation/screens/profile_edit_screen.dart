import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/influencer_repository.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = false;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final status = await getIt<InfluencerRepository>().loadOnboarding();
      _profileId = status.profileId;
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(ImSpacing.space24),
              child: ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ImTextField(label: 'Display name', controller: _name),
                    const SizedBox(height: ImSpacing.space16),
                    ImTextField(
                      label: 'Biography',
                      controller: _bio,
                      maxLines: 4,
                    ),
                    const SizedBox(height: ImSpacing.space24),
                    ImButton(
                      label: 'Save profile',
                      onPressed: _profileId == null
                          ? null
                          : () async {
                              try {
                                await getIt<InfluencerRepository>()
                                    .updateProfileBasics(
                                  profileId: _profileId!,
                                  displayName: _name.text.trim(),
                                  biography: _bio.text.trim(),
                                );
                                if (context.mounted) {
                                  ImToast.show(
                                    context,
                                    message: 'Profile updated',
                                    tone: ImToastTone.success,
                                  );
                                }
                              } on Failure catch (f) {
                                if (context.mounted) {
                                  ErrorPresenter.show(context, f);
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
