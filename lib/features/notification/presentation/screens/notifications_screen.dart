import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              flexibleSpace: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80,
                      color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Please log in to view notifications',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<NotificationBloc>().add(
            LoadNotifications(authState.user.id),
          );
        });

        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Notifications'),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                actions: [
                  if (state is NotificationLoaded && state.unreadCount > 0)
                    TextButton(
                      onPressed: () => context.read<NotificationBloc>().add(
                        MarkAllNotificationsRead(authState.user.id),
                      ),
                      child: const Text('Mark all read',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    if (state is NotificationLoading || state is NotificationInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is NotificationError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    if (state is NotificationLoaded) {
      if (state.notifications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No notifications yet',
                  style: TextStyle(
                      fontSize: 18, color: AppColors.textSecondary)),
            ],
          ),
        );
      }
      return ListView.separated(
        itemCount: state.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final n = state.notifications[index];
          return _NotificationTile(
            notification: n,
            onTap: () {
              if (!n.isRead) {
                context
                    .read<NotificationBloc>()
                    .add(MarkNotificationRead(n.id));
              }
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? null : AppColors.primaryGreen.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color(notification.type).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(notification.type),
                  color: _color(notification.type), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                          fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(notification.body,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_formatTime(notification.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'chat': return Icons.chat_bubble_outline;
      case 'ad_approved': return Icons.check_circle_outline;
      case 'ad_denied': return Icons.cancel_outlined;
      case 'location_approved': return Icons.location_on;
      case 'location_denied': return Icons.location_off;
      case 'announcement': return Icons.campaign_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'chat': return AppColors.accentGreen;
      case 'ad_approved':
      case 'location_approved': return AppColors.primaryGreen;
      case 'ad_denied':
      case 'location_denied': return Colors.red;
      case 'announcement': return Colors.orange;
      default: return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(dt);
  }
}