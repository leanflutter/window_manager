import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_manager_macos_method_channel.dart';

abstract class WindowManagerMacosPlatform extends PlatformInterface {
  /// Constructs a WindowManagerMacosPlatform.
  WindowManagerMacosPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowManagerMacosPlatform _instance = MethodChannelWindowManagerMacos();

  /// The default instance of [WindowManagerMacosPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowManagerMacos].
  static WindowManagerMacosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowManagerMacosPlatform] when
  /// they register themselves.
  static set instance(WindowManagerMacosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
