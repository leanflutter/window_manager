import 'package:flutter/material.dart';

import '../resize_edge.dart';
import '../window_manager.dart';

class DragToResizeArea extends StatelessWidget {
  final Widget child;
  final double resizeEdgeSize;
  final Color resizeEdgeColor;
  final List<ResizeEdge>? enableResizeEdges;

  const DragToResizeArea({
    Key? key,
    required this.child,
    this.resizeEdgeColor = Colors.transparent,
    this.resizeEdgeSize = 4,
    this.enableResizeEdges,
  }) : super(key: key);

  Widget _buildDragToResizeEdge(
    ResizeEdge resizeEdge, {
    MouseCursor cursor = SystemMouseCursors.basic,
    double? width,
    double? height,
  }) {
    if (enableResizeEdges != null && !enableResizeEdges!.contains(resizeEdge))
      return Container();
    return Container(
      width: width,
      height: height,
      color: this.resizeEdgeColor,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (_) => windowManager.startResizing(resizeEdge),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          child: Column(
            children: [
              Row(
                children: [
                  _buildDragToResizeEdge(
                    ResizeEdge.topLeft,
                    cursor: SystemMouseCursors.resizeUpLeft,
                    width: resizeEdgeSize,
                    height: resizeEdgeSize,
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDragToResizeEdge(
                      ResizeEdge.top,
                      cursor: SystemMouseCursors.resizeUp,
                      height: resizeEdgeSize,
                    ),
                  ),
                  _buildDragToResizeEdge(
                    ResizeEdge.topRight,
                    cursor: SystemMouseCursors.resizeUpRight,
                    width: resizeEdgeSize,
                    height: resizeEdgeSize,
                  ),
                ],
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildDragToResizeEdge(
                      ResizeEdge.left,
                      cursor: SystemMouseCursors.resizeLeft,
                      width: resizeEdgeSize,
                      height: double.infinity,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    _buildDragToResizeEdge(
                      ResizeEdge.right,
                      cursor: SystemMouseCursors.resizeRight,
                      width: resizeEdgeSize,
                      height: double.infinity,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildDragToResizeEdge(
                    ResizeEdge.bottomLeft,
                    cursor: SystemMouseCursors.resizeDownLeft,
                    width: resizeEdgeSize,
                    height: resizeEdgeSize,
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDragToResizeEdge(
                      ResizeEdge.bottom,
                      cursor: SystemMouseCursors.resizeDown,
                      height: resizeEdgeSize,
                    ),
                  ),
                  _buildDragToResizeEdge(
                    ResizeEdge.bottomRight,
                    cursor: SystemMouseCursors.resizeDownRight,
                    width: resizeEdgeSize,
                    height: resizeEdgeSize,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
