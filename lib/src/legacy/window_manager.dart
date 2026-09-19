// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:io';
import 'dart:ui' show Brightness, Color, Offset, PlatformDispatcher, Rect, Size;

import 'package:flutter/foundation.dart' show ObserverList, VoidCallback;
import 'package:flutter/painting.dart' show Alignment;
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/src/legacy/calc_window_position.dart';
import 'package:window_manager/src/legacy/window_listener.dart';
import 'package:window_manager/src/legacy/window_options.dart';
import 'package:window_manager/src/native_guard.dart';

// The event names of the 0.5.x implementation; part of its public API.
const kWindowEventClose = 'close';
const kWindowEventFocus = 'focus';
const kWindowEventBlur = 'blur';
const kWindowEventMaximize = 'maximize';
const kWindowEventUnmaximize = 'unmaximize';
const kWindowEventMinimize = 'minimize';
const kWindowEventRestore = 'restore';
const kWindowEventResize = 'resize';
const kWindowEventResized = 'resized';
const kWindowEventMove = 'move';
const kWindowEventMoved = 'moved';
const kWindowEventEnterFullScreen = 'enter-full-screen';
const kWindowEventLeaveFullScreen = 'leave-full-screen';

const kWindowEventDocked = 'docked';
const kWindowEventUndocked = 'undocked';

@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
enum DockSide { left, right }

/// The pre-nativeapi `WindowManager` on top of a single [nativeapi.Window],
/// for code that has not moved to the native API yet.
///
/// Every call goes to the window the platform currently considers the app's
/// own. 0.5.x only ever addressed one window; an app with several of them
/// should use the native API, where each [nativeapi.Window] is addressed
/// directly.
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
class WindowManager {
  WindowManager._();

  /// The shared instance of [WindowManager].
  static final WindowManager instance = WindowManager._();

  final ObserverList<WindowListener> _listeners =
      ObserverList<WindowListener>();

  nativeapi.Window? _window;
  nativeapi.ListenerId? _nativeListenerId;

  bool _isPreventClose = false;
  bool _isMaximized = false;
  bool _isMinimized = false;
  bool _isFullScreen = false;

  /// The window every call below addresses, resolved once the platform has
  /// one. Null before the first window exists.
  nativeapi.Window? get _target {
    return _window ??= tryNative<nativeapi.Window?>(
      () => nativeapi.WindowManager.instance.getCurrent(),
    );
  }

  List<WindowListener> get listeners {
    return List<WindowListener>.from(_listeners);
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(WindowListener listener) {
    _listeners.add(listener);
    _wireNativeEvents();
  }

  void removeListener(WindowListener listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _unwireNativeEvents();
    }
  }

  double getDevicePixelRatio() {
    final views = PlatformDispatcher.instance.views;
    return views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  }

  /// Kept for source compatibility; nativeapi needs no initialization.
  Future<void> ensureInitialized() async {}

  /// Returns `int` - The ID of the window.
  ///
  /// This is nativeapi's own window id, not the `NSWindow` number or the
  /// `HWND` that 0.5.x returned.
  Future<int> getId() async {
    return _target?.id ?? 0;
  }

  /// You can call this to remove the window frame (title bar, outline border,
  /// etc), which is basically everything except the Flutter view, also can call
  /// setTitleBarStyle(TitleBarStyle.normal) to restore it.
  Future<void> setAsFrameless() async {
    final window = _target;
    if (window == null) return;
    window.titleBarStyle = nativeapi.TitleBarStyle.hidden;
    window.isWindowControlButtonsVisible = false;
  }

  /// Wait until ready to show.
  Future<void> waitUntilReadyToShow([
    WindowOptions? options,
    VoidCallback? callback,
  ]) async {
    if (options?.titleBarStyle != null) {
      await setTitleBarStyle(
        options!.titleBarStyle!,
        windowButtonVisibility: options.windowButtonVisibility ?? true,
      );
    }

    if (await isFullScreen()) await setFullScreen(false);
    if (await isMaximized()) await unmaximize();
    if (await isMinimized()) await restore();

    if (options?.size != null) await setSize(options!.size!);
    if (options?.center == true) await setAlignment(Alignment.center);
    if (options?.minimumSize != null) {
      await setMinimumSize(options!.minimumSize!);
    }
    if (options?.maximumSize != null) {
      await setMaximumSize(options!.maximumSize!);
    }
    if (options?.alwaysOnTop != null) {
      await setAlwaysOnTop(options!.alwaysOnTop!);
    }
    if (options?.fullScreen != null) await setFullScreen(options!.fullScreen!);
    if (options?.backgroundColor != null) {
      await setBackgroundColor(options!.backgroundColor!);
    }
    if (options?.skipTaskbar != null) {
      await setSkipTaskbar(options!.skipTaskbar!);
    }
    if (options?.title != null) await setTitle(options!.title!);

    if (callback != null) {
      callback();
    }
  }

