import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/complete_onboarding.dart';

// States
abstract class OnboardingState {}
class OnboardingInitial   extends OnboardingState {}
class OnboardingCompleted extends OnboardingState {}

// Cubit
class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboarding _completeOnboarding;
  OnboardingCubit(this._completeOnboarding) : super(OnboardingInitial());

  Future<void> finish() async {
    await _completeOnboarding();
    emit(OnboardingCompleted());
  }
}