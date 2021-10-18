# window_manager

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

This plugin allows Flutter **desktop** apps to resizing and repositioning the window.

[![Discord](https://img.shields.io/badge/discord-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/vba8W9SF)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [window_manager](#window_manager)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
      - [Listening events](#listening-events)
      - [Hidden at launch](#hidden-at-launch)
        - [macOS](#macos)
  - [Who's using it?](#whos-using-it)
  - [Discussion](#discussion)
  - [API](#api)
    - [WindowManager](#windowmanager)
    - [WindowListener](#windowlistener)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  window_manager: ^0.0.5
```

Or

```yaml
dependencies:
  window_manager:
    git:
      url: https://github.com/leanflutter/window_manager.git
      ref: main
```

### Usage

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  // Use it only after calling `hiddenWindowAtLaunch`
  windowManager.waitUntilReadyToShow().then((_) async{
    // Set to frameless window
    await windowManager.setAsFrameless();
    await windowManager.setSize(Size(600, 600));
    await windowManager.setPosition(Offset.zero);
    windowManager.show();
  });

  runApp(MyApp());
}

```

> Please see the example app of this plugin for a full example.

#### Listening events

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

#### Hidden at launch

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

## Who's using it?

- [AuthPass](https://authpass.app/) - Password Manager based on Flutter for all platforms. Keepass 2.x (kdbx 3.x) compatible.
- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app written in dart / Flutter.
- [BlueBubbles](https://github.com/BlueBubblesApp/bluebubbles-app) - BlueBubbles is an ecosystem of apps bringing iMessage to Android, Windows, and Linux
- [Yukino](https://github.com/yukino-app/yukino/tree/flutter-rewrite) - Yukino lets you read manga or stream anime ad-free from multiple sources.

## Discussion

> Welcome to join the discussion group to share your suggestions and ideas with me.

- WeChat Group 请添加我的微信 `lijy91`，并备注 `LeanFlutter`
- [QQ Group](https://jq.qq.com/?_wv=1027&k=e3kwRnnw)
- [Telegram Group](https://t.me/leanflutter)

## API

### WindowManager

| Method           | Description                                                                                                | Linux | macOS | Windows |
| ---------------- | ---------------------------------------------------------------------------------------------------------- | ----- | ----- | ------- |
| `focus`          | Focuses on the window.                                                                                     | ✔️    | ✔️    | ➖      |
| `blur`           | Removes focus from the window.                                                                             | ➖    | ✔️    | ➖      |
| `show`           | Shows and gives focus to the window.                                                                       | ✔️    | ✔️    | ✔️      |
| `hide`           | Hides the window.                                                                                          | ✔️    | ✔️    | ✔️      |
| `isVisible`      | Returns `bool` - Whether the window is visible to the user.                                                | ✔️    | ✔️    | ✔️      |
| `isMaximized`    | Returns `bool` - Whether the window is maximized.                                                          | ✔️    | ✔️    | ✔️      |
| `maximize`       | Maximizes the window.                                                                                      | ✔️    | ✔️    | ✔️      |
| `unmaximize`     | Unmaximizes the window.                                                                                    | ✔️    | ✔️    | ✔️      |
| `isMinimized`    | Returns `bool` - Whether the window is minimized.                                                          | ✔️    | ✔️    | ✔️      |
| `minimize`       | Minimizes the window.                                                                                      | ✔️    | ✔️    | ✔️      |
| `restore`        | Restores the window from minimized state to its previous state.                                            | ✔️    | ✔️    | ✔️      |
| `isFullScreen`   | Returns `bool` - Whether the window is in fullscreen mode.                                                 | ✔️    | ✔️    | ✔️      |
| `setFullScreen`  | Sets whether the window should be in fullscreen mode.                                                      | ✔️    | ✔️    | ✔️      |
| `getBounds`      | Returns `Rect` - The bounds of the window as Object.                                                       | ✔️    | ✔️    | ✔️      |
| `setBounds`      | Resizes and moves the window to the supplied bounds.                                                       | ✔️    | ✔️    | ✔️      |
| `getPosition`    | Returns `Offset` - Contains the window's current position.                                                 | ✔️    | ✔️    | ✔️      |
| `setPosition`    | Moves window to `x` and `y`.                                                                               | ✔️    | ✔️    | ✔️      |
| `getSize`        | Returns `Size` - Contains the window's width and height.                                                   | ✔️    | ✔️    | ✔️      |
| `setSize`        | Resizes the window to `width` and `height`.                                                                | ✔️    | ✔️    | ✔️      |
| `setMinimumSize` | Sets the minimum size of window to `width` and `height`.                                                   | ✔️    | ✔️    | ✔️      |
| `setMaximumSize` | Sets the maximum size of window to `width` and `height`.                                                   | ✔️    | ✔️    | ✔️      |
| `isResizable`    | Returns `bool` - Whether the window can be manually resized by the user.                                   | ➖    | ✔️    | ➖      |
| `setResizable`   | Sets whether the window can be manually resized by the user.                                               | ➖    | ✔️    | ➖      |
| `isMovable`      | Returns `bool` - Whether the window can be moved by user. On Linux always returns `true`.                  | ➖    | ✔️    | ➖      |
| `setMovable`     | Sets whether the window can be moved by user. On Linux does nothing.                                       | ➖    | ✔️    | ➖      |
| `isMinimizable`  | Returns `bool` - Whether the window can be manually minimized by the user. On Linux always returns `true`. | ➖    | ✔️    | ➖      |
| `setMinimizable` | Sets whether the window can be manually minimized by user. On Linux does nothing.                          | ➖    | ✔️    | ➖      |
| `isClosable`     | Returns `bool` - Whether the window can be manually closed by user. On Linux always returns `true`.        | ➖    | ✔️    | ➖      |
| `setClosable`    | Sets whether the window can be manually closed by user. On Linux does nothing.                             | ➖    | ✔️    | ➖      |
| `isAlwaysOnTop`  | Returns `bool` - Whether the window is always on top of other windows.                                     | ✔️    | ✔️    | ✔️      |
| `setAlwaysOnTop` | Sets whether the window should show always on top of other windows.                                        | ✔️    | ✔️    | ✔️      |
| `getTitle`       | Returns `String` - The title of the native window.                                                         | ✔️    | ✔️    | ✔️      |
| `setTitle`       | Changes the title of native window to title.                                                               | ✔️    | ✔️    | ✔️      |
| `setSkipTaskbar` | Makes the window not show in the taskbar / dock.                                                           | ✔️    | ✔️    | ✔️      |
| `hasShadow`      | Returns `bool` - Whether the window has a shadow.                                                          | ➖    | ✔️    | ➖      |
| `setHasShadow`   | Sets whether the window should have a shadow.                                                              | ➖    | ✔️    | ➖      |
| `startDragging`  | -                                                                                                          | ✔️    | ✔️    | ✔️      |
| `terminate`      |                                                                                                            | ✔️    | ✔️    | ✔️      |

### WindowListener

| Method                    | Description                                                 | Linux | macOS | Windows |
| ------------------------- | ----------------------------------------------------------- | ----- | ----- | ------- |
| `onWindowFocus`           | Emitted when the window gains focus.                        | ✔️    | ✔️    | ✔️      |
| `onWindowBlur`            | Emitted when the window loses focus.                        | ✔️    | ✔️    | ✔️      |
| `onWindowMaximize`        | Emitted when window is maximized.                           | ✔️    | ✔️    | ✔️      |
| `onWindowUnmaximize`      | Emitted when the window exits from a maximized state.       | ✔️    | ✔️    | ✔️      |
| `onWindowMinimize`        | Emitted when the window is minimized.                       | ✔️    | ✔️    | ✔️      |
| `onWindowRestore`         | Emitted when the window is restored from a minimized state. | ✔️    | ✔️    | ✔️      |
| `onWindowResize`          | Emitted after the window has been resized.                  | ✔️    | ✔️    | ✔️      |
| `onWindowMove`            | Emitted when the window is being moved to a new position.   | ✔️    | ✔️    | ✔️      |
| `onWindowEnterFullScreen` | Emitted when the window enters a full-screen state.         | ✔️    | ✔️    | ✔️      |
| `onWindowLeaveFullScreen` | Emitted when the window leaves a full-screen state.         | ✔️    | ✔️    | ✔️      |

## License

```text
MIT License

Copyright (c) 2021 LiJianying <lijy91@foxmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
