import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AppException implements Exception {
  final int code;
  final String message;
  const AppException(this.code, this.message);

  @override
  String toString() =>
      'An internal error occurred, if the error persists contact support (errCode: $code)';
}

class AppError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final int? code;

  AppError(this.message, this.type, {this.statusCode, this.code});

  static AppError tamperedWallet() {
    return AppError(
        "CRITICAL: YOUR INSTALLATION OF QUBIC WALLET IS TAMPERED. PLEASE UNINSTALL THE APP, DOWNLOAD IT FROM A TRUSTED SOURCE AND INSTALL IT AGAIN",
        ErrorType.tamperedWallet);
  }

  @override
  String toString() {
    String errorMessage = message;

    if (code != null) {
      errorMessage += ', ${l10nWrapper.l10n!.generalCode}: $code';
    }
    if (statusCode != null) {
      errorMessage += ' (${l10nWrapper.l10n!.generalStatusCode}: $statusCode)';
    }

    return errorMessage;
  }

  /// This consructor is used when the error comes from server (bad response).
  ///
  /// Here you can update it to handle server errors, according to the error model
  /// comes from back end.
  factory AppError.serverErrorParse(DioException error) {
    appLogger.e(error.response?.data?.toString() ?? "NULL");

    final responseData = error.response?.data;
    String serverMessage;
    int? code;

    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] ??
          l10nWrapper.l10n!.generalErrorUnexpectedError;
      code = responseData['code'];
    } else if (responseData is String) {
      serverMessage = responseData;
    } else {
      // Handling unexpected response formats (null, int, etc.)
      serverMessage = l10nWrapper.l10n!.generalErrorUnexpectedError;
    }

    return AppError(
      "${l10nWrapper.l10n!.generalErrorServerError}: $serverMessage",
      ErrorType.server,
      statusCode: error.response?.statusCode,
      code: code,
    );
  }
}

enum ErrorType {
  network,
  server,
  validation,
  format,
  unknown,
  tamperedWallet,
}

class ErrorHandler {
  static AppError handleError(Object? error) {
    appLogger.e(error.toString());
    appLogger.e("Error type:${error.runtimeType}");
    switch (error) {
      case DioException dioError:
        switch (dioError.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return AppError(l10nWrapper.l10n!.generalErrorConnectionTimeout,
                ErrorType.network);
          case DioExceptionType.connectionError:
            return AppError(l10nWrapper.l10n!.generalErrorNoInternetConnection,
                ErrorType.network);
          case DioExceptionType.badResponse:
            return AppError.serverErrorParse(dioError);
          case DioExceptionType.cancel:
            return AppError(l10nWrapper.l10n!.generalErrorRequestCancelled,
                ErrorType.network);
          case DioExceptionType.unknown:
          default:
            return AppError(l10nWrapper.l10n!.generalErrorUnexpectedError,
                ErrorType.unknown);
        }

      case TypeError _:
        return AppError(
            '${l10nWrapper.l10n!.generalErrorCouldntParseResponse}, $error',
            ErrorType.format);

      case SocketException _:
        return AppError(l10nWrapper.l10n!.generalErrorNoInternetConnection,
            ErrorType.network);

      case TimeoutException _:
        return AppError(
            l10nWrapper.l10n!.generalErrorConnectionTimeout, ErrorType.network);

      default:
        return AppError(error.toString(), ErrorType.unknown);
    }
  }
}
