import '../repositories/notification_repository.dart';

class MarkAllAsRead {
  final NotificationRepository repository;
  MarkAllAsRead(this.repository);

  Future<void> call(String userId) =>
      repository.markAllAsRead(userId);
}