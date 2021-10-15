import 'package:flutter/material.dart';

import '../window_manager.dart';

class DragToMoveArea extends StatelessWidget {
  final Widget child;

  const DragToMoveArea({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: () async {
        bool isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      },
      child: child,
    );
  }
}
