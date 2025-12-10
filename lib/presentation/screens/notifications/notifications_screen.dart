import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = [
      {
        'type': 'message',
        'title': 'New Message',
        'body': 'Kamal sent you a message about your cinnamon listing',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
      },
      {
        'type': 'price',
        'title': 'Price Alert',
        'body': 'Cinnamon prices increased by 5% this week! ',
        'time': DateTime. now().subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'type': 'ad',
        'title': 'New Advertisement',
        'body': 'Premium Alba grade cinnamon available near you',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
      },
      {
        'type': 'system',
        'title': 'Welcome! ',
        'body': 'Thank you for joining Cinnamon Marketplace',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary. withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: notifications. length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead = notification['isRead'] as bool;

          return Container(
            color: isRead ? null : AppColors.primaryBrown. withOpacity(0.05),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type'] as String)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type'] as String),
                  color: _getNotificationColor(notification['type'] as String),
                ),
              ),
              title: Text(
                notification['title'] as String,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight. normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification['body'] as String),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification['time'] as DateTime),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: ! isRead
                  ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrown,
                  shape: BoxShape. circle,
                ),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.chat;
      case 'price':
        return Icons.trending_up;
      case 'ad':
        return Icons.shopping_bag;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'message':
        return AppColors.accentGreen;
      case 'price':
        return AppColors.accentYellow;
      case 'ad':
        return AppColors.primaryBrown;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy'). format(dateTime);
    }
  }
}