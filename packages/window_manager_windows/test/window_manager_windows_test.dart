import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager_windows/window_manager_windows.dart';
import 'package:window_manager_windows/window_manager_windows_platform_interface.dart';
import 'package:window_manager_windows/window_manager_windows_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowManagerWindowsPlatform
    with MockPlatformInterfaceMixin
    implements WindowManagerWindowsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WindowManagerWindowsPlatform initialPlatform = WindowManagerWindowsPlatform.instance;

  test('$MethodChannelWindowManagerWindows is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowManagerWindows>());
  });

  test('getPlatformVersion', () async {
    WindowManagerWindows windowManagerWindowsPlugin = WindowManagerWindows();
    MockWindowManagerWindowsPlatform fakePlatform = MockWindowManagerWindowsPlatform();
    WindowManagerWindowsPlatform.instance = fakePlatform;

    expect(await windowManagerWindowsPlugin.getPlatformVersion(), '42');
  });
}
