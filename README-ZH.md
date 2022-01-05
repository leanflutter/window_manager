# window_manager

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用调整窗口的大小和位置。

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
        - [Windows](#windows)
      - [在启动时隐藏](#在启动时隐藏)
        - [macOS](#macos-1)
  - [谁在用使用它？](#谁在用使用它)
  - [API](#api)
    - [WindowManager](#windowmanager)
    - [WindowListener](#windowlistener)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  window_manager: ^0.1.1
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

  // Use it only after calling `hiddenWindowAtLaunch`
  windowManager.waitUntilReadyToShow().then((_) async{
    // 设置为无边框窗口
    await windowManager.setAsFrameless();
    await windowManager.setSize(Size(600, 600));
    await windowManager.setPosition(Offset.zero);
    windowManager.show();
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

`macos/Runner/AppDelegate.swift`

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

##### Windows

`windows/runner/main.cpp`

```diff
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // ...

-  window.SetQuitOnClose(true);
+  window.SetQuitOnClose(false);

  // ...

  return EXIT_SUCCESS;
}
```

#### 在启动时隐藏

##### macOS

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

## 谁在用使用它？

- [AuthPass](https://authpass.app/) - 基于Flutter的密码管理器，适用于所有平台。兼容Keepass 2.x（kdbx 3.x）。
- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。
- [BlueBubbles](https://github.com/BlueBubblesApp/bluebubbles-app) - BlueBubbles is an ecosystem of apps bringing iMessage to Android, Windows, and Linux
- [Yukino](https://github.com/yukino-app/yukino/tree/flutter-rewrite) - Yukino lets you read manga or stream anime ad-free from multiple sources.

## API

### WindowManager

| Method           | Description                                                                                                | Linux | macOS | Windows |
| ---------------- | ---------------------------------------------------------------------------------------------------------- | ----- | ----- | ------- |
| `focus`          | Focuses on the window.                                                                                     | ✔️     | ✔️     | ➖       |
| `blur`           | Removes focus from the window.                                                                             | ➖     | ✔️     | ➖       |
| `show`           | Shows and gives focus to the window.                                                                       | ✔️     | ✔️     | ✔️       |
| `hide`           | Hides the window.                                                                                          | ✔️     | ✔️     | ✔️       |
| `isVisible`      | Returns `bool` - Whether the window is visible to the user.                                                | ✔️     | ✔️     | ✔️       |
| `isMaximized`    | Returns `bool` - Whether the window is maximized.                                                          | ✔️     | ✔️     | ✔️       |
| `maximize`       | Maximizes the window.                                                                                      | ✔️     | ✔️     | ✔️       |
| `unmaximize`     | Unmaximizes the window.                                                                                    | ✔️     | ✔️     | ✔️       |
| `isMinimized`    | Returns `bool` - Whether the window is minimized.                                                          | ✔️     | ✔️     | ✔️       |
| `minimize`       | Minimizes the window.                                                                                      | ✔️     | ✔️     | ✔️       |
| `restore`        | Restores the window from minimized state to its previous state.                                            | ✔️     | ✔️     | ✔️       |
| `isFullScreen`   | Returns `bool` - Whether the window is in fullscreen mode.                                                 | ✔️     | ✔️     | ✔️       |
| `setFullScreen`  | Sets whether the window should be in fullscreen mode.                                                      | ✔️     | ✔️     | ✔️       |
| `getBounds`      | Returns `Rect` - The bounds of the window as Object.                                                       | ✔️     | ✔️     | ✔️       |
| `setBounds`      | Resizes and moves the window to the supplied bounds.                                                       | ✔️     | ✔️     | ✔️       |
| `getPosition`    | Returns `Offset` - Contains the window's current position.                                                 | ✔️     | ✔️     | ✔️       |
| `setPosition`    | Moves window to `x` and `y`.                                                                               | ✔️     | ✔️     | ✔️       |
| `getSize`        | Returns `Size` - Contains the window's width and height.                                                   | ✔️     | ✔️     | ✔️       |
| `setSize`        | Resizes the window to `width` and `height`.                                                                | ✔️     | ✔️     | ✔️       |
| `setMinimumSize` | Sets the minimum size of window to `width` and `height`.                                                   | ✔️     | ✔️     | ✔️       |
| `setMaximumSize` | Sets the maximum size of window to `width` and `height`.                                                   | ✔️     | ✔️     | ✔️       |
| `isResizable`    | Returns `bool` - Whether the window can be manually resized by the user.                                   | ✔️     | ✔️     | ✔️       |
| `setResizable`   | Sets whether the window can be manually resized by the user.                                               | ✔️     | ✔️     | ✔️       |
| `isMovable`      | Returns `bool` - Whether the window can be moved by user. On Linux always returns `true`.                  | ➖     | ✔️     | ➖       |
| `setMovable`     | Sets whether the window can be moved by user. On Linux does nothing.                                       | ➖     | ✔️     | ➖       |
| `isMinimizable`  | Returns `bool` - Whether the window can be manually minimized by the user. On Linux always returns `true`. | ➖     | ✔️     | ✔️       |
| `setMinimizable` | Sets whether the window can be manually minimized by user. On Linux does nothing.                          | ➖     | ✔️     | ✔️       |
| `isClosable`     | Returns `bool` - Whether the window can be manually closed by user. On Linux always returns `true`.        | ✔️     | ✔️     | ✔️       |
| `setClosable`    | Sets whether the window can be manually closed by user. On Linux does nothing.                             | ✔️     | ✔️     | ✔️       |
| `isAlwaysOnTop`  | Returns `bool` - Whether the window is always on top of other windows.                                     | ✔️     | ✔️     | ✔️       |
| `setAlwaysOnTop` | Sets whether the window should show always on top of other windows.                                        | ✔️     | ✔️     | ✔️       |
| `getTitle`       | Returns `String` - The title of the native window.                                                         | ✔️     | ✔️     | ✔️       |
| `setTitle`       | Changes the title of native window to title.                                                               | ✔️     | ✔️     | ✔️       |
| `setSkipTaskbar` | Makes the window not show in the taskbar / dock.                                                           | ✔️     | ✔️     | ✔️       |
| `hasShadow`      | Returns `bool` - Whether the window has a shadow.                                                          | ➖     | ✔️     | ➖       |
| `setHasShadow`   | Sets whether the window should have a shadow.                                                              | ➖     | ✔️     | ➖       |
| `startDragging`  | -                                                                                                          | ✔️     | ✔️     | ✔️       |

### WindowListener

| Method                    | Description                                                 | Linux | macOS | Windows |
| ------------------------- | ----------------------------------------------------------- | ----- | ----- | ------- |
| `onWindowFocus`           | Emitted when the window gains focus.                        | ✔️     | ✔️     | ✔️       |
| `onWindowBlur`            | Emitted when the window loses focus.                        | ✔️     | ✔️     | ✔️       |
| `onWindowMaximize`        | Emitted when window is maximized.                           | ✔️     | ✔️     | ✔️       |
| `onWindowUnmaximize`      | Emitted when the window exits from a maximized state.       | ✔️     | ✔️     | ✔️       |
| `onWindowMinimize`        | Emitted when the window is minimized.                       | ✔️     | ✔️     | ✔️       |
| `onWindowRestore`         | Emitted when the window is restored from a minimized state. | ✔️     | ✔️     | ✔️       |
| `onWindowResize`          | Emitted after the window has been resized.                  | ✔️     | ✔️     | ✔️       |
| `onWindowMove`            | Emitted when the window is being moved to a new position.   | ✔️     | ✔️     | ✔️       |
| `onWindowEnterFullScreen` | Emitted when the window enters a full-screen state.         | ✔️     | ✔️     | ✔️       |
| `onWindowLeaveFullScreen` | Emitted when the window leaves a full-screen state.         | ✔️     | ✔️     | ✔️       |

## 许可证

[MIT](./LICENSE)
