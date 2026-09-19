import 'package:flutter/material.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;
import 'package:window_manager/src/native_guard.dart';
import 'package:window_manager/src/widgets/window_caption_button.dart';

const double kWindowCaptionHeight = 32;

/// A widget to simulate the title bar of windows 11.
///
/// {@tool snippet}
///
/// ```dart
/// Scaffold(
///   appBar: PreferredSize(
///     child: WindowCaption(
///       brightness: Theme.of(context).brightness,
///       title: Text('window_manager_example'),
///     ),
///     preferredSize: const Size.fromHeight(kWindowCaptionHeight),
///   ),
/// )
/// ```
/// {@end-tool}
class WindowCaption extends StatefulWidget {
  const WindowCaption({
    super.key,
    this.title,
    this.backgroundColor,
    this.brightness,
    this.window,
    this.onClose,
  });

  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;

  /// The window the buttons act on. When omitted, resolves the current window
  /// on interaction.
  final nativeapi.Window? window;

  /// What the close button does. Quits the application by default, because the
  /// core library has no per-window close yet.
  final VoidCallback? onClose;

  @override
  State<WindowCaption> createState() => _WindowCaptionState();
}

class _WindowCaptionState extends State<WindowCaption> {
  nativeapi.ListenerId? _listenerId;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _isMaximized = _window?.isMaximized ?? false;
    _listenerId = tryNative(
      () => nativeapi.WindowManager.instance.addListener((event) {
        switch (event) {
          case nativeapi.WindowMaximizedEvent():
          case nativeapi.WindowRestoredEvent():
            final isMaximized = _window?.isMaximized ?? false;
            if (isMaximized != _isMaximized && mounted) {
              setState(() => _isMaximized = isMaximized);
            }
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (widget.brightness == Brightness.dark
                ? const Color(0xff1C1C1C)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: nativeapi.DragToMoveArea(
              window: widget.window,
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.brightness == Brightness.light
                              ? Colors.black.withValues(alpha: 0.8956)
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
          ),
          WindowCaptionButton.minimize(
            brightness: widget.brightness,
            onPressed: () {
              final window = _window;
              if (window == null) return;
              if (window.isMinimized) {
                window.restore();
              } else {
                window.minimize();
              }
            },
          ),
          if (_isMaximized)
            WindowCaptionButton.unmaximize(
              brightness: widget.brightness,
              onPressed: () => _window?.unmaximize(),
            )
          else
            WindowCaptionButton.maximize(
              brightness: widget.brightness,
              onPressed: () => _window?.maximize(),
            ),
          WindowCaptionButton.close(
            brightness: widget.brightness,
            onPressed:
                widget.onClose ?? () => nativeapi.Application.instance.quit(0),
          ),
        ],
      ),
    );
  }
}
