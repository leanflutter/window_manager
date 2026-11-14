import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

// Caption buttons are laid out in a Row; mirror that sizing here.
Widget _host(Widget button) => MaterialApp(
  home: Center(child: UnconstrainedBox(child: button)),
);

Color? _background(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(WindowCaptionButton),
      matching: find.byType(Container),
    ),
  );
  return (container.decoration! as BoxDecoration).color;
}

CustomPainter _painter(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find.descendant(
        of: find.byType(WindowCaptionButtonIcon),
        matching: find.byType(CustomPaint),
      ),
    )
    .painter!;

Color? _iconColor(WidgetTester tester) => tester
    .widget<WindowCaptionButtonIcon>(find.byType(WindowCaptionButtonIcon))
    .color;

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets('chrome icon painters repaint when the icon color changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        WindowCaptionButton.close(
          brightness: Brightness.light,
          onPressed: () {},
        ),
      ),
    );
    final light = _painter(tester);
    await tester.pumpWidget(
      _host(
        WindowCaptionButton.close(
          brightness: Brightness.dark,
          onPressed: () {},
        ),
      ),
    );
    final dark = _painter(tester);

    expect(dark.shouldRepaint(light), isTrue);
    expect(dark.shouldRepaint(dark), isFalse);

    for (final button in [
      WindowCaptionButton.minimize(onPressed: () {}),
      WindowCaptionButton.maximize(onPressed: () {}),
      WindowCaptionButton.unmaximize(onPressed: () {}),
    ]) {
      await tester.pumpWidget(_host(button));
      final normal = _painter(tester);
      final down = await tester.startGesture(
        tester.getCenter(find.byType(WindowCaptionButton)),
      );
      await tester.pump();
      final pressed = _painter(tester);
      expect(pressed.shouldRepaint(normal), isTrue, reason: '$button');
      await down.up();
      await tester.pump();
    }
  });

  testWidgets('hover is shown on enter, cleared on exit, without per-move '
      'rebuilds', (tester) async {
    await tester.pumpWidget(_host(WindowCaptionButton.close(onPressed: () {})));
    final center = tester.getCenter(find.byType(WindowCaptionButton));
    final mouse = await _mouse(tester);
    expect(_background(tester), Colors.transparent);

    await mouse.moveTo(center);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();
    expect(_background(tester), const Color(0xffC42B1C));

    // Moving within the button must not schedule another frame.
    await mouse.moveTo(center + const Offset(3, 2));
    expect(tester.binding.hasScheduledFrame, isFalse);

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(_background(tester), Colors.transparent);
  });

  testWidgets('a custom icon is rendered and follows the state color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        WindowCaptionButton(
          brightness: Brightness.light,
          icon: const Icon(Icons.push_pin),
          onPressed: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
    expect(find.byType(WindowCaptionButtonIcon), findsNothing);

    IconThemeData theme() =>
        IconTheme.of(tester.element(find.byIcon(Icons.push_pin)));
    expect(theme().color, Colors.black.withValues(alpha: 0.8956));
    expect(theme().size, 16);

    await tester.pumpWidget(
      _host(
        WindowCaptionButton(
          brightness: Brightness.light,
          icon: const Icon(Icons.push_pin),
          onPressed: null,
        ),
      ),
    );
    expect(theme().color, Colors.black.withValues(alpha: 0.3614));
  });

  testWidgets('a disabled button shows the disabled color and ignores input', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        WindowCaptionButton.close(brightness: Brightness.dark, onPressed: null),
      ),
    );
    // Light-on-dark: the disabled glyph must stay visible on a dark caption.
    expect(_iconColor(tester), Colors.white.withValues(alpha: 0.3628));

    final center = tester.getCenter(find.byType(WindowCaptionButton));
    final mouse = await _mouse(tester);
    await mouse.moveTo(center);
    await tester.pump();
    final down = await tester.startGesture(center);
    await tester.pump();
    expect(_background(tester), Colors.transparent);
    expect(_iconColor(tester), Colors.white.withValues(alpha: 0.3628));
    await down.up();
  });

  testWidgets('disabling during a press and re-enabling under the pointer', (
    tester,
  ) async {
    var taps = 0;
    Future<void> show({required bool enabled}) => tester.pumpWidget(
      _host(
        WindowCaptionButton.minimize(
          brightness: Brightness.light,
          onPressed: enabled ? () => taps++ : null,
        ),
      ),
    );

    await show(enabled: true);
    final center = tester.getCenter(find.byType(WindowCaptionButton));
    final mouse = await _mouse(tester);
    await mouse.moveTo(center);
    final down = await tester.startGesture(center);
    await tester.pump();
    final pressedColor = Colors.black.withValues(alpha: 0.0241);
    expect(_background(tester), pressedColor);

    await show(enabled: false);
    expect(_background(tester), Colors.transparent);
    await down.up();
    expect(taps, 0);

    // The pointer never left, so re-enabling shows the hover state at once.
    await show(enabled: true);
    expect(_background(tester), Colors.black.withValues(alpha: 0.0373));

    await tester.tap(find.byType(WindowCaptionButton));
    expect(taps, 1);
  });

  testWidgets('exposes button semantics with the enabled state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(WindowCaptionButton.close(onPressed: () {})));
    expect(
      tester.getSemantics(find.byType(WindowCaptionButton)),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.pumpWidget(_host(WindowCaptionButton.close(onPressed: null)));
    expect(
      tester.getSemantics(find.byType(WindowCaptionButton)),
      matchesSemantics(isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });
}
