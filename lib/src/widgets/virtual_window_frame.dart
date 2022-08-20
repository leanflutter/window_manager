import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './drag_to_resize_area.dart';
import '../resize_edge.dart';
import '../window_listener.dart';
import '../window_manager.dart';

final _kIsLinux = !kIsWeb && Platform.isLinux;
final _kIsWindows = !kIsWeb && Platform.isWindows;

double get kVirtualWindowFrameMargin => (_kIsLinux) ? 20.0 : 0;

class VirtualWindowFrame extends StatefulWidget {
  /// The [child] contained by the VirtualWindowFrame.
  final Widget child;

  const VirtualWindowFrame({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VirtualWindowFrameState();
}

class _VirtualWindowFrameState extends State<VirtualWindowFrame>
    with WindowListener {
  bool _isFocused = true;
  bool _isMaximized = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Widget _buildVirtualWindowFrame(BuildContext context) {
    return Container(
      margin: (_isMaximized || _isFullScreen)
          ? EdgeInsets.zero
          : EdgeInsets.all(kVirtualWindowFrameMargin),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: (_isMaximized || _isFullScreen) ? 0 : 1,
        ),
        borderRadius: BorderRadius.circular(
          (_isMaximized || _isFullScreen) ? 0 : 6,
        ),
        boxShadow: <BoxShadow>[
          if (!_isMaximized && !_isFullScreen)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0.0, _isFocused ? 4 : 2),
              blurRadius: 6,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (_isMaximized || _isFullScreen) ? 0 : 6,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_kIsLinux) {
      return DragToResizeArea(
        child: _buildVirtualWindowFrame(context),
        resizeEdgeMargin: (_isMaximized || _isFullScreen)
            ? EdgeInsets.zero
            : EdgeInsets.all(kVirtualWindowFrameMargin * 0.6),
        enableResizeEdges: (_isMaximized || _isFullScreen) ? [] : null,
      );
    } else if (_kIsWindows) {
      return DragToResizeArea(
        child: widget.child,
        enableResizeEdges: (_isMaximized || _isFullScreen)
            ? []
            : [
                ResizeEdge.topLeft,
                ResizeEdge.top,
                ResizeEdge.topRight,
              ],
      );
    }

    return widget.child;
  }

  @override
  void onWindowFocus() {
    setState(() {
      _isFocused = true;
    });
  }

  @override
  void onWindowBlur() {
    setState(() {
      _isFocused = false;
    });
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
  }

  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
  }
}

// ignore: non_constant_identifier_names
TransitionBuilder VirtualWindowFrameInit() {
  return (_, Widget? child) {
    return VirtualWindowFrame(
      child: child!,
    );
  };
}
