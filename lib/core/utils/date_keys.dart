/// Local calendar-day helpers. Day boundaries use the device's local time so
/// "come back tomorrow" matches the player's midnight.
library;

abstract final class DateKeys {
  /// `yyyy-MM-dd` key of the local day containing [time].
  static String of(DateTime time) {
    final t = time.toLocal();
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    return '${t.year}-$m-$d';
  }

  /// Key of the day before [time].
  static String yesterdayOf(DateTime time) {
    final t = time.toLocal();
    return of(DateTime(t.year, t.month, t.day - 1, 12));
  }

  /// Parses a key back to local midnight; null if malformed.
  static DateTime? parse(String? key) {
    if (key == null) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Whole calendar days between two keys (b - a). Null if either is invalid.
  static int? daysBetween(String? a, String? b) {
    final da = parse(a);
    final db = parse(b);
    if (da == null || db == null) return null;
    // Use noon to avoid DST off-by-one.
    final na = DateTime.utc(da.year, da.month, da.day, 12);
    final nb = DateTime.utc(db.year, db.month, db.day, 12);
    return nb.difference(na).inDays;
  }

  /// Time left until the next local midnight.
  static Duration untilMidnight(DateTime now) {
    final t = now.toLocal();
    final next = DateTime(t.year, t.month, t.day + 1);
    return next.difference(t);
  }

  /// Stable integer seed for a day key (used for deterministic daily content).
  static int seedOf(String key) {
    var h = 17;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }
}
