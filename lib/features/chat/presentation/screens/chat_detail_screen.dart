import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
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
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
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
          adId: adId, // ✅ adId passed
        )),
      child: _ChatDetailView(
        currentUserId: authState.user.id,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserImage: otherUserImage,
        adId: adId,
        adTitle: adTitle,
        adImageUrl: adImageUrl,
        adPrice: adPrice,
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const _ChatDetailView({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final List<MessageEntity> _pendingMessages = [];
  final Map<String, String> _pendingImagePaths = {};
  ChatMessagesLoaded? _lastMessagesState;

  // ✅ Single source of truth for chatId within this screen
  String get _chatId {
    final ids = [widget.currentUserId, widget.otherUserId]..sort();
    return '${ids.join('_')}_${widget.adId}';
  }

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
        title: Text(widget.otherUserName,
            style: const TextStyle(fontSize: 18)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) return const SizedBox.shrink();
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
                        Icon(Icons.block,
                            color: isBlocked ? Colors.green : Colors.red,
                            size: 20),
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
                if (state is ChatImageSent) {
                  setState(() {
                    _pendingMessages.removeWhere((p) => p.id == state.pendingId);
                    _pendingImagePaths.remove(state.pendingId);
                  });
                }
                if (state is ChatMessagesLoaded) {
                  setState(() {
                    _pendingMessages.removeWhere((p) {
                      if (_pendingImagePaths.containsKey(p.id)) return false;
                      return state.messages.any((m) =>
                      m.localId == p.id &&
                          !m.deletedFor.contains(widget.currentUserId));
                    });
                  });
                }
                if (state is ChatUserBlocked) {
                  context.read<AuthBloc>().add(const AuthCheckRequested());
                  context.read<ChatBloc>().add(ChatMessagesLoadRequested(
                    currentUserId: widget.currentUserId,
                    otherUserId: widget.otherUserId,
                    adId: widget.adId, // ✅
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
                  context.read<ChatBloc>().add(ChatMessagesLoadRequested(
                    currentUserId: widget.currentUserId,
                    otherUserId: widget.otherUserId,
                    adId: widget.adId, // ✅
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
                if (chatState is ChatMessagesLoaded) {
                  _lastMessagesState = chatState;
                }
                if (chatState is ChatLoading && _lastMessagesState == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final effectiveState = chatState is ChatMessagesLoaded
                    ? chatState
                    : _lastMessagesState;
                if (effectiveState == null) return const SizedBox.shrink();

                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final blockedUsers = authState is AuthAuthenticated
                        ? authState.user.blockedUsers
                        : <String>[];

                    final visibleMessages = effectiveState.messages
                        .where((m) =>
                    !m.deletedFor.contains(widget.currentUserId) &&
                        !blockedUsers.contains(m.senderId))
                        .toList();

                    final stillPending = _pendingMessages
                        .where((p) => !visibleMessages.any((m) =>
                    m.localId == p.id &&
                        !m.deletedFor.contains(widget.currentUserId) &&
                        !m.id.startsWith('pending_')))
                        .toList();

                    final allMessages = [
                      ...stillPending,
                      ...visibleMessages,
                    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
                      context.read<ChatBloc>().add(ChatMarkAsReadRequested(
                        chatId: _chatId, // ✅ uses getter
                        userId: widget.currentUserId,
                      ));
                    });

                    final groupedItems = <dynamic>[];
                    int i = 0;
                    while (i < allMessages.length) {
                      final msg = allMessages[i];
                      final isImage = msg.imageUrl != null ||
                          _pendingImagePaths.containsKey(msg.id);
                      if (isImage) {
                        final group = <MessageEntity>[msg];
                        int j = i + 1;
                        while (j < allMessages.length) {
                          final next = allMessages[j];
                          final nextIsImage = next.imageUrl != null ||
                              _pendingImagePaths.containsKey(next.id);
                          if (nextIsImage && next.senderId == msg.senderId) {
                            group.add(next);
                            j++;
                          } else {
                            break;
                          }
                        }
                        if (group.length >= 5) {
                          groupedItems.add(group);
                        } else {
                          groupedItems.addAll(group);
                        }
                        i = j;
                      } else {
                        groupedItems.add(msg);
                        i++;
                      }
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      itemCount: groupedItems.length,
                      itemBuilder: (context, index) {
                        final item = groupedItems[index];
                        if (item is List<MessageEntity>) {
                          final isMe =
                              item.first.senderId == widget.currentUserId;
                          return _ImageGridBubble(
                            messages: item,
                            isMe: isMe,
                            pendingImagePaths: _pendingImagePaths,
                          );
                        }
                        final message = item as MessageEntity;
                        final isMe = message.senderId == widget.currentUserId;
                        return _ChatBubble(
                          message: message,
                          isMe: isMe,
                          currentUserId: widget.currentUserId,
                          chatId: _chatId, // ✅ uses getter
                          localImagePath: _pendingImagePaths[message.id],
                          onLongPress: isMe &&
                              !message.id.startsWith('pending_')
                              ? () => _showDeleteOptions(context, message)
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              textCapitalization: TextCapitalization.sentences,
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
                  chatId: _chatId, // ✅ uses getter
                  messageId: message.id,
                  userId: widget.currentUserId,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete for everyone',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(
                    ChatMessageDeleteForEveryoneRequested(
                      chatId: _chatId, // ✅ uses getter
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

    final localId = 'pending_${DateTime.now().millisecondsSinceEpoch}';

    final optimistic = MessageEntity(
      id: localId,
      localId: localId,
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
      localId: localId,
      adId: widget.adId,
      adTitle: widget.adTitle,
      adImageUrl: widget.adImageUrl,
      adPrice: widget.adPrice,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    final pendingId = 'pending_${DateTime.now().millisecondsSinceEpoch}';

    final optimistic = MessageEntity(
      id: pendingId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      text: '📷 Photo',
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _pendingMessages.add(optimistic);
      _pendingImagePaths[pendingId] = image.path;
    });

    _scrollToBottom();

    if (mounted) {
      context.read<ChatBloc>().add(ChatImageSendRequested(
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        chatId: _chatId, // ✅ uses getter
        image: File(image.path),
        pendingId: pendingId,
        adId: widget.adId,
        adTitle: widget.adTitle,
        adImageUrl: widget.adImageUrl,
        adPrice: widget.adPrice,
      ));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
  final String? localImagePath;
  final String chatId;
  final VoidCallback? onLongPress;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.chatId,
    this.localImagePath,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImageBubble =
        message.imageUrl != null || localImagePath != null;

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
                padding: isImageBubble
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe && !isImageBubble
                      ? AppColors.primaryGradient
                      : null,
                  color: isMe || isImageBubble ? null : AppColors.background,
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
                      GestureDetector(
                        onTap: () =>
                            _showFullScreen(context, imageUrl: message.imageUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: message.imageUrl!,
                                width: 200,
                                fit: BoxFit.cover,
                                memCacheWidth: 400,
                              ),
                              Positioned(
                                left: 8,
                                bottom: 6,
                                child: _timestampRow(),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (localImagePath != null)
                      GestureDetector(
                        onTap: () =>
                            _showFullScreen(context, localPath: localImagePath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.file(
                                File(localImagePath!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                cacheWidth: 400,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    return child;
                                  }
                                  return Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.grey[200]);
                                },
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.white.withOpacity(0.8)),
                                  minHeight: 3,
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 6,
                                child: _timestampRow(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (message.text != '📷 Photo')
                      Padding(
                        padding: isImageBubble
                            ? const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4)
                            : EdgeInsets.zero,
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    if (!isImageBubble)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
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

  Widget _timestampRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            _statusIcon(),
          ],
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context,
      {String? imageUrl, String? localPath}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: imageUrl != null
                ? CachedNetworkImage(imageUrl: imageUrl)
                : Image.file(File(localPath!)),
          ),
        ),
      ),
    ));
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

class _ImageGridBubble extends StatelessWidget {
  final List<MessageEntity> messages;
  final bool isMe;
  final Map<String, String> pendingImagePaths;

  const _ImageGridBubble({
    required this.messages,
    required this.isMe,
    required this.pendingImagePaths,
  });

  void _openGallery(BuildContext context, int startIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ImageGalleryViewer(
        messages: messages,
        pendingImagePaths: pendingImagePaths,
        initialIndex: startIndex,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = messages.length > 4 ? 4 : messages.length;
    final hiddenCount = messages.length - visibleCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 220),
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
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleCount,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final localPath = pendingImagePaths[msg.id];
                      final isLastVisible = index == visibleCount - 1;
                      final showCounter = isLastVisible && hiddenCount > 0;

                      return GestureDetector(
                        onTap: () => _openGallery(context, index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (msg.imageUrl != null)
                                CachedNetworkImage(
                                  imageUrl: msg.imageUrl!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                )
                              else if (localPath != null)
                                Image.file(
                                  File(localPath),
                                  fit: BoxFit.cover,
                                  cacheWidth: 200,
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded ||
                                        frame != null) return child;
                                    return Container(color: Colors.grey[200]);
                                  },
                                ),
                              if (localPath != null)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.white.withOpacity(0.8)),
                                    minHeight: 2,
                                  ),
                                ),
                              if (showCounter)
                                Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Text(
                                      '+$hiddenCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (isLastVisible && !showCounter)
                                Positioned(
                                  left: 6,
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGalleryViewer extends StatefulWidget {
  final List<MessageEntity> messages;
  final Map<String, String> pendingImagePaths;
  final int initialIndex;

  const _ImageGalleryViewer({
    required this.messages,
    required this.pendingImagePaths,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.messages.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (_isZoomed) return;
          const threshold = 200.0;
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -threshold &&
              _currentIndex < widget.messages.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else if (velocity > threshold && _currentIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        },
        child: PageView.builder(
          controller: _pageController,
          physics: _isZoomed
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          itemCount: widget.messages.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final msg = widget.messages[index];
            final localPath = widget.pendingImagePaths[msg.id];
            final imageProvider = msg.imageUrl != null
                ? CachedNetworkImageProvider(msg.imageUrl!)
                : localPath != null
                ? FileImage(File(localPath)) as ImageProvider
                : null;
            if (imageProvider == null) return const SizedBox.shrink();
            return SizedBox(
              width: size.width,
              height: size.height,
              child: PhotoView(
                imageProvider: imageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration:
                const BoxDecoration(color: Colors.black),
                scaleStateChangedCallback: (state) {
                  final zoomed = state != PhotoViewScaleState.initial &&
                      state != PhotoViewScaleState.zoomedOut;
                  setState(() => _isZoomed = zoomed);
                },
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}