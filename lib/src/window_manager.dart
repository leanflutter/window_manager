import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'window_listener.dart';

const kWindowEventFocus = 'focus';
const kWindowEventBlur = 'blur';
const kWindowEventMaximize = 'maximize';
const kWindowEventUnmaximize = 'unmaximize';
const kWindowEventMinimize = 'minimize';
const kWindowEventRestore = 'restore';
const kWindowEventEnterFullScreen = 'enter-full-screen';
const kWindowEventLeaveFullScreen = 'leave-full-screen';

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
        kWindowEventFocus: listener.onWindowFocus,
        kWindowEventBlur: listener.onWindowBlur,
        kWindowEventMaximize: listener.onWindowMaximize,
        kWindowEventUnmaximize: listener.onWindowUnmaximize,
        kWindowEventMinimize: listener.onWindowMinimize,
        kWindowEventRestore: listener.onWindowRestore,
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

  Future<void> ensureInitialized() {
    if (Platform.isMacOS || Platform.isWindows) {
      return _channel.invokeMethod('ensureInitialized');
    }
    return Future.value();
  }

  Future<void> waitUntilReadyToShow() {
    return _channel.invokeMethod('waitUntilReadyToShow');
  }

  Future<void> setAsFrameless() {
    return _channel.invokeMethod('setAsFrameless');
  }

  // 聚焦于窗口
  void focus({bool inactive = false}) {
    _channel.invokeMethod('focus');
  }

  // 取消窗口的聚焦
  void blur({bool inactive = false}) {
    _channel.invokeMethod('blur');
  }

  // 显示并聚焦于窗口
  void show({bool inactive = false}) {
    final Map<String, dynamic> arguments = {
      'inactive': inactive,
    };
    _channel.invokeMethod('show', arguments);
  }

  // 隐藏窗口
  void hide() {
    _channel.invokeMethod('hide');
  }

  // 返回 bool - 判断窗口是否可见
  Future<bool> isVisible() async {
    return await _channel.invokeMethod('isVisible');
  }

  Future<bool> isMaximized() async {
    return await _channel.invokeMethod('isMaximized');
  }

  // 最大化窗口。 如果窗口尚未显示，该方法也会将其显示 (但不会聚焦)。
  void maximize() {
    _channel.invokeMethod('maximize');
  }

  // 取消窗口最大化
  void unmaximize() {
    _channel.invokeMethod('unmaximize');
  }

  Future<bool> isMinimized() async {
    return await _channel.invokeMethod('isMinimized');
  }

  // 最小化窗口。 在某些平台上, 最小化的窗口将显示在Dock中。
  void minimize() {
    _channel.invokeMethod('minimize');
  }

  // 将窗口从最小化状态恢复到以前的状态。
  void restore() {
    _channel.invokeMethod('restore');
  }

  // 返回 bool - 窗口当前是否已全屏
  Future<bool> isFullScreen() async {
    return await _channel.invokeMethod('isFullScreen');
  }

  // 设置窗口是否应处于全屏模式。
  void setFullScreen(bool isFullScreen) {
    final Map<String, dynamic> arguments = {
      'isFullScreen': isFullScreen,
    };
    _channel.invokeMethod('setFullScreen', arguments);
  }

  void setBackgroundColor(Color backgroundColor) {
    final Map<String, dynamic> arguments = {
      'backgroundColorA': backgroundColor.alpha,
      'backgroundColorR': backgroundColor.red,
      'backgroundColorG': backgroundColor.green,
      'backgroundColorB': backgroundColor.blue,
    };
    _channel.invokeMethod('setBackgroundColor', arguments);
  }

  Future<void> center() async {
    final Map<String, dynamic> arguments = {};

    await _channel.invokeMethod('center', arguments);
  }

  Future<Rect> getBounds() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getBounds', arguments);
    return Rect.fromLTWH(
      resultData['x'],
      resultData['y'],
      resultData['width'],
      resultData['height'],
    );
  }

  Future<void> setBounds(Rect bounds, {animate = false}) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'x': bounds.topLeft.dx,
      'y': bounds.topLeft.dy,
      'width': bounds.size.width,
      'height': bounds.size.height,
      'animate': animate,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('setBounds', arguments);
  }

  Future<Offset> getPosition() async {
    Rect bounds = await this.getBounds();
    return bounds.topLeft;
  }

  Future<void> setPosition(Offset position, {animate = false}) async {
    Rect oldBounds = await this.getBounds();
    Rect newBounds = Rect.fromLTWH(
      position.dx,
      position.dy,
      oldBounds.width,
      oldBounds.height,
    );
    await this.setBounds(newBounds, animate: animate);
  }

  Future<Size> getSize() async {
    Rect bounds = await this.getBounds();
    return bounds.size;
  }

  Future<void> setSize(Size size, {animate = false}) async {
    Rect oldBounds = await this.getBounds();
    Rect newBounds = Rect.fromLTWH(
      oldBounds.left,
      oldBounds.top,
      size.width,
      size.height,
    );
    await this.setBounds(newBounds, animate: animate);
  }

  Future<void> setMinimumSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMinimumSize', arguments);
  }

  Future<void> setMaximumSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMaximumSize', arguments);
  }

  Future<bool> isResizable() async {
    return await _channel.invokeMethod('isResizable');
  }

  setResizable(isResizable) {
    final Map<String, dynamic> arguments = {
      'isResizable': isResizable,
    };
    _channel.invokeMethod('setResizable', arguments);
  }

  Future<bool> isMovable() async {
    return await _channel.invokeMethod('isMovable');
  }

  setMovable(isMovable) {
    final Map<String, dynamic> arguments = {
      'isMovable': isMovable,
    };
    _channel.invokeMethod('setMovable', arguments);
  }

  Future<bool> isMinimizable() async {
    return await _channel.invokeMethod('isResizable');
  }

  setMinimizable(isMinimizable) {
    final Map<String, dynamic> arguments = {
      'isMinimizable': isMinimizable,
    };
    _channel.invokeMethod('setMinimizable', arguments);
  }

  Future<bool> isClosable() async {
    return await _channel.invokeMethod('isClosable');
  }

  void setClosable(bool isClosable) {
    final Map<String, dynamic> arguments = {'isClosable': isClosable};
    _channel.invokeMethod('setClosable', arguments);
  }

  Future<bool> isAlwaysOnTop() async {
    return await _channel.invokeMethod('isAlwaysOnTop');
  }

  void setAlwaysOnTop(bool isAlwaysOnTop) {
    final Map<String, dynamic> arguments = {
      'isAlwaysOnTop': isAlwaysOnTop,
    };
    _channel.invokeMethod('setAlwaysOnTop', arguments);
  }

  Future<String> getTitle() async {
    return await _channel.invokeMethod('getTitle');
  }

  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {
      'title': title,
    };
    await _channel.invokeMethod('setTitle', arguments);
  }

  Future<bool> hasShadow() async {
    return await _channel.invokeMethod('hasShadow');
  }

  Future<void> setHasShadow(bool hasShadow) async {
    final Map<String, dynamic> arguments = {
      'hasShadow': hasShadow,
    };
    await _channel.invokeMethod('setHasShadow', arguments);
  }

  Future<void> startDragging() async {
    await _channel.invokeMethod('startDragging');
  }

  Future<void> terminate() async {
    await _channel.invokeMethod('terminate');
  }
}
