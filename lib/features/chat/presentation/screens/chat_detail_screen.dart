import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/message_entity.dart';

class ChatDetailScreen extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return BlocProvider(
      create: (_) => sl<ChatBloc>()
        ..add(ChatMessagesLoadRequested(
          currentUserId: authState.user.id,
          otherUserId: otherUserId,
        )),
      child: _ChatDetailView(
        currentUserId: authState.user.id,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserImage: otherUserImage,
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const _ChatDetailView({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final List<MessageEntity> _pendingMessages = [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTyping) setState(() => _isTyping = hasText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryGreen,
              backgroundImage: widget.otherUserImage != null
                  ? CachedNetworkImageProvider(widget.otherUserImage!)
                  : null,
              child: widget.otherUserImage == null
                  ? Text(widget.otherUserName[0].toUpperCase(),
                  style:
                  const TextStyle(color: Colors.white, fontSize: 16))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.otherUserName,
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          // ✅ AppBar only has the block/unblock menu — uses AuthBloc correctly
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const SizedBox.shrink();
              }
              final isBlocked =
              authState.user.blockedUsers.contains(widget.otherUserId);
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'block') {
                    context.read<ChatBloc>().add(ChatUserBlockRequested(
                      currentUserId: widget.currentUserId,
                      targetUserId: widget.otherUserId,
                    ));
                  } else if (value == 'unblock') {
                    context.read<ChatBloc>().add(ChatUserUnblockRequested(
                      currentUserId: widget.currentUserId,
                      targetUserId: widget.otherUserId,
                    ));
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: isBlocked ? 'unblock' : 'block',
                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: isBlocked ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBlocked ? 'Unblock User' : 'Block User',
                          style: TextStyle(
                              color: isBlocked ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                // pending cleanup
                if (state is ChatMessagesLoaded) {
                  setState(() {
                    _pendingMessages.removeWhere((p) => state.messages.any(
                          (m) =>
                      m.text == p.text &&
                          m.senderId == p.senderId &&
                          m.timestamp
                              .difference(p.timestamp)
                              .inSeconds
                              .abs() <
                              10 &&
                          !m.deletedFor.contains(widget.currentUserId),
                    ));
                  });
                }
                // block/unblock feedback
                if (state is ChatUserBlocked) {
                  context.read<AuthBloc>().add(const AuthCheckRequested());
                  //  Reload messages so chatState goes back to ChatMessagesLoaded
                  context.read<ChatBloc>().add(ChatMessagesLoadRequested(
                    currentUserId: widget.currentUserId,
                    otherUserId: widget.otherUserId,
                  ));
                  Fluttertoast.showToast(
                    msg: 'User blocked',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  );
                }
                if (state is ChatUserUnblocked) {
                  context.read<AuthBloc>().add(const AuthCheckRequested());
                  //  Same here
                  context.read<ChatBloc>().add(ChatMessagesLoadRequested(
                    currentUserId: widget.currentUserId,
                    otherUserId: widget.otherUserId,
                  ));
                  Fluttertoast.showToast(
                    msg: 'User unblocked',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  );
                }
              },
              builder: (context, chatState) {
                if (chatState is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chatState is ChatMessagesLoaded) {
                  // ✅ Nested BlocBuilder<AuthBloc> so it rebuilds on block/unblock
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final blockedUsers = authState is AuthAuthenticated
                          ? authState.user.blockedUsers
                          : <String>[];

                      final visibleMessages = chatState.messages
                          .where((m) =>
                      !m.deletedFor.contains(widget.currentUserId) &&
                          !blockedUsers.contains(m.senderId))
                          .toList();

                      final stillPending = _pendingMessages
                          .where((p) => !visibleMessages.any((m) =>
                      m.text == p.text &&
                          m.senderId == p.senderId &&
                          m.timestamp
                              .difference(p.timestamp)
                              .inSeconds
                              .abs() <
                              10))
                          .toList();

                      final allMessages = [
                        ...stillPending.reversed,
                        ...visibleMessages
                      ];

                      if (allMessages.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 64, color: AppColors.textSecondary),
                              SizedBox(height: 16),
                              Text('No messages yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        final chatId =
                        ([widget.currentUserId, widget.otherUserId]
                          ..sort())
                            .join('_');
                        context.read<ChatBloc>().add(ChatMarkAsReadRequested(
                          chatId: chatId,
                          userId: widget.currentUserId,
                        ));
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final message = allMessages[index];
                          final isMe =
                              message.senderId == widget.currentUserId;
                          return _ChatBubble(
                            message: message,
                            isMe: isMe,
                            currentUserId: widget.currentUserId,
                            chatId:
                            ([widget.currentUserId, widget.otherUserId]
                              ..sort())
                                .join('_'),
                            onLongPress: isMe &&
                                !message.id.startsWith('pending_')
                                ? () => _showDeleteOptions(context, message)
                                : null,
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Input
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Write a message...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              maxLines: null,
                              textCapitalization:
                              TextCapitalization.sentences,
                            ),
                          ),
                          if (_isTyping)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: IconButton(
                                icon: const Icon(Icons.send),
                                color: AppColors.primaryGreen,
                                onPressed: _sendMessage,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!_isTyping) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      color: AppColors.primaryGreen,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      color: AppColors.primaryGreen,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteOptions(BuildContext context, MessageEntity message) {
    final chatId =
    ([widget.currentUserId, widget.otherUserId]..sort()).join('_');
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete for me'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(ChatMessageDeleteForMeRequested(
                  chatId: chatId,
                  messageId: message.id,
                  userId: widget.currentUserId,
                ));
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete for everyone',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(
                    ChatMessageDeleteForEveryoneRequested(
                      chatId: chatId,
                      messageId: message.id,
                      senderId: widget.currentUserId,
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final optimistic = MessageEntity(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    setState(() => _pendingMessages.add(optimistic));

    context.read<ChatBloc>().add(ChatMessageSendRequested(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      text: text,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    final chatId =
    ([widget.currentUserId, widget.otherUserId]..sort()).join('_');
    if (mounted) {
      context.read<ChatBloc>().add(ChatImageSendRequested(
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        chatId: chatId,
        image: File(image.path),
      ));
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String currentUserId;
  final String chatId;
  final VoidCallback? onLongPress;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.chatId,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe ? AppColors.primaryGradient : null,
                  color: isMe ? null : AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: message.imageUrl!,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (message.text != '📷 Photo')
                      Text(
                        message.text,
                        style: TextStyle(
                          color:
                          isMe ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isMe
                                ? Colors.white.withOpacity(0.7)
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _statusIcon(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    IconData icon;
    Color color = Colors.white.withOpacity(0.7);
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
    }
    return Icon(icon, size: 14, color: color);
  }
}