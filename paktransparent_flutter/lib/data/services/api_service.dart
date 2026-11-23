import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';

/// Base HTTP client for all API calls.
/// Replaces the TypeScript axios-based API client.
/// Handles auth token injection, 401 responses, and retries.
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Track if a token refresh is in progress to avoid concurrent refreshes
  bool _isRefreshing = false;

  ApiService({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.apiTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConstants.apiTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject auth token from secure storage
          final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            // Attempt token refresh once
            _isRefreshing = true;
            try {
              final refreshToken =
                  await _secureStorage.read(key: AppConstants.keyRefreshToken);
              if (refreshToken != null) {
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: Options(headers: {'Authorization': ''}),
                );
                if (response.statusCode == 200) {
                  final newToken = response.data['data']['token'] as String?;
                  if (newToken != null) {
                    await _secureStorage.write(
                        key: AppConstants.keyAuthToken, value: newToken);
                    // Retry original request with new token
                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newToken';
                    final retryResponse =
                        await _dio.fetch(error.requestOptions);
                    handler.resolve(retryResponse);
                    return;
                  }
                }
              }
            } catch (_) {
              // Refresh failed — clear credentials
              await _clearCredentials();
            } finally {
              _isRefreshing = false;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _clearCredentials() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    await _secureStorage.delete(key: AppConstants.keyUserData);
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.patch<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) async {
    return _dio.delete<T>(path, options: options);
  }

  /// Upload multiple files with progress tracking.
  /// Replaces the TypeScript uploadMultiple method.
  Future<Response<T>> uploadFiles<T>(
    String path,
    List<File> files, {
    String fieldName = 'files',
    Map<String, String>? extraFields,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData();

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      formData.files.add(
        MapEntry(
          fieldName,
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    if (extraFields != null) {
      formData.fields.addAll(extraFields.entries.map((e) => MapEntry(e.key, e.value)));
    }

    return _dio.post<T>(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onProgress,
    );
  }

  /// Set the base URL (useful for switching between environments).
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}

/// Thrown when an API call fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Parse a DioException into a user-friendly ApiException.
ApiException handleDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return const ApiException('Request timed out. Please check your connection.');
  }
  if (e.type == DioExceptionType.connectionError) {
    return const ApiException('No internet connection.');
  }
  final statusCode = e.response?.statusCode;
  final message = e.response?.data?['error'] as String? ??
      e.response?.data?['message'] as String? ??
      'An error occurred';
  return ApiException(message, statusCode: statusCode, data: e.response?.data);
}
