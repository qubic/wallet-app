import 'package:logger/logger.dart';

/// A logger instance that uses a custom printer to format log messages with colors
/// and emojis, only in debug mode.
///
///  The logger uses the following log levels with corresponding emojis:
/// - debug (🐛): Information useful for developers during development.
/// - info (ℹ️): General informational messages.
/// - warning (⚠️):  Potentially harmful situations which still allow the application to continue running.
/// - error (❌): Error events that might still allow the application to continue running.
/// - fatal (🔥):  Severe error events that when logged indicate a serious problem.
///
/// Example usage:
/// ```dart
/// appLogger.d('This is a debug message.');
/// appLogger.i('This is an info message.');
/// appLogger.w('This is a warning message.');
/// appLogger.e('This is an error message.');
///
final appLogger = Logger(
  printer: CustomPrinter(),
  filter: null,
  output: null,
);

class CustomPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final colors = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;
    return [colors!('$emoji: $message')];
  }
}
