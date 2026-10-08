// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:window_manager/legacy.dart';

const kDefaultTitle = 'window_manager example';

/// Every `windowManager` call the example makes, plus the [WindowListener] it
/// registers, behind a [ChangeNotifier] the widgets rebuild from.
class WindowController extends ChangeNotifier with WindowListener {
  WindowController({bool listen = true}) {
    if (listen) {
      windowManager.addListener(this);
      refresh();
    }
  }

  // What the system says, read back after every call.
  Rect bounds = Rect.zero;
  int titleBarHeight = 0;
  bool isVisible = true;
  bool isFocused = true;
  bool isMaximized = false;
  bool isMinimized = false;
  bool isFullScreen = false;
  bool isResizable = true;
  bool isMovable = true;
  bool isMinimizable = true;
  bool isMaximizable = true;
  bool isClosable = true;
  bool isAlwaysOnTop = false;
  bool isAlwaysOnBottom = false;
  bool isSkipTaskbar = false;
  bool hasShadow = true;
  double opacity = 1;
  String title = kDefaultTitle;

  // What the chips asked for, where the system has nothing to read back.
  TitleBarStyle titleBarStyle = TitleBarStyle.normal;
  bool windowButtonVisibility = true;
  bool isPreventClose = false;

  String lastEvent = 'no event yet';
  final List<String> log = <String>[];

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Reading back
  // ---------------------------------------------------------------------------

