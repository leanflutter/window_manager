import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

// Only the widgets' window state is needed; no native window is created.
class _Window extends Window {
  _Window({required this.maximized}) : super.borrowed(0);

  bool maximized;
  int maximizes = 0;
  int unmaximizes = 0;
  int stateReads = 0;
  final _listeners = <ListenerId, FutureOr<void> Function(WindowEvent)>{};
  var _nextListenerId = 0;

  int get listenerCount => _listeners.length;

  @override
  ListenerId addListener(FutureOr<void> Function(WindowEvent) callback) {
    _listeners[++_nextListenerId] = callback;
    return _nextListenerId;
  }

  @override
  bool removeListener(ListenerId listenerId) =>
      _listeners.remove(listenerId) != null;

  Future<void> emit(WindowEvent event) async {
    for (final listener in _listeners.values.toList()) {
      await listener(event);
    }
  }

  @override
  bool get isMaximized {
    stateReads++;
    return maximized;
  }

  @override
  bool get isFocused {
    stateReads++;
    return true;
  }

  @override
  bool get isFullScreen {
    stateReads++;
    return false;
  }

  @override
  void maximize() {
    maximizes++;
  }

  @override
  void unmaximize() {
    unmaximizes++;
  }
}

void main() {
  testWidgets('caption adopts the state and actions of a replacement window', (
    tester,
  ) async {
    final normal = _Window(maximized: false);
    final maximized = _Window(maximized: true);

    Future<void> show(Window window) => tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: kWindowCaptionHeight,
          child: WindowCaption(window: window),
        ),
      ),
    );

    await show(normal);
    await show(maximized);
    final buttons = find.byType(WindowCaptionButton);
    await tester.tap(buttons.at(1));
    expect(maximized.unmaximizes, 1);
    expect(maximized.maximizes, 0);
    expect(normal.maximizes, 0);

    await show(normal);
    await tester.tap(buttons.at(1));
    expect(normal.maximizes, 1);
    expect(normal.unmaximizes, 0);
  });

  String maximizeIcon(WidgetTester tester) => tester
      .widget<WindowCaptionButton>(find.byType(WindowCaptionButton).at(1))
      .iconName!;

  Future<void> showCaption(WidgetTester tester, Window? window) =>
      tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: kWindowCaptionHeight,
            child: WindowCaption(window: window),
          ),
        ),
      );

  testWidgets('caption listens only to its own window', (tester) async {
    final a = _Window(maximized: false);
    final b = _Window(maximized: false);

    await showCaption(tester, a);
    expect(a.listenerCount, 1);
    expect(b.listenerCount, 0);

    // Moving the caption to another window releases the old subscription.
    await showCaption(tester, b);
    expect(a.listenerCount, 0);
    expect(b.listenerCount, 1);

    a.maximized = true;
    await a.emit(const WindowMaximizedEvent(windowId: 1));
    await tester.pump();
    expect(maximizeIcon(tester), 'icon_chrome_maximize');

    b.maximized = true;
    await b.emit(const WindowMaximizedEvent(windowId: 2));
    await tester.pump();
    expect(maximizeIcon(tester), 'icon_chrome_unmaximize');

    b.maximized = false;
    await b.emit(const WindowRestoredEvent(windowId: 2));
    await tester.pump();
    expect(maximizeIcon(tester), 'icon_chrome_maximize');

    await tester.pumpWidget(const SizedBox.shrink());
    expect(b.listenerCount, 0);
  });

  testWidgets('caption keeps its subscription when rebuilt with its window', (
    tester,
  ) async {
    final window = _Window(maximized: false);

    await showCaption(tester, window);
    await showCaption(tester, window);
    expect(window.listenerCount, 1);
    expect(window._nextListenerId, 1);
  });

  testWidgets('caption without a window builds and disposes cleanly', (
    tester,
  ) async {
    await showCaption(tester, null);
    expect(maximizeIcon(tester), 'icon_chrome_maximize');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  Future<void> showFrame(WidgetTester tester, Window window) =>
      tester.pumpWidget(
        MaterialApp(
          home: VirtualWindowFrame(window: window, child: const SizedBox()),
        ),
      );

  testWidgets('frame listens only to its own window', (tester) async {
    final a = _Window(maximized: true);
    final b = _Window(maximized: false);

    // A window that starts maximized is read without setState in initState.
    await showFrame(tester, a);
    expect(tester.takeException(), isNull);
    expect(a.listenerCount, 1);

    await showFrame(tester, b);
    expect(a.listenerCount, 0);
    expect(b.listenerCount, 1);

    // Events of the window it left no longer reach the frame.
    final readsOfB = b.stateReads;
    await a.emit(const WindowBlurredEvent(windowId: 1));
    await a.emit(const WindowFocusedEvent(windowId: 1));
    expect(a.stateReads, 3, reason: 'only its initial read');
    expect(b.stateReads, readsOfB);

    await b.emit(const WindowMaximizedEvent(windowId: 2));
    expect(b.stateReads, readsOfB + 3);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(b.listenerCount, 0);
  });
}
