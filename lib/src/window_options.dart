import 'dart:ui';

import 'title_bar_style.dart';

/// WindowOptions
class WindowOptions {
  Size? size;
  bool? center;
  Size? minimumSize;
  Size? maximumSize;
  bool? alwaysOnTop;
  bool? fullScreen;
  Color? backgroundColor;
  bool? skipTaskbar;
  String? title;
  TitleBarStyle? titleBarStyle;

  WindowOptions({
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
  });
}
