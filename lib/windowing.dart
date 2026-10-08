/// Flutter's experimental multi-window API, bridged to window_manager.
///
/// `nativeWindowOf(controller)` (or `controller.nativeWindow`) answers the
/// `Window` behind one of Flutter's window controllers, so every window an app
/// opens that way gets the whole native API. This re-exports
/// `package:nativeapi_flutter/windowing.dart`; read it for which Flutter
/// releases it follows and how an app turns the multi-window API on.
library;

export 'package:nativeapi_flutter/windowing.dart';
