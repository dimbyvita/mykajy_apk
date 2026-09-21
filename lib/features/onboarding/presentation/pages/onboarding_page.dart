import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import 'onboarding_step1_language.dart';
import 'onboarding_step2_theme.dart';
import 'onboarding_step3_profile.dart';
import 'onboarding_step4_completion.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    ever(controller.currentStep, (step) {
      _animateToPage((step as int) - 1);
    });

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            OnboardingStep1Language(
              onNext: controller.nextStep,
            ),
            OnboardingStep2Theme(
              onNext: controller.nextStep,
              onBack: controller.prevStep,
            ),
            OnboardingStep3Profile(
              onNext: controller.completeOnboarding,
              onBack: controller.prevStep,
            ),
            OnboardingStep4Completion(
              onStart: controller.goToDashboard,
            ),
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.