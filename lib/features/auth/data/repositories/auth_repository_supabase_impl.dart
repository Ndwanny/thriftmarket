import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_supabase_datasource.dart';
import '../models/user_model.dart';

class AuthRepositorySupabaseImpl implements AuthRepository {
  final AuthSupabaseDataSource _dataSource;

  AuthRepositorySupabaseImpl(this._dataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _dataSource.loginWithEmail(
        email: email,
        password: password,
      );
      return Right(_userFromMap(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
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
      final data = await _dataSource.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      return Right(_userFromMap(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final data = await _dataSource.loginWithGoogle();
      if (data == null) {
        // OAuth redirect in progress
        return Left(const ServerFailure(message: 'Redirecting to Google...'));
      }
      return Right(_userFromMap(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _dataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final data = await _dataSource.getCurrentUser();
      if (data == null) return const Right(null);
      return Right(_userFromMap(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithApple() async {
    return Left(const ServerFailure(message: 'Apple Sign-In not supported on this platform'));
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return Left(const ServerFailure(message: 'Use the link sent to your email to reset your password'));
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String otp) async {
    return const Right(null); // Supabase handles email verification via link
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Right(null); // Supabase sends it automatically on signup
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final data = await _dataSource.getCurrentUser();
      return Right(data != null);
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    try {
      final data = await _dataSource.getCurrentUser();
      if (data == null) return Left(const ServerFailure(message: 'Not logged in'));
      return Right(_userFromMap(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  UserEntity _userFromMap(Map<String, dynamic> data) {
    return UserModel.fromJson(data);
  }
}
