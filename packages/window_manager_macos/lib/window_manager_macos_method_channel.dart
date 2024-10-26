import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_manager_macos_platform_interface.dart';

/// An implementation of [WindowManagerMacosPlatform] that uses method channels.
class MethodChannelWindowManagerMacos extends WindowManagerMacosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('window_manager_macos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
