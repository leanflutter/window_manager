import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'resize_edge.dart';
import 'window_listener.dart';

const kWindowEventClose = 'close';
const kWindowEventFocus = 'focus';
const kWindowEventBlur = 'blur';
const kWindowEventMaximize = 'maximize';
const kWindowEventUnmaximize = 'unmaximize';
const kWindowEventMinimize = 'minimize';
const kWindowEventRestore = 'restore';
const kWindowEventResize = 'resize';
const kWindowEventMove = 'move';
const kWindowEventEnterFullScreen = 'enter-full-screen';
const kWindowEventLeaveFullScreen = 'leave-full-screen';

// WindowManager
class WindowManager {
  WindowManager._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [WindowManager].
  static final WindowManager instance = WindowManager._();

  final MethodChannel _channel = const MethodChannel('window_manager');

  ObserverList<WindowListener>? _listeners = ObserverList<WindowListener>();

  Future<void> _methodCallHandler(MethodCall call) async {
    if (_listeners == null) return;

    for (final WindowListener listener in listeners) {
      if (!_listeners!.contains(listener)) {
        return;
      }

      if (call.method != 'onEvent') throw UnimplementedError();

      String eventName = call.arguments['eventName'];
      listener.onWindowEvent(eventName);
      Map<String, Function> funcMap = {
        kWindowEventClose: listener.onWindowClose,
        kWindowEventFocus: listener.onWindowFocus,
        kWindowEventBlur: listener.onWindowBlur,
        kWindowEventMaximize: listener.onWindowMaximize,
        kWindowEventUnmaximize: listener.onWindowUnmaximize,
        kWindowEventMinimize: listener.onWindowMinimize,
        kWindowEventRestore: listener.onWindowRestore,
        kWindowEventResize: listener.onWindowResize,
        kWindowEventMove: listener.onWindowMove,
        kWindowEventEnterFullScreen: listener.onWindowEnterFullScreen,
        kWindowEventLeaveFullScreen: listener.onWindowLeaveFullScreen,
      };
      funcMap[eventName]!();
    }
  }

  List<WindowListener> get listeners {
    final List<WindowListener> localListeners =
        List<WindowListener>.from(_listeners!);
    return localListeners;
  }

  bool get hasListeners {
    return _listeners!.isNotEmpty;
  }

  void addListener(WindowListener listener) {
    _listeners!.add(listener);
  }

  void removeListener(WindowListener listener) {
    _listeners!.remove(listener);
  }

  Future<void> ensureInitialized() async {
    await _channel.invokeMethod('ensureInitialized');
  }

  Future<void> setAsFrameless() async {
    await _channel.invokeMethod('setAsFrameless');
  }

  Future<void> waitUntilReadyToShow() async {
    await _channel.invokeMethod('waitUntilReadyToShow');
  }

  /// Force closing the window.
  ///
  /// @platforms macos,windows
  Future<void> destroy() async {
    await _channel.invokeMethod('destroy');
  }

  /// Try to close the window.
  Future<void> close() async {
    await _channel.invokeMethod('close');
  }

  /// Check if is intercepting the native close signal.
  Future<bool> isPreventClose() async {
    return await _channel.invokeMethod("isPreventClose");
  }

  /// Set if intercept the native close signal. May useful when combine with the onclose event listener.
  /// This will also prevent the manually triggered close event.
  Future<void> setPreventClose(bool isPreventClose) async {
    final Map<String, dynamic> arguments = {
      'isPreventClose': isPreventClose,
    };
    await _channel.invokeMethod('setPreventClose', arguments);
  }

  /// Focuses on the window.
  Future<void> focus() async {
    await _channel.invokeMethod('focus');
  }

  /// Removes focus from the window.
  ///
  /// @platforms macos,windows
  Future<void> blur() async {
    await _channel.invokeMethod('blur');
  }

  /// Returns `bool` - Whether window is focused.
  ///
  /// @platforms macos,windows
  Future<bool> isFocused() async {
    return await _channel.invokeMethod('isFocused');
  }

  /// Shows and gives focus to the window.
  Future<void> show({bool inactive = false}) async {
    bool isMinimized = await this.isMinimized();
    if (isMinimized) {
      await this.restore();
    }
    final Map<String, dynamic> arguments = {
      'inactive': inactive,
    };
    await _channel.invokeMethod('show', arguments);
  }

  /// Hides the window.
  Future<void> hide() async {
    await _channel.invokeMethod('hide');
  }

