/// The pre-nativeapi window event callbacks.
///
/// nativeapi reports fewer events than the platform channels did: see the
/// per-callback notes for the ones that no longer fire.
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
abstract mixin class WindowListener {
  /// Emitted when the window is going to be closed.
  ///
  /// Only a `windowManager.close()` call with `setPreventClose(true)` reports
  /// this; the core library cannot intercept the system's own close yet.
  void onWindowClose() {}

  /// Emitted when the window gains focus.
  void onWindowFocus() {}

  /// Emitted when the window loses focus.
  void onWindowBlur() {}

  /// Emitted when window is maximized.
  void onWindowMaximize() {}

  /// Emitted when the window exits from a maximized state.
  void onWindowUnmaximize() {}

  /// Emitted when the window is minimized.
  void onWindowMinimize() {}

  /// Emitted when the window is restored from a minimized state.
  void onWindowRestore() {}

  /// Emitted after the window has been resized.
  void onWindowResize() {}

  /// Emitted once when the window has finished being resized.
  ///
  /// nativeapi reports one resize event, so this arrives with
  /// [onWindowResize] rather than after it.
  void onWindowResized() {}

  /// Emitted when the window is being moved to a new position.
  void onWindowMove() {}

  /// Emitted once when the window is moved to a new position.
  ///
  /// nativeapi reports one move event, so this arrives with [onWindowMove]
  /// rather than after it.
  void onWindowMoved() {}

  /// Emitted when the window enters a full-screen state.
  ///
  /// Derived from the window's state after a resize, so a full-screen change
  /// that resizes nothing goes unreported.
  void onWindowEnterFullScreen() {}

  /// Emitted when the window leaves a full-screen state.
  ///
  /// Derived from the window's state after a resize, so a full-screen change
  /// that resizes nothing goes unreported.
  void onWindowLeaveFullScreen() {}

  /// Emitted when the window entered a docked state.
  ///
  /// Never emitted: the core library has no aero-snap docking.
  ///
  /// @platforms windows
  void onWindowDocked() {}

  /// Emitted when the window leaves a docked state.
  ///
  /// Never emitted: the core library has no aero-snap docking.
  ///
  /// @platforms windows
  void onWindowUndocked() {}

  /// Emitted all events.
  void onWindowEvent(String eventName) {}
}
