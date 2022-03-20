import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window, document;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the WindowManager plugin.
class WindowManagerWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'window_manager',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = WindowManagerWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  StreamSubscription? isPreventCloseSubscription;

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'ensureInitialized':
        return true;
      case 'waitUntilReadyToShow':
        return true;
      case 'destory':
      case 'close':
        html.window.close();
        return;
      case 'setPreventClose':
        final isPreventClose = call.arguments['isPreventClose'] as bool;
        if (isPreventClose) {
          isPreventCloseSubscription =
              html.window.onBeforeUnload.listen((event) {
            // TODO (web): set prevent clsoe
          });
        } else {
          isPreventCloseSubscription?.cancel();
          isPreventCloseSubscription = null;
        }
        return;
      case 'isPreventClose':
        return isPreventCloseSubscription != null;
      case 'isVisible':
        return !(html.document.hidden ?? true);
      case 'getSize':
        final int width = html.window.innerWidth ?? html.window.outerWidth;
        final int height = html.window.innerHeight ?? html.window.outerHeight;
        return {'height': height.toDouble(), 'width': width.toDouble()};
      case 'isClosable':
        // See https://stackoverflow.com/questions/30575988/how-know-if-a-window-can-be-closed-with-js
        return html.window.opener != null;
      case 'getTitle':
        return html.document.title;
      case 'setTitle':
        final title = call.arguments['title'] as String;
        html.document.title = title;
        return;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'window_manager for web doesn\'t implement \'${call.method}\'',
        );
    }
  }
}
