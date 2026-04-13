import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imagePath: 'assets/images/onboarding_buy_sell.png',
      title: 'Find & Sell Cinnamon Plants',
      description:
      'Connect directly with farmers, nurseries, and buyers. Trade cinnamon products easily.',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding_ai.png',
      title: 'AI-Powered Predictions',
      description: 'Get accurate price forecasts using advanced AI technology.',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding_location.png',
      title: 'Find cinnamon plants and bale buyers near you',
      description: 'Find the exact locations of bale buyers, and nurseries.',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding_expenses.png',
      title: 'Track Your Expenses',
      description:
      'Manage your farm expenses and make data-driven decisions for better profits.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // ── Page view ────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            // ── Page indicator ───────────────────────────────────────────
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const WormEffect(
                dotColor: AppColors.divider,
                activeDotColor: AppColors.primaryGreen,  // ← #2A9C2A
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),

            const SizedBox(height: 32),

            // ── Next / Get Started button (gradient) ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,  // ← #2A9C2A → #244A19
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Image / placeholder ────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              page.imagePath,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 56,
                      color: AppColors.primaryGreen.withOpacity(0.45),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Image placeholder',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryGreen.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      page.imagePath.split('/').last,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryGreen.withOpacity(0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
          // ──────────────────────────────────────────────────────────────

          const SizedBox(height: 48),

          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = context.read<SharedPreferences>();
    await prefs.setBool('is_first_time', false);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}