import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

// Only the caption's window state is needed; no native window is created.
class _Window extends Window {
  _Window({required this.maximized}) : super.borrowed(0);

  final bool maximized;
  int maximizes = 0;
  int unmaximizes = 0;

  @override
  bool get isMaximized => maximized;

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
}
