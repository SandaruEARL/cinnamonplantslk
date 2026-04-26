import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;
  GetNotifications(this.repository);

  Stream<List<NotificationEntity>> call(String userId) =>
      repository.getNotifications(userId);
}