import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/step_indicator.dart';

class OnboardingStep1Language extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingStep1Language({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Obx(() => StepIndicator(
                currentStep: ctrl.currentStep.value,
                totalSteps: OnboardingController.totalSteps,
              )),
          const SizedBox(height: 20),
          const OnboardingHeader(
            emoji: '🌍',
            title: 'Choisissez votre langue',
            subtitle: 'Nous adapterons l\'application\nà votre préférence',
          ),
          Expanded(
            child: Obx(() => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: OnboardingController.languages.length,
                  itemBuilder: (context, i) {
                    final lang = OnboardingController.languages[i];
                    final isSelected =
                        ctrl.selectedLanguage.value == lang['code'];
                    return _LanguageCard(
                      flag: lang['flag']!,
                      name: lang['name']!,
                      native: lang['native']!,
                      isSelected: isSelected,
                      onTap: () => ctrl.selectLanguage(lang['code']!),
                    );
                  },
                )),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Continuer →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String native;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.native,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE4E9F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              native,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.