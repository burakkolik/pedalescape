/// Thin wrapper around `shared_preferences` that stores JSON documents under
/// versioned keys (e.g. `profile.v1`). Repositories are the only users.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> open() async =>
      LocalStorage._(await SharedPreferences.getInstance());

  /// Reads a JSON object; returns null if missing or corrupt.
  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      debugPrint('LocalStorage: corrupt "$key" ignored ($e)');
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);
}
