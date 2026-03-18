import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('Initialize SharedPreferences first');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences first');
});

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // String
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // Int
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  // Bool
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  // JSON object
  Future<bool> setObject(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // JSON list
  Future<bool> setList(String key, List<dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  List<dynamic>? getList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as List<dynamic>;
  }

  // Remove
  Future<bool> remove(String key) => _prefs.remove(key);

  // Clear all
  Future<bool> clear() => _prefs.clear();

  // Contains
  bool containsKey(String key) => _prefs.containsKey(key);
}
