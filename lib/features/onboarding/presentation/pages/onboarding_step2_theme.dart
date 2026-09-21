import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/step_indicator.dart';

class OnboardingStep2Theme extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingStep2Theme({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  static const _themeColors = {
    'light': [Color(0xFFEEF2FD), Color(0xFFdde6ff), Color(0xFF2D5BE3)],
    'dark': [Color(0xFF1C2030), Color(0xFF0F1119), Color(0xFF7B93FF)],
    'ocean': [Color(0xFFE0F7FA), Color(0xFFb3eaf5), Color(0xFF0891B2)],
    'rose': [Color(0xFFFCE7F3), Color(0xFFfbcfe8), Color(0xFFBE185D)],
  };

  static const _themeIcons = {
    'light': '☀️',
    'dark': '🌙',
    'ocean': '🌊',
    'rose': '🌸',
  };

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();
    final themeCtrl = Get.find<ThemeController>();

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
            emoji: '🎨',
            title: 'Votre style d\'interface',
            subtitle: 'Choisissez le thème\nqui vous ressemble',
          ),
          Expanded(
            child: Obx(() => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: OnboardingController.themes.length,
                  itemBuilder: (context, i) {
                    final theme = OnboardingController.themes[i];
                    final key = theme['key']!;
                    final isSelected = ctrl.selectedTheme.value == key;
                    final colors = _themeColors[key]!;
                    return _ThemeCard(
                      icon: _themeIcons[key]!,
                      name: theme['name']!,
                      desc: theme['desc']!,
                      gradientColors: colors,
                      accentColor: colors[2],
                      isSelected: isSelected,
                      onTap: () {
                        ctrl.selectTheme(key);
                        themeCtrl.setTheme(key);
                      },
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
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onBack,
              child: const Text('← Retour'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String icon;
  final String name;
  final String desc;
  final List<Color> gradientColors;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.icon,
    required this.name,
    required this.desc,
    required this.gradientColors,
    required this.accentColor,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : const Color(0xFFE4E9F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientColors[0], gradientColors[1]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.