  /// Force closing the window.
  ///
  /// The core library has no per-window close yet, so this quits the
  /// application.
  Future<void> destroy() async {
    tryNative(() => nativeapi.Application.instance.quit(0));
  }

  /// Try to close the window.
  ///
  /// With [setPreventClose] on, this reports `close` to the listeners and
  /// leaves the window alone, as before. Without it, the application quits:
  /// the core library has no per-window close yet.
  Future<void> close() async {
    if (_isPreventClose) {
      _emit(kWindowEventClose);
      return;
    }
    tryNative(() => nativeapi.Application.instance.quit(0));
  }

  /// Check if is intercepting the native close signal.
  Future<bool> isPreventClose() async {
    return _isPreventClose;
  }

  /// Set if intercept the native close signal. May useful when combine with the
  /// onclose event listener.
  ///
  /// Only [close] honours this. The title bar's own close button cannot be
  /// intercepted yet — the core library has no cancellable close event.
  Future<void> setPreventClose(bool isPreventClose) async {
    _isPreventClose = isPreventClose;
  }

  /// Focuses on the window.
  Future<void> focus() async {
    _target?.focus();
  }

  /// Removes focus from the window.
  ///
  /// @platforms macos,windows
  Future<void> blur() async {
    _target?.blur();
  }

  /// Returns `bool` - Whether window is focused.
  ///
  /// @platforms macos,windows
  Future<bool> isFocused() async {
    return _target?.isFocused ?? false;
  }

  /// Shows and gives focus to the window.
  Future<void> show({bool inactive = false}) async {
    final window = _target;
    if (window == null) return;
    if (window.isMinimized) {
      window.restore();
    }
    if (inactive) {
      window.showInactive();
    } else {
      window.show();
    }
  }

  /// Hides the window.
  Future<void> hide() async {
    _target?.hide();
  }

  /// Returns `bool` - Whether the window is visible to the user.
  Future<bool> isVisible() async {
    return _target?.isVisible ?? false;
  }

  /// Returns `bool` - Whether the window is maximized.
  Future<bool> isMaximized() async {
    return _target?.isMaximized ?? false;
  }

  /// Maximizes the window. [vertically] is accepted but ignored.
  Future<void> maximize({bool vertically = false}) async {
    _target?.maximize();
  }

  /// Unmaximizes the window.
  Future<void> unmaximize() async {
    _target?.unmaximize();
  }

  /// Returns `bool` - Whether the window is minimized.
  Future<bool> isMinimized() async {
    return _target?.isMinimized ?? false;
  }

  /// Minimizes the window. On some platforms the minimized window will be shown
  /// in the Dock.
  Future<void> minimize() async {
    _target?.minimize();
  }

  /// Restores the window from minimized state to its previous state.
  Future<void> restore() async {
    _target?.restore();
  }

  /// Returns `bool` - Whether the window is in fullscreen mode.
  Future<bool> isFullScreen() async {
    return _target?.isFullScreen ?? false;
  }

  /// Sets whether the window should be in fullscreen mode.
  Future<void> setFullScreen(bool isFullScreen) async {
    _target?.isFullScreen = isFullScreen;
    _syncFullScreen();
  }

  /// Returns `bool` - Whether the window is dockable or not.
  ///
  /// Aero-snap docking has no equivalent in the core library; this always
  /// answers false.
  ///
  /// @platforms windows
  Future<bool> isDockable() async {
    return false;
  }

  /// Returns `DockSide?` - Which side the window is docked to.
  ///
  /// Aero-snap docking has no equivalent in the core library; this always
  /// answers null.
  ///
  /// @platforms windows
  Future<DockSide?> isDocked() async {
    return null;
  }

  /// Docks the window.
  ///
  /// Aero-snap docking has no equivalent in the core library; this does
  /// nothing.
  ///
  /// @platforms windows
  Future<void> dock({required DockSide side, required int width}) async {}

  /// Undocks the window.
  ///
  /// Aero-snap docking has no equivalent in the core library; this does
  /// nothing and answers false.
  ///
  /// @platforms windows
  Future<bool> undock() async {
    return false;
  }

