// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/legacy.dart';

// Like an X11 window manager, keep reporting the old geometry until the
// outstanding requests have been processed. A bounds write replaces both.
class _DeferredWindow extends Fake implements nativeapi.Window {
  nativeapi.Rectangle reported = const nativeapi.Rectangle(
    x: 100,
    y: 100,
    width: 1280,
    height: 720,
  );
  late nativeapi.Rectangle requested = reported;
  bool supportsAnimation = false;
  int boundsReads = 0;

  @override
  nativeapi.Rectangle get bounds {
    boundsReads++;
    return reported;
  }

  @override
  set bounds(nativeapi.Rectangle value) => requested = value;

  @override
  set position(nativeapi.Point value) {
    requested = nativeapi.Rectangle(
      x: value.x,
      y: value.y,
      width: requested.width,
      height: requested.height,
    );
  }

  @override
  void setSize(nativeapi.Size value, bool animate) {
    requested = nativeapi.Rectangle(
      x: requested.x,
      y: requested.y,
      width: value.width,
      height: value.height,
    );
  }

  @override
  bool animateBounds(nativeapi.Rectangle value) {
    if (supportsAnimation) requested = value;
    return supportsAnimation;
  }
}

void main() {
  late _DeferredWindow window;

  setUp(() {
    window = _DeferredWindow();
    windowManager.debugBindWindow(window);
  });

  tearDown(() => windowManager.debugBindWindow(null));

  test(
    'moving preserves a resize that the window manager has not applied',
    () async {
      await windowManager.setSize(const Size(1920, 1080));
      await windowManager.setPosition(Offset.zero);

      expect(window.requested.width, 1920);
      expect(window.requested.height, 1080);
      expect(window.requested.x, 0);
      expect(window.requested.y, 0);
      expect(window.boundsReads, 0);
    },
  );

  test('size-only bounds preserve an outstanding position request', () async {
    await windowManager.setPosition(const Offset(300, 400));
    await windowManager.setBounds(null, size: const Size(800, 600));

    expect(window.requested.x, 300);
    expect(window.requested.y, 400);
    expect(window.requested.width, 800);
    expect(window.requested.height, 600);
  });

  test('unsupported position animation preserves a pending resize', () async {
    await windowManager.setSize(const Size(1920, 1080));
    await windowManager.setPosition(Offset.zero, animate: true);

    expect(window.requested.width, 1920);
    expect(window.requested.height, 1080);
    expect(window.requested.x, 0);
    expect(window.requested.y, 0);
  });

  test(
    'full bounds and supported native animation still update the frame',
    () async {
      await windowManager.setBounds(const Rect.fromLTWH(20, 30, 800, 600));
      expect(window.requested.x, 20);
      expect(window.requested.width, 800);

      window.supportsAnimation = true;
      await windowManager.setPosition(const Offset(40, 50), animate: true);
      expect(window.requested.x, 40);
      expect(window.requested.y, 50);
      expect(window.requested.width, window.reported.width);
    },
  );
}
