import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/review_repository.dart';
import '../cubit/review_cubit.dart';

/// Mutual review after collaboration settled (`/b|c/collaborations/:id/review-rating`).
class LeaveReviewScreen extends StatelessWidget {
  const LeaveReviewScreen({
    super.key,
    required this.collaborationId,
    this.portalHome = '/b/applications',
  });

  final String collaborationId;
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewCubit(
        getIt<ReviewRepository>(),
        collaborationId,
      )..load(),
      child: _View(portalHome: portalHome),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.portalHome});
  final String portalHome;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _body = TextEditingController();

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.portalHome),
        ),
      ),
      body: BlocConsumer<ReviewCubit, ReviewState>(
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
          if (state.loading && state.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final cubit = context.read<ReviewCubit>();
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Text(
                'Rate this collaboration (1–5). Reviews may stay private until both sides submit or the window ends.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ImSpacing.space16),
              Semantics(
                label: 'Star rating ${state.selectedRating} of 5',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    final selected = star <= state.selectedRating;
                    return IconButton(
                      tooltip: '$star stars',
                      onPressed: () => cubit.setRating(star),
                      icon: Icon(
                        selected ? Icons.star : Icons.star_border,
                        color: selected
                            ? ImColors.warning600
                            : ImColors.ink300,
                        size: 36,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: ImSpacing.space12),
              TextField(
                controller: _body,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                ),
              ),
              const SizedBox(height: ImSpacing.space16),
              FilledButton(
                onPressed: state.canSubmit
                    ? () => cubit.submit(
                          body: _body.text.trim().isEmpty
                              ? null
                              : _body.text.trim(),
                        )
                    : null,
                child: Text(
                  state.submitting ? 'Submitting…' : 'Submit review',
                ),
              ),
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Reviews on this collaboration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space8),
              if (state.reviews.isEmpty)
                const Text('No reviews yet.')
              else
                ...state.reviews.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                    child: ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.reviewerSide}${r.visible ? '' : ' (hidden until reveal)'}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          if (r.visible && r.rating != null)
                            Text('★ ${r.rating}/5')
                          else
                            Text(
                              'Not yet visible',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (r.visible && r.body != null && r.body!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: ImSpacing.space4),
                              child: Text(r.body!),
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
