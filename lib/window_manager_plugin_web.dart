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
      case "getBounds":
        return getBounds(call);
      case "setBounds":
        return setBounds(call);
      case "isAlwaysOnTop":
        return isAlwaysOnTop(call);
      case "setAlwaysOnTop":
        return setAlwaysOnTop(call);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'window_manager for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<Map<dynamic, dynamic>> getBounds(MethodCall call) {
    if (!_inited) _init();

    num x = 0;
    num y = 0;
    num width = 0;
    num height = 0;

    js.JsObject bounds = js.context.callMethod(
      'windowManagerPluginGetBounds',
      [],
    );

    x = bounds['x'];
    y = bounds['y'];
    width = bounds['width'];
    height = bounds['height'];

    return Future<Map<dynamic, dynamic>>.value({
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    });
  }

  Future<bool> setBounds(MethodCall call) {
    if (!_inited) _init();

    Map<String, dynamic> args = Map<String, dynamic>.from(call.arguments);
    num? x = args['x'];
    num? y = args['y'];
    num? width = args['width'];
    num? height = args['height'];

    js.context.callMethod(
      'windowManagerPluginSetBounds',
      [
        js.JsObject.jsify({'x': x, 'y': y, 'width': width, 'height': height}),
      ],
    );

    return Future.value(true);
  }

  Future<Map<dynamic, dynamic>> isAlwaysOnTop(MethodCall call) {
    return Future.value({
      'isAlwaysOnTop': true,
    });
  }

  Future<bool> setAlwaysOnTop(MethodCall call) async {
    return Future.value(true);
  }
}
