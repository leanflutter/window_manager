import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/painting.dart' show Alignment;
import 'package:nativeapi/nativeapi.dart' as nativeapi;

/// Where a window of [windowSize] has to sit to be [alignment] on the display
/// the cursor is on, inside that display's work area.
///
/// Unlike 0.5.x this handles any [Alignment], not only the nine constants.
Future<Offset> calcWindowPosition(Size windowSize, Alignment alignment) async {
  final displayManager = nativeapi.DisplayManager.instance;
  final displays = displayManager.getAll();
  final cursorPosition = displayManager.getCursorPosition();

  nativeapi.Display? currentDisplay;
  for (final display in displays) {
    final bounds = Rect.fromLTWH(
      display.position.dx,
      display.position.dy,
      display.size.width,
      display.size.height,
    );
    if (bounds.contains(cursorPosition)) {
      currentDisplay = display;
      break;
    }
  }
  currentDisplay ??= displayManager.getPrimary();
  if (currentDisplay == null) {
    return Offset.zero;
  }

  final workArea = currentDisplay.workArea;
  return Offset(
    workArea.left + (workArea.width - windowSize.width) * (alignment.x + 1) / 2,
    workArea.top +
        (workArea.height - windowSize.height) * (alignment.y + 1) / 2,
  );
}
