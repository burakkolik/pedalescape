import 'package:shared_preferences/shared_preferences.dart';

/// Small persistent store. Only a handful of primitive values are kept, so the
/// app's on-disk footprint stays tiny and never grows over time.
class Storage {
  Storage._(this._p);

  final SharedPreferences? _p;

  static Future<Storage> open() async {
    try {
      return Storage._(await SharedPreferences.getInstance());
    } catch (_) {
      // Storage unavailable (tests / broken platform channel): run in memory.
      return Storage._(null);
    }
  }

  /// In-memory store for tests.
  factory Storage.memory() => Storage._(null);

  final Map<String, Object> _mem = {};

  int _int(String k, int d) => _p?.getInt(k) ?? (_mem[k] as int?) ?? d;
  bool _bool(String k, bool d) => _p?.getBool(k) ?? (_mem[k] as bool?) ?? d;
  String _str(String k, String d) => _p?.getString(k) ?? (_mem[k] as String?) ?? d;

  void _setInt(String k, int v) {
    _mem[k] = v;
    _p?.setInt(k, v);
  }

  void _setBool(String k, bool v) {
    _mem[k] = v;
    _p?.setBool(k, v);
  }

  void _setStr(String k, String v) {
    _mem[k] = v;
    _p?.setString(k, v);
  }

  int get best => _int('best', 0);
  set best(int v) => _setInt('best', v);

  int get bestDistance => _int('bestDist', 0);
  set bestDistance(int v) => _setInt('bestDist', v);

  int get wallet => _int('wallet', 0);
  set wallet(int v) => _setInt('wallet', v);

  int get runs => _int('runs', 0);
  set runs(int v) => _setInt('runs', v);

  int get totalCoins => _int('totalCoins', 0);
  set totalCoins(int v) => _setInt('totalCoins', v);

  int get totalDistance => _int('totalDist', 0);
  set totalDistance(int v) => _setInt('totalDist', v);

  /// -1 = automatic, otherwise index into Quality.levels.
  int get quality => _int('quality', -1);
  set quality(int v) => _setInt('quality', v);

  bool get haptics => _bool('haptics', true);
  set haptics(bool v) => _setBool('haptics', v);

  bool get highFps => _bool('highFps', false);
  set highFps(bool v) => _setBool('highFps', v);

  bool get tutorialSeen => _bool('tutorial', false);
  set tutorialSeen(bool v) => _setBool('tutorial', v);

  String get skin => _str('skin', 'classic');
  set skin(String v) => _setStr('skin', v);

  Set<String> get owned => {'classic', ..._str('owned', '').split(',').where((e) => e.isNotEmpty)};
  void addOwned(String id) => _setStr('owned', (owned..add(id)).join(','));

  /// Completed mission ids.
  Set<String> get missionsDone => _str('missions', '').split(',').where((e) => e.isNotEmpty).toSet();
  void completeMission(String id) => _setStr('missions', (missionsDone..add(id)).join(','));
}
