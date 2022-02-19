abstract class WindowListener {
  /// Emitted when the window is going to be closed.
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

  /// Emitted when the window is being moved to a new position.
  void onWindowMove() {}

  /// Emitted when the window enters a full-screen state.
  void onWindowEnterFullScreen() {}

  /// Emitted when the window leaves a full-screen state.
  void onWindowLeaveFullScreen() {}

  /// Emitted all events.
  void onWindowEvent(String eventName) {}
}
