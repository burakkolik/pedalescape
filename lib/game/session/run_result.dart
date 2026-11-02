/// Outcome of a finished run, returned by `GameplayScreen` via
/// `Navigator.pop(context, result)`. Menus apply it to the player profile.
library;

import 'game_mode.dart';

class RunResult {
  const RunResult({
    required this.mode,
    required this.completed,
    required this.distanceMeters,
    required this.coins,
    required this.gems,
    required this.timeSeconds,
    this.levelNumber,
    this.starFinish = false,
    this.starCoins = false,
    this.starThird = false,
    this.crashes = 0,
    this.jumps = 0,
    this.ducks = 0,
    this.nearMisses = 0,
    this.powerUpsUsed = 0,
    this.bestCombo = 1,
    this.quitByUser = false,
  });

  final GameMode mode;
  final int? levelNumber;

  /// Mission: finish line reached. Endless/free ride: always false.
  final bool completed;
  final double distanceMeters;

  /// Coins already multiplied by bike/power-up multipliers.
  final int coins;
  final int gems;
  final double timeSeconds;

  final bool starFinish;
  final bool starCoins;
  final bool starThird;

  final int crashes;
  final int jumps;
  final int ducks;
  final int nearMisses;
  final int powerUpsUsed;
  final int bestCombo;

  /// The player left via the pause menu (rewards still apply).
  final bool quitByUser;

  int get stars => (starFinish ? 1 : 0) + (starCoins ? 1 : 0) + (starThird ? 1 : 0);
}
