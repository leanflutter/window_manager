import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowManager {
  WindowManager._();

  /// The shared instance of [WindowManager].
  static final WindowManager instance = WindowManager._();

  final MethodChannel _channel = const MethodChannel('window_manager');

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {
      'title': title,
    };
    await _channel.invokeMethod('setTitle', arguments);
  }

  Future<Size> getSize() async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('getSize', arguments);
    return Size(
      resultData['width'],
      resultData['height'],
    );
  }

  Future<void> setSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setSize', arguments);
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
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isUseAnimator');
    return resultData['isUseAnimator'];
  }

  Future<void> setUseAnimator(bool isUseAnimator) async {
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
}
