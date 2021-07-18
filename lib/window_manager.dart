import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowManager {
  static const MethodChannel _channel = const MethodChannel('window_manager');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Size> getSize() async {
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

  static Future<void> setSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setSize', arguments);
  }

  static Future<void> setMinSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMinSize', arguments);
  }

  static Future<void> setMaxSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': window.devicePixelRatio,
      'width': size.width,
      'height': size.height,
    };
    await _channel.invokeMethod('setMaxSize', arguments);
  }

  static Future<bool> isUseAnimator() async {
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isUseAnimator');
    return resultData['isUseAnimator'];
  }

  static Future<void> setUseAnimator(bool isUseAnimator) async {
    final Map<String, dynamic> arguments = {
      'isUseAnimator': isUseAnimator,
    };
    await _channel.invokeMethod('setUseAnimator', arguments);
  }

  static Future<bool> isAlwaysOnTop() async {
    final Map<dynamic, dynamic> resultData =
        await _channel.invokeMethod('isAlwaysOnTop');
    return resultData['isAlwaysOnTop'];
  }

  static Future<void> setAlwaysOnTop(bool isAlwaysOnTop) async {
    final Map<String, dynamic> arguments = {
      'isAlwaysOnTop': isAlwaysOnTop,
    };
    await _channel.invokeMethod('setAlwaysOnTop', arguments);
  }
}
