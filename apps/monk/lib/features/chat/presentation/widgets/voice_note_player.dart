import 'package:flutter/material.dart';

class VoiceNotePlayerStub extends StatelessWidget {
  const VoiceNotePlayerStub({
    super.key,
    required this.messageId,
    required this.durationSeconds,
    required this.isPlaying,
    required this.onTogglePlay,
  });

  final String messageId;
  final int durationSeconds;
  final bool isPlaying;
  final VoidCallback onTogglePlay;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            onPressed: onTogglePlay,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(16, (i) {
                  final height = (i % 3 == 0 ? 16.0 : (i % 2 == 0 ? 22.0 : 10.0));
                  final isActive = isPlaying && (i < 8);
                  return Container(
                    width: 3,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                isPlaying ? '0:15 / ${_formatDuration(durationSeconds)}' : _formatDuration(durationSeconds),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
