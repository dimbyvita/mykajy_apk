import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingStep4Completion extends StatefulWidget {
  final Future<void> Function() onStart;

  const OnboardingStep4Completion({super.key, required this.onStart});

  @override
  State<OnboardingStep4Completion> createState() =>
      _OnboardingStep4CompletionState();
}

class _OnboardingStep4CompletionState
    extends State<OnboardingStep4Completion>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _confettiOpacity;
  late Animation<Offset> _confettiSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _confettiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiCtrl, curve: Curves.easeIn),
    );
    _confettiSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _confettiCtrl, curve: Curves.easeOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    // Staggered sequence
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _checkCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _confettiCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _textCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();
    final firstName = ctrl.firstNameController.text.trim().isEmpty
        ? 'vous'
        : ctrl.firstNameController.text.trim();
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big check
          FadeTransition(
            opacity: _checkOpacity,
            child: ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFF1EAD6F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Confetti
          SlideTransition(
            position: _confettiSlide,
            child: FadeTransition(
              opacity: _confettiOpacity,
              child: const Text(
                '🎉  🌟  🎊',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Text
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  Text(
                    'Bienvenue, $firstName !',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Votre profil est prêt.\nCommencez à suivre vos finances dès maintenant.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          FadeTransition(
            opacity: _textOpacity,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onStart,
                child: const Text('Accéder au dashboard 🚀'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// TODO Implement this library.