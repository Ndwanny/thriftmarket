import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/supabase/supabase_config.dart';

abstract class AuthSupabaseDataSource {
  Future<Map<String, dynamic>> loginWithEmail(
      {required String email, required String password});

  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<Map<String, dynamic>?> loginWithGoogle();

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<Map<String, dynamic>?> getCurrentUser();

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  });
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  @override
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException(message: 'Login failed');
      }
      return _buildUserMap(response.user!);
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, if (phone != null) 'phone': phone},
      );
      if (response.user == null) {
        throw const ServerException(message: 'Registration failed');
      }
      // Profile is auto-created by the handle_new_user() trigger in Supabase
      return _buildUserMap(response.user!);
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      // OAuth redirects — user will be set after redirect
      return null;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Fetch profile from DB
    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null) {
        return {..._buildUserMap(user), ...profile};
      }
    } catch (_) {}
    return _buildUserMap(user);
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'id': userId,
      'updated_at': DateTime.now().toIso8601String(),
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    final result = await supabase
        .from('profiles')
        .upsert(updates)
        .select()
        .single();
    return result;
  }

  Map<String, dynamic> _buildUserMap(User user) {
    return {
      'id': user.id,
      'email': user.email ?? '',
      'full_name': user.userMetadata?['full_name'] ?? '',
      'phone': user.userMetadata?['phone'] ?? user.phone ?? '',
      'avatar_url': user.userMetadata?['avatar_url'],
      'is_email_verified': user.emailConfirmedAt != null,
      'created_at': user.createdAt,
    };
  }
}
