// The taskbar progress and badge of package:window_manager/legacy.dart.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/legacy.dart';

// A nativeapi window simulated in Dart; no native window is created.
class _FakeNativeWindow extends nativeapi.Window {
  _FakeNativeWindow() : super.borrowed(0);
}

// Only the primary window and taskbar calls the bridge makes; any other
// member throws.
class _FakeApplication implements nativeapi.Application {
  nativeapi.Window? primaryWindow;
  final List<String> calls = <String>[];

  @override
  nativeapi.Window? getPrimaryWindow() => primaryWindow;

  @override
  void setPrimaryWindow(nativeapi.Window? window) {
    calls.add('setPrimaryWindow');
    primaryWindow = window;
  }

  @override
  bool setProgressBar(double progress) {
    calls.add('setProgressBar($progress)');
    return true;
  }

  @override
  bool setBadgeLabel(String label) {
    calls.add('setBadgeLabel($label)');
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeApplication application;

  setUp(() {
    application = _FakeApplication();
    windowManager.debugApplicationOverride = application;
  });

  tearDown(() {
    windowManager.debugApplicationOverride = null;
    windowManager.debugBindWindow(null);
  });

  test('progress and badge designate the window as primary', () async {
    final window = _FakeNativeWindow();
    windowManager.debugBindWindow(window);

    await windowManager.setProgressBar(0.5);
    expect(application.primaryWindow, same(window));
    await windowManager.setBadgeLabel('3');
    expect(application.calls, [
      'setPrimaryWindow',
      'setProgressBar(0.5)',
      'setBadgeLabel(3)',
    ]);
  });

  test('a primary window the app chose is kept', () async {
    final chosen = _FakeNativeWindow();
    application.primaryWindow = chosen;
    windowManager.debugBindWindow(_FakeNativeWindow());

    await windowManager.setProgressBar(1);
    await windowManager.setBadgeLabel();
    expect(application.primaryWindow, same(chosen));
    expect(application.calls, ['setProgressBar(1.0)', 'setBadgeLabel()']);
  });
}
