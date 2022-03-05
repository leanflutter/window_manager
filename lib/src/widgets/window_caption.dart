import 'package:flutter/material.dart';

import 'drag_to_move_area.dart';
import 'drag_to_resize_area.dart';
import 'window_caption_button.dart';
import '../resize_edge.dart';
import '../window_listener.dart';
import '../window_manager.dart';

const double kWindowCaptionHeight = 32;

class WindowCaption extends StatefulWidget {
  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;

  const WindowCaption({
    Key? key,
    this.title,
    this.backgroundColor,
    this.brightness,
  }) : super(key: key);

  @override
  State<WindowCaption> createState() => _WindowCaptionState();
}

class _WindowCaptionState extends State<WindowCaption> with WindowListener {
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

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: DragToResizeArea(
        enableResizeEdges: [
          ResizeEdge.topLeft,
          ResizeEdge.top,
          ResizeEdge.topRight,
        ],
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (widget.brightness == Brightness.dark
                    ? Color(0xff1C1C1C)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 16),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: widget.brightness == Brightness.light
                                ? Colors.black.withOpacity(0.8956)
                                : Colors.white,
                            fontSize: 14,
                          ),
                          child: widget.title ?? Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              WindowCaptionButton.minimize(
                brightness: widget.brightness,
                onPressed: () async {
                  bool isMinimized = await windowManager.isMinimized();
                  if (isMinimized) {
                    windowManager.restore();
                  } else {
                    windowManager.minimize();
                  }
                },
              ),
              FutureBuilder<bool>(
                future: windowManager.isMaximized(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data == true) {
                    return WindowCaptionButton.unmaximize(
                      brightness: widget.brightness,
                      onPressed: () {
                        windowManager.unmaximize();
                      },
                    );
                  }
                  return WindowCaptionButton.maximize(
                    brightness: widget.brightness,
                    onPressed: () {
                      windowManager.maximize();
                    },
                  );
                },
              ),
              WindowCaptionButton.close(
                brightness: widget.brightness,
                onPressed: () {
                  windowManager.close();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
