import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Call once in main() before runApp.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: false,
  );
}

/// Access the Supabase client anywhere.
SupabaseClient get supabase => Supabase.instance.client;

/// Riverpod provider for the Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current authenticated user (null if not logged in).
final currentSupabaseUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Stream of auth state changes.
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