  /// This will make a window maintain an aspect ratio.
  Future<void> setAspectRatio(double aspectRatio) async {
    _target?.aspectRatio = aspectRatio;
  }

  /// Sets the background color of the window.
  Future<void> setBackgroundColor(Color backgroundColor) async {
    _target?.backgroundColor = backgroundColor;
  }

  /// Move the window to a position aligned with the screen.
  Future<void> setAlignment(Alignment alignment, {bool animate = false}) async {
    final windowSize = await getSize();
    final position = await calcWindowPosition(windowSize, alignment);
    await setPosition(position, animate: animate);
  }

  /// Moves window to the center of the screen.
  Future<void> center({bool animate = false}) async {
    await setAlignment(Alignment.center, animate: animate);
  }

  /// Returns `Rect` - The bounds of the window as Object.
  Future<Rect> getBounds() async {
    return _target?.bounds ?? Rect.zero;
  }

  /// Resizes and moves the window to the supplied bounds.
  Future<void> setBounds(
    Rect? bounds, {
    Offset? position,
    Size? size,
    bool animate = false,
  }) async {
    final window = _target;
    if (window == null) return;
    if (bounds != null) {
      window.bounds = bounds;
      return;
    }
    if (size != null) {
      window.setSize(size, animate);
    }
    if (position != null) {
      window.position = position;
    }
  }

  /// Returns `Size` - Contains the window's width and height.
  Future<Size> getSize() async {
    return _target?.size ?? Size.zero;
  }

  /// Resizes the window to `width` and `height`.
  Future<void> setSize(Size size, {bool animate = false}) async {
    _target?.setSize(size, animate);
  }

  /// Returns `Offset` - Contains the window's current position.
  Future<Offset> getPosition() async {
    return _target?.position ?? Offset.zero;
  }

  /// Moves window to position. [animate] is accepted but ignored.
  Future<void> setPosition(Offset position, {bool animate = false}) async {
    _target?.position = position;
  }

  /// Sets the minimum size of window to `width` and `height`.
  Future<void> setMinimumSize(Size size) async {
    _target?.minimumSize = size;
  }

  /// Sets the maximum size of window to `width` and `height`.
  Future<void> setMaximumSize(Size size) async {
    _target?.maximumSize = size;
  }

  /// Returns `bool` - Whether the window can be manually resized by the user.
  Future<bool> isResizable() async {
    return _target?.isResizable ?? false;
  }

  /// Sets whether the window can be manually resized by the user.
  Future<void> setResizable(bool isResizable) async {
    _target?.isResizable = isResizable;
  }

  /// Returns `bool` - Whether the window can be moved by user.
  ///
  /// @platforms macos
  Future<bool> isMovable() async {
    return _target?.isMovable ?? false;
  }

  /// Sets whether the window can be moved by user.
  ///
  /// @platforms macos
  Future<void> setMovable(bool isMovable) async {
    _target?.isMovable = isMovable;
  }

  /// Returns `bool` - Whether the window can be manually minimized by the user.
  ///
  /// @platforms macos,windows
  Future<bool> isMinimizable() async {
    return _target?.isMinimizable ?? false;
  }

  /// Sets whether the window can be manually minimized by user.
  ///
  /// @platforms macos,windows
  Future<void> setMinimizable(bool isMinimizable) async {
    _target?.isMinimizable = isMinimizable;
  }

  /// Returns `bool` - Whether the window can be manually closed by user.
  ///
  /// @platforms windows
  Future<bool> isClosable() async {
    return _target?.isClosable ?? false;
  }

  /// Returns `bool` - Whether the window can be manually maximized by the user.
  ///
  /// @platforms macos,windows
  Future<bool> isMaximizable() async {
    return _target?.isMaximizable ?? false;
  }

  /// Sets whether the window can be manually maximized by the user.
  Future<void> setMaximizable(bool isMaximizable) async {
    _target?.isMaximizable = isMaximizable;
  }

  /// Sets whether the window can be manually closed by user.
  ///
  /// @platforms macos,windows
  Future<void> setClosable(bool isClosable) async {
    _target?.isClosable = isClosable;
  }

  /// Returns `bool` - Whether the window is always on top of other windows.
  Future<bool> isAlwaysOnTop() async {
    return _target?.isAlwaysOnTop ?? false;
  }

  /// Sets whether the window should show always on top of other windows.
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {
    _target?.isAlwaysOnTop = isAlwaysOnTop;
  }

  /// Returns `bool` - Whether the window is always below other windows.
  Future<bool> isAlwaysOnBottom() async {
    return _target?.isAlwaysOnBottom ?? false;
  }

