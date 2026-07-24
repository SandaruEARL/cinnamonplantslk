import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';


class OnboardingRepositoryImpl implements OnboardingRepository {
  final SharedPreferences prefs;
  OnboardingRepositoryImpl(this.prefs);

  @override
  Future<void> completeOnboarding() =>
      prefs.setBool('is_first_time', false);
}