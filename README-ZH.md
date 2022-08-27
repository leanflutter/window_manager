# window_manager

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.window_manager/visits

这个插件允许 Flutter 桌面应用调整窗口的大小和位置。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [window_manager](#window_manager)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
      - [监听事件](#监听事件)
      - [关闭时退出](#关闭时退出)
        - [macOS](#macos)
      - [关闭前确认](#关闭前确认)
      - [在启动时隐藏](#在启动时隐藏)
        - [macOS](#macos-1)
        - [Windows](#windows)
  - [文章](#文章)
  - [谁在用使用它？](#谁在用使用它)
  - [API](#api)
    - [WindowManager](#windowmanager)
      - [Methods](#methods)
        - [waitUntilReadyToShow](#waituntilreadytoshow)
        - [destroy](#destroy)
        - [close](#close)
        - [isPreventClose](#ispreventclose)
        - [setPreventClose](#setpreventclose)
        - [focus](#focus)
        - [blur  `macos`  `windows`](#blur--macos--windows)
        - [isFocused  `macos`  `windows`](#isfocused--macos--windows)
        - [show](#show)
        - [hide](#hide)
        - [isVisible](#isvisible)
        - [isMaximized](#ismaximized)
        - [maximize](#maximize)
        - [unmaximize](#unmaximize)
        - [isMinimized](#isminimized)
        - [minimize](#minimize)
        - [restore](#restore)
        - [isFullScreen](#isfullscreen)
        - [setFullScreen](#setfullscreen)
        - [setAspectRatio](#setaspectratio)
        - [setBackgroundColor](#setbackgroundcolor)
        - [setAlignment](#setalignment)
        - [center](#center)
        - [getBounds](#getbounds)
        - [setBounds](#setbounds)
        - [getSize](#getsize)
        - [setSize](#setsize)
        - [getPosition](#getposition)
        - [setPosition](#setposition)
        - [setMinimumSize](#setminimumsize)
        - [setMaximumSize](#setmaximumsize)
        - [isResizable](#isresizable)
        - [setResizable](#setresizable)
        - [isMovable  `macos`](#ismovable--macos)
        - [setMovable  `macos`](#setmovable--macos)
        - [isMinimizable  `macos`  `windows`](#isminimizable--macos--windows)
        - [setMinimizable  `macos`  `windows`](#setminimizable--macos--windows)
        - [isClosable  `windows`](#isclosable--windows)
        - [isMaximizable  `windows`](#ismaximizable--windows)
        - [setMaximizable](#setmaximizable)
        - [setClosable  `macos`  `windows`](#setclosable--macos--windows)
        - [isAlwaysOnTop](#isalwaysontop)
        - [setAlwaysOnTop](#setalwaysontop)
        - [isAlwaysOnBottom](#isalwaysonbottom)
        - [setAlwaysOnBottom  `linux`](#setalwaysonbottom--linux)
        - [getTitle](#gettitle)
        - [setTitle](#settitle)
        - [setTitleBarStyle](#settitlebarstyle)
        - [getTitleBarHeight](#gettitlebarheight)
        - [isSkipTaskbar](#isskiptaskbar)
        - [setSkipTaskbar](#setskiptaskbar)
        - [setProgressBar  `macos`](#setprogressbar--macos)
        - [setIcon  `windows`](#seticon--windows)
        - [hasShadow  `macos`  `windows`](#hasshadow--macos--windows)
        - [setHasShadow  `macos`  `windows`](#sethasshadow--macos--windows)
        - [getOpacity](#getopacity)
        - [setOpacity](#setopacity)
        - [setBrightness  `macos`  `windows`](#setbrightness--macos--windows)
        - [setIgnoreMouseEvents](#setignoremouseevents)
        - [startDragging](#startdragging)
        - [startResizing  `linux`  `windows`](#startresizing--linux--windows)
    - [WindowListener](#windowlistener)
      - [Methods](#methods-1)
        - [onWindowClose](#onwindowclose)
        - [onWindowFocus](#onwindowfocus)
        - [onWindowBlur](#onwindowblur)
        - [onWindowMaximize](#onwindowmaximize)
        - [onWindowUnmaximize](#onwindowunmaximize)
        - [onWindowMinimize](#onwindowminimize)
        - [onWindowRestore](#onwindowrestore)
        - [onWindowResize](#onwindowresize)
        - [onWindowResized  `macos`  `windows`](#onwindowresized--macos--windows)
        - [onWindowMove](#onwindowmove)
        - [onWindowMoved  `macos`  `windows`](#onwindowmoved--macos--windows)
        - [onWindowEnterFullScreen](#onwindowenterfullscreen)
        - [onWindowLeaveFullScreen](#onwindowleavefullscreen)
        - [onWindowEvent](#onwindowevent)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 `pubspec.yaml` 文件：

```yaml
dependencies:
  window_manager: ^0.2.7
```

或

```yaml
dependencies:
  window_manager:
    git:
      url: https://github.com/leanflutter/window_manager.git
      ref: main
```

### 用法

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());
}

```

> 请看这个插件的示例应用，以了解完整的例子。

#### 监听事件

```dart
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
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
    // ...
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() {
    // do something
  }

  @override
  void onWindowFocus() {
    // do something
  }

  @override
  void onWindowBlur() {
    // do something
  }

  @override
  void onWindowMaximize() {
    // do something
  }

  @override
  void onWindowUnmaximize() {
    // do something
  }

  @override
  void onWindowMinimize() {
    // do something
  }

  @override
  void onWindowRestore() {
    // do something
  }

  @override
  void onWindowResize() {
    // do something
  }

  @override
  void onWindowMove() {
    // do something
  }

  @override
  void onWindowEnterFullScreen() {
    // do something
  }

  @override
  void onWindowLeaveFullScreen() {
    // do something
  }
}
```

#### 关闭时退出

如果你需要使用 `hide` 方法，你需要禁用 `QuitOnClose`。

##### macOS

更改文件 `macos/Runner/AppDelegate.swift` 如下：

```diff
import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
-    return true
+    return false
  }
}
```

#### 关闭前确认

```dart
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    // 添加此行以覆盖默认关闭处理程序
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ...
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
```

#### 在启动时隐藏

##### macOS

更改文件 `macos/Runner/MainFlutterWindow.swift` 如下：

```diff
import Cocoa
import FlutterMacOS
+import window_manager

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

+    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
+        super.order(place, relativeTo: otherWin)
+        hiddenWindowAtLaunch()
+    }
}

```

##### Windows

更改文件 `windows/runner/win32_window.cpp` 如下：

```diff
bool Win32Window::CreateAndShow(const std::wstring& title,
                                const Point& origin,
                                const Size& size) {
  ...                              
  HWND window = CreateWindow(
-      window_class, title.c_str(), WS_OVERLAPPEDWINDOW | WS_VISIBLE,
+      window_class, title.c_str(),
+      WS_OVERLAPPEDWINDOW, // do not add WS_VISIBLE since the window will be shown later
      Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
      Scale(size.width, scale_factor), Scale(size.height, scale_factor),
      nullptr, nullptr, GetModuleHandle(nullptr), this);
```

确保在 `onWindowFocus` 事件中调用一次 `setState`。

```dart
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
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
    // ...
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }
}

```

## 文章

- [关闭窗口后点击Dock图标进行恢复](https://leanflutter.org/zh/blog/click-dock-icon-to-restore-after-closing-the-window)
- [让应用成为单实例](https://leanflutter.org/zh/blog/making-the-app-single-instanced)

## 谁在用使用它？

- [AuthPass](https://authpass.app/) - 基于Flutter的密码管理器，适用于所有平台。兼容Keepass 2.x（kdbx 3.x）。
- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。
- [BlueBubbles](https://github.com/BlueBubblesApp/bluebubbles-app) - BlueBubbles is an ecosystem of apps bringing iMessage to Android, Windows, and Linux
- [LunaSea](https://github.com/CometTools/LunaSea) - A self-hosted controller for mobile and macOS built using the Flutter framework.
- [Linwood Butterfly](https://github.com/LinwoodCloud/Butterfly) - 用 Flutter 编写的开源笔记应用
- [RustDesk](https://github.com/rustdesk/rustdesk) - 远程桌面软件，开箱即用，无需任何配置。您完全掌控数据，不用担心安全问题。
- [Ubuntu Desktop Installer](https://github.com/canonical/ubuntu-desktop-installer) - This project is a modern implementation of the Ubuntu Desktop installer.

## API

<!-- README_DOC_GEN -->
### WindowManager

#### Methods

##### waitUntilReadyToShow

Wait until ready to show.

##### destroy

Force closing the window.

##### close

Try to close the window.

##### isPreventClose

Check if is intercepting the native close signal.

##### setPreventClose

Set if intercept the native close signal. May useful when combine with the onclose event listener.
This will also prevent the manually triggered close event.

##### focus

Focuses on the window.

##### blur  `macos`  `windows`

Removes focus from the window.


##### isFocused  `macos`  `windows`

Returns `bool` - Whether window is focused.


##### show

Shows and gives focus to the window.

##### hide

Hides the window.

##### isVisible

Returns `bool` - Whether the window is visible to the user.

##### isMaximized

Returns `bool` - Whether the window is maximized.

##### maximize

Maximizes the window. `vertically` simulates aero snap, only works on Windows

##### unmaximize

Unmaximizes the window.

##### isMinimized

Returns `bool` - Whether the window is minimized.

##### minimize

Minimizes the window. On some platforms the minimized window will be shown in the Dock.

##### restore

Restores the window from minimized state to its previous state.

##### isFullScreen

Returns `bool` - Whether the window is in fullscreen mode.

##### setFullScreen

Sets whether the window should be in fullscreen mode.

##### setAspectRatio

This will make a window maintain an aspect ratio.

##### setBackgroundColor

Sets the background color of the window.

##### setAlignment

Move the window to a position aligned with the screen.

##### center

Moves window to the center of the screen.

##### getBounds

Returns `Rect` - The bounds of the window as Object.

##### setBounds

Resizes and moves the window to the supplied bounds.

##### getSize

Returns `Size` - Contains the window's width and height.

##### setSize

Resizes the window to `width` and `height`.

##### getPosition

Returns `Offset` - Contains the window's current position.

##### setPosition

Moves window to position.

##### setMinimumSize

Sets the minimum size of window to `width` and `height`.

##### setMaximumSize

Sets the maximum size of window to `width` and `height`.

##### isResizable

Returns `bool` - Whether the window can be manually resized by the user.

##### setResizable

Sets whether the window can be manually resized by the user.

##### isMovable  `macos`

Returns `bool` - Whether the window can be moved by user.


##### setMovable  `macos`

Sets whether the window can be moved by user.


##### isMinimizable  `macos`  `windows`

Returns `bool` - Whether the window can be manually minimized by the user.


##### setMinimizable  `macos`  `windows`

Sets whether the window can be manually minimized by user.


##### isClosable  `windows`

Returns `bool` - Whether the window can be manually closed by user.


##### isMaximizable  `windows`

Returns `bool` - Whether the window can be manually maximized by the user.


##### setMaximizable

Sets whether the window can be manually maximized by the user.

##### setClosable  `macos`  `windows`

Sets whether the window can be manually closed by user.


##### isAlwaysOnTop

Returns `bool` - Whether the window is always on top of other windows.

##### setAlwaysOnTop

Sets whether the window should show always on top of other windows.

##### isAlwaysOnBottom

Returns `bool` - Whether the window is always below other windows.

##### setAlwaysOnBottom  `linux`

Sets whether the window should show always below other windows.


##### getTitle

Returns `String` - The title of the native window.

##### setTitle

Changes the title of native window to title.

##### setTitleBarStyle

Changes the title bar style of native window.

##### getTitleBarHeight

Returns `int` - The title bar height of the native window.

##### isSkipTaskbar

Returns `bool` - Whether skipping taskbar is enabled.

##### setSkipTaskbar

Makes the window not show in the taskbar / dock.

##### setProgressBar  `macos`

Sets progress value in progress bar. Valid range is [0, 1.0].


##### setIcon  `windows`

Sets window/taskbar icon.


##### hasShadow  `macos`  `windows`

Returns `bool` - Whether the window has a shadow. On Windows, always returns true unless window is frameless.


##### setHasShadow  `macos`  `windows`

Sets whether the window should have a shadow. On Windows, doesn't do anything unless window is frameless.


##### getOpacity

Returns `double` - between 0.0 (fully transparent) and 1.0 (fully opaque).

##### setOpacity

Sets the opacity of the window.

##### setBrightness  `macos`  `windows`

Sets the brightness of the window.


##### setIgnoreMouseEvents

Makes the window ignore all mouse events.

All mouse events happened in this window will be passed to the window below this window, but if this window has focus, it will still receive keyboard events.

##### startDragging

Starts a window drag based on the specified mouse-down event.

##### startResizing  `linux`  `windows`

Starts a window resize based on the specified mouse-down & mouse-move event.


### WindowListener

#### Methods

##### onWindowClose

Emitted when the window is going to be closed.

##### onWindowFocus

Emitted when the window gains focus.

##### onWindowBlur

Emitted when the window loses focus.

##### onWindowMaximize

Emitted when window is maximized.

##### onWindowUnmaximize

Emitted when the window exits from a maximized state.

##### onWindowMinimize

Emitted when the window is minimized.

##### onWindowRestore

Emitted when the window is restored from a minimized state.

##### onWindowResize

Emitted after the window has been resized.

##### onWindowResized  `macos`  `windows`

Emitted once when the window has finished being resized.


##### onWindowMove

Emitted when the window is being moved to a new position.

##### onWindowMoved  `macos`  `windows`

Emitted once when the window is moved to a new position.


##### onWindowEnterFullScreen

Emitted when the window enters a full-screen state.

##### onWindowLeaveFullScreen

Emitted when the window leaves a full-screen state.

##### onWindowEvent

Emitted all events.


<!-- README_DOC_GEN -->

## 许可证

[MIT](./LICENSE)
