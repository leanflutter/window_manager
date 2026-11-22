// Windows looked up after listeners, prevent-close or show() were set up, as
// when the platform reports no current window yet, and bindWindow.
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
  FutureOr<void> Function(nativeapi.WindowEvent)? _callback;

  bool get isListening => _callback != null;

  @override
  bool get isVisible => visible;

  @override
  bool get isMinimized => false;

  @override
  bool get isMaximized => false;

  @override
  bool get isFullScreen => false;

  @override
  void show() => visible = true;

  @override
  void showInactive() => visible = true;

  @override
  void hide() => visible = false;

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

class _FakeCloseRequest extends nativeapi.EventRequest {
  _FakeCloseRequest() : super.borrowed(0);

  bool cancelled = false;

  @override
  bool cancel() => cancelled = true;
}

void main() {
  nativeapi.Window? current;
  var lookups = 0;

  setUp(() {
    current = null;
    lookups = 0;
    windowManager.debugCurrentWindowOverride = () {
      lookups++;
      return current;
    };
    windowManager.bindWindow(null);
  });

  tearDown(() async {
    await windowManager.setPreventClose(false);
    windowManager.debugCurrentWindowOverride = null;
    windowManager.bindWindow(null);
  });

  test('a window found after the listener is wired then', () async {
    final listener = _Recorder();
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));
    await windowManager.setPreventClose(true);
    expect(await windowManager.isVisible(), isFalse);

    final fake = _FakeNativeWindow();
    current = fake;
    // Any call that addresses the window finds it now.
    await windowManager.isMaximized();
    expect(fake.isListening, isTrue);

    final request = _FakeCloseRequest();
    await fake.fire(
      nativeapi.WindowCloseRequestedEvent(windowId: 1, request: request),
    );
    expect(request.cancelled, isTrue);
    expect(listener.events, [kWindowEventClose]);
  });

  test('a missing window is looked up again on every call', () async {
    await windowManager.isVisible();
    await windowManager.isVisible();
    expect(lookups, 2);

    current = _FakeNativeWindow();
    await windowManager.isVisible();
    await windowManager.isVisible();
    expect(lookups, 3);
  });

  test('ensureInitialized wires a window found late', () async {
    final listener = _Recorder();
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));

    final fake = _FakeNativeWindow();
    current = fake;
    await windowManager.ensureInitialized();
    expect(fake.isListening, isTrue);
  });

  test('show without a window is carried out on the bound one', () async {
    await windowManager.show();

    final fake = _FakeNativeWindow();
    windowManager.bindWindow(fake);
    expect(fake.visible, isTrue);
  });

  test('show without a window is carried out on the one found', () async {
    await windowManager.show(inactive: true);

    final fake = _FakeNativeWindow();
    current = fake;
    await windowManager.isMaximized();
    expect(fake.visible, isTrue);
  });

  test('hide cancels a show that found no window', () async {
    await windowManager.show();
    await windowManager.hide();

    final fake = _FakeNativeWindow();
    current = fake;
    await windowManager.isVisible();
    expect(fake.visible, isFalse);
  });

  test('bindWindow moves listeners and prevent-close', () async {
    final listener = _Recorder();
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));
    await windowManager.setPreventClose(true);

    final first = _FakeNativeWindow();
    current = first;
    await windowManager.ensureInitialized();
    expect(first.isListening, isTrue);

    final second = _FakeNativeWindow();
    windowManager.bindWindow(second);
    expect(first.isListening, isFalse);
    expect(second.isListening, isTrue);
    expect(await windowManager.isPreventClose(), isTrue);

    final request = _FakeCloseRequest();
    await second.fire(
      nativeapi.WindowCloseRequestedEvent(windowId: 2, request: request),
    );
    expect(request.cancelled, isTrue);
    expect(listener.events, [kWindowEventClose]);

    // Back to the current window.
    windowManager.bindWindow(null);
    expect(second.isListening, isFalse);
    expect(first.isListening, isTrue);
  });
}
