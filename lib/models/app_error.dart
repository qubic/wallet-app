import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AppError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final int? code;

  AppError(this.message, this.type, {this.statusCode, this.code});

  @override
  String toString() {
    String errorMessage = message;

    if (statusCode != null) {
      errorMessage += ', ${l10nWrapper.l10n!.generalStatusCode}: $statusCode';
    }
    if (code != null) {
      errorMessage += ', ${l10nWrapper.l10n!.generalCode}: $code';
    }

    return errorMessage;
  }

  /// This consructor is used when the error comes from server (bad response).
  ///
  /// Here you can update it to handle server errors, according to the error model
  /// comes from back end.
  factory AppError.serverErrorParse(DioException error) {
    appLogger.e(error.response?.data?.toString() ?? "NULL");
    final serverMessage = error.response?.data['message'] ??
        l10nWrapper.l10n!.generalErrorUnexpectedError;
    final code = error.response?.data['code'];
    return AppError(
        "${l10nWrapper.l10n!.generalErrorServerError}: $serverMessage",
        ErrorType.server,
        statusCode: error.response?.statusCode,
        code: code);
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
