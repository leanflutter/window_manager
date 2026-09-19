import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/src/native_guard.dart';

final _kIsLinux = !kIsWeb && Platform.isLinux;
final _kIsWindows = !kIsWeb && Platform.isWindows;

/// Draws the border and shadow of a frameless window, and puts native resize
/// handles along its edges.
class VirtualWindowFrame extends StatefulWidget {
  const VirtualWindowFrame({super.key, required this.child, this.window});

  /// The [child] contained by the VirtualWindowFrame.
  final Widget child;

  /// The window the resize handles act on. When omitted, resolves the current
  /// window on interaction.
  final nativeapi.Window? window;

  @override
  State<StatefulWidget> createState() => _VirtualWindowFrameState();
}

class _VirtualWindowFrameState extends State<VirtualWindowFrame> {
  nativeapi.ListenerId? _listenerId;
  bool _isFocused = true;
  bool _isMaximized = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _readState();
    _listenerId = tryNative(
      () => nativeapi.WindowManager.instance.addListener((event) {
        switch (event) {
          case nativeapi.WindowFocusedEvent():
          case nativeapi.WindowBlurredEvent():
          case nativeapi.WindowMaximizedEvent():
          case nativeapi.WindowRestoredEvent():
          case nativeapi.WindowResizedEvent():
            _readState();
          default:
            break;
        }
      }),
    );
  }

  @override
  void dispose() {
    final listenerId = _listenerId;
    if (listenerId != null) {
      nativeapi.WindowManager.instance.removeListener(listenerId);
    }
    super.dispose();
  }

  nativeapi.Window? get _window =>
      widget.window ??
      tryNative<nativeapi.Window?>(
        () => nativeapi.WindowManager.instance.getCurrent(),
      );

  void _readState() {
    final window = _window;
    if (window == null) return;
    final isFocused = window.isFocused;
    final isMaximized = window.isMaximized;
    final isFullScreen = window.isFullScreen;
    if (isFocused == _isFocused &&
        isMaximized == _isMaximized &&
        isFullScreen == _isFullScreen) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isFocused = isFocused;
      _isMaximized = isMaximized;
      _isFullScreen = isFullScreen;
    });
  }

  Widget _buildVirtualWindowFrame(BuildContext context) {
    final isFilling = _isMaximized || _isFullScreen;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: isFilling ? 0 : 1,
        ),
        borderRadius: BorderRadius.circular(isFilling ? 0 : 6),
        boxShadow: <BoxShadow>[
          if (!isFilling)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: Offset(0.0, _isFocused ? 4 : 2),
              blurRadius: 6,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFilling ? 0 : 6),
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFilling = _isMaximized || _isFullScreen;
    if (_kIsLinux) {
      return nativeapi.DragToResizeArea(
        window: widget.window,
        enableResizeEdges: isFilling ? [] : null,
        child: _buildVirtualWindowFrame(context),
      );
    } else if (_kIsWindows) {
      return nativeapi.DragToResizeArea(
        window: widget.window,
        enableResizeEdges: isFilling
            ? []
            : [
                nativeapi.ResizeEdge.topLeft,
                nativeapi.ResizeEdge.top,
                nativeapi.ResizeEdge.topRight,
              ],
        child: widget.child,
      );
    }

    return widget.child;
  }
}

// ignore: non_constant_identifier_names
TransitionBuilder VirtualWindowFrameInit() {
  return (_, Widget? child) {
    return VirtualWindowFrame(child: child!);
  };
}
