// splash_event.dart
import 'package:equatable/equatable.dart';
import '../../../data/services/ml/model_update_service.dart';
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class SplashStarted extends SplashEvent {
  const SplashStarted();
}

class SplashModelUpdateChecked extends SplashEvent {
  const SplashModelUpdateChecked();
}

class SplashModelUpdateDownloaded extends SplashEvent {
  final ModelUpdateInfo updateInfo;

  const SplashModelUpdateDownloaded(this.updateInfo);

  @override
  List<Object?> get props => [updateInfo];
}

class SplashNavigationRequested extends SplashEvent {
  const SplashNavigationRequested();
}