import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/step_indicator.dart';

class OnboardingStep3Profile extends StatefulWidget {
  final Future<void> Function() onNext;
  final VoidCallback onBack;

  const OnboardingStep3Profile({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OnboardingStep3Profile> createState() => _OnboardingStep3ProfileState();
}

class _OnboardingStep3ProfileState extends State<OnboardingStep3Profile> {
  bool _showEmojis = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Obx(() => StepIndicator(
                currentStep: ctrl.currentStep.value,
                totalSteps: OnboardingController.totalSteps,
              )),
          const SizedBox(height: 20),
          const OnboardingHeader(
            emoji: '👤',
            title: 'Votre profil',
            subtitle: 'Personnalisez votre espace MoneyTrack',
          ),

          // Avatar picker
          Obx(() {
            final picked = ctrl.avatarIsPicked;
            return GestureDetector(
              onTap: () => setState(() => _showEmojis = !_showEmojis),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary,
                    width: picked ? 2.5 : 1.5,
                    style: picked ? BorderStyle.solid : BorderStyle.none,
                  ),
                ),
                child: Center(
                  child: Text(
                    ctrl.avatarDisplay,
                    style: TextStyle(
                      fontSize: ctrl.selectedEmoji.value.isNotEmpty ? 38 : 28,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            'Appuyez pour choisir un avatar',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 14),

          // Emoji row
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showEmojis
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Obx(() => Wrap(
                          spacing: 10,
                          children:
                              OnboardingController.avatarEmojis.map((e) {
                            final isSelE = ctrl.selectedEmoji.value == e;
                            return GestureDetector(
                              onTap: () {
                                ctrl.selectEmoji(e);
                                setState(() => _showEmojis = false);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelE
                                      ? primary.withOpacity(0.15)
                                      : Theme.of(context).cardTheme.color,
                                  border: Border.all(
                                    color: isSelE
                                        ? primary
                                        : const Color(0xFFE4E9F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                  )
                : const SizedBox.shrink(),
          ),

          // Name fields
          _buildField(
            context,
            label: 'PRÉNOM',
            controller: ctrl.firstNameController,
            hint: 'Jean',
            onChanged: (_) => ctrl.firstNameController.notifyListeners(),
          ),
          const SizedBox(height: 12),
          _buildField(
            context,
            label: 'NOM',
            controller: ctrl.lastNameController,
            hint: 'Dupont',
          ),
          const SizedBox(height: 12),

          // Currency dropdown
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEVISE PRINCIPALE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: ctrl.selectedCurrencyCode.value,
                    decoration: const InputDecoration(),
                    items: OnboardingController.currencies.map((c) {
                      return DropdownMenuItem(
                        value: c['code'],
                        child: Text(c['label']!),
                      );
                    }).toList(),
                    onChanged: (code) {
                      if (code == null) return;
                      final cur = OnboardingController.currencies
                          .firstWhere((c) => c['code'] == code);
                      ctrl.selectCurrency(cur['symbol']!, cur['code']!);
                    },
                  ),
                ],
              )),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await widget.onNext();
                      setState(() => _loading = false);
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Créer mon profil →'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onBack,
              child: const Text('← Retour'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
// TODO Implement this library.