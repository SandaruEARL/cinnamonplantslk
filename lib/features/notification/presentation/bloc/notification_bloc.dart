import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/mark_all_as_read.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;
  StreamSubscription? _subscription;

  NotificationBloc({
    required this.getNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<NotificationsUpdated>(_onUpdated);
    on<NotificationsError>(_onError);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  void _onLoad(LoadNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = getNotifications(event.userId).listen(
          (notifications) => add(NotificationsUpdated(notifications)),
      onError: (e) => add(NotificationsError(e.toString())),
    );
  }

  void _onUpdated(NotificationsUpdated event, Emitter<NotificationState> emit) {
    emit(NotificationLoaded(event.notifications.cast<NotificationEntity>()));
  }

  void _onError(NotificationsError event, Emitter<NotificationState> emit) {
    emit(NotificationError(event.message));
  }

  Future<void> _onMarkRead(
      MarkNotificationRead event, Emitter<NotificationState> emit) async {
    await markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllRead(
      MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    await markAllAsRead(event.userId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}