import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/app_colors.dart';
import '../../../../data/services/ai/tflite_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        tfliteService: di.sl<TFLiteService>(),
        prefs: di.sl<SharedPreferences>(),
      )..add(const SplashStarted()),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.navigateToOnboarding) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
        if (state.status == SplashStatus.navigateToHome) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        // Silent auto-update — no dialog
        if (state.status == SplashStatus.updateAvailable &&
            state.updateInfo != null) {
          context.read<SplashBloc>().add(
            SplashModelUpdateDownloaded(state.updateInfo!),
          );
        }
        if (state.status == SplashStatus.error) {
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.read<SplashBloc>().add(const SplashNavigationRequested());
            }
          });
        }
      },
      child: const Scaffold(
        body: _SplashBody(),
      ),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with TickerProviderStateMixin {

  late final AnimationController _logoController;
  late final AnimationController _taglineController;
  late final AnimationController _loaderController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = CurvedAnimation(
        parent: _logoController, curve: Curves.elasticOut);
    _logoFade = CurvedAnimation(
        parent: _logoController, curve: Curves.easeIn);

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = CurvedAnimation(
        parent: _taglineController, curve: Curves.easeIn);
    _taglineSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
          parent: _taglineController, curve: Curves.easeOut),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loaderFade = CurvedAnimation(
        parent: _loaderController, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _loaderController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ── Logo pop-in ────────────────────────────────────
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoFade,
                child: Image.asset(
                  'assets/images/onboarding_buy_sell.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── App name fade + slide ──────────────────────────
            AnimatedBuilder(
              animation: _taglineController,
              builder: (_, __) => Opacity(
                opacity: _taglineFade.value,
                child: Transform.translate(
                  offset: Offset(0, _taglineSlide.value),
                  child: Column(
                    children: [
                      Text(
                        'Cinnamon',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plants Lk',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tagline ────────────────────────────────────────
            AnimatedBuilder(
              animation: _taglineController,
              builder: (_, __) => Opacity(
                opacity: _taglineFade.value,
                child: Transform.translate(
                  offset: Offset(0, _taglineSlide.value),
                  child: Text(
                    "Find cinnamon plants, find cinnamon nurseries, find cinnamon bale buyers, see current cinnamon market prices, see predictions",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 56),

            // ── Loader + silent status ─────────────────────────
            BlocBuilder<SplashBloc, SplashState>(
              builder: (context, state) {
                return FadeTransition(
                  opacity: _loaderFade,
                  child: Column(
                    children: [
                      if (state.status == SplashStatus.downloadingUpdate &&
                          state.downloadProgress != null)
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: state.downloadProgress,
                            valueColor: const AlwaysStoppedAnimation(
                                Colors.white),
                            backgroundColor:
                            Colors.white.withOpacity(0.25),
                            strokeWidth: 3,
                          ),
                        )
                      else
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        _statusMessage(state.status, state.downloadProgress),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusMessage(SplashStatus status, double? progress) {
    switch (status) {
      case SplashStatus.checkingUpdate:
        return 'Checking for updates...';
      case SplashStatus.downloadingUpdate:
        return progress != null
            ? 'Updating AI model ${(progress * 100).toInt()}%'
            : 'Updating AI model...';
      case SplashStatus.updateComplete:
        return 'Ready';
      case SplashStatus.error:
        return 'Starting with cached model...';
      default:
        return 'Loading...';
    }
  }
}