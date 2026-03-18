import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/storage/local_storage.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.storefront_rounded,
      color: Color(0xFF6C3CE1),
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
    ),
    _OnboardingData(
      icon: Icons.payment_rounded,
      color: Color(0xFFFF6B35),
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
    ),
    _OnboardingData(
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF10B981),
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
    ),
  ];

  void _completeOnboarding() async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.setBool(AppConstants.onboardingKey, true);
    if (mounted) context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(AppStrings.skip),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),

            // Indicator & button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.grey300,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLast) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        isLast ? AppStrings.getStarted : AppStrings.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
