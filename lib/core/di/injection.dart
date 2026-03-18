import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/local_storage.dart';

Future<void> configureDependencies() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  _sharedPreferences = prefs;
}

SharedPreferences? _sharedPreferences;

// Override providers after initialization
List<Override> getProviderOverrides() {
  return [
    sharedPreferencesProvider.overrideWithValue(_sharedPreferences!),
    localStorageProvider.overrideWithValue(LocalStorage(_sharedPreferences!)),
  ];
}
