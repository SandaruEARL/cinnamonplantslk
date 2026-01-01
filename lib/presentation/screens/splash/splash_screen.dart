// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/ai/tflite_service.dart';
import '../../bloc/splash/splash_bloc.dart';
import '../../bloc/splash/splash_event.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        tfliteService: context.read<TFLiteService>(),
        prefs: context.read<SharedPreferences>(),
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
        // Navigate to onboarding (first time user)
        if (state.status == SplashStatus.navigateToOnboarding) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }

        // Navigate to home (returning user)
        if (state.status == SplashStatus.navigateToHome) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        // Show update dialog when available
        if (state.status == SplashStatus.updateAvailable &&
            state.updateInfo != null) {
          _showUpdateDialog(context, state.updateInfo!);
        }

        // Show error (but continue)
        if (state.status == SplashStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.errorMessage ?? "Unknown error"}'),
              backgroundColor: AppColors.accentRed,
            ),
          );
          // Still navigate after error
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.read<SplashBloc>().add(const SplashNavigationRequested());
            }
          });
        }

        // Show success snackbar
        if (state.status == SplashStatus.updateComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('AI model updated successfully!'),
                ],
              ),
              backgroundColor: AppColors.accentGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 64,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'Cinnamon Marketplace',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Sri Lanka\'s Cinnamon Trading Hub',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading indicator with progress
                    if (state.status == SplashStatus.downloadingUpdate &&
                        state.downloadProgress != null)
                      Column(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              value: state.downloadProgress,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.3),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(state.downloadProgress! * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                      ),
                    const SizedBox(height: 16),

                    // Status message
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.system_update,
                color: AppColors.primaryBrown,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('AI Model Update')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A new AI model is available with improved predictions.'),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.new_releases,
              label: 'Version',
              value: updateInfo.newVersion,
            ),
            _InfoRow(
              icon: Icons.storage,
              label: 'Size',
              value: updateInfo.sizeFormatted,
            ),
            _InfoRow(
              icon: Icons.dataset,
              label: 'Training Data',
              value: '${updateInfo.recordsCount} records',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.accentGreen,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Update now for the most accurate predictions',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Continue without updating
              context.read<SplashBloc>().add(const SplashNavigationRequested());
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Download and install update
              context.read<SplashBloc>().add(
                SplashModelUpdateDownloaded(updateInfo),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}