import 'package:no_screenshot/no_screenshot.dart';

class ScreenshotService {
  final _noScreenshot = NoScreenshot.instance;

  void disableScreenshot() {
    _noScreenshot.screenshotOff();
  }

  void enableScreenshot() {
    _noScreenshot.screenshotOn();
  }
}
