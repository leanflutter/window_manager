// Tests for `WindowManager.setPosition` of package:window_manager/legacy.dart.
//
// The native library is not available in a unit test. A fake window replaces
// it. The fake applies a size request later, like a window manager on Linux
// (X11): until then `bounds` returns the old size.
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/legacy.dart';

class _FakeWindow implements nativeapi.Window {
  /// The size that the window manager applied. `bounds` returns this size.
  final nativeapi.Size appliedSize = const nativeapi.Size(
    width: 1280,
    height: 720,
  );

  /// The size that the window gets when the window manager applies the last
  /// request. A size request and a write to `bounds` both change it.
  nativeapi.Size? requestedSize;

  nativeapi.Point? lastPosition;
  nativeapi.Rectangle? lastBoundsWrite;
  nativeapi.Rectangle? lastAnimatedBounds;
  bool animationSupported = false;

  /// The native calls, in the order of the calls.
  final List<String> calls = <String>[];

  @override
  nativeapi.Rectangle get bounds {
    calls.add('get bounds');
    return nativeapi.Rectangle(
      x: 0,
      y: 0,
      width: appliedSize.width,
      height: appliedSize.height,
    );
  }

  @override
  set bounds(nativeapi.Rectangle value) {
    calls.add('set bounds');
    lastBoundsWrite = value;
    requestedSize = nativeapi.Size(width: value.width, height: value.height);
  }

  @override
  bool animateBounds(nativeapi.Rectangle bounds) {
    calls.add('animate bounds');
    if (!animationSupported) return false;
    lastAnimatedBounds = bounds;
    return true;
  }

  @override
  set position(nativeapi.Point value) {
    calls.add('set position');
    lastPosition = value;
  }

  @override
  void setSize(nativeapi.Size size, bool animate) {
    calls.add('set size');
    requestedSize = size;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeWindow window;

  setUp(() {
    window = _FakeWindow();
    windowManager.debugBindWindow(window);
  });

  tearDown(() {
    windowManager.debugBindWindow(null);
  });

  group('WindowManager.setPosition', () {
    group('with animate false', () {
      test('moves the window and does not read or write the bounds', () async {
        await windowManager.setPosition(const Offset(10, 20));

        expect(window.calls, <String>['set position']);
        expect(window.lastPosition, const nativeapi.Point(x: 10, y: 20));
      });

      test('does not cancel a size request that is not applied yet', () async {
        await windowManager.setSize(const Size(1920, 1080));
        await windowManager.setPosition(Offset.zero);

        expect(
          window.requestedSize,
          const nativeapi.Size(width: 1920, height: 1080),
        );
        expect(window.lastBoundsWrite, isNull);
      });

      test('keeps the size request after several moves', () async {
        await windowManager.setSize(const Size(1920, 1080));
        await windowManager.setPosition(const Offset(1, 2));
        await windowManager.setPosition(const Offset(3, 4));

        expect(
          window.requestedSize,
          const nativeapi.Size(width: 1920, height: 1080),
        );
        expect(window.lastPosition, const nativeapi.Point(x: 3, y: 4));
      });
    });

    group('with animate true', () {
      test('animates to the new position with the current size', () async {
        window.animationSupported = true;

        await windowManager.setPosition(const Offset(5, 6), animate: true);

        expect(window.calls, <String>['get bounds', 'animate bounds']);
        final animated = window.lastAnimatedBounds!;
        expect(animated.x, 5);
        expect(animated.y, 6);
        expect(animated.width, 1280);
        expect(animated.height, 720);
      });

      test('writes the bounds when the platform has no animation', () async {
        await windowManager.setPosition(const Offset(5, 6), animate: true);

        expect(window.calls, <String>[
          'get bounds',
          'animate bounds',
          'set bounds',
        ]);
        final written = window.lastBoundsWrite!;
        expect(written.x, 5);
        expect(written.y, 6);
        expect(written.width, 1280);
        expect(written.height, 720);
      });
    });
  });
}
