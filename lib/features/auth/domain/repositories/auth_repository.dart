import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<Either<Failure, UserEntity>> loginWithGoogle();

  Future<Either<Failure, UserEntity>> loginWithApple();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, void>> verifyEmail(String otp);

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, UserEntity>> refreshToken();
}
