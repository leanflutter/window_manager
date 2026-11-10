// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/legacy.dart';

class _Recorder with WindowListener {
  final List<String> events = <String>[];

  @override
  void onWindowEvent(String eventName) => events.add(eventName);
}

// A nativeapi window simulated in Dart; no native window is created.
class _FakeNativeWindow extends nativeapi.Window {
  _FakeNativeWindow() : super.borrowed(0);

  bool visible = false;
  bool minimized = false;
  bool maximized = false;
  bool refuseVisibilityChanges = false;
  FutureOr<void> Function(nativeapi.WindowEvent)? _callback;

  bool get isListening => _callback != null;

  // As nativeapi on macOS, a minimized window does not count as visible.
  @override
  bool get isVisible => visible && !minimized;

  @override
  bool get isMinimized => minimized;

  @override
  bool get isMaximized => maximized;

  @override
  bool get isFullScreen => false;

  @override
  void show() => visible = visible || !refuseVisibilityChanges;

  @override
  void showInactive() => show();

  @override
  void hide() => visible = visible && refuseVisibilityChanges;

  @override
  void restore() => minimized = false;

  @override
  nativeapi.ListenerId addListener(
    FutureOr<void> Function(nativeapi.WindowEvent) listener,
  ) {
    _callback = listener;
    return 1;
  }

  @override
  bool removeListener(nativeapi.ListenerId id) {
    _callback = null;
    return true;
  }

  Future<void> fire(nativeapi.WindowEvent event) async {
    await _callback?.call(event);
  }
}

class _Named with WindowListener {
  final List<String> calls = <String>[];

  @override
  void onWindowMaximize() => calls.add('maximize');

  @override
  void onWindowUnmaximize() => calls.add('unmaximize');

  @override
  void onWindowRestore() => calls.add('restore');
}

void main() {
  late _FakeNativeWindow fake;
  late _Recorder listener;

  setUp(() {
    fake = _FakeNativeWindow();
    listener = _Recorder();
    windowManager.debugBindWindow(fake);
    windowManager.addListener(listener);
  });

  tearDown(() {
    windowManager.removeListener(listener);
    windowManager.debugBindWindow(null);
  });

  group('show and hide', () {
    test('are reported only when the visibility changes', () async {
      await windowManager.show();
      await windowManager.show();
      await windowManager.hide();
      await windowManager.hide();
      await windowManager.show(inactive: true);
      expect(listener.events, ['show', 'hide', 'show']);
    });

    test('a minimized window counts as shown', () async {
      fake.visible = true;
      fake.minimized = true;
      await windowManager.hide();
      expect(listener.events, ['hide']);

      fake.visible = true;
      fake.minimized = true;
      await windowManager.show();
      expect(fake.minimized, isFalse);
      expect(listener.events, ['hide', 'show']);
    });

    test('are not reported when the platform keeps the visibility', () async {
      fake.refuseVisibilityChanges = true;
      await windowManager.show();
      fake.visible = true;
      await windowManager.hide();
      expect(listener.events, isEmpty);
    });
  });

  group('restore tracking', () {
    test(
      'a minimized window that comes back maximized is not minimized',
      () async {
        fake.minimized = true;
        await fake.fire(const nativeapi.WindowMinimizedEvent(windowId: 1));
        fake.minimized = false;
        fake.maximized = true;
        await fake.fire(const nativeapi.WindowMaximizedEvent(windowId: 1));
        fake.maximized = false;
        await fake.fire(const nativeapi.WindowRestoredEvent(windowId: 1));

        expect(listener.events, [
          kWindowEventMinimize,
          kWindowEventMaximize,
          kWindowEventUnmaximize,
        ]);
      },
    );

    test('restoring a minimized window keeps it maximized', () async {
      fake.maximized = true;
      await fake.fire(const nativeapi.WindowMaximizedEvent(windowId: 1));
      fake.minimized = true;
      await fake.fire(const nativeapi.WindowMinimizedEvent(windowId: 1));
      fake.minimized = false;
      await fake.fire(const nativeapi.WindowRestoredEvent(windowId: 1));
      fake.maximized = false;
      await fake.fire(const nativeapi.WindowRestoredEvent(windowId: 1));

      expect(listener.events, [
        kWindowEventMaximize,
        kWindowEventMinimize,
        kWindowEventRestore,
        kWindowEventUnmaximize,
      ]);
    });

    test('named callbacks follow the tracked state', () async {
      final named = _Named();
      windowManager.addListener(named);
      addTearDown(() => windowManager.removeListener(named));

      fake.maximized = true;
      await fake.fire(const nativeapi.WindowMaximizedEvent(windowId: 1));
      fake.maximized = false;
      await fake.fire(const nativeapi.WindowRestoredEvent(windowId: 1));
      fake.minimized = true;
      await fake.fire(const nativeapi.WindowMinimizedEvent(windowId: 1));
      fake.minimized = false;
      await fake.fire(const nativeapi.WindowRestoredEvent(windowId: 1));

      expect(named.calls, ['maximize', 'unmaximize', 'restore']);
    });
  });
}
