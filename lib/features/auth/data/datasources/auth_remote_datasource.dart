import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<Map<String, dynamic>> loginWithGoogle(String idToken);

  Future<void> logout(String refreshToken);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({required String token, required String newPassword});

  Future<void> verifyEmail(String otp);

  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._dio)
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          clientId: kIsWeb ? 'placeholder.apps.googleusercontent.com' : null,
        );

  @override
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Login failed');
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
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Registration failed');
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post('/auth/google', data: {
        'id_token': idToken,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Google login failed');
    }
  }

  Future<String?> getGoogleIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.idToken;
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send reset email');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to reset password');
    }
  }

  @override
  Future<void> verifyEmail(String otp) async {
    try {
      await _dio.post('/auth/verify-email', data: {'otp': otp});
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Email verification failed');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': token,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw UnauthorizedException(message: e.message ?? 'Token refresh failed');
    }
  }
}