  /// Sets whether the window should show always below other windows.
  ///
  /// @platforms linux,windows
  Future<void> setAlwaysOnBottom(bool isAlwaysOnBottom) async {
    _target?.isAlwaysOnBottom = isAlwaysOnBottom;
  }

  /// Returns `String` - The title of the native window.
  Future<String> getTitle() async {
    return _target?.title ?? '';
  }

  /// Changes the title of native window to title.
  Future<void> setTitle(String title) async {
    _target?.title = title;
  }

  /// Changes the title bar style of native window.
  Future<void> setTitleBarStyle(
    nativeapi.TitleBarStyle titleBarStyle, {
    bool windowButtonVisibility = true,
  }) async {
    final window = _target;
    if (window == null) return;
    window.titleBarStyle = titleBarStyle;
    window.isWindowControlButtonsVisible = windowButtonVisibility;
  }

  /// Returns `int` - The title bar height of the native window.
  Future<int> getTitleBarHeight() async {
    final window = _target;
    if (window == null) return 0;
    final height = window.contentBounds.top - window.bounds.top;
    return height < 0 ? 0 : height.round();
  }

  /// Returns `bool` - Whether skipping taskbar is enabled.
  Future<bool> isSkipTaskbar() async {
    final window = _target;
    return window == null ? false : !window.isVisibleInTaskbar;
  }

  /// Makes the window not show in the taskbar / dock.
  Future<void> setSkipTaskbar(bool isSkipTaskbar) async {
    _target?.isVisibleInTaskbar = !isSkipTaskbar;
  }

  /// Sets progress value in progress bar. Valid range is [0, 1.0].
  ///
  /// @platforms macos,windows
  Future<void> setProgressBar(double progress) async {
    tryNative(() => nativeapi.Application.instance.setProgressBar(progress));
  }

  /// Sets window/taskbar icon.
  ///
  /// @platforms windows
  Future<void> setIcon(String iconPath) async {
    final executableDirectory = File(Platform.resolvedExecutable).parent.path;
    final separator = Platform.pathSeparator;
    tryNative(
      () => nativeapi.Application.instance.setIcon(
        '$executableDirectory${separator}data${separator}flutter_assets'
        '$separator$iconPath',
      ),
    );
  }

  /// Returns `bool` - Whether the window is visible on all workspaces.
  ///
  /// @platforms macos
  Future<bool> isVisibleOnAllWorkspaces() async {
    return _target?.isVisibleOnAllWorkspaces ?? false;
  }

  /// Sets whether the window should be visible on all workspaces.
  ///
  /// [visibleOnFullScreen] is accepted but ignored.
  ///
  /// @platforms macos
  Future<void> setVisibleOnAllWorkspaces(
    bool visible, {
    bool? visibleOnFullScreen,
  }) async {
    _target?.isVisibleOnAllWorkspaces = visible;
  }

  /// Set/unset label on taskbar(dock) app icon
  ///
  /// Note that it's required to request access at your AppDelegate.swift like
  /// this:
  /// UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge])
  ///
  /// @platforms macos
  Future<void> setBadgeLabel([String? label]) async {
    tryNative(() => nativeapi.Application.instance.setBadgeLabel(label ?? ''));
  }

  /// Returns `bool` - Whether the window has a shadow. On Windows, always
  /// returns true unless window is frameless.
  ///
  /// @platforms macos,windows
  Future<bool> hasShadow() async {
    return _target?.hasShadow ?? false;
  }

  /// Sets whether the window should have a shadow. On Windows, doesn't do
  /// anything unless window is frameless.
  Future<void> setHasShadow(bool hasShadow) async {
    _target?.hasShadow = hasShadow;
  }

  /// Returns `double` - between 0.0 (fully transparent) and 1.0 (fully opaque).
  Future<double> getOpacity() async {
    return _target?.opacity ?? 1.0;
  }

  /// Sets the opacity of the window.
  Future<void> setOpacity(double opacity) async {
    _target?.opacity = opacity;
  }

  /// Sets the brightness of the window.
  Future<void> setBrightness(Brightness brightness) async {
    tryNative(
      () => nativeapi.Application.instance.setBrightness(switch (brightness) {
        Brightness.light => nativeapi.Brightness.light,
        Brightness.dark => nativeapi.Brightness.dark,
      }),
    );
  }

  /// Makes the window ignore all mouse events.
  ///
  /// All mouse events happened in this window will be passed to the window
  /// below this window, but if this window has focus, it will still receive
  /// keyboard events. [forward] is accepted but ignored.
  Future<void> setIgnoreMouseEvents(bool ignore, {bool forward = false}) async {
    _target?.isIgnoreMouseEvents = ignore;
  }

