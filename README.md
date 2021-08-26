# window_manager

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

This plugin allows Flutter **desktop** apps to resizing and repositioning the window.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [window_manager](#window_manager)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [API](#api)
    - [WindowManager](#windowmanager)
    - [WindowListener](#windowlistener)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | MacOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

> In fact, `window_manager` support the `web` platform to integrate flutter web to web page.

See [demo](https://embed-window-manager-example.vercel.app/).

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  window_manager: ^0.0.2
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
Size windowSize = await WindowManager.instance.getSize();
await WindowManager.instance.setSize(Size(400, 600));
await WindowManager.instance.setAlwaysOnTop(_isAlwaysOnTop);
```

> Please see the example app of this plugin for a full example.

## API

### WindowManager

| Method           | Description                                                            | Linux | MacOS | Windows |
| ---------------- | ---------------------------------------------------------------------- | ----- | ----- | ------- |
| `focus`          | Focuses on the window.                                                 | ✔️    | ✔️    | ➖      |
| `blur`           | Removes focus from the window.                                         | ➖    | ✔️    | ➖      |
| `show`           | Shows and gives focus to the window.                                   | ✔️    | ✔️    | ✔️      |
| `hide`           | Hides the window.                                                      | ✔️    | ✔️    | ✔️      |
| `isVisible`      | Returns `bool` - Whether the window is visible to the user.            | ✔️    | ✔️    | ✔️      |
| `isMaximized`    | Returns Boolean - Whether the window is maximized.                     | ✔️    | ✔️    | ✔️      |
| `maximize`       | Maximizes the window.                                                  | ✔️    | ✔️    | ✔️      |
| `unmaximize`     | Unmaximizes the window.                                                | ✔️    | ✔️    | ✔️      |
| `isMinimized`    | Returns `bool` - Whether the window is minimized.                      | ➖    | ✔️    | ✔️      |
| `minimize`       | Minimizes the window.                                                  | ➖    | ✔️    | ✔️      |
| `restore`        | Restores the window from minimized state to its previous state.        | ➖    | ✔️    | ✔️      |
| `isFullScreen`   | Returns `bool` - Whether the window is in fullscreen mode.             | ✔️    | ✔️    | ✔️      |
| `setFullScreen`  | Sets whether the window should be in fullscreen mode.                  | ✔️    | ✔️    | ✔️      |
| `getBounds`      | Returns `Rect` - The bounds of the window as Object.                   | ✔️    | ✔️    | ✔️      |
| `setBounds`      | Resizes and moves the window to the supplied bounds.                   | ✔️    | ✔️    | ✔️      |
| `getPosition`    | Returns `Offset` - Contains the window's current position.             | ✔️    | ✔️    | ✔️      |
| `setPosition`    | Moves window to `x` and `y`.                                           | ✔️    | ✔️    | ✔️      |
| `getSize`        | Returns `Size` - Contains the window's width and height.               | ✔️    | ✔️    | ✔️      |
| `setSize`        | Resizes the window to `width` and `height`.                            | ✔️    | ✔️    | ✔️      |
| `setMinimumSize` | Sets the minimum size of window to `width` and `height`.               | ✔️    | ✔️    | ➖      |
| `setMaximumSize` | Sets the maximum size of window to `width` and `height`.               | ✔️    | ✔️    | ➖      |
| `isAlwaysOnTop`  | Returns `bool` - Whether the window is always on top of other windows. | ✔️    | ✔️    | ✔️      |
| `setAlwaysOnTop` | Sets whether the window should show always on top of other windows.    | ✔️    | ✔️    | ✔️      |
| `terminate`      |                                                                        | ✔️    | ✔️    | ✔️      |

### WindowListener

| Method                    | Description                                                 | Linux | MacOS | Windows |
| ------------------------- | ----------------------------------------------------------- | ----- | ----- | ------- |
| `onWindowFocus`           | Emitted when the window gains focus.                        | ➖    | ✔️    | ➖      |
| `onWindowBlur`            | Emitted when the window loses focus.                        | ➖    | ✔️    | ➖      |
| `onWindowMaximize`        | Emitted when window is maximized.                           | ➖    | ➖    | ➖      |
| `onWindowUnmaximize`      | Emitted when the window exits from a maximized state.       | ➖    | ➖    | ➖      |
| `onWindowMinimize`        | Emitted when the window is minimized.                       | ➖    | ✔️    | ➖      |
| `onWindowRestore`         | Emitted when the window is restored from a minimized state. | ➖    | ✔️    | ➖      |
| `onWindowEnterFullScreen` | Emitted when the window enters a full-screen state.         | ➖    | ✔️    | ➖      |
| `onWindowLeaveFullScreen` | Emitted when the window leaves a full-screen state.         | ➖    | ✔️    | ➖      |

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
