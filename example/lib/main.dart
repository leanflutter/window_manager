// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:window_manager/legacy.dart';

import 'widgets/event_footer.dart';
import 'widgets/option_chip.dart';
import 'widgets/palette.dart';
import 'window_controller.dart';

// window_manager through its 0.5.x compatible API
// (package:window_manager/legacy.dart): one window, the classic
// `windowManager` calls, a `WindowListener`.
//
//   window_controller.dart   every windowManager call, the listener
//   widgets/                 the few widgets the window is made of (no Material)
//
// This is deliberately the small example. The full one — several windows at
// once, parent and child windows, every native property with read-back — is
// nativeapi's window_example:
// https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/window_example

const kFullExampleUrl =
    'github.com/libnativeapi/nativeapi-flutter/tree/main/examples/window_example';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(820, 720),
      center: true,
      minimumSize: Size(480, 400),
      title: kDefaultTitle,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const WindowManagerExampleApp());
}

class WindowManagerExampleApp extends StatelessWidget {
  const WindowManagerExampleApp({
    super.key,
    this.shell = const Shell(),
    this.fontFamily,
  });

  final Widget shell;

  /// Null uses the platform's font; a test has to name one it has loaded.
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'window_manager example',
      color: Palette.light.accent,
      debugShowCheckedModeBanner: false,
      builder: (context, _) {
        final palette = Palette.of(context);
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            height: 1.3,
            color: palette.text,
          ),
          child: shell,
        );
      },
    );
  }
}

/// A drag strip standing in for the hidden title bar, one row per group of
/// compatible API, the geometry the system reports, and an event footer.
class Shell extends StatefulWidget {
  const Shell({super.key, this.controller});

  /// Defaults to a controller that talks to the real window.
  final WindowController? controller;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late final WindowController _controller =
      widget.controller ?? WindowController();

  static const _sizes = <String, Size>{
    '640 × 480': Size(640, 480),
    '820 × 720': Size(820, 720),
    '1000 × 800': Size(1000, 800),
  };

  static const _alignments = <String, Alignment>{
    'top left': Alignment.topLeft,
    'top right': Alignment.topRight,
    'center': Alignment.center,
    'bottom left': Alignment.bottomLeft,
    'bottom right': Alignment.bottomRight,
  };

