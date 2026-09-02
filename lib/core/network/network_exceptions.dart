import 'package:dio/dio.dart';

/// Standardized application network exception.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    String message = 'An unexpected network error occurred.';
    int? status = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Connection timed out. Please check your internet connection.';
        status = 408;
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            message = data['message'].toString();
          } else if (data['title'] != null) {
            message = data['title'].toString();
          }

          // Handle ASP.NET ModelState validation error dictionaries
          if (data['errors'] is Map<String, dynamic>) {
            final errMap = data['errors'] as Map<String, dynamic>;
            final fieldErrors = <String>[];
            errMap.forEach((key, val) {
              if (val is List) {
                fieldErrors.add('$key: ${val.join(", ")}');
              } else {
                fieldErrors.add('$key: $val');
              }
            });
            if (fieldErrors.isNotEmpty) {
              message = '$message (${fieldErrors.join(" | ")})';
            }
          }
        } else if (data is String && data.isNotEmpty) {
          message = data;
        } else {
          message = 'Server returned error ($status).';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to Switch Fiber servers. You may be offline.';
        break;
      case DioExceptionType.unknown:
      default:
        message = error.message ?? 'An unknown network error occurred.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: status,
      details: error.response?.data,
    );
  }

  @override
  String toString() => message;
}
