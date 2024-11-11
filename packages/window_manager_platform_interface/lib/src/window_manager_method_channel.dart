import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager_platform_interface/src/window_manager_platform_interface.dart';

/// An implementation of [WindowManagerPlatform] that uses method channels.
class MethodChannelWindowManager extends WindowManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('window_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
