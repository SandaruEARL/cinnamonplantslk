// splash_state.dart
part of 'splash_bloc.dart';

enum SplashStatus {
  initial,
  initializing,
  checkingUpdate,
  updateAvailable,
  downloadingUpdate,
  updateComplete,
  navigateToOnboarding,  // Navigate to onboarding (first time)
  navigateToHome,        // Navigate to home (returning user)
  error,
}

class SplashState extends Equatable {
  final SplashStatus status;
  final String message;
  final ModelUpdateInfo? updateInfo;
  final String? errorMessage;
  final double? downloadProgress;

  const SplashState({
    this.status = SplashStatus.initial,
    this.message = 'Initializing...',
    this.updateInfo,
    this.errorMessage,
    this.downloadProgress,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? message,
    ModelUpdateInfo? updateInfo,
    String? errorMessage,
    double? downloadProgress,
  }) {
    return SplashState(
      status: status ?? this.status,
      message: message ?? this.message,
      updateInfo: updateInfo ?? this.updateInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    updateInfo,
    errorMessage,
    downloadProgress,
  ];
}