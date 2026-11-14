// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/legacy.dart';

// A nativeapi window simulated in Dart; no native window is created.
class _FakeNativeWindow extends nativeapi.Window {
  _FakeNativeWindow() : super.borrowed(0);

  int boundsReads = 0;
  nativeapi.Rectangle currentBounds = const nativeapi.Rectangle(
    x: 1,
    y: 2,
    width: 300,
    height: 200,
  );

  @override
  nativeapi.Rectangle get bounds {
    boundsReads++;
    return currentBounds;
  }

  @override
  set bounds(nativeapi.Rectangle value) {
    currentBounds = value;
  }

  // Simulates a platform without native bounds animation (Windows/Linux).
  final List<nativeapi.Rectangle> animateRequests = [];

  @override
  bool animateBounds(nativeapi.Rectangle bounds) {
    animateRequests.add(bounds);
    return false;
  }
}

void main() {
  late _FakeNativeWindow native;

  setUp(() {
    native = _FakeNativeWindow();
    windowManager.debugBindWindow(native);
  });

  tearDown(() => windowManager.debugBindWindow(null));

  test('full bounds are applied without reading the window bounds', () async {
    await windowManager.setBounds(const Rect.fromLTWH(40, 70, 800, 600));
    expect(native.boundsReads, 0);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 40, y: 70, width: 800, height: 600),
    );
  });

  test('partial updates still read the omitted dimensions', () async {
    await windowManager.setBounds(null, position: const Offset(25, 35));
    expect(native.boundsReads, 1);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 25, y: 35, width: 300, height: 200),
    );

    await windowManager.setBounds(null, size: const Size(640, 480));
    expect(native.boundsReads, 2);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 25, y: 35, width: 640, height: 480),
    );
  });

  test('full bounds win over position and size', () async {
    await windowManager.setBounds(
      const Rect.fromLTWH(5, 6, 700, 500),
      position: const Offset(99, 99),
      size: const Size(1, 1),
    );
    expect(native.boundsReads, 0);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 5, y: 6, width: 700, height: 500),
    );
  });

  test('animate falls back to a plain set when refused', () async {
    await windowManager.setBounds(
      const Rect.fromLTWH(10, 20, 900, 650),
      animate: true,
    );
    expect(native.boundsReads, 0);
    expect(native.animateRequests, [
      const nativeapi.Rectangle(x: 10, y: 20, width: 900, height: 650),
    ]);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 10, y: 20, width: 900, height: 650),
    );
  });

  test('an empty request is a no-op', () async {
    await windowManager.setBounds(null);
    expect(native.boundsReads, 0);
    expect(
      native.currentBounds,
      const nativeapi.Rectangle(x: 1, y: 2, width: 300, height: 200),
    );
  });
}
