import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_manager_linux_platform_interface.dart';

/// An implementation of [WindowManagerLinuxPlatform] that uses method channels.
class MethodChannelWindowManagerLinux extends WindowManagerLinuxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('window_manager_linux');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
