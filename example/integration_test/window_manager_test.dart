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

  testWidgets('bounds', (tester) async {
    expect(await windowManager.getBounds(),
        isA<Rect>().having((r) => r.size, 'size', Size(640, 480)));
  });

  testWidgets('always on bottom', (tester) async {
    expect(await windowManager.isAlwaysOnBottom(), isFalse);
  }, skip: Platform.isMacOS || Platform.isWindows);

  testWidgets('always on top', (tester) async {
    expect(await windowManager.isAlwaysOnTop(), isFalse);
  });

  testWidgets('closable', (tester) async {
    expect(await windowManager.isClosable(), isTrue);
  });

  testWidgets('focused', (tester) async {
    expect(await windowManager.isFocused(), isTrue);
  });

  testWidgets('fullscreen', (tester) async {
    expect(await windowManager.isFullScreen(), isFalse);
  });

  testWidgets('has shadow', (tester) async {
    expect(await windowManager.hasShadow(), isTrue);
  }, skip: Platform.isLinux);

  testWidgets('maximizable', (tester) async {
    expect(await windowManager.isMaximizable(), isTrue);
  }, skip: Platform.isMacOS);

  testWidgets('maximized', (tester) async {
    expect(await windowManager.isMaximized(), isFalse);
  });

  testWidgets('minimizable', (tester) async {
    expect(await windowManager.isMinimizable(), isTrue);
  }, skip: Platform.isMacOS);

  testWidgets('minimized', (tester) async {
    expect(await windowManager.isMinimized(), isFalse);
  });

  testWidgets('movable', (tester) async {
    expect(await windowManager.isMovable(), isTrue);
  }, skip: Platform.isLinux || Platform.isWindows);

  testWidgets('opacity', (tester) async {
    expect(await windowManager.getOpacity(), 1.0);
  });

  testWidgets('position', (tester) async {
    expect(await windowManager.getPosition(), isA<Offset>());
  });

  testWidgets('prevent close', (tester) async {
    expect(await windowManager.isPreventClose(), isFalse);
  });

  testWidgets('resizable', (tester) async {
    expect(await windowManager.isResizable(), isTrue);
  });

  testWidgets('size', (tester) async {
    expect(await windowManager.getSize(), Size(640, 480));
  });

  testWidgets('skip taskbar', (tester) async {
    expect(await windowManager.isSkipTaskbar(), isFalse);
  }, skip: Platform.isWindows);

  testWidgets('title', (tester) async {
    expect(await windowManager.getTitle(), 'window_manager_test');
  });

  testWidgets('title bar height', (tester) async {
    expect(await windowManager.getTitleBarHeight(), isNonNegative);
  });

  testWidgets('visible', (tester) async {
    expect(await windowManager.isVisible(), isTrue);
  });
}
