/// Loads, holds and persists [AppSettings]. Listen to it (ChangeNotifier) to
/// react to language / audio changes. Side effects such as muting audio are
/// wired by the app layer (see `lib/app/bootstrap.dart`).
library;

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../storage/local_storage.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository(this._storage);

  /// App-wide instance, assigned in `bootstrap()` (and in tests).
  static late SettingsRepository instance;

  static const String storageKey = 'settings.v1';

  final LocalStorage _storage;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  Future<void> load() async {
    final json = _storage.readJson(storageKey);
    _settings = json == null ? const AppSettings() : AppSettings.fromJson(json);
    notifyListeners();
  }

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    _settings = change(_settings);
    notifyListeners();
    await _storage.writeJson(storageKey, _settings.toJson());
  }
}
