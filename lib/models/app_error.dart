import 'dart:developer';

import 'package:dio/dio.dart';

class AppError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final int? code;

  AppError(this.message, this.type, {this.statusCode, this.code});

  @override
  String toString() =>
      'AppError(message: $message, type: $type, statusCode: $statusCode, code: $code)';

  /// This consructor is used when the error comes from server (bad response).
  ///
  /// Here you can update it to handle server errors, according to the error model
  /// comes from back end.
  factory AppError.serverErrorParse(DioException error) {
    log(error.response?.data?.toString() ?? "NULL",
        name: "AppError.serverErrorParse");
    final serverMessage = error.response?.data['message'] ?? "Not Defined";
    final code = error.response?.data['code'];
    return AppError("Server error: $serverMessage", ErrorType.server,
        statusCode: error.response?.statusCode, code: code);
  }
}

enum ErrorType {
  network,
  server,
  validation,
  format,
  unknown,
}

class ErrorHandler {
  static AppError handleError(Object? error) {
    log(error.toString());
    log(error.runtimeType.toString(), name: "Error type");
    if (error.runtimeType == DioException) {
      switch ((error as DioException).type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppError('Connection Timeout', ErrorType.network);
        case DioExceptionType.badResponse:
          return AppError.serverErrorParse(error);
        case DioExceptionType.cancel:
          return AppError('Request Cancelled', ErrorType.network);
        case DioExceptionType.unknown:
        default:
          return AppError('Unexpected Error', ErrorType.unknown);
      }
    } else if (error is TypeError) {
      return AppError('Could not parse response, $error', ErrorType.format);
    } else {
      return AppError(error.toString(), ErrorType.unknown);
    }
  }
}
