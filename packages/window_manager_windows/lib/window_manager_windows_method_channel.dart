import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_manager_windows_platform_interface.dart';

/// An implementation of [WindowManagerWindowsPlatform] that uses method channels.
class MethodChannelWindowManagerWindows extends WindowManagerWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('window_manager_windows');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
