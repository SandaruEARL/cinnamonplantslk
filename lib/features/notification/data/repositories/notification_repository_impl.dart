import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) =>
      remoteDataSource
          .getNotifications(userId)
          .map((models) => models.map((m) => m.toEntity()).toList());

  @override
  Future<void> markAsRead(String notificationId) =>
      remoteDataSource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(String userId) =>
      remoteDataSource.markAllAsRead(userId);
}