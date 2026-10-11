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
  /// Reported for both `windowManager.close()` and the native close button.
  /// With `setPreventClose(true)` the request is cancelled before this callback.
  /// `destroy()` bypasses this callback and the compatibility layer's veto.
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
  /// Forwarded from the native window's full-screen event.
  void onWindowEnterFullScreen() {}

  /// Emitted when the window leaves a full-screen state.
  ///
  /// Forwarded from the native window's full-screen event.
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
