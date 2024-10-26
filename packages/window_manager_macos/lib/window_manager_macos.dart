
import 'window_manager_macos_platform_interface.dart';

class WindowManagerMacos {
  Future<String?> getPlatformVersion() {
    return WindowManagerMacosPlatform.instance.getPlatformVersion();
  }
}
