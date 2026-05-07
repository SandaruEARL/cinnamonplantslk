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
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                        color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(l10n.noMessagesYet,
                        style: const TextStyle(
                            fontSize: 18, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(l10n.startTheConversation,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
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
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          otherUserId: chat.otherUserId,
          otherUserName: chat.otherUserName,
          otherUserImage: chat.otherUserImage,
          adId: chat.adId,
          adTitle: chat.adTitle,
          adImageUrl: chat.adImageUrl,
          adPrice: chat.adPrice,
        ),
      )),
      onLongPress: () => _showDeleteDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: ad thumbnail + user avatar overlay ─────────────
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ad thumbnail fills the slot
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: chat.adImageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: chat.adImageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _adImageFallback(size: 56),
                    )
                        : _adImageFallback(size: 56),
                  ),

                  // Unread dot — top-left corner
                  if (isUnread)
                    Positioned(
                      left: -2,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),

                  // User avatar — small circle at bottom-right
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.primaryGreen,
                        backgroundImage: chat.otherUserImage != null
                            ? CachedNetworkImageProvider(chat.otherUserImage!)
                            : null,
                        child: chat.otherUserImage == null
                            ? Text(
                          chat.otherUserName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // ── Middle: name + time / ad info / last message ─────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: user name + verified badge + timestamp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                chat.otherUserName,
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified,
                                    color: AppColors.accentGreen, size: 14),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: isUnread
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                          fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Row 2: ad title + price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.adTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs.${chat.adPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Row 3: last message preview
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      isUnread ? FontWeight.w600 : FontWeight.normal,
                      color: isUnread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adImageFallback({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
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