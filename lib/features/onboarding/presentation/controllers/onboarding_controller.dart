import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../data/onboarding_datasource.dart';
import '../../domain/entities/user_profile.dart';

class OnboardingController extends GetxController {
  final OnboardingDatasource _datasource;

  OnboardingController({required OnboardingDatasource datasource})
      : _datasource = datasource;

  // ── Step ──────────────────────────────────────────────────────────
  final currentStep = 1.obs;
  static const totalSteps = 4;

  // ── Selections ────────────────────────────────────────────────────
  final selectedLanguage = 'fr'.obs;
  final selectedTheme = 'light'.obs;
  final selectedEmoji = ''.obs;
  final selectedCurrencySymbol = '€'.obs;
  final selectedCurrencyCode = 'EUR'.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // ── Derived ───────────────────────────────────────────────────────
  String get avatarDisplay {
    if (selectedEmoji.value.isNotEmpty) return selectedEmoji.value;
    final name = firstNameController.text.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get avatarIsPicked =>
      selectedEmoji.value.isNotEmpty || firstNameController.text.isNotEmpty;

  // ── Static data ───────────────────────────────────────────────────
  static const languages = [
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français', 'native': 'Français'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'native': 'English'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español', 'native': 'Español'},
    {'code': 'mg', 'flag': '🇲🇬', 'name': 'Malagasy', 'native': 'Malagasy'},
    {'code': 'ar', 'flag': '🇸🇦', 'name': 'العربية', 'native': 'Arabic'},
    {'code': 'pt', 'flag': '🇧🇷', 'name': 'Português', 'native': 'Português'},
  ];

  static const themes = [
    {'key': 'light', 'name': 'Clair', 'desc': 'Propre & moderne'},
    {'key': 'dark', 'name': 'Sombre', 'desc': 'Repose les yeux'},
    {'key': 'ocean', 'name': 'Océan', 'desc': 'Apaisant & frais'},
    {'key': 'rose', 'name': 'Rose', 'desc': 'Doux & élégant'},
  ];

  static const currencies = [
    {'symbol': '€', 'code': 'EUR', 'label': '€ — Euro'},
    {'symbol': '\$', 'code': 'USD', 'label': '\$ — Dollar US'},
    {'symbol': 'Ar', 'code': 'MGA', 'label': 'Ar — Ariary malgache'},
    {'symbol': '£', 'code': 'GBP', 'label': '£ — Livre sterling'},
    {'symbol': '₣', 'code': 'XOF', 'label': '₣ — Franc CFA'},
  ];

  static const avatarEmojis = ['🦁', '🐻', '🦊', '🐧', '🐳', '🦋'];

  // ── Actions ───────────────────────────────────────────────────────
  void selectLanguage(String code) => selectedLanguage.value = code;

  void selectTheme(String key) {
    selectedTheme.value = key;
    Get.find<ThemeController>().setTheme(key);
  }

  void selectEmoji(String emoji) => selectedEmoji.value = emoji;

  void selectCurrency(String symbol, String code) {
    selectedCurrencySymbol.value = symbol;
    selectedCurrencyCode.value = code;
  }

  void nextStep() {
    if (currentStep.value < totalSteps) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  Future<void> completeOnboarding() async {
    await _datasource.saveProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      avatarEmoji: selectedEmoji.value,
      currencySymbol: selectedCurrencySymbol.value,
      currencyCode: selectedCurrencyCode.value,
      languageCode: selectedLanguage.value,
      themeKey: selectedTheme.value,
    );
    nextStep();
  }

  Future<void> goToDashboard() async {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  UserProfile get userProfile => UserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        avatarEmoji: selectedEmoji.value,
        currencySymbol: selectedCurrencySymbol.value,
        currencyCode: selectedCurrencyCode.value,
        languageCode: selectedLanguage.value,
        themeKey: selectedTheme.value,
      );

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}
// TODO Implement this library.