import 'package:logger/logger.dart';

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
