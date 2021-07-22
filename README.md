# window_manager

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

This plugin allows Flutter **desktop** apps to resizing and repositioning the window.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Platform Support](#platform-support)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Usage](#usage)
- [API](#api)
  - [WindowManager](#windowmanager)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| MacOS | Linux | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ➖   |   ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  window_manager: ^0.0.1
```

Or

```yaml
dependencies:
  flutter_flipperkit:
    git:
      url: https://github.com/leanflutter/window_manager
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

| Method         | Description |
| -------------- | ----------- |
| setTitle       |             |
| getSize        |             |
| setSize        |             |
| setMinSize     |             |
| setMaxSize     |             |
| isUseAnimator  |             |
| setUseAnimator |             |
| isAlwaysOnTop  |             |
| setAlwaysOnTop |             |

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