  /// Returns `bool` - Whether the window is visible to the user.
  Future<bool> isVisible() async {
    return await _channel.invokeMethod('isVisible');
  }

  /// Returns `bool` - Whether the window is maximized.
  Future<bool> isMaximized() async {
    return await _channel.invokeMethod('isMaximized');
  }

  /// Maximizes the window.
  Future<void> maximize() async {
    await _channel.invokeMethod('maximize');
  }

  /// Unmaximizes the window.
  Future<void> unmaximize() async {
    await _channel.invokeMethod('unmaximize');
  }

  /// Returns `bool` - Whether the window is minimized.
  Future<bool> isMinimized() async {
    return await _channel.invokeMethod('isMinimized');
  }

  /// Minimizes the window. On some platforms the minimized window will be shown in the Dock.
  Future<void> minimize() async {
    await _channel.invokeMethod('minimize');
  }

  /// Restores the window from minimized state to its previous state.
  Future<void> restore() async {
    await _channel.invokeMethod('restore');
  }

  /// Returns `bool` - Whether the window is in fullscreen mode.
  Future<bool> isFullScreen() async {
    return await _channel.invokeMethod('isFullScreen');
  }

  /// Sets whether the window should be in fullscreen mode.
  Future<void> setFullScreen(bool isFullScreen) async {
    final Map<String, dynamic> arguments = {
      'isFullScreen': isFullScreen,
    };
    await _channel.invokeMethod('setFullScreen', arguments);
  }

  /// This will make a window maintain an aspect ratio.
  Future<void> setAspectRatio(double aspectRatio) async {
    final Map<String, dynamic> arguments = {
      'aspectRatio': aspectRatio,
    };
    await _channel.invokeMethod('setAspectRatio', arguments);
  }

  /// Sets the background color of the window.
  Future<void> setBackgroundColor(Color backgroundColor) async {
    final Map<String, dynamic> arguments = {
      'backgroundColorA': backgroundColor.alpha,
      'backgroundColorR': backgroundColor.red,
      'backgroundColorG': backgroundColor.green,
      'backgroundColorB': backgroundColor.blue,
    };
    await _channel.invokeMethod('setBackgroundColor', arguments);
  }

  /// Returns `Rect` - The bounds of the window as Object.
  Future<Rect> getBounds() async {
    Offset position = await getPosition();
    Size size = await getSize();
    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Resizes and moves the window to the supplied bounds.
  Future<void> setBounds(Rect bounds, {animate = false}) async {
    await setPosition(bounds.topLeft);
    await setSize(bounds.size);
  }

  /// Returns `Offset` - Contains the window's current position.
  Future<Offset> getPosition() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getPosition', arguments);
    return Offset(resultData['x'], resultData['y']);
  }

  /// Move the window to a position aligned with the screen.
  Future<void> setAlignment(Alignment alignment) async {
    Size windowSize = await getSize();
    Map<String, dynamic> primaryDisplay = await _getPrimaryDisplay();

    num visibleWidth = primaryDisplay['size']['width'];
    num visibleHeight = primaryDisplay['size']['height'];
    num visibleStartY = 0;

    if (primaryDisplay['visibleSize'] != null) {
      visibleWidth = primaryDisplay['visibleSize']['width'];
      visibleHeight = primaryDisplay['visibleSize']['height'];
    }
    if (primaryDisplay['visiblePosition'] != null) {
      visibleStartY = primaryDisplay['visiblePosition']['y'];
    }
    Offset position = Offset(0, 0);

    if (alignment == Alignment.topLeft) {
      position = Offset(0, 0);
    } else if (alignment == Alignment.topCenter) {
      position = Offset(
        (visibleWidth / 2) - (windowSize.width / 2),
        visibleStartY + 0,
      );
    } else if (alignment == Alignment.topRight) {
      position = Offset(
        visibleWidth - windowSize.width,
        visibleStartY + 0,
      );
    } else if (alignment == Alignment.centerLeft) {
      position = Offset(
        0,
        visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
      );
    } else if (alignment == Alignment.center) {
      position = Offset(
        (visibleWidth / 2) - (windowSize.width / 2),
        visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
      );
    } else if (alignment == Alignment.centerRight) {
      position = Offset(
        visibleWidth - windowSize.width,
        visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
      );
    } else if (alignment == Alignment.bottomLeft) {
      position = Offset(
        0,
        visibleStartY + (visibleHeight - windowSize.height),
      );
    } else if (alignment == Alignment.bottomCenter) {
      position = Offset(
        (visibleWidth / 2) - (windowSize.width / 2),
        visibleStartY + (visibleHeight - windowSize.height),
      );
    } else if (alignment == Alignment.bottomRight) {
      position = Offset(
        visibleWidth - windowSize.width,
        visibleStartY + (visibleHeight - windowSize.height),
      );
    }

    await this.setPosition(position);
  }

