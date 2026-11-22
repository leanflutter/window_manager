// How package:window_manager/legacy.dart treats nativeapi window events that
// 0.5.x had no counterpart for.
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

  FutureOr<void> Function(nativeapi.WindowEvent)? _callback;

  @override
  bool get isMinimized => false;

  @override
  bool get isMaximized => false;

  @override
  bool get isFullScreen => false;

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

  test('events without a 0.5.x counterpart are dropped', () async {
    await fake.fire(const nativeapi.WindowCreatedEvent(windowId: 1));
    await fake.fire(const nativeapi.WindowClosedEvent(windowId: 1));
    await fake.fire(
      const nativeapi.WindowOcclusionChangedEvent(
        windowId: 1,
        occlusionState: nativeapi.WindowOcclusionState.occluded,
      ),
    );
    expect(listener.events, isEmpty);
  });

  test('events with a 0.5.x counterpart still arrive', () async {
    await fake.fire(const nativeapi.WindowFocusedEvent(windowId: 1));
    await fake.fire(const nativeapi.WindowCreatedEvent(windowId: 1));
    await fake.fire(const nativeapi.WindowBlurredEvent(windowId: 1));
    expect(listener.events, [kWindowEventFocus, kWindowEventBlur]);
  });
}
