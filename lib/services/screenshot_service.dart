import 'dart:async';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:no_screenshot/screenshot_snapshot.dart';

class ScreenshotService {
  final _noScreenshot = NoScreenshot.instance;

  StreamSubscription<ScreenshotSnapshot>? _subscription;

  /// Disable screenshot and screen recording
  Future<void> disableScreenshot() async {
    await _noScreenshot.screenshotOff();
  }

  /// Enable screenshot and screen recording
  Future<void> enableScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  /// Toggle screenshot state
  Future<void> toggleScreenshot() async {
    await _noScreenshot.toggleScreenshot();
  }

  /// Start listening to screenshot events
  Future<void> startListening({
    required void Function(ScreenshotSnapshot event) onScreenshot,
  }) async {
    await _noScreenshot.startScreenshotListening();
    _subscription = _noScreenshot.screenshotStream.listen(onScreenshot);
  }

  /// Stop listening to screenshot events
  Future<void> stopListening() async {
    await _noScreenshot.stopScreenshotListening();
    await _subscription?.cancel();
    _subscription = null;
  }
}
