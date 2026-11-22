// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:io';
import 'dart:ui' show Brightness, Color, Offset, PlatformDispatcher, Rect, Size;

import 'package:flutter/foundation.dart'
    show ObserverList, VoidCallback, visibleForTesting;
import 'package:flutter/painting.dart' show Alignment;
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:nativeapi_flutter/nativeapi_flutter.dart'
    show
        ColorToNative,
        NativeSizeToSize,
        OffsetToNative,
        PointToOffset,
        RectToNative,
        RectangleToRect,
        SizeToNative;
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

// Reported by 0.5.x through onWindowEvent only, without a named constant.
const _kWindowEventShow = 'show';
const _kWindowEventHide = 'hide';

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

  // Move/resize events are frequent; only rebuild the immutable iteration
  // snapshot when subscriptions change.
  List<WindowListener> _listenerSnapshot = const <WindowListener>[];

  nativeapi.Window? _window;
  nativeapi.ListenerId? _nativeListenerId;

  /// Addresses [window] instead of the platform's current window, or goes
  /// back to the current window with null. For tests of this bridge only.
  @visibleForTesting
  void debugBindWindow(nativeapi.Window? window) {
    _unwireNativeEvents();
    _window = window;
    if (_listeners.isNotEmpty || _isPreventClose) _wireNativeEvents();
  }

  bool _isPreventClose = false;
  bool _isDestroying = false;
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
    return List<WindowListener>.from(_listenerSnapshot);
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(WindowListener listener) {
    _listeners.add(listener);
    _listenerSnapshot = List<WindowListener>.of(_listeners);
    _wireNativeEvents();
  }

  void removeListener(WindowListener listener) {
    _listeners.remove(listener);
    _listenerSnapshot = List<WindowListener>.of(_listeners);
    if (_listeners.isEmpty && !_isPreventClose) {
      _unwireNativeEvents();
    }
  }

  double getDevicePixelRatio() {
    final views = PlatformDispatcher.instance.views;
    return views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  }

  /// Connects listeners registered before the native window was available.
  Future<void> ensureInitialized() async {
    if (_listeners.isNotEmpty || _isPreventClose) _wireNativeEvents();
  }

  /// Returns `int` - The ID of the window.
  ///
  /// On macOS this is the window-server number; on Windows it is the HWND,
  /// matching 0.5.x. Other platforms return nativeapi's window id.
  Future<int> getId() async {
    final window = _target;
    if (window == null) return 0;
    if (Platform.isWindows) return window.nativeObject.address;
    if (Platform.isMacOS) return window.nativeNumber;
    return window.id;
  }

  /// You can call this to remove the window frame (title bar, outline border,
  /// etc), which is basically everything except the Flutter view, also can call
  /// setTitleBarStyle(TitleBarStyle.normal) to restore it.
  Future<void> setAsFrameless() async {
    final window = _target;
    if (window == null) return;
    window.setFrameless(true);
    if (Platform.isMacOS) {
      window.hasShadow = false;
      window.backgroundColor = const Color(0x00000000).toNative();
    }
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

  /// Force closing the window, past [setPreventClose].
  ///
  /// Closing the app's last window ends the app, as the platform's runner
  /// decides.
  Future<void> destroy() async {
    _isDestroying = true;
    await close();
  }

  /// Try to close the window.
  ///
  /// With [setPreventClose] on, the window stays and the listeners get
  /// `onWindowClose`, as for the title bar's close button.
  Future<void> close() async {
    final window = _target;
    final closing =
        window != null &&
        (tryNative(() {
              if (!nativeapi.Window.isCloseSupported()) return false;
              _wireNativeEvents();
              return window.close();
            }) ??
            false);
    if (!closing) {
      // Without a native close, as on a platform the core cannot close a
      // window on, prevent-close still reports and otherwise the app quits.
      final destroying = _isDestroying;
      _isDestroying = false;
      if (!destroying) {
        _emit(kWindowEventClose);
        if (_isPreventClose) return;
      }
      tryNative(() => nativeapi.Application.instance.quit(0));
    }
  }

  /// Check if is intercepting the native close signal.
  Future<bool> isPreventClose() async {
    return _isPreventClose;
  }

  /// Set if intercept the native close signal. May useful when combine with the
  /// onclose event listener.
  ///
  /// The title bar's close button and [close] then report `onWindowClose`
  /// and leave the window open; [destroy] still closes it.
  Future<void> setPreventClose(bool isPreventClose) async {
    _isPreventClose = isPreventClose;
    if (isPreventClose) {
      _wireNativeEvents();
    } else if (_listeners.isEmpty) {
      _unwireNativeEvents();
    }
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
  ///
  /// Listeners get `onWindowEvent('show')` when this call makes a hidden
  /// window visible.
  Future<void> show({bool inactive = false}) async {
    final window = _target;
    if (window == null) return;
    final wasVisible = window.isVisible;
    if (window.isMinimized) {
      window.restore();
    }
    if (inactive) {
      window.showInactive();
    } else {
      window.show();
    }
    // nativeapi has no show/hide event; 0.5.x reported both through
    // onWindowEvent, which apps use to pause and resume work.
    // Check the result: the platform may refuse or defer the change.
    if (!wasVisible && window.isVisible) _emit(_kWindowEventShow);
  }

  /// Hides the window.
  ///
  /// Listeners get `onWindowEvent('hide')` when this call hides a window that
  /// was visible or minimized.
  Future<void> hide() async {
    final window = _target;
    if (window == null) return;
    // macOS reports a minimized window as not visible.
    final wasShown = window.isVisible || window.isMinimized;
    window.hide();
    if (wasShown && !window.isVisible) _emit(_kWindowEventHide);
  }

  /// Returns `bool` - Whether the window is visible to the user.
  Future<bool> isVisible() async {
    return _target?.isVisible ?? false;
  }

  /// Returns `bool` - Whether the window is maximized.
  Future<bool> isMaximized() async {
    return _target?.isMaximized ?? false;
  }

  /// Maximizes the window, or only its height on Windows with [vertically].
  Future<void> maximize({bool vertically = false}) async {
    final window = _target;
    if (window == null) return;
    if (vertically && nativeapi.Window.isVerticalMaximizeSupported()) {
      window.setMaximizedVertically(true);
    } else {
      window.maximize();
    }
  }

  /// Unmaximizes the window.
  Future<void> unmaximize() async {
    final window = _target;
    if (window == null) return;
    if (window.isMaximizedVertically) window.setMaximizedVertically(false);
    window.unmaximize();
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
  }

  /// Whether the system supports reserving desktop space for a docked window.
  ///
  /// @platforms windows
  Future<bool> isDockable() async {
    return tryNative(nativeapi.Window.isDockingSupported) ?? false;
  }

  /// Returns the edge reserved by this window, or null when undocked.
  ///
  /// @platforms windows
  Future<DockSide?> isDocked() async {
    return switch (_target?.dockSide) {
      nativeapi.WindowDockSide.left => DockSide.left,
      nativeapi.WindowDockSide.right => DockSide.right,
      _ => null,
    };
  }

  /// Reserves [width] logical pixels at the monitor's [side] for this window.
  ///
  /// @platforms windows
  Future<void> dock({required DockSide side, required int width}) async {
    _wireNativeEvents();
    _target?.dock(switch (side) {
      DockSide.left => nativeapi.WindowDockSide.left,
      DockSide.right => nativeapi.WindowDockSide.right,
    }, width.toDouble());
  }

  /// Removes the desktop reservation and restores the window's previous bounds.
  ///
  /// @platforms windows
  Future<bool> undock() async {
    return _target?.undock() ?? false;
  }

  /// This will make a window maintain an aspect ratio.
  Future<void> setAspectRatio(double aspectRatio) async {
    _target?.aspectRatio = aspectRatio;
  }

  /// Sets the background color of the window.
  Future<void> setBackgroundColor(Color backgroundColor) async {
    _target?.backgroundColor = backgroundColor.toNative();
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
    return _target?.bounds.toRect() ?? Rect.zero;
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
    if (bounds == null && position == null && size == null) return;
    final current = window.bounds.toRect();
    final target =
        bounds ??
        Rect.fromLTWH(
          position?.dx ?? current.left,
          position?.dy ?? current.top,
          size?.width ?? current.width,
          size?.height ?? current.height,
        );
    if (!animate || !window.animateBounds(target.toNative())) {
      window.bounds = target.toNative();
    }
  }

  /// Returns `Size` - Contains the window's width and height.
  Future<Size> getSize() async {
    return _target?.size.toSize() ?? Size.zero;
  }

  /// Resizes the window to `width` and `height`.
  Future<void> setSize(Size size, {bool animate = false}) async {
    _target?.setSize(size.toNative(), animate);
  }

  /// Returns `Offset` - Contains the window's current position.
  Future<Offset> getPosition() async {
    return _target?.position.toOffset() ?? Offset.zero;
  }

  /// Moves window to position, with a native animation on macOS if requested.
  Future<void> setPosition(Offset position, {bool animate = false}) async {
    await setBounds(null, position: position, animate: animate);
  }

  /// Sets the minimum size of window to `width` and `height`.
  Future<void> setMinimumSize(Size size) async {
    _target?.minimumSize = size.toNative();
  }

  /// Sets the maximum size of window to `width` and `height`.
  Future<void> setMaximumSize(Size size) async {
    _target?.maximumSize = size.toNative();
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
    final wasFrameless = window.isFrameless;
    window.titleBarStyle = titleBarStyle;
    window.isWindowControlButtonsVisible = windowButtonVisibility;
    if (Platform.isMacOS && wasFrameless) window.hasShadow = true;
  }

  /// Returns `int` - The title bar height of the native window.
  Future<int> getTitleBarHeight() async {
    final window = _target;
    if (window == null) return 0;
    final height = window.contentBounds.y - window.bounds.y;
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
  /// [visibleOnFullScreen] also allows joining full-screen spaces on macOS.
  ///
  /// @platforms macos
  Future<void> setVisibleOnAllWorkspaces(
    bool visible, {
    bool? visibleOnFullScreen,
  }) async {
    final window = _target;
    if (window == null) return;
    window.isVisibleOnAllWorkspaces = visible;
    window.setVisibleOnFullScreen(visibleOnFullScreen ?? false);
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
  /// keyboard events. With [forward], the window still hears the pointer move
  /// over it where the platform can tell it (macOS, Windows and X11); elsewhere
  /// the mouse events are ignored without it.
  Future<void> setIgnoreMouseEvents(bool ignore, {bool forward = false}) async {
    final window = _target;
    if (window == null) return;
    if (!window.setIgnoreMouseEvents(ignore, forward) && forward) {
      window.setIgnoreMouseEvents(ignore, false);
    }
  }

  /// Opens the window menu at the cursor.
  ///
  /// The system menu exists on Windows and on Linux window managers that
  /// offer one; elsewhere this does nothing.
  Future<void> popUpWindowMenu() async {
    final window = _target;
    if (window == null) return;
    tryNative(() {
      if (!nativeapi.Window.isSystemMenuSupported()) return;
      final cursor = nativeapi.DisplayManager.instance
          .getCursorPosition()
          .toOffset();
      final content = window.contentBounds.toRect();
      window.showSystemMenu((cursor - content.topLeft).toNative());
    });
  }

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
  /// Exclusive on Linux X11; returns false on Wayland and other platforms.
  ///
  /// @platforms linux
  Future<bool> grabKeyboard() async {
    return _target?.grabKeyboard() ?? false;
  }

  /// Ungrabs the keyboard.
  ///
  /// Exclusive on Linux X11; returns false on Wayland and other platforms.
  ///
  /// @platforms linux
  Future<bool> ungrabKeyboard() async {
    return _target?.ungrabKeyboard() ?? false;
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  // A listener on the window itself, not on nativeapi's WindowManager: close
  // requests reach only the window's own listeners, and other windows of the
  // app stay out of the 0.5.x events.
  void _wireNativeEvents() {
    if (_nativeListenerId != null) return;
    final window = _target;
    if (window == null) return;
    // State may have changed while there were no listeners, or before the
    // first listener was added. A restored event alone cannot tell us whether
    // the window was minimized or maximized.
    _isMaximized = window.isMaximized;
    _isMinimized = window.isMinimized;
    _isFullScreen = window.isFullScreen;
    _nativeListenerId = tryNative(() => window.addListener(_onNativeEvent));
  }

  void _unwireNativeEvents() {
    final listenerId = _nativeListenerId;
    if (listenerId == null) return;
    _window?.removeListener(listenerId);
    _nativeListenerId = null;
  }

  // nativeapi reports one `restored` for both "no longer maximized" and
  // "no longer minimized", so that pair is told apart from what came before.
  void _onNativeEvent(nativeapi.WindowEvent event) {
    switch (event) {
      case nativeapi.WindowCloseRequestedEvent(:final request):
        final destroying = _isDestroying;
        _isDestroying = false;
        if (destroying) break;
        if (_isPreventClose) request.cancel();
        _emit(kWindowEventClose);
      case nativeapi.WindowDockedEvent():
        _emit(kWindowEventDocked);
      case nativeapi.WindowUndockedEvent():
        _emit(kWindowEventUndocked);
      case nativeapi.WindowEnteredFullScreenEvent():
        _setFullScreenState(true);
      case nativeapi.WindowExitedFullScreenEvent():
        _setFullScreenState(false);
      case nativeapi.WindowFocusedEvent():
        _emit(kWindowEventFocus);
      case nativeapi.WindowBlurredEvent():
        _emit(kWindowEventBlur);
      case nativeapi.WindowMaximizedEvent():
        // A minimized window that was maximized comes back with this event
        // alone, as 0.5.x reported it on Windows.
        _isMinimized = false;
        _isMaximized = true;
        _emit(kWindowEventMaximize);
      case nativeapi.WindowMinimizedEvent():
        _isMinimized = true;
        _emit(kWindowEventMinimize);
      case nativeapi.WindowRestoredEvent():
        final wasMinimized = _isMinimized;
        final wasMaximized = _isMaximized;
        _isMinimized = false;
        // Leaving the minimized state may land back in the maximized one.
        _isMaximized = _target?.isMaximized ?? false;
        if (!wasMinimized && wasMaximized && !_isMaximized) {
          _emit(kWindowEventUnmaximize);
        } else {
          _emit(kWindowEventRestore);
        }
      case nativeapi.WindowResizedEvent():
        _emit(kWindowEventResize);
        _emit(kWindowEventResized);
      case nativeapi.WindowMovedEvent():
        _emit(kWindowEventMove);
        _emit(kWindowEventMoved);
      // Created, closed, property and occlusion changes have no 0.5.x
      // counterpart. A default rather than a list keeps this switch compiling
      // when a nativeapi 0.5.x release adds a WindowEvent subclass.
      default:
        break;
    }
  }

  void _setFullScreenState(bool isFullScreen) {
    if (isFullScreen == _isFullScreen) return;
    _isFullScreen = isFullScreen;
    _emit(
      isFullScreen ? kWindowEventEnterFullScreen : kWindowEventLeaveFullScreen,
    );
  }

  void _emit(String eventName) {
    if (_listeners.isEmpty) return;
    // Existing listeners receive this event. Callbacks may subscribe others,
    // which join only on the next event rather than this iteration.
    for (final listener in _listenerSnapshot) {
      if (!_listeners.contains(listener)) continue;
      listener.onWindowEvent(eventName);
      // A switch, not a map of tear-offs per listener: move and resize arrive
      // many times per second while the user drags the window.
      switch (eventName) {
        case kWindowEventClose:
          listener.onWindowClose();
        case kWindowEventFocus:
          listener.onWindowFocus();
        case kWindowEventBlur:
          listener.onWindowBlur();
        case kWindowEventMaximize:
          listener.onWindowMaximize();
        case kWindowEventUnmaximize:
          listener.onWindowUnmaximize();
        case kWindowEventMinimize:
          listener.onWindowMinimize();
        case kWindowEventRestore:
          listener.onWindowRestore();
        case kWindowEventResize:
          listener.onWindowResize();
        case kWindowEventResized:
          listener.onWindowResized();
        case kWindowEventMove:
          listener.onWindowMove();
        case kWindowEventMoved:
          listener.onWindowMoved();
        case kWindowEventEnterFullScreen:
          listener.onWindowEnterFullScreen();
        case kWindowEventLeaveFullScreen:
          listener.onWindowLeaveFullScreen();
        case kWindowEventDocked:
          listener.onWindowDocked();
        case kWindowEventUndocked:
          listener.onWindowUndocked();
      }
    }
  }
}

@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:window_manager/window_manager.dart.',
)
final windowManager = WindowManager.instance;
