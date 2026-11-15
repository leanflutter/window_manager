import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

Color? _background(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(WindowCaptionButton),
      matching: find.byType(Container),
    ),
  );
  return (container.decoration as BoxDecoration?)?.color;
}

Future<void> _pump(WidgetTester tester, WindowCaptionButton button) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: button),
    ),
  );
}

void main() {
  testWidgets('idle button has the normal background', (tester) async {
    await _pump(tester, WindowCaptionButton.maximize(onPressed: () {}));
    expect(_background(tester), Colors.transparent);
  });

  testWidgets('hovered shows the hover look without a pointer', (tester) async {
    await _pump(
      tester,
      WindowCaptionButton.maximize(onPressed: () {}, hovered: true),
    );
    expect(_background(tester), Colors.black.withValues(alpha: 0.0373));
  });

  testWidgets('pressed wins over hovered', (tester) async {
    await _pump(
      tester,
      WindowCaptionButton.unmaximize(
        onPressed: () {},
        hovered: true,
        pressed: true,
      ),
    );
    expect(_background(tester), Colors.black.withValues(alpha: 0.0241));
  });

  testWidgets('dark close button uses its own hover color', (tester) async {
    await _pump(
      tester,
      WindowCaptionButton.close(
        brightness: Brightness.dark,
        onPressed: () {},
        hovered: true,
      ),
    );
    expect(_background(tester), const Color(0xffC42B1C));
  });
}
