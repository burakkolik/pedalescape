/// Injectable wall clock. Services read time through [AppClock.now] so tests
/// can freeze or move time (daily rewards, wheel cooldowns, tasks).
library;

typedef NowProvider = DateTime Function();

abstract final class AppClock {
  static NowProvider _now = DateTime.now;

  static DateTime now() => _now();

  /// Overrides the clock (tests only). Pass null to restore the real clock.
  static void override(NowProvider? provider) => _now = provider ?? DateTime.now;
}
