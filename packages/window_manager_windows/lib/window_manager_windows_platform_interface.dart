import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_manager_windows_method_channel.dart';

abstract class WindowManagerWindowsPlatform extends PlatformInterface {
  /// Constructs a WindowManagerWindowsPlatform.
  WindowManagerWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowManagerWindowsPlatform _instance = MethodChannelWindowManagerWindows();

  /// The default instance of [WindowManagerWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowManagerWindows].
  static WindowManagerWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowManagerWindowsPlatform] when
  /// they register themselves.
  static set instance(WindowManagerWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
