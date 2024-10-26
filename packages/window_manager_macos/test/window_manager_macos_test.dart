import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager_macos/window_manager_macos.dart';
import 'package:window_manager_macos/window_manager_macos_platform_interface.dart';
import 'package:window_manager_macos/window_manager_macos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowManagerMacosPlatform
    with MockPlatformInterfaceMixin
    implements WindowManagerMacosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WindowManagerMacosPlatform initialPlatform = WindowManagerMacosPlatform.instance;

  test('$MethodChannelWindowManagerMacos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowManagerMacos>());
  });

  test('getPlatformVersion', () async {
    WindowManagerMacos windowManagerMacosPlugin = WindowManagerMacos();
    MockWindowManagerMacosPlatform fakePlatform = MockWindowManagerMacosPlatform();
    WindowManagerMacosPlatform.instance = fakePlatform;

    expect(await windowManagerMacosPlugin.getPlatformVersion(), '42');
  });
}
