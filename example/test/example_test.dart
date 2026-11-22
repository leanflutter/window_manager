// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/legacy.dart';
import 'package:window_manager/window_manager.dart' as nativeapi;
import 'package:window_manager_example/main.dart';
import 'package:window_manager_example/window_controller.dart';

class _SpyWindow extends nativeapi.Window {
  _SpyWindow() : super.borrowed(0);

  Rect currentBounds = const Rect.fromLTWH(10, 20, 820, 720);
  int boundsReads = 0;
  int otherReads = 0;
  FutureOr<void> Function(nativeapi.WindowEvent)? _listener;

  @override
  nativeapi.ListenerId addListener(
    FutureOr<void> Function(nativeapi.WindowEvent) callback,
  ) {
    _listener = callback;
    return 1;
  }

  @override
  bool removeListener(nativeapi.ListenerId listenerId) {
    _listener = null;
    return true;
  }

  Future<void> emit(nativeapi.WindowEvent event) async {
    await _listener?.call(event);
  }

  @override
  get bounds {
    boundsReads++;
    return currentBounds.toNative();
  }

  @override
  get contentBounds {
    otherReads++;
    return currentBounds.toNative();
  }

  bool _readBool() {
    otherReads++;
    return false;
  }

  @override
  bool get isVisible => _readBool();
  @override
  bool get isFocused => _readBool();
  @override
  bool get isMaximized => _readBool();
  @override
  bool get isMinimized => _readBool();
  @override
  bool get isFullScreen => _readBool();
  @override
  bool get isResizable => _readBool();
  @override
  bool get isMovable => _readBool();
  @override
  bool get isMinimizable => _readBool();
  @override
  bool get isMaximizable => _readBool();
  @override
  bool get isClosable => _readBool();
  @override
  bool get isAlwaysOnTop => _readBool();
  @override
  bool get isAlwaysOnBottom => _readBool();
  @override
  bool get isVisibleInTaskbar => _readBool();
  @override
  bool get hasShadow => _readBool();

  @override
  double get opacity {
    otherReads++;
    return 1.0;
  }

  @override
  String get title {
    otherReads++;
    return kDefaultTitle;
  }
}

// The window itself is not there in a test, so the shell is given a controller
// that never talks to it; what is checked is that the whole surface builds.
void main() {
  testWidgets('the example window builds', (tester) async {
    tester.view.physicalSize = const Size(820, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WindowManagerExampleApp(
        shell: Shell(controller: WindowController(listen: false)),
      ),
    );
    await tester.pump();

    expect(find.text('Full screen'), findsOneWidget);
    expect(find.text('Prevent close'), findsOneWidget);
  });

  test('geometry events only refresh bounds once per move/resize', () async {
    final spy = _SpyWindow();
    windowManager.debugBindWindow(spy);
    final controller = WindowController();
    addTearDown(() {
      controller.dispose();
      windowManager.debugBindWindow(null);
    });

    // Wait for initial refresh() to complete.
    await Future<void>.delayed(Duration.zero);
    spy.boundsReads = 0;
    spy.otherReads = 0;

    spy.currentBounds = const Rect.fromLTWH(10, 20, 960, 760);
    await spy.emit(
      nativeapi.WindowResizedEvent(
        windowId: 1,
        newSize: const Size(960, 760).toNative(),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.bounds, const Rect.fromLTWH(10, 20, 960, 760));
    expect(controller.log.take(2), [
      'onWindowEvent  resized',
      'onWindowEvent  resize',
    ]);
    expect(spy.boundsReads, 1);
    expect(spy.otherReads, 0);

    spy.currentBounds = const Rect.fromLTWH(50, 60, 960, 760);
    await spy.emit(
      nativeapi.WindowMovedEvent(
        windowId: 1,
        newPosition: const Offset(50, 60).toNative(),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.bounds, const Rect.fromLTWH(50, 60, 960, 760));
    expect(spy.boundsReads, 2);
    expect(spy.otherReads, 0);

    await spy.emit(const nativeapi.WindowFocusedEvent(windowId: 1));
    await Future<void>.delayed(Duration.zero);
    expect(spy.otherReads, greaterThan(0));
  });
}
