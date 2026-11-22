import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

typedef _ButtonFactory = WindowCaptionButton Function(Brightness brightness);

class _Glyph {
  const _Glyph(this.name, this.create, this.includes, this.excludes);

  final String name;
  final _ButtonFactory create;

  /// Points (in the 16x16 icon space) that the glyph must fill.
  final List<Offset> includes;

  /// Points (in the 16x16 icon space) that the glyph must leave empty.
  final List<Offset> excludes;
}

final _glyphs = <_Glyph>[
  _Glyph(
    'minimize',
    (b) => WindowCaptionButton.minimize(brightness: b, onPressed: () {}),
    const [Offset(8, 7.5), Offset(4, 7.5), Offset(12, 7.5)],
    const [Offset(8, 5), Offset(8, 9), Offset(2, 7.5)],
  ),
  _Glyph(
    'maximize',
    (b) => WindowCaptionButton.maximize(brightness: b, onPressed: () {}),
    const [Offset(8, 3.5), Offset(3.5, 8), Offset(12.5, 8), Offset(8, 12.5)],
    // The center of the frame is a hole.
    const [Offset(8, 8), Offset(1, 1), Offset(15, 15)],
  ),
  _Glyph(
    'unmaximize',
    (b) => WindowCaptionButton.unmaximize(brightness: b, onPressed: () {}),
    // Front frame edges and the back frame's top edge.
    const [Offset(3.5, 9), Offset(7, 12.5), Offset(8, 3.5)],
    // Inside the front frame.
    const [Offset(7, 9), Offset(1, 1)],
  ),
  _Glyph(
    'close',
    (b) => WindowCaptionButton.close(brightness: b, onPressed: () {}),
    const [Offset(8, 8), Offset(5, 5), Offset(11, 5), Offset(5, 11)],
    const [Offset(8, 4), Offset(4, 8), Offset(12, 8), Offset(8, 12)],
  ),
];

Widget _host(Widget button) => MaterialApp(
  home: Center(child: UnconstrainedBox(child: button)),
);

Finder get _iconPaint => find.descendant(
  of: find.byType(WindowCaptionButtonIcon),
  matching: find.byType(CustomPaint),
);

void main() {
  for (final glyph in _glyphs) {
    testWidgets('${glyph.name} glyph keeps its geometry in both themes', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(_host(glyph.create(brightness)));
        final color = tester
            .widget<WindowCaptionButtonIcon>(
              find.byType(WindowCaptionButtonIcon),
            )
            .color;
        expect(
          _iconPaint,
          paints..path(
            color: color,
            style: PaintingStyle.fill,
            includes: glyph.includes,
            excludes: glyph.excludes,
          ),
        );
      }
    });

    testWidgets('${glyph.name} glyph Path is reused across repaints', (
      tester,
    ) async {
      final drawn = <ui.Path>[];
      for (final brightness in [...Brightness.values, Brightness.light]) {
        await tester.pumpWidget(_host(glyph.create(brightness)));
        expect(
          _iconPaint,
          paints..something((method, arguments) {
            if (method != #drawPath) return false;
            drawn.add(arguments[0] as ui.Path);
            return true;
          }),
        );
      }
      expect(drawn, hasLength(3));
      expect(identical(drawn[0], drawn[1]), isTrue);
      expect(identical(drawn[1], drawn[2]), isTrue);
    });
  }

  testWidgets('glyph types do not share a cached Path', (tester) async {
    final drawn = <ui.Path>{};
    for (final glyph in _glyphs) {
      await tester.pumpWidget(_host(glyph.create(Brightness.light)));
      expect(
        _iconPaint,
        paints..something((method, arguments) {
          if (method != #drawPath) return false;
          drawn.add(arguments[0] as ui.Path);
          return true;
        }),
      );
    }
    expect(drawn, hasLength(_glyphs.length));
  });
}