  /// Moves window to the center of the screen.
  Future<void> center() async {
    Size windowSize = await getSize();
    Map<String, dynamic> primaryDisplay = await _getPrimaryDisplay();

    num visibleWidth = primaryDisplay['size']['width'];
    num visibleHeight = primaryDisplay['size']['height'];
    num visibleStartY = 0;

    if (primaryDisplay['visibleSize'] != null) {
      visibleWidth = primaryDisplay['visibleSize']['width'];
      visibleHeight = primaryDisplay['visibleSize']['height'];
    }
    if (primaryDisplay['visiblePosition'] != null) {
      visibleStartY = primaryDisplay['visiblePosition']['y'];
    }

    Offset position = Offset(
      (visibleWidth / 2) - (windowSize.width / 2),
      visibleStartY + ((visibleHeight / 2) - (windowSize.height / 2)),
    );

    await this.setPosition(position);
  }

  /// Moves window to position.
  Future<void> setPosition(Offset position, {animate = false}) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'x': position.dx,
      'y': position.dy,
      'animate': animate,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('setPosition', arguments);
  }

  /// Returns `Size` - Contains the window's width and height.
  Future<Size> getSize() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getSize', arguments);
    return Size(resultData['width'], resultData['height']);
  }

  /// Resizes the window to `width` and `height`.
  Future<void> setSize(Size size, {animate = false}) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
      'animate': animate,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('setSize', arguments);
  }

  /// Sets the minimum size of window to `width` and `height`.
  Future<void> setMinimumSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMinimumSize', arguments);
  }

  /// Sets the maximum size of window to `width` and `height`.
  Future<void> setMaximumSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMaximumSize', arguments);
  }

  /// Returns `bool` - Whether the window can be manually resized by the user.
  Future<bool> isResizable() async {
    return await _channel.invokeMethod('isResizable');
  }

  /// Sets whether the window can be manually resized by the user.
  setResizable(isResizable) {
    final Map<String, dynamic> arguments = {
      'isResizable': isResizable,
    };
    _channel.invokeMethod('setResizable', arguments);
  }

  /// Returns `bool` - Whether the window can be moved by user.
  ///
  /// @platforms macos
  Future<bool> isMovable() async {
    return await _channel.invokeMethod('isMovable');
  }

  /// Sets whether the window can be moved by user.
  ///
  /// @platforms macos
  setMovable(isMovable) {
    final Map<String, dynamic> arguments = {
      'isMovable': isMovable,
    };
    _channel.invokeMethod('setMovable', arguments);
  }

  /// Returns `bool` - Whether the window can be manually minimized by the user.
  ///
  /// @platforms macos,windows
  Future<bool> isMinimizable() async {
    return await _channel.invokeMethod('isMinimizable');
  }

  /// Sets whether the window can be manually minimized by user.
  ///
  /// @platforms macos,windows
  setMinimizable(isMinimizable) {
    final Map<String, dynamic> arguments = {
      'isMinimizable': isMinimizable,
    };
    _channel.invokeMethod('setMinimizable', arguments);
  }

  /// Returns `bool` - Whether the window can be manually closed by user.
  ///
  /// @platforms macos,windows
  Future<bool> isClosable() async {
    return await _channel.invokeMethod('isClosable');
  }

  /// Sets whether the window can be manually closed by user.
  ///
  /// @platforms macos,windows
  Future<void> setClosable(bool isClosable) async {
    final Map<String, dynamic> arguments = {
      'isClosable': isClosable,
    };
    await _channel.invokeMethod('setClosable', arguments);
  }

  /// Returns `bool` - Whether the window is always on top of other windows.
  Future<bool> isAlwaysOnTop() async {
    return await _channel.invokeMethod('isAlwaysOnTop');
  }

  /// Sets whether the window should show always on top of other windows.
  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {
    final Map<String, dynamic> arguments = {
      'isAlwaysOnTop': isAlwaysOnTop,
    };
    await _channel.invokeMethod('setAlwaysOnTop', arguments);
  }

  /// Returns `String` - The title of the native window.
  Future<String> getTitle() async {
    return await _channel.invokeMethod('getTitle');
  }

  /// Changes the title of native window to title.
  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {
      'title': title,
    };
    await _channel.invokeMethod('setTitle', arguments);
  }

  /// Changes the title bar style of native window.
  ///
  /// @platforms macos,windows
  Future<void> setTitleBarStyle(
    String titleBarStyle, {
    bool windowButtonVisibility = true,
  }) async {
    final Map<String, dynamic> arguments = {
      'titleBarStyle': titleBarStyle,
      'windowButtonVisibility': windowButtonVisibility,
    };
    await _channel.invokeMethod('setTitleBarStyle', arguments);
  }

  /// Returns `int` - The title bar height of the native window.
  ///
  /// @platforms macos,windows
  Future<int> getTitleBarHeight() async {
    return await _channel.invokeMethod('getTitleBarHeight');
  }

  /// Makes the window not show in the taskbar / dock.
  Future<void> setSkipTaskbar(bool isSkipTaskbar) async {
    final Map<String, dynamic> arguments = {
      'isSkipTaskbar': isSkipTaskbar,
    };
    await _channel.invokeMethod('setSkipTaskbar', arguments);
  }

  /// Sets progress value in progress bar. Valid range is [0, 1.0].
  ///
  /// @platforms macos
  Future<void> setProgressBar(double progress) async {
    final Map<String, dynamic> arguments = {
      'progress': progress,
    };
    await _channel.invokeMethod('setProgressBar', arguments);
  }

  /// Returns `bool` - Whether the window has a shadow.
  ///
  /// @platforms macos
  Future<bool> hasShadow() async {
    return await _channel.invokeMethod('hasShadow');
  }

  /// Sets whether the window should have a shadow.
  ///
  /// @platforms macos
  Future<void> setHasShadow(bool hasShadow) async {
    final Map<String, dynamic> arguments = {
      'hasShadow': hasShadow,
    };
    await _channel.invokeMethod('setHasShadow', arguments);
  }

  /// Returns `double` - between 0.0 (fully transparent) and 1.0 (fully opaque). On Linux, always returns 1.
  ///
  /// @platforms macos,windows
  Future<double> getOpacity() async {
    return await _channel.invokeMethod('getOpacity');
  }

  /// Sets the opacity of the window.
  ///
  /// @platforms macos,windows
  Future<void> setOpacity(double opacity) async {
    final Map<String, dynamic> arguments = {
      'opacity': opacity,
    };
    await _channel.invokeMethod('setOpacity', arguments);
  }

  /// Sets the brightness of the window.
  ///
  /// @platforms macos,windows
  Future<void> setBrightness(Brightness brightness) async {
    final Map<String, dynamic> arguments = {
      'brightness': brightness.name,
    };
    await _channel.invokeMethod('setBrightness', arguments);
  }

  /// Starts a window drag based on the specified mouse-down event.
  Future<void> startDragging() async {
    await _channel.invokeMethod('startDragging');
  }

  Future<void> startResizing(ResizeEdge resizeEdge) {
    return _channel.invokeMethod<bool>(
      'startResizing',
      {
        "top": resizeEdge == ResizeEdge.top ||
            resizeEdge == ResizeEdge.topLeft ||
            resizeEdge == ResizeEdge.topRight,
        "bottom": resizeEdge == ResizeEdge.bottom ||
            resizeEdge == ResizeEdge.bottomLeft ||
            resizeEdge == ResizeEdge.bottomRight,
        "right": resizeEdge == ResizeEdge.right ||
            resizeEdge == ResizeEdge.topRight ||
            resizeEdge == ResizeEdge.bottomRight,
        "left": resizeEdge == ResizeEdge.left ||
            resizeEdge == ResizeEdge.topLeft ||
            resizeEdge == ResizeEdge.bottomLeft,
      },
    );
  }

  Future<Map<String, dynamic>> _getPrimaryDisplay() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getPrimaryDisplay', arguments);
    return Map<String, dynamic>.from(resultData);
  }

  Future<bool> isSubWindow() async {
    return await _channel.invokeMethod('isSubWindow');
  }

  Future<void> createSubWindow({
    Size? size,
    Offset? position,
    bool center = true,
    required String title,
  }) async {
    final Map<String, dynamic> arguments = {
      'width': size?.width,
      'height': size?.height,
      'x': position?.dx,
      'y': position?.dy,
      'center': center,
      'title': title,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('createSubWindow', arguments);
  }
}

final windowManager = WindowManager.instance;
