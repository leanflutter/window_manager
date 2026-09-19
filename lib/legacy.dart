// ignore_for_file: deprecated_member_use_from_same_package

/// The `window_manager` API as it was before the move to nativeapi.
///
/// Existing apps keep working by importing this library instead of
/// `package:window_manager/window_manager.dart`. The changed import is
/// deliberate: this API is a bridge, its classes are deprecated, and it will be
/// removed in a future release. New code should use the native API exported
/// from `package:window_manager/window_manager.dart`.
library;

// `ResizeEdge` and `TitleBarStyle` kept their names and their values, so the
// native ones stand in for the 0.5.x enums; so do the two drag widgets, whose
// constructors take the same arguments.
export 'package:nativeapi/nativeapi.dart'
    show DragToMoveArea, DragToResizeArea, ResizeEdge, TitleBarStyle;

export 'src/legacy/calc_window_position.dart';
export 'src/legacy/window_listener.dart';
export 'src/legacy/window_manager.dart';
export 'src/legacy/window_options.dart';
export 'src/widgets/virtual_window_frame.dart';
export 'src/widgets/window_caption.dart';
export 'src/widgets/window_caption_button.dart';
