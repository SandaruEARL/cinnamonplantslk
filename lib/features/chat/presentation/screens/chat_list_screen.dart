import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/chat/presentation/screens/chat_detail_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/chat_entity.dart';


class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const _UnauthenticatedView();
    }

    return BlocProvider(
      create: (_) => sl<ChatBloc>()
        ..add(ChatListLoadRequested(authState.user.id)),
      child: _ChatListView(currentUserId: authState.user.id),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messagesTitle),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Center(child: Text(l10n.pleaseLoginToViewMessages)),
    );
  }
}

class _ChatListView extends StatelessWidget {
  final String currentUserId;
  const _ChatListView({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(l10n.messagesTitle),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          if (state is ChatListLoaded) {
            if (state.chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 80,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(l10n.noMessagesYet,
                        style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(l10n.startTheConversation,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final isUnread = chat.isUnreadFor(currentUserId);
                return _ChatTile(
                  chat: chat,
                  isUnread: isUnread,
                  currentUserId: currentUserId,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatEntity chat;
  final bool isUnread;
  final String currentUserId;

  const _ChatTile({
    required this.chat,
    required this.isUnread,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          otherUserId: chat.otherUserId,
          otherUserName: chat.otherUserName,
          otherUserImage: chat.otherUserImage,
        ),
      )),
      onLongPress: () => _showDeleteDialog(context),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryGreen,
            backgroundImage: chat.otherUserImage != null
                ? CachedNetworkImageProvider(chat.otherUserImage!)
                : null,
            child: chat.otherUserImage == null
                ? Text(chat.otherUserName[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))
                : null,
          ),
          if (isUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(chat.otherUserName,
                style: TextStyle(
                    fontWeight: isUnread
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
          if (chat.isVerified)
            const Icon(Icons.verified,
                color: AppColors.accentGreen, size: 16),
        ],
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight:
          isUnread ? FontWeight.w600 : FontWeight.normal,
          color: isUnread
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        _formatTime(chat.lastMessageTime),
        style: TextStyle(
          fontSize: 12,
          color: isUnread
              ? AppColors.primaryGreen
              : AppColors.textSecondary,
          fontWeight:
          isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text(
          'Delete your conversation with ${chat.otherUserName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatBloc>().add(ChatDeleteRequested(
                chatId: chat.chatId,
                userId: currentUserId,
              ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}