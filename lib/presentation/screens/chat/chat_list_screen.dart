import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/auth_service.dart';
import '../../../data/services/firebase/messaging_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Messages'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is!  AuthAuthenticated) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Please login to view messages')),
                );
              }

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: context.read<MessagingService>().getUserChats(state.user. id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (! snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: AppColors.textSecondary. withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start chatting with sellers',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final chats = snapshot.data!;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final chat = chats[index];
                        final participants = chat['participants'] as List;
                        final otherUserId = participants.firstWhere(
                              (id) => id != state.user. id,
                        );

                        return FutureBuilder(
                          future: context.read<AuthService>().getUserData(otherUserId),
                          builder: (context, userSnapshot) {
                            if (! userSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final otherUser = userSnapshot.data! ;
                            final lastMessage = chat['lastMessage'] as String;
                            final lastMessageTime = DateTime.parse(
                              chat['lastMessageTime'] as String,
                            );
                            final isUnread = chat['lastMessageSender'] != state.user.id;

                            return ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      otherUserId: otherUser.id,
                                      otherUserName: otherUser.name,
                                      otherUserImage: otherUser.profilePicUrl,
                                    ),
                                  ),
                                );
                              },
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.primaryBrown,
                                    backgroundImage: otherUser.profilePicUrl != null
                                        ? CachedNetworkImageProvider(
                                      otherUser.profilePicUrl!,
                                    )
                                        : null,
                                    child: otherUser.profilePicUrl == null
                                        ? Text(
                                      otherUser.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
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
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      otherUser.name,
                                      style: TextStyle(
                                        fontWeight: isUnread
                                            ? FontWeight.bold
                                            : FontWeight. normal,
                                      ),
                                    ),
                                  ),
                                  if (otherUser.isVerified)
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.accentGreen,
                                      size: 16,
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight. normal,
                                  color: isUnread
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              trailing: Text(
                                _formatTime(lastMessageTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isUnread
                                      ? AppColors.primaryBrown
                                      : AppColors.textSecondary,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: chats.length,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour. toString().padLeft(2, '0')}:${dateTime. minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime. year}';
    }
  }
}