  Future<void> refresh() async {
    bounds = await windowManager.getBounds();
    titleBarHeight = await windowManager.getTitleBarHeight();
    isVisible = await windowManager.isVisible();
    isFocused = await windowManager.isFocused();
    isMaximized = await windowManager.isMaximized();
    isMinimized = await windowManager.isMinimized();
    isFullScreen = await windowManager.isFullScreen();
    isResizable = await windowManager.isResizable();
    isMovable = await windowManager.isMovable();
    isMinimizable = await windowManager.isMinimizable();
    isMaximizable = await windowManager.isMaximizable();
    isClosable = await windowManager.isClosable();
    isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    isAlwaysOnBottom = await windowManager.isAlwaysOnBottom();
    isSkipTaskbar = await windowManager.isSkipTaskbar();
    hasShadow = await windowManager.hasShadow();
    opacity = await windowManager.getOpacity();
    title = await windowManager.getTitle();
    isPreventClose = await windowManager.isPreventClose();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle and state
  // ---------------------------------------------------------------------------

  Future<void> hideThenShow() async {
    record('hide()  +  show() in 2s');
    await windowManager.hide();
    await Future<void>.delayed(const Duration(seconds: 2));
    await windowManager.show();
    await refresh();
  }

  Future<void> minimize() async {
    record('minimize()');
    await windowManager.minimize();
    await refresh();
  }

  Future<void> setMaximized(bool maximized) async {
    record(maximized ? 'maximize()' : 'unmaximize()');
    if (maximized) {
      await windowManager.maximize();
    } else {
      await windowManager.unmaximize();
    }
    await refresh();
  }

  Future<void> setFullScreen(bool fullScreen) async {
    record('setFullScreen($fullScreen)');
    await windowManager.setFullScreen(fullScreen);
    await refresh();
  }

  Future<void> focus() async {
    record('focus()');
    await windowManager.focus();
    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Geometry
  // ---------------------------------------------------------------------------

  Future<void> setSize(Size size) async {
    record('setSize(${size.width.round()} × ${size.height.round()})');
    await windowManager.setSize(size);
    await refresh();
  }

  Future<void> setAlignment(Alignment alignment) async {
    record('setAlignment($alignment)');
    await windowManager.setAlignment(alignment);
    await refresh();
  }

  Future<void> center() async {
    record('center()');
    await windowManager.center();
    await refresh();
  }

  Future<void> setMinimumSize(Size size) async {
    record('setMinimumSize(${size.width.round()} × ${size.height.round()})');
    await windowManager.setMinimumSize(size);
  }

  Future<void> setMaximumSize(Size size) async {
    record('setMaximumSize(${size.width.round()} × ${size.height.round()})');
    await windowManager.setMaximumSize(size);
  }

  Future<void> setAspectRatio(double aspectRatio) async {
    record('setAspectRatio($aspectRatio)');
    await windowManager.setAspectRatio(aspectRatio);
  }

  // ---------------------------------------------------------------------------
  // Flags
  // ---------------------------------------------------------------------------

  Future<void> setResizable(bool value) async {
    record('setResizable($value)');
    await windowManager.setResizable(value);
    await refresh();
  }

  Future<void> setMovable(bool value) async {
    record('setMovable($value)');
    await windowManager.setMovable(value);
    await refresh();
  }

  Future<void> setMinimizable(bool value) async {
    record('setMinimizable($value)');
    await windowManager.setMinimizable(value);
    await refresh();
  }

  Future<void> setMaximizable(bool value) async {
    record('setMaximizable($value)');
    await windowManager.setMaximizable(value);
    await refresh();
  }

  Future<void> setClosable(bool value) async {
    record('setClosable($value)');
    await windowManager.setClosable(value);
    await refresh();
  }

  Future<void> setAlwaysOnTop(bool value) async {
    record('setAlwaysOnTop($value)');
    await windowManager.setAlwaysOnTop(value);
    await refresh();
  }

  Future<void> setAlwaysOnBottom(bool value) async {
    record('setAlwaysOnBottom($value)');
    await windowManager.setAlwaysOnBottom(value);
    await refresh();
  }

  Future<void> setSkipTaskbar(bool value) async {
    record('setSkipTaskbar($value)');
    await windowManager.setSkipTaskbar(value);
    await refresh();
  }

  Future<void> setHasShadow(bool value) async {
    record('setHasShadow($value)');
    await windowManager.setHasShadow(value);
    await refresh();
  }

  Future<void> setOpacity(double value) async {
    record('setOpacity($value)');
    await windowManager.setOpacity(value);
    await refresh();
  }

  Future<void> setProgressBar(double value) async {
    record('setProgressBar($value)');
    await windowManager.setProgressBar(value);
  }

  Future<void> setBadgeLabel(String label) async {
    record(label.isEmpty ? 'setBadgeLabel()' : 'setBadgeLabel("$label")');
    await windowManager.setBadgeLabel(label.isEmpty ? null : label);
  }

  // ---------------------------------------------------------------------------
  // Title bar
  // ---------------------------------------------------------------------------

  Future<void> setTitle(String value) async {
    record('setTitle("$value")');
    await windowManager.setTitle(value);
    await refresh();
  }

  Future<void> setTitleBarStyle(
    TitleBarStyle style, {
    bool windowButtonVisibility = true,
  }) async {
    record(
      'setTitleBarStyle(${style.name}, '
      'windowButtonVisibility: $windowButtonVisibility)',
    );
    titleBarStyle = style;
    this.windowButtonVisibility = windowButtonVisibility;
    await windowManager.setTitleBarStyle(
      style,
      windowButtonVisibility: windowButtonVisibility,
    );
    await refresh();
  }

  Future<void> setAsFrameless() async {
    record('setAsFrameless()');
    titleBarStyle = TitleBarStyle.hidden;
    windowButtonVisibility = false;
    await windowManager.setAsFrameless();
    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Closing
  // ---------------------------------------------------------------------------

  Future<void> setPreventClose(bool value) async {
    record('setPreventClose($value)');
    await windowManager.setPreventClose(value);
    await refresh();
  }

  Future<void> close() async {
    record('close()');
    await windowManager.close();
  }

  Future<void> destroy() async {
    record('destroy()');
    await windowManager.destroy();
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  @override
  void onWindowEvent(String eventName) {
    record('onWindowEvent  $eventName');
    refresh();
  }

  @override
  void onWindowClose() {
    // What an app that sets preventClose would ask the user here. The example
    // simply lets the window go.
    record('onWindowClose  →  destroy()');
    windowManager.destroy();
  }

  void record(String event) {
    lastEvent = event;
    log.insert(0, event);
    if (log.length > 40) log.removeLast();
    notifyListeners();
  }

  void clearLog() {
    log.clear();
    lastEvent = 'no event yet';
    notifyListeners();
  }
}
