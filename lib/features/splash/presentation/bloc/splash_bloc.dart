// splash_bloc.dart

import 'package:cinnamon_marketplace_app/features/splash/presentation/bloc/splash_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../data/services/ai/tflite_service.dart';
import '../../../../../data/services/ml/model_update_service.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final TFLiteService tfliteService;
  final SharedPreferences prefs;

  SplashBloc({
    required this.tfliteService,
    required this.prefs,
  }) : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
    on<SplashModelUpdateChecked>(_onModelUpdateChecked);
    on<SplashModelUpdateDownloaded>(_onModelUpdateDownloaded);
    on<SplashNavigationRequested>(_onNavigationRequested);
  }

  Future<void> _onStarted(
      SplashStarted event,
      Emitter<SplashState> emit,
      ) async {
    try {
      // Step 1: Initialize
      emit(state.copyWith(
        status: SplashStatus.initializing,
        message: 'Loading resources...',
      ));

      await Future.delayed(const Duration(seconds: 1));

      // Step 2: Check for model updates
      emit(state.copyWith(
        status: SplashStatus.checkingUpdate,
        message: 'Checking for AI model updates...',
      ));

      final updateInfo = await tfliteService.checkForModelUpdate();

      if (updateInfo != null) {
        // Update available
        emit(state.copyWith(
          status: SplashStatus.updateAvailable,
          message: 'Model update available',
          updateInfo: updateInfo,
        ));
      } else {
        // No update, check if first time and navigate
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateBasedOnFirstTime(emit);
      }
    } catch (e) {
      // Non-critical error, still navigate
      _navigateBasedOnFirstTime(emit);
    }
  }

  Future<void> _onModelUpdateChecked(
      SplashModelUpdateChecked event,
      Emitter<SplashState> emit,
      ) async {
    try {
      emit(state.copyWith(
        status: SplashStatus.checkingUpdate,
        message: 'Checking for updates...',
      ));

      final updateInfo = await tfliteService.checkForModelUpdate();

      if (updateInfo != null) {
        emit(state.copyWith(
          status: SplashStatus.updateAvailable,
          updateInfo: updateInfo,
        ));
      } else {
        _navigateBasedOnFirstTime(emit);
      }
    } catch (e) {
      emit(state.copyWith(
        status: SplashStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onModelUpdateDownloaded(
      SplashModelUpdateDownloaded event,
      Emitter<SplashState> emit,
      ) async {
    try {
      emit(state.copyWith(
        status: SplashStatus.downloadingUpdate,
        message: 'Downloading model...',
        downloadProgress: 0.0,
      ));

      final success = await tfliteService.installModelUpdate(event.updateInfo);

      if (success) {
        emit(state.copyWith(
          status: SplashStatus.updateComplete,
          message: 'Update complete',
          downloadProgress: 1.0,
        ));

        // Wait a bit then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateBasedOnFirstTime(emit);
      } else {
        emit(state.copyWith(
          status: SplashStatus.error,
          errorMessage: 'Failed to download model',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SplashStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onNavigationRequested(
      SplashNavigationRequested event,
      Emitter<SplashState> emit,
      ) async {
    _navigateBasedOnFirstTime(emit);
  }

  void _navigateBasedOnFirstTime(Emitter<SplashState> emit) {
    // Check if first time user
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (isFirstTime) {
      // First time: go to onboarding
      emit(state.copyWith(
        status: SplashStatus.navigateToOnboarding,
        message: 'Welcome!',
      ));
    } else {
      // Not first time: go to home
      emit(state.copyWith(
        status: SplashStatus.navigateToHome,
        message: 'Ready',
      ));
    }
  }
}