import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:window_manager_platform_interface/src/window_manager_method_channel.dart';

abstract class WindowManagerPlatform extends PlatformInterface {
  /// Constructs a WindowManagerPlatform.
  WindowManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowManagerPlatform _instance = MethodChannelWindowManager();

  /// The default instance of [WindowManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowManager].
  static WindowManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowManagerPlatform] when
  /// they register themselves.
  static set instance(WindowManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
