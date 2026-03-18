import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveTokens(data);
      await _saveUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: 401));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final data = await _remoteDataSource.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveTokens(data);
      await _saveUser(user);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final idToken = await (_remoteDataSource as AuthRemoteDataSourceImpl)
          .getGoogleIdToken();
      if (idToken == null) {
        return Left(AuthFailure(message: 'Google sign-in cancelled'));
      }
      final data = await _remoteDataSource.loginWithGoogle(idToken);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveTokens(data);
      await _saveUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithApple() async {
    return Left(ServerFailure(message: 'Apple login coming soon'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken =
          await _secureStorage.read(AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken);
      }
      await _secureStorage.deleteAll();
      return const Right(null);
    } catch (e) {
      await _secureStorage.deleteAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(token: token, newPassword: newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String otp) async {
    try {
      await _remoteDataSource.verifyEmail(otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(AppConstants.userKey);
      if (userJson == null) return const Right(null);
      final user = UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load user'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    return Right(token != null && token.isNotEmpty);
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    try {
      final token = await _secureStorage.read(AppConstants.refreshTokenKey);
      if (token == null) {
        return Left(AuthFailure(message: 'No refresh token'));
      }
      final data = await _remoteDataSource.refreshToken(token);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveTokens(data);
      await _saveUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: 401));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _secureStorage.write(
        AppConstants.accessTokenKey, data['access_token'] as String);
    await _secureStorage.write(
        AppConstants.refreshTokenKey, data['refresh_token'] as String);
  }

  Future<void> _saveUser(UserModel user) async {
    await _secureStorage.write(
        AppConstants.userKey, jsonEncode(user.toJson()));
  }
}
