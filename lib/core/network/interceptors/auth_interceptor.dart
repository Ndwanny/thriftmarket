import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._dio, this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken =
            await _secureStorage.read(AppConstants.refreshTokenKey);
        if (refreshToken == null) {
          _clearTokensAndRedirect();
          handler.next(err);
          return;
        }

        final response = await _dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await _secureStorage.write(AppConstants.accessTokenKey, newAccessToken);
        await _secureStorage.write(
            AppConstants.refreshTokenKey, newRefreshToken);

        // Retry pending requests
        for (final pendingRequest in _pendingRequests) {
          pendingRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          await _dio.fetch(pendingRequest);
        }
        _pendingRequests.clear();

        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final cloneReq = await _dio.fetch(opts);
        handler.resolve(cloneReq);
      } catch (e) {
        _clearTokensAndRedirect();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  void _clearTokensAndRedirect() async {
    await _secureStorage.delete(AppConstants.accessTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
    // Navigation handled by auth state listener in app router
  }
}