  /// Opens the window menu.
  ///
  /// The core library has no window menu; this does nothing.
  Future<void> popUpWindowMenu() async {}

  /// Starts a window drag based on the specified mouse-down event.
  Future<void> startDragging() async {
    _target?.startDragging();
  }

  /// Starts a window resize based on the specified mouse-down & mouse-move
  /// event.
  ///
  /// @platforms linux,windows
  Future<void> startResizing(nativeapi.ResizeEdge resizeEdge) async {
    _target?.startResizing(resizeEdge);
  }

  /// Grabs the keyboard.
  ///
  /// The core library does not grab the keyboard; this answers false.
  ///
  /// @platforms linux
  Future<bool> grabKeyboard() async {
    return false;
  }

  /// Ungrabs the keyboard.
  ///
  /// The core library does not grab the keyboard; this answers false.
  ///
  /// @platforms linux
  Future<bool> ungrabKeyboard() async {
    return false;
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  void _wireNativeEvents() {
    if (_nativeListenerId != null) return;
    _nativeListenerId = tryNative(
      () => nativeapi.WindowManager.instance.addListener(_onNativeEvent),
    );
  }

  void _unwireNativeEvents() {
    final listenerId = _nativeListenerId;
    if (listenerId == null) return;
    nativeapi.WindowManager.instance.removeListener(listenerId);
    _nativeListenerId = null;
  }

  // nativeapi reports one `restored` for both "no longer maximized" and
  // "no longer minimized", and reports no full-screen events at all, so the
  // 0.5.x event set is rebuilt from what the window says afterwards.
  void _onNativeEvent(nativeapi.WindowEvent event) {
    switch (event) {
      case nativeapi.WindowFocusedEvent():
        _emit(kWindowEventFocus);
      case nativeapi.WindowBlurredEvent():
        _emit(kWindowEventBlur);
      case nativeapi.WindowMaximizedEvent():
        _isMaximized = true;
        _emit(kWindowEventMaximize);
      case nativeapi.WindowMinimizedEvent():
        _isMinimized = true;
        _emit(kWindowEventMinimize);
      case nativeapi.WindowRestoredEvent():
        if (_isMinimized) {
          _isMinimized = false;
          _emit(kWindowEventRestore);
        } else if (_isMaximized) {
          _isMaximized = false;
          _emit(kWindowEventUnmaximize);
        } else {
          _emit(kWindowEventRestore);
        }
      case nativeapi.WindowResizedEvent():
        _syncFullScreen();
        _emit(kWindowEventResize);
        _emit(kWindowEventResized);
      case nativeapi.WindowMovedEvent():
        _emit(kWindowEventMove);
        _emit(kWindowEventMoved);
      case nativeapi.WindowCreatedEvent():
      case nativeapi.WindowClosedEvent():
        break;
    }
  }

  void _syncFullScreen() {
    final isFullScreen = _target?.isFullScreen ?? false;
    if (isFullScreen == _isFullScreen) return;
    _isFullScreen = isFullScreen;
    _emit(
      isFullScreen ? kWindowEventEnterFullScreen : kWindowEventLeaveFullScreen,
    );
  }

  void _emit(String eventName) {
    for (final listener in listeners) {
      if (!_listeners.contains(listener)) {
        continue;
      }
      listener.onWindowEvent(eventName);
      final Map<String, void Function()> funcMap = {
        kWindowEventClose: listener.onWindowClose,
        kWindowEventFocus: listener.onWindowFocus,
        kWindowEventBlur: listener.onWindowBlur,
        kWindowEventMaximize: listener.onWindowMaximize,
        kWindowEventUnmaximize: listener.onWindowUnmaximize,
        kWindowEventMinimize: listener.onWindowMinimize,
        kWindowEventRestore: listener.onWindowRestore,
        kWindowEventResize: listener.onWindowResize,
        kWindowEventResized: listener.onWindowResized,
        kWindowEventMove: listener.onWindowMove,
        kWindowEventMoved: listener.onWindowMoved,
        kWindowEventEnterFullScreen: listener.onWindowEnterFullScreen,
        kWindowEventLeaveFullScreen: listener.onWindowLeaveFullScreen,
        kWindowEventDocked: listener.onWindowDocked,
        kWindowEventUndocked: listener.onWindowUndocked,
      };
      funcMap[eventName]?.call();
    }
  }
}

@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
final windowManager = WindowManager.instance;
