import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'network_exceptions.dart';

/// Centralized HTTP client configured with Bearer token authentication and error interceptors.
class ApiClient {
  static final ApiClient instance = ApiClient._internal();

  factory ApiClient() => instance;

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService.instance;
  void Function()? onUnauthorized;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.defaultBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
    _setupCertificatePinning();
  }

  /// Trust the Switch Fiber API server's self-signed certificate, and only that
  /// certificate.
  ///
  /// The server presents a self-signed cert with no Subject Alternative Name, so
  /// Dart's normal hostname verification can never pass for it, and adding the
  /// CA as a trusted root would not help. Instead the exact certificate is
  /// pinned by SHA-256 fingerprint: any other certificate, including a valid one
  /// swapped in by an attacker, is still rejected. Certificates that verify
  /// normally never reach this callback, so public HTTPS hosts are unaffected.
  ///
  /// If the server's certificate is ever reissued, this fingerprint must be
  /// updated or the app will refuse to connect.
  void _setupCertificatePinning() {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) =>
            _fingerprintOf(cert) == AppConstants.pinnedApiCertSha256;
        return client;
      },
    );
  }

  String _fingerprintOf(X509Certificate cert) => sha256
      .convert(cert.der)
      .bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(':')
      .toUpperCase();

  /// Update base URL dynamically (e.g., from technician settings)
  void setBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer token from secure storage if present
          final token = await _storage.getToken();
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Clear credentials on 401 Unauthorized, but keep the configured
            // base URL so the app still points at the right server afterwards.
            await _storage.clearCredentials();
            onUnauthorized?.call();
          }

          // Convert to domain-friendly ApiException
          final apiException = ApiException.fromDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiException,
              message: apiException.message,
            ),
          );
        },
      ),
    );
  }

  /// GET helper
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// POST helper
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT helper
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE helper
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioException(e);
    }
  }
}
