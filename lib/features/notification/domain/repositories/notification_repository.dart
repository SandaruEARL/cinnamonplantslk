import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
}