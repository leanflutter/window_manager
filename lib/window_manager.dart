
import 'dart:async';

import 'package:flutter/services.dart';

class WindowManager {
  static const MethodChannel _channel =
      const MethodChannel('window_manager');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
