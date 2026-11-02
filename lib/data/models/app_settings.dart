/// Player preferences (immutable). Persisted by `SettingsRepository`.
library;

import '../../game/session/run_config.dart';

class AppSettings {
  const AppSettings({
    this.languageCode,
    this.sfxEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.graphics = GraphicsQuality.high,
    this.swipeSensitivity = 0.5,
    this.onboardingDone = false,
    this.tutorialDone = false,
  });

  /// Explicit language override; null = follow the phone language.
  final String? languageCode;
  final bool sfxEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final GraphicsQuality graphics;

  /// 0..1 (see [GameplaySettings.swipeSensitivity]).
  final double swipeSensitivity;
  final bool onboardingDone;
  final bool tutorialDone;

  static const int schemaVersion = 1;

  AppSettings copyWith({
    String? Function()? languageCode,
    bool? sfxEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    GraphicsQuality? graphics,
    double? swipeSensitivity,
    bool? onboardingDone,
    bool? tutorialDone,
  }) =>
      AppSettings(
        languageCode: languageCode != null ? languageCode() : this.languageCode,
        sfxEnabled: sfxEnabled ?? this.sfxEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        graphics: graphics ?? this.graphics,
        swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        tutorialDone: tutorialDone ?? this.tutorialDone,
      );

  /// Gameplay-facing subset.
  GameplaySettings toGameplay() => GameplaySettings(
        graphics: graphics,
        swipeSensitivity: swipeSensitivity,
        vibration: vibrationEnabled,
        showTutorial: !tutorialDone,
      );

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'lang': languageCode,
        'sfx': sfxEnabled,
        'music': musicEnabled,
        'vib': vibrationEnabled,
        'gfx': graphics.name,
        'swipe': swipeSensitivity,
        'onb': onboardingDone,
        'tut': tutorialDone,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        languageCode: j['lang'] as String?,
        sfxEnabled: j['sfx'] as bool? ?? true,
        musicEnabled: j['music'] as bool? ?? true,
        vibrationEnabled: j['vib'] as bool? ?? true,
        graphics: GraphicsQuality.values.firstWhere(
          (g) => g.name == j['gfx'],
          orElse: () => GraphicsQuality.high,
        ),
        swipeSensitivity: ((j['swipe'] as num?)?.toDouble() ?? 0.5).clamp(0.0, 1.0),
        onboardingDone: j['onb'] as bool? ?? false,
        tutorialDone: j['tut'] as bool? ?? false,
      );
}
