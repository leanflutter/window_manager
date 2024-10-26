import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_manager_linux_method_channel.dart';

abstract class WindowManagerLinuxPlatform extends PlatformInterface {
  /// Constructs a WindowManagerLinuxPlatform.
  WindowManagerLinuxPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowManagerLinuxPlatform _instance = MethodChannelWindowManagerLinux();

  /// The default instance of [WindowManagerLinuxPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowManagerLinux].
  static WindowManagerLinuxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowManagerLinuxPlatform] when
  /// they register themselves.
  static set instance(WindowManagerLinuxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
