import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'window_listener.dart';

const kWindowEventFocus = 'focus';
const kWindowEventBlur = 'blur';

class WindowManager {
  WindowManager._();

  /// The shared instance of [WindowManager].
  static final WindowManager instance = WindowManager._();

  final MethodChannel _channel = const MethodChannel('window_manager');

  bool _inited = false;

  ObserverList<WindowListener>? _listeners = ObserverList<WindowListener>();

  void _init() {
    _channel.setMethodCallHandler(_methodCallHandler);
    _inited = true;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (_listeners == null) return;

    final List<WindowListener> localListeners =
        List<WindowListener>.from(_listeners!);
    for (final WindowListener listener in localListeners) {
      if (!_listeners!.contains(listener)) {
        return;
      }

      if (call.method != 'onEvent') throw UnimplementedError();

      String eventName = call.arguments['eventName'];
      Map<String, Function> funcMap = {
        kWindowEventFocus: listener.onWindowFocus,
        kWindowEventBlur: listener.onWindowBlur,
      };
      funcMap[eventName]!();
    }
  }

  bool get hasListeners {
    return _listeners!.isNotEmpty;
  }

  void addListener(WindowListener listener) {
    if (!_inited) this._init();

    _listeners!.add(listener);
  }

  void removeListener(WindowListener listener) {
    if (!_inited) this._init();

    _listeners!.remove(listener);
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

  // 最大化窗口。 如果窗口尚未显示，该方法也会将其显示 (但不会聚焦)。
  void maximize() {
    _channel.invokeMethod('maximize');
  }

  // 取消窗口最大化
  void unmaximize() {
    _channel.invokeMethod('unmaximize');
  }

  // 最小化窗口。 在某些平台上, 最小化的窗口将显示在Dock中。
  void minimize() {
    _channel.invokeMethod('minimize');
  }

  // 将窗口从最小化状态恢复到以前的状态。
  void restore() {
    _channel.invokeMethod('restore');
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
      oldBounds.top + (oldBounds.size.height - size.height),
      size.width,
      size.height,
    );
    await this.setBounds(newBounds, animate: animate);
  }

  Future<void> setMinSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMinSize', arguments);
  }

  Future<void> setMaxSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMaxSize', arguments);
  }

  Future<bool> isAlwaysOnTop() async {
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isAlwaysOnTop');
    return resultData['isAlwaysOnTop'];
  }

  void setAlwaysOnTop(bool isAlwaysOnTop) {
    final Map<String, dynamic> arguments = {
      'isAlwaysOnTop': isAlwaysOnTop,
    };
    _channel.invokeMethod('setAlwaysOnTop', arguments);
  }

  Future<void> terminate() async {
    await _channel.invokeMethod('terminate');
  }
}
