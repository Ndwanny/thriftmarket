import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// Login use case
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.loginWithEmail(email: email, password: password);
}

// Register use case
class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      _repository.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
}

// Google login use case
class LoginWithGoogleUseCase {
  final AuthRepository _repository;
  LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() => _repository.loginWithGoogle();
}

// Apple login use case
class LoginWithAppleUseCase {
  final AuthRepository _repository;
  LoginWithAppleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() => _repository.loginWithApple();
}

// Logout use case
class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.logout();
}

// Forgot password use case
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) =>
      _repository.forgotPassword(email);
}

// Get current user use case
class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() => _repository.getCurrentUser();
}
