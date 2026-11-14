import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

// A window whose close request cannot be made, as when the platform refuses
// it. No native window is created.
class _RefusingWindow extends Window {
  _RefusingWindow() : super.borrowed(0);

  int closes = 0;

  @override
  bool get isMaximized => false;

  @override
  bool close() {
    closes++;
    return false;
  }
}

void main() {
  testWidgets('close button of an explicit window only addresses that window', (
    tester,
  ) async {
    final window = _RefusingWindow();
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: kWindowCaptionHeight,
          child: WindowCaption(window: window),
        ),
      ),
    );

    await tester.tap(find.byType(WindowCaptionButton).last);
    await tester.pump();

    // The request went to the given window and nothing else was attempted:
    // with an explicit window the caption no longer falls back to quitting
    // the application when the window does not close.
    expect(window.closes, Window.isCloseSupported() ? 1 : 0);
    expect(tester.takeException(), isNull);
  });
}
