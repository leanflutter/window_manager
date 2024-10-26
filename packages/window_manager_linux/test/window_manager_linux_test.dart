import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager_linux/window_manager_linux.dart';
import 'package:window_manager_linux/window_manager_linux_platform_interface.dart';
import 'package:window_manager_linux/window_manager_linux_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowManagerLinuxPlatform
    with MockPlatformInterfaceMixin
    implements WindowManagerLinuxPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WindowManagerLinuxPlatform initialPlatform = WindowManagerLinuxPlatform.instance;

  test('$MethodChannelWindowManagerLinux is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowManagerLinux>());
  });

  test('getPlatformVersion', () async {
    WindowManagerLinux windowManagerLinuxPlugin = WindowManagerLinux();
    MockWindowManagerLinuxPlatform fakePlatform = MockWindowManagerLinuxPlatform();
    WindowManagerLinuxPlatform.instance = fakePlatform;

    expect(await windowManagerLinuxPlugin.getPlatformVersion(), '42');
  });
}
