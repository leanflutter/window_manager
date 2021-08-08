import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowManager {
  WindowManager._();

  /// The shared instance of [WindowManager].
  static final WindowManager instance = WindowManager._();

  final MethodChannel _channel = const MethodChannel('window_manager');

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
