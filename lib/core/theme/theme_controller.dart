import 'package:get/get.dart';

import 'app_themes.dart';

class ThemeController extends GetxController {
  final RxString _themeKey = 'light'.obs;

  String get themeKey => _themeKey.value;

  void setTheme(String key) {
    // Only accept valid themes
    const validThemes = [
      'light',
      'dark',
      'ocean',
      'rose',
    ];

    if (!validThemes.contains(key)) {
      key = 'light';
    }

    _themeKey.value = key;

    Get.changeTheme(
      AppThemes.fromKey(key),
    );
  }

  void toggleDarkMode() {
    setTheme(
      _themeKey.value == 'dark'
          ? 'light'
          : 'dark',
    );
  }
}