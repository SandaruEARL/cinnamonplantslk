abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String userId;
  LoadNotifications(this.userId);
}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationRead(this.notificationId);
}

class MarkAllNotificationsRead extends NotificationEvent {
  final String userId;
  MarkAllNotificationsRead(this.userId);
}

class NotificationsUpdated extends NotificationEvent {
  final List<dynamic> notifications;
  NotificationsUpdated(this.notifications);
}

class NotificationsError extends NotificationEvent {
  final String message;
  NotificationsError(this.message);
}