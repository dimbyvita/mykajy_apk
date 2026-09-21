class UserProfile {
  final String firstName;
  final String lastName;
  final String avatarEmoji;
  final String currencySymbol;
  final String currencyCode;
  final String languageCode;
  final String themeKey;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.avatarEmoji,
    required this.currencySymbol,
    required this.currencyCode,
    required this.languageCode,
    required this.themeKey,
  });

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get displayName => '$firstName $lastName'.trim();

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? avatarEmoji,
    String? currencySymbol,
    String? currencyCode,
    String? languageCode,
    String? themeKey,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      languageCode: languageCode ?? this.languageCode,
      themeKey: themeKey ?? this.themeKey,
    );
  }
}
// TODO Implement this library.