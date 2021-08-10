import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'window_listener.dart';

const kEventOnWindowWillResize = 'onWindowWillResize';
const kEventOnWindowDidResize = 'onWindowDidResize';
const kEventOnWindowWillMiniaturize = 'onWindowWillMiniaturize';
const kEventOnWindowDidMiniaturize = 'onWindowDidMiniaturize';
const kEventOnWindowDidDeminiaturize = 'onWindowDidDeminiaturize';

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
      if (_listeners!.contains(listener)) {
        switch (call.method) {
          case kEventOnWindowWillResize:
            listener.onWindowWillResize();
            break;
          case kEventOnWindowDidResize:
            listener.onWindowDidResize();
            break;
          case kEventOnWindowWillMiniaturize:
            listener.onWindowWillMiniaturize();
            break;
          case kEventOnWindowDidMiniaturize:
            listener.onWindowDidMiniaturize();
            break;
          case kEventOnWindowDidDeminiaturize:
            listener.onWindowDidDeminiaturize();
            break;
        }
      }
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

  Future<void> setId(String id) async {
    final Map<String, dynamic> arguments = {
      'id': id,
    };
    await _channel.invokeMethod('setId', arguments);
  }

  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {
      'title': title,
    };
    await _channel.invokeMethod('setTitle', arguments);
  }

  Future<Rect> getFrame() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getFrame', arguments);
    return Rect.fromLTWH(
      resultData['origin_x'],
      resultData['origin_y'],
      resultData['size_width'],
      resultData['size_height'],
    );
  }

  Future<void> setFrame({Offset? origin, Size? size}) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'origin_x': origin?.dx,
      'origin_y': origin?.dy,
      'size_width': size?.width,
      'size_height': size?.height,
    }..removeWhere((key, value) => value == null);
    await _channel.invokeMethod('setFrame', arguments);
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

  Future<bool> isUseAnimator() async {
    if (!Platform.isMacOS) return false;

    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isUseAnimator');
    return resultData['isUseAnimator'];
  }

  Future<void> setUseAnimator(bool isUseAnimator) async {
    if (!Platform.isMacOS) {
      print(
          '[window_manager] Warning: setUseAnimator is only supported on MacOS.');
      return;
    }
    final Map<String, dynamic> arguments = {
      'isUseAnimator': isUseAnimator,
    };
    await _channel.invokeMethod('setUseAnimator', arguments);
  }

  Future<bool> isAlwaysOnTop() async {
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isAlwaysOnTop');
    return resultData['isAlwaysOnTop'];
  }

  Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {
    final Map<String, dynamic> arguments = {
      'isAlwaysOnTop': isAlwaysOnTop,
    };
    await _channel.invokeMethod('setAlwaysOnTop', arguments);
  }

  Future<void> activate() async {
    await _channel.invokeMethod('activate');
  }

  Future<void> deactivate() async {
    await _channel.invokeMethod('deactivate');
  }

  Future<void> miniaturize() async {
    await _channel.invokeMethod('miniaturize');
  }

  Future<void> deminiaturize() async {
    await _channel.invokeMethod('deminiaturize');
  }

  Future<void> terminate() async {
    await _channel.invokeMethod('terminate');
  }
}
