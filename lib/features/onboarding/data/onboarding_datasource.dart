import 'package:hive_flutter/hive_flutter.dart';

class OnboardingDatasource {
  static const boxName = 'prefs';
  static const _kDone = 'onboarding_done';
  static const _kFirstName = 'first_name';
  static const _kLastName = 'last_name';
  static const _kAvatar = 'avatar_emoji';
  static const _kCurrencySymbol = 'currency_symbol';
  static const _kCurrencyCode = 'currency_code';
  static const _kLanguage = 'language_code';
  static const _kTheme = 'theme_key';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  bool get isOnboardingDone => _box.get(_kDone, defaultValue: false) as bool;

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String avatarEmoji,
    required String currencySymbol,
    required String currencyCode,
    required String languageCode,
    required String themeKey,
  }) async {
    await _box.putAll({
      _kFirstName: firstName,
      _kLastName: lastName,
      _kAvatar: avatarEmoji,
      _kCurrencySymbol: currencySymbol,
      _kCurrencyCode: currencyCode,
      _kLanguage: languageCode,
      _kTheme: themeKey,
      _kDone: true,
    });
  }

  String get firstName => _box.get(_kFirstName, defaultValue: '') as String;
  String get lastName => _box.get(_kLastName, defaultValue: '') as String;
  String get avatarEmoji => _box.get(_kAvatar, defaultValue: '') as String;
  String get currencySymbol =>
      _box.get(_kCurrencySymbol, defaultValue: '€') as String;
  String get currencyCode =>
      _box.get(_kCurrencyCode, defaultValue: 'EUR') as String;
  String get languageCode =>
      _box.get(_kLanguage, defaultValue: 'fr') as String;
  String get themeKey =>
      _box.get(_kTheme, defaultValue: 'light') as String;

  Future<void> reset() => _box.clear();
}
// TODO Implement this library.