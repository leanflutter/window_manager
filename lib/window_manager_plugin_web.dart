import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the WindowManager plugin.
class WindowManagerPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'window_manager',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = WindowManagerPlugin();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  bool _inited = false;

  void _init() {
    js.context.callMethod(
      'windowManagerPluginInit',
      [],
    );
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "setTitle":
        return setTitle(call);
      case "getFrame":
        return getFrame(call);
      case "setFrame":
        return setFrame(call);
      case "setMinSize":
        return setMinSize(call);
      case "setMaxSize":
        return setMaxSize(call);
      case "isUseAnimator":
        return isUseAnimator(call);
      case "setUseAnimator":
        return setUseAnimator(call);
      case "isAlwaysOnTop":
        return isAlwaysOnTop(call);
      case "setAlwaysOnTop":
        return setAlwaysOnTop(call);
      case "activate":
        activate(call);
        break;
      case "deactivate":
        deactivate(call);
        break;
      case "miniaturize":
        miniaturize(call);
        break;
      case "deminiaturize":
        deminiaturize(call);
        break;
      case "terminate":
        terminate(call);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'window_manager for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<bool> setTitle(MethodCall call) {
    Map<String, dynamic> args = Map<String, dynamic>.from(call.arguments);
    html.document.title = args['title'];
    return Future.value(true);
  }

  Future<Map<dynamic, dynamic>> getFrame(MethodCall call) {
    if (!_inited) _init();

    num x = 0;
    num y = 0;
    num width = 0;
    num height = 0;

    js.JsObject frame = js.context.callMethod(
      'windowManagerPluginGetFrame',
      [],
    );

    x = frame['origin']['x'];
    y = frame['origin']['y'];
    width = frame['size']['width'];
    height = frame['size']['height'];

    return Future<Map<dynamic, dynamic>>.value({
      'origin_x': x,
      'origin_y': y,
      'size_width': width,
      'size_height': height,
    });
  }

  Future<bool> setFrame(MethodCall call) {
    if (!_inited) _init();

    Map<String, dynamic> args = Map<String, dynamic>.from(call.arguments);
    num? x = args['origin_x'];
    num? y = args['origin_y'];
    num? width = args['size_width'];
    num? height = args['size_height'];

    js.context.callMethod(
      'windowManagerPluginSetFrame',
      [
        js.JsObject.jsify({
          'origin': x == null || y == null ? null : {'x': x, 'y': y},
          'size': (width == null || height == null)
              ? null
              : {'width': width, 'height': height},
        }),
      ],
    );

    return Future.value(true);
  }

  Future<bool> setMinSize(MethodCall call) async {
    return Future.value(false);
  }

  Future<bool> setMaxSize(MethodCall call) async {
    return Future.value(false);
  }

  Future<Map<dynamic, dynamic>> isUseAnimator(MethodCall call) {
    return Future.value({
      'isUseAnimator': false,
    });
  }

  Future<String> setUseAnimator(MethodCall call) async {
    return '';
  }

  Future<Map<dynamic, dynamic>> isAlwaysOnTop(MethodCall call) {
    return Future.value({
      'isAlwaysOnTop': true,
    });
  }

  Future<bool> setAlwaysOnTop(MethodCall call) async {
    return Future.value(false);
  }

  Future<String> activate(MethodCall call) async {
    return '';
  }

  Future<String> deactivate(MethodCall call) async {
    return '';
  }

  Future<String> miniaturize(MethodCall call) async {
    return '';
  }

  Future<String> deminiaturize(MethodCall call) async {
    return '';
  }

  Future<String> terminate(MethodCall call) async {
    return '';
  }
}
