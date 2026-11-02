/// Maps device locales to one of the supported languages.
///
/// Rules: match by language code only; any `zh*` (zh, zh-Hant, zh-TW, zh-CN…)
/// maps to our single Traditional Chinese translation; unknown → English.
/// Codes are also filtered by what the generated `AppLocalizations` actually
/// ships, so a missing ARB file can never crash the app.
library;

import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'supported_languages.dart';

abstract final class LocaleResolver {
  /// Language codes that both we and the generated localizations support.
  static Set<String> get availableCodes {
    final generated = {
      for (final l in AppLocalizations.supportedLocales) l.languageCode,
    };
    return {
      for (final l in SupportedLanguages.all)
        if (generated.contains(l.code)) l.code,
    };
  }

  /// Supported language code for a single [locale] or null if unsupported.
  static String? codeFor(Locale? locale) {
    if (locale == null) return null;
    var code = locale.languageCode.toLowerCase();
    if (code.startsWith('zh')) code = 'zh';
    if (code == 'in') code = 'id'; // legacy Java code for Indonesian
    return availableCodes.contains(code) ? code : null;
  }

  /// Resolves the best locale from the device's preference list.
  static Locale resolve(List<Locale>? deviceLocales) {
    for (final l in deviceLocales ?? const <Locale>[]) {
      final code = codeFor(l);
      if (code != null) return Locale(code);
    }
    return const Locale(SupportedLanguages.fallbackCode);
  }

  /// Locale for an explicit settings override, or null to follow the device.
  static Locale? overrideLocale(String? languageCode) {
    if (languageCode == null) return null;
    return availableCodes.contains(languageCode) ? Locale(languageCode) : null;
  }

  /// Locales passed to `MaterialApp.supportedLocales`.
  static List<Locale> get supportedLocales => [
        for (final l in SupportedLanguages.all)
          if (availableCodes.contains(l.code)) l.locale,
      ];
}
