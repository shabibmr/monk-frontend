import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/chat_thread.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/voice_note_player.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatState state) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final threadId = state.selectedThreadId;
    if (threadId == null) return;

    context.read<ChatBloc>().add(
          SendTextMessageEvent(threadId: threadId, text: text),
        );
    _textController.clear();
  }

  void _sendVoiceNoteStub(ChatState state) {
    final threadId = state.selectedThreadId;
    if (threadId == null) return;

    context.read<ChatBloc>().add(
          SendVoiceNoteMessageEvent(
            threadId: threadId,
            mediaUrl: 'https://cdn.monk.com/audio/voice_note_stub.mp3',
            durationSeconds: 24,
          ),
        );
    ImToast.show(
      context,
      message: 'Voice note recorded & sent!',
      tone: ImToastTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(const LoadChatThreads()),
      child: Scaffold(
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ImToast.show(
                context,
                message: state.errorMessage!,
                tone: ImToastTone.danger,
              );
            }
          },
          builder: (context, state) {
            if (state.phase == ChatPhase.loading && state.threads.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              children: [
                // Thread list column
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline),
                            const SizedBox(width: 8),
                            Text(
                              'Chat Threads',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: state.threads.isEmpty
                            ? const ImEmptyState(
                                message: 'No active campaign threads yet.',
                              )
                            : ListView.separated(
                                itemCount: state.threads.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final thread = state.threads[index];
                                  final isSelected = thread.id == state.selectedThreadId;
                                  return ListTile(
                                    selected: isSelected,
                                    title: Text(
                                      thread.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${thread.participantName} • ${thread.lastMessageText}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: thread.unreadCount > 0
                                        ? ImStatusChip(
                                            status: EntityStatus.inProgress,
                                            label: '${thread.unreadCount}',
                                          )
                                        : Text(
                                            thread.lastMessageTime,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                    onTap: () {
                                      context.read<ChatBloc>().add(SelectThreadEvent(thread.id));
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // Chat detail column
                Expanded(
                  child: state.selectedThread == null
                      ? const ImEmptyState(
                          message: 'Select a conversation from the sidebar to view messages.',
                        )
                      : Column(
                          children: [
                            _buildThreadHeader(context, state.selectedThread!),
                            Expanded(
                              child: _buildMessagesList(context, state),
                            ),
                            _buildInputBar(context, state),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildThreadHeader(BuildContext context, ChatThread thread) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(thread.participantName.substring(0, 1)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${thread.participantName} (${thread.participantRole})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          ImStatusChip(
            status: thread.isVoiceAllowed ? EntityStatus.verified : EntityStatus.inProgress,
            label: thread.isVoiceAllowed ? 'Voice Enabled' : 'Text Only',
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    if (state.phase == ChatPhase.loading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty) {
      return const ImEmptyState(
        message: 'No messages yet. Send a message to start the conversation.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMine = message.isMine;
        final side = isMine ? ImBubbleSide.creator : ImBubbleSide.brand;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                '${message.senderName} • ${message.createdAt}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              ImBubbleCard(
                side: side,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.mediaType == 'voice' && message.voiceDurationSeconds != null)
                      VoiceNotePlayerStub(
                        messageId: message.id,
                        durationSeconds: message.voiceDurationSeconds!,
                        isPlaying: state.playingVoiceMessageId == message.id,
                        onTogglePlay: () {
                          context
                              .read<ChatBloc>()
                              .add(ToggleVoicePlaybackEvent(message.id));
                        },
                      )
                    else
                      Text(
                        message.text,
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context, ChatState state) {
    final isVoiceAllowed = state.selectedThread?.isVoiceAllowed ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isVoiceAllowed) ...[
            IconButton(
              icon: const Icon(Icons.mic),
              tooltip: 'Record Voice Note',
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => _sendVoiceNoteStub(state),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ImTextField(
              label: 'Message',
              hint: 'Type a message...',
              controller: _textController,
              onSubmitted: (_) => _sendMessage(state),
            ),
          ),
          const SizedBox(width: 12),
          ImButton(
            label: 'Send',
            icon: const Icon(Icons.send),
            loading: state.isSending,
            onPressed: () => _sendMessage(state),
          ),
        ],
      ),
    );
  }
}