  static const _titles = <String>[kDefaultTitle, 'A different title', '你好'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final c = _controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => ColoredBox(
        color: palette.background,
        child: Column(
          children: [
            _dragStrip(palette, c),
            Expanded(
              child: ListView(
                children: [
                  _stateBlock(palette, c),
                  OptionRow(
                    label: 'Window',
                    children: [
                      OptionChip(label: 'Focus', onTap: c.focus),
                      OptionChip(label: 'Hide 2s', onTap: c.hideThenShow),
                      OptionChip(label: 'Minimize', onTap: c.minimize),
                      OptionChip(
                        label: 'Maximize',
                        selected: c.isMaximized,
                        onTap: () => c.setMaximized(!c.isMaximized),
                      ),
                      OptionChip(
                        label: 'Full screen',
                        selected: c.isFullScreen,
                        onTap: () => c.setFullScreen(!c.isFullScreen),
                      ),
                    ],
                  ),
                  OptionRow(
                    label: 'Size',
                    children: [
                      for (final MapEntry(:key, :value) in _sizes.entries)
                        OptionChip(
                          label: key,
                          selected: c.bounds.size == value,
                          onTap: () => c.setSize(value),
                        ),
                    ],
                  ),
                  OptionRow(
                    label: 'Limits',
                    children: [
                      OptionChip(
                        label: 'Minimum 480 × 400',
                        onTap: () => c.setMinimumSize(const Size(480, 400)),
                      ),
                      OptionChip(
                        label: 'Maximum 1200 × 900',
                        onTap: () => c.setMaximumSize(const Size(1200, 900)),
                      ),
                      OptionChip(
                        label: 'Aspect 16:9',
                        onTap: () => c.setAspectRatio(16 / 9),
                      ),
                      OptionChip(
                        label: 'Aspect off',
                        onTap: () => c.setAspectRatio(0),
                      ),
                    ],
                  ),
                  OptionRow(
                    label: 'Position',
                    children: [
                      for (final MapEntry(:key, :value) in _alignments.entries)
                        OptionChip(
                          label: key,
                          onTap: () => c.setAlignment(value),
                        ),
                      OptionChip(label: 'center()', onTap: c.center),
                    ],
                  ),
                  OptionRow(
                    label: 'Allowed',
                    children: [
                      _toggle('Resizable', c.isResizable, c.setResizable),
                      _toggle('Movable', c.isMovable, c.setMovable),
                      _toggle('Minimizable', c.isMinimizable, c.setMinimizable),
                      _toggle('Maximizable', c.isMaximizable, c.setMaximizable),
                      _toggle('Closable', c.isClosable, c.setClosable),
                    ],
                  ),
                  OptionRow(
                    label: 'Stacking',
                    children: [
                      _toggle(
                        'Always on top',
                        c.isAlwaysOnTop,
                        c.setAlwaysOnTop,
                      ),
                      _toggle(
                        'Always on bottom',
                        c.isAlwaysOnBottom,
                        c.setAlwaysOnBottom,
                      ),
                      _toggle(
                        'Skip taskbar',
                        c.isSkipTaskbar,
                        c.setSkipTaskbar,
                      ),
                      _toggle('Shadow', c.hasShadow, c.setHasShadow),
                    ],
                  ),
                  OptionRow(
                    label: 'Opacity',
                    children: [
                      for (final opacity in const [1.0, 0.8, 0.5])
                        OptionChip(
                          label: '$opacity',
                          selected: c.opacity == opacity,
                          onTap: () => c.setOpacity(opacity),
                        ),
                    ],
                  ),
                  OptionRow(
                    label: 'App icon',
                    children: [
                      OptionChip(
                        label: 'Progress 40%',
                        onTap: () => c.setProgressBar(0.4),
                      ),
                      OptionChip(
                        label: 'Progress off',
                        onTap: () => c.setProgressBar(0),
                      ),
                      OptionChip(
                        label: 'Badge 4',
                        onTap: () => c.setBadgeLabel('4'),
                      ),
                      OptionChip(
                        label: 'Badge off',
                        onTap: () => c.setBadgeLabel(''),
                      ),
                      const Hint('macOS and Windows'),
                    ],
                  ),
                  OptionRow(
                    label: 'Title bar',
                    children: [
                      OptionChip(
                        label: 'Normal',
                        selected:
                            c.titleBarStyle == TitleBarStyle.normal &&
                            c.windowButtonVisibility,
                        onTap: () => c.setTitleBarStyle(TitleBarStyle.normal),
                      ),
                      OptionChip(
                        label: 'No buttons',
                        selected:
                            c.titleBarStyle == TitleBarStyle.normal &&
                            !c.windowButtonVisibility,
                        onTap: () => c.setTitleBarStyle(
                          TitleBarStyle.normal,
                          windowButtonVisibility: false,
                        ),
                      ),
                      OptionChip(
                        label: 'Hidden',
                        selected: c.titleBarStyle == TitleBarStyle.hidden,
                        onTap: () => c.setTitleBarStyle(TitleBarStyle.hidden),
                      ),
                      OptionChip(label: 'Frameless', onTap: c.setAsFrameless),
                    ],
                  ),
                  OptionRow(
                    label: 'Title',
                    children: [
                      for (final title in _titles)
                        OptionChip(
                          label: title,
                          selected: c.title == title,
                          onTap: () => c.setTitle(title),
                        ),
                    ],
                  ),
                  OptionRow(
                    label: 'Closing',
                    children: [
                      _toggle(
                        'Prevent close',
                        c.isPreventClose,
                        c.setPreventClose,
                      ),
                      OptionChip(label: 'close()', onTap: c.close),
                      OptionChip(label: 'destroy()', onTap: c.destroy),
                      const Hint(
                        'close() reports onWindowClose when prevented',
                      ),
                    ],
                  ),
                  _fullExampleNote(palette),
                ],
              ),
            ),
            EventFooter(controller: c),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, Future<void> Function(bool) set) {
    return OptionChip(label: label, selected: value, onTap: () => set(!value));
  }

  /// Drag here to move the window, whether or not the title bar is hidden.
  Widget _dragStrip(Palette palette, WindowController c) {
    return DragToMoveArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'DragToMoveArea — drag to move, double-click to maximize',
                style: TextStyle(fontSize: 11, color: palette.muted),
              ),
            ),
            Text(
              c.isFocused ? 'focused' : 'not focused',
              style: TextStyle(fontSize: 11, color: palette.muted),
            ),
          ],
        ),
      ),
    );
  }

  /// What the system says, as opposed to what the chips asked for.
  Widget _stateBlock(Palette palette, WindowController c) {
    final b = c.bounds;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // One Text per line: a UI probe reads them one at a time.
                Text(
                  'getBounds()  ${b.left.round()}, ${b.top.round()}  '
                  '${b.width.round()} × ${b.height.round()}',
                  style: palette.mono,
                ),
                Wrap(
                  spacing: 14,
                  children: [
                    for (final MapEntry(:key, :value) in {
                      'titleBarHeight': '${c.titleBarHeight}',
                      'isVisible': '${c.isVisible}',
                      'isMaximized': '${c.isMaximized}',
                      'isFullScreen': '${c.isFullScreen}',
                    }.entries)
                      Text('$key $value', style: palette.mono),
                  ],
                ),
              ],
            ),
          ),
          OptionChip(label: 'Refresh', onTap: c.refresh),
        ],
      ),
    );
  }

  Widget _fullExampleNote(Palette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: palette.accentSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Looking for the full example?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'This window only covers the 0.5.x compatible API. Several '
              'windows at once, parent and child windows and every native '
              "property are in nativeapi's window_example:",
            ),
            const SizedBox(height: 6),
            Text(kFullExampleUrl, style: palette.mono),
          ],
        ),
      ),
    );
  }
}
