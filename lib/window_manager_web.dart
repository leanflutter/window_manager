import 'dart:async';
import 'dart:ui';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window, document;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'window_manager.dart';

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

    void invokeEvent(String eventName) {
      channel.invokeMethod('onEvent', {'eventName': eventName});
    }

    html.window.onUnload.listen((event) => invokeEvent(kWindowEventClose));
    html.window.onFocus.listen((event) => invokeEvent(kWindowEventFocus));
    html.window.onBlur.listen((event) => invokeEvent(kWindowEventBlur));
    html.document.onFullscreenChange.listen((event) {
      if (isFullScreen) {
        invokeEvent(kWindowEventMaximize);
        invokeEvent(kWindowEventEnterFullScreen);
      } else {
        invokeEvent(kWindowEventUnmaximize);
        invokeEvent(kWindowEventRestore);
        invokeEvent(kWindowEventLeaveFullScreen);
      }
    });
    html.window.onResize.listen((event) => invokeEvent(kWindowEventResized));
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
      case 'blur':
        html.window.document.documentElement?.blur();
        return;
      case 'focus':
        html.window.document.documentElement?.focus();
        return;
      case 'isVisible':
        return !(html.document.hidden ?? true);
      case 'getSize':
        final int width = html.window.innerWidth ?? html.window.outerWidth;
        final int height = html.window.innerHeight ?? html.window.outerHeight;
        return {'height': height.toDouble(), 'width': width.toDouble()};
      case 'getPosition':
        return {'x': 0.0, 'h': 0.0};
      case 'isClosable':
        // See https://stackoverflow.com/questions/30575988/how-know-if-a-window-can-be-closed-with-js
        return html.window.opener != null;
      case 'getTitle':
        return html.document.title;
      case 'setTitle':
        final title = call.arguments['title'] as String;
        html.document.title = title;
        return;
      case 'isMaximized':
      case 'isFullScreen':
        return isFullScreen;
      case 'maximize':
        final element = html.document.documentElement;
        element?.requestFullscreen();
        return;
      case 'unmaximize':
      case 'restore':
        html.document.exitFullscreen();
        return;
      case 'setFullScreen':
        final isFullScreen = call.arguments['isFullScreen'] as bool;
        if (isFullScreen) {
          final element = html.document.documentElement;
          element?.requestFullscreen();
        } else {
          html.document.exitFullscreen();
        }
        return;
      case 'setBackgroundColor':
        int a = call.arguments['backgroundColorA'];
        int r = call.arguments['backgroundColorR'];
        int g = call.arguments['backgroundColorG'];
        int b = call.arguments['backgroundColorB'];

        final element = html.document.documentElement;
        element?.style.background = Color.fromARGB(a, r, g, b).toHex();
        return;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'window_manager for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  static bool get isFullScreen => html.document.fullscreenElement != null;
}

extension _HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'
      '${alpha.toRadixString(16).padLeft(2, '0')}';
}