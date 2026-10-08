import 'dart:ui' show Color, Size;

import 'package:nativeapi/nativeapi.dart' show TitleBarStyle;

/// What `windowManager.waitUntilReadyToShow` applies before the window is
/// shown.
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
class WindowOptions {
  const WindowOptions({
    this.size,
    this.center,
    this.minimumSize,
    this.maximumSize,
    this.alwaysOnTop,
    this.fullScreen,
    this.backgroundColor,
    this.skipTaskbar,
    this.title,
    this.titleBarStyle,
    this.windowButtonVisibility,
  });

  final Size? size;
  final bool? center;
  final Size? minimumSize;
  final Size? maximumSize;
  final bool? alwaysOnTop;
  final bool? fullScreen;
  final Color? backgroundColor;
  final bool? skipTaskbar;
  final String? title;
  final TitleBarStyle? titleBarStyle;
  final bool? windowButtonVisibility;
}
