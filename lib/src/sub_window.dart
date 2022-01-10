import 'dart:ui';

import 'window_manager.dart';

class SubWindow {
  static Future<SubWindow> create({
    Size? size,
    Offset? position,
    bool center = true,
    required String title,
  }) async {
    SubWindow subWindow = SubWindow();
    windowManager.createSubWindow(
      size: size,
      position: position,
      center: center,
      title: title,
    );
    return subWindow;
  }
}
