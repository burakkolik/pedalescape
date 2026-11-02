/// The 15 languages shipped with the game, with their native display names
/// (used by the settings language picker – never translated).
library;

import 'package:flutter/widgets.dart';

class SupportedLanguage {
  const SupportedLanguage(this.code, this.nativeName, {this.isRtl = false});

  /// ISO 639-1 language code; matches `app_<code>.arb`.
  final String code;

  /// Name of the language written in that language.
  final String nativeName;
  final bool isRtl;

  Locale get locale => Locale(code);
}

abstract final class SupportedLanguages {
  static const String fallbackCode = 'en';

  static const List<SupportedLanguage> all = [
    SupportedLanguage('en', 'English'),
    SupportedLanguage('tr', 'Türkçe'),
    SupportedLanguage('de', 'Deutsch'),
    SupportedLanguage('es', 'Español'),
    SupportedLanguage('pt', 'Português'),
    SupportedLanguage('ru', 'Русский'),
    SupportedLanguage('hi', 'हिन्दी'),
    SupportedLanguage('id', 'Bahasa Indonesia'),
    SupportedLanguage('ja', '日本語'),
    SupportedLanguage('fr', 'Français'),
    SupportedLanguage('ko', '한국어'),
    SupportedLanguage('ar', 'العربية', isRtl: true),
    SupportedLanguage('pl', 'Polski'),
    // Traditional Chinese (all zh* device locales map here).
    SupportedLanguage('zh', '繁體中文'),
    SupportedLanguage('it', 'Italiano'),
  ];

  static List<Locale> get locales => [for (final l in all) l.locale];

  static bool isSupported(String? code) => all.any((l) => l.code == code);

  static SupportedLanguage byCode(String? code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);
}
