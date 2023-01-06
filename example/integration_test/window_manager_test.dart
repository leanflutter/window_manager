import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(640, 480),
      title: 'window_manager_test',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  testWidgets('getBounds', (tester) async {
    expect(await windowManager.getBounds(),
        isA<Rect>().having((r) => r.size, 'size', Size(640, 480)));
  });

  testWidgets('isAlwaysOnBottom', (tester) async {
    expect(await windowManager.isAlwaysOnBottom(), isFalse);
  }, skip: Platform.isMacOS || Platform.isWindows);

  testWidgets('isAlwaysOnTop', (tester) async {
    expect(await windowManager.isAlwaysOnTop(), isFalse);
  });

  testWidgets('isClosable', (tester) async {
    expect(await windowManager.isClosable(), isTrue);
  });

  testWidgets('isFocused', (tester) async {
    expect(await windowManager.isFocused(), isTrue);
  });

  testWidgets('isFullScreen', (tester) async {
    expect(await windowManager.isFullScreen(), isFalse);
  });

  testWidgets('setFullScreen', (tester) async {
    final events = listenWindowEvents();
    expect(events, emitsThrough(kWindowEventEnterFullScreen));
    await windowManager.setFullScreen(true);
    await tester.waitUntil(windowManager.isFullScreen, isTrue);

    expect(events, emitsThrough(kWindowEventLeaveFullScreen));
    await windowManager.setFullScreen(false);
    await tester.waitUntil(windowManager.isFullScreen, isFalse);
  }, skip: !Platform.isLinux);

  testWidgets('hasShadow', (tester) async {
    expect(await windowManager.hasShadow(), isTrue);
  }, skip: Platform.isLinux);

  testWidgets('isMaximizable', (tester) async {
    expect(await windowManager.isMaximizable(), isTrue);
  }, skip: Platform.isMacOS);

  testWidgets('isMaximized', (tester) async {
    expect(await windowManager.isMaximized(), isFalse);
  });

  testWidgets('maximize', (tester) async {
    final events = listenWindowEvents();
    expect(events, emitsThrough(kWindowEventMaximize));
    await windowManager.maximize();
    await tester.waitUntil(windowManager.isMaximized, isTrue);

    expect(events, emitsThrough(kWindowEventUnmaximize));
    await windowManager.unmaximize();
    await tester.waitUntil(windowManager.isMaximized, isFalse);
  }, skip: !Platform.isLinux);

  testWidgets('isMinimizable', (tester) async {
    expect(await windowManager.isMinimizable(), isTrue);
  }, skip: Platform.isMacOS);

  testWidgets('isMinimized', (tester) async {
    expect(await windowManager.isMinimized(), isFalse);
  });

  testWidgets('minimize', (tester) async {
    final events = listenWindowEvents();
    expect(events, emitsThrough(kWindowEventMinimize));
    await windowManager.minimize();
    await tester.waitUntil(windowManager.isMinimized, isTrue);

    expect(events, emitsThrough(kWindowEventRestore));
    await windowManager.restore();
    await tester.waitUntil(windowManager.isMinimized, isFalse);
  }, skip: !Platform.isLinux);

  testWidgets('isMovable', (tester) async {
    expect(await windowManager.isMovable(), isTrue);
  }, skip: Platform.isLinux || Platform.isWindows);

  testWidgets('getOpacity', (tester) async {
    expect(await windowManager.getOpacity(), 1.0);
  });

  testWidgets('getPosition', (tester) async {
    expect(await windowManager.getPosition(), isA<Offset>());
  });

  testWidgets('setPosition', (tester) async {
    final oldPosition = await windowManager.getPosition();
    final newPosition = oldPosition + Offset(10, 10);

    final events = listenWindowEvents();
    expect(events, emitsThrough(kWindowEventMove));
    await windowManager.setPosition(newPosition);
    await tester.waitUntil(windowManager.getPosition, newPosition);

    expect(events, emitsThrough(kWindowEventMove));
    await windowManager.setPosition(oldPosition);
    await tester.waitUntil(windowManager.getPosition, oldPosition);
  }, skip: !Platform.isLinux);

  testWidgets('isPreventClose', (tester) async {
    expect(await windowManager.isPreventClose(), isFalse);
  });

  testWidgets('isResizable', (tester) async {
    expect(await windowManager.isResizable(), isTrue);
  });

  testWidgets('getSize', (tester) async {
    expect(await windowManager.getSize(), Size(640, 480));
  });

  testWidgets('isSkipTaskbar', (tester) async {
    expect(await windowManager.isSkipTaskbar(), isFalse);
  }, skip: Platform.isWindows);

  testWidgets('getTitle', (tester) async {
    expect(await windowManager.getTitle(), 'window_manager_test');
  });

  testWidgets('getTitleBarHeight', (tester) async {
    expect(await windowManager.getTitleBarHeight(), isNonNegative);
  });

  testWidgets('isVisible', (tester) async {
    expect(await windowManager.isVisible(), isTrue);
  });

  testWidgets('setVisible', (tester) async {
    final events = listenWindowEvents();

    windowManager.hide();
    expect(events, emitsThrough('hide'));
    await tester.waitUntil(windowManager.isVisible, isFalse);

    windowManager.show();
    expect(events, emitsThrough('show'));
    await tester.waitUntil(windowManager.isVisible, isTrue);
  }, skip: !Platform.isLinux);
}

Stream<String> listenWindowEvents() {
  final listener = TestWindowListener();
  windowManager.addListener(listener);
  addTearDown(() => windowManager.removeListener(listener));
  return listener.events;
}

class TestWindowListener extends WindowListener {
  StreamController<String> _events = StreamController.broadcast();
  Stream<String> get events => _events.stream;
  @override
  void onWindowEvent(String eventName) => _events.add(eventName);
}

extension WindowTester on WidgetTester {
  Future<void> waitUntil(Future Function() callback, dynamic matcher,
      {Duration timeout = const Duration(seconds: 30)}) {
    return Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.processEvents();
      dynamic actual = await callback();
      return !wrapMatcher(matcher).matches(actual, {});
    }).timeout(timeout);
  }
}
