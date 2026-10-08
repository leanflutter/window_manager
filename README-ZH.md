> **window_manager 现在构建在 [nativeapi](https://github.com/libnativeapi/nativeapi) 之上**，
> 它是 C++ 核心库 [libnativeapi/nativeapi](https://github.com/libnativeapi/nativeapi) 的 Flutter 绑定，
> macOS、Windows、Linux 共用同一份实现。从 0.5.x 升级？请看[从 0.5.x 升级](#从-05x-升级)。

# window_manager

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] [![All Contributors][all-contributors-image]](#contributors)

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb
[all-contributors-image]: https://img.shields.io/github/all-contributors/leanflutter/window_manager?color=ee8449&style=flat-square

这个插件让 Flutter 桌面应用可以调整、移动、显示、隐藏和装饰自己的窗口。

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [平台支持](#平台支持)
- [快速开始](#快速开始)
  - [安装](#安装)
    - [环境要求](#环境要求)
  - [用法](#用法)
    - [从 0.5.x 升级](#从-05x-升级)
    - [迁移到原生 API](#迁移到原生-api)
- [文章](#文章)
- [谁在使用](#谁在使用)
- [API](#api)
  - [原生 API](#原生-api)
- [Contributors](#contributors)
- [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

## 快速开始

### 安装

把它加到你的 pubspec.yaml 里：

```yaml
dependencies:
  window_manager: ^0.6.0
```

或者

```yaml
dependencies:
  window_manager:
    git:
      url: https://github.com/leanflutter/window_manager.git
      ref: main
```

#### 环境要求

- Flutter 3.47 / Dart 3.13 及以上，macOS 10.15 及以上。
- Linux 构建机需要 GTK 3、X11 和 Xi 的开发文件：

```
sudo apt-get install libgtk-3-dev libx11-dev libxi-dev
```

### 用法

```dart
import 'package:window_manager/window_manager.dart';

final window = WindowManager.instance.getCurrent()!;

window.title = 'window_manager';
window.setSize(const Size(1000, 700).toNative(), false);
window.minimumSize = const Size(640, 480).toNative();
window.center();
window.show();

// 本应用所有窗口的所有窗口事件。
WindowManager.instance.addListener((event) {
  switch (event) {
    case WindowFocusedEvent():
      debugPrint('window ${event.windowId} focused');
    case WindowResizedEvent():
      debugPrint('window ${event.windowId} is now ${event.newSize.toSize()}');
    default:
      break;
  }
});

// 无论用户怎样关闭，关闭这个窗口前先询问。关闭请求只会发给窗口自己的监听器。
window.addListener((event) async {
  if (event is WindowCloseRequestedEvent && !await confirmClose()) {
    event.request.cancel();
  }
});
```

`Window` 使用的是 nativeapi 的 `Size`、`Point`、`Rectangle`、`Color`，它们和 Flutter
的同名类型冲突，所以没有导出：用 `toNative()` 把 Flutter 的值转过去，用 `toSize()`、
`toOffset()`、`toRect()`、`toColor()` 转回来。

使用 Flutter 的多窗口 API 时，`package:window_manager/windowing.dart` 可以拿到每个 Flutter
窗口控制器背后的 `Window`：

```dart
import 'package:window_manager/windowing.dart';

final window = controller.nativeWindow; // 或者 nativeWindowOf(controller)
window?.title = 'Inspector';
```

隐藏系统标题栏，改由 widget 来拖动和缩放：

```dart
final window = WindowManager.instance.getCurrent()!;
window.titleBarStyle = TitleBarStyle.hidden;

// 在应用里：
DragToResizeArea(
  child: Column(
    children: [
      WindowCaption(
        brightness: Theme.of(context).brightness,
        title: const Text('window_manager'),
      ),
      Expanded(child: body),
    ],
  ),
)
```

> 本插件的[示例应用](./example)演示的是 0.5.x 兼容 API。完整示例——同时管理多个窗口、
> 父子窗口、每一个原生属性——在 nativeapi 的
> [window_example](https://github.com/libnativeapi/nativeapi/tree/main/examples/flutter_window_example)。

#### 从 0.5.x 升级

为 `window_manager` 0.5.x 写的代码，只要把导入从
`package:window_manager/window_manager.dart` 换成
`package:window_manager/legacy.dart` 就能继续工作：老的 `windowManager`、
`WindowListener`、`WindowOptions` 和 `calcWindowPosition` 都在那里，底层换成了原生 API。

导入路径特意要改：`legacy.dart` 是一座桥，不是这个包的未来。里面的类都标了
`@Deprecated`，**会在之后的版本里删掉**——能迁就迁到上面的原生 API。

```dart
import 'package:window_manager/legacy.dart';

await windowManager.ensureInitialized();
await windowManager.waitUntilReadyToShow(
  const WindowOptions(size: Size(1000, 700), center: true),
  () async {
    await windowManager.show();
    await windowManager.focus();
  },
);
```

和 0.5.x 的差别：

- 需要 Flutter 3.47 / Dart 3.13 和 macOS 10.15（0.5.x 是 Flutter 3.3、macOS 10.11），
  但不再需要在 `MainFlutterWindow.swift`、`my_application.cc` 或 Windows runner 里做插件
  自己的接入——已经没有任何平台插件代码了。
- `close()`、`destroy()`、`setPreventClose()` 的行为和以前一样：设了
  `setPreventClose(true)` 之后，标题栏的关闭按钮和 `close()` 都会报告 `onWindowClose`
  而不关闭窗口，`destroy()` 仍然会关掉它。关闭最后一个窗口时是否退出应用，由平台的 runner 决定。
- `onWindowResized`、`onWindowMoved` 和 `onWindowResize`、`onWindowMove` 一起到达：
  nativeapi 每次变化只报一个事件，没有"过程中"和"结束时"之分。
- Aero-snap 贴边没有了：`isDockable()` 返回 false，`isDocked()` 返回 null，`dock()` 什么
  都不做，`undock()` 返回 false，`onWindowDocked` / `onWindowUndocked` 不会触发。
  `grabKeyboard()` / `ungrabKeyboard()`（Linux）同理。
- `popUpWindowMenu()` 在 Windows 和提供系统菜单的 Linux 窗口管理器上会在光标处弹出系统菜单，
  在 macOS 上什么都不做。
- `setIgnoreMouseEvents` 的 `forward` 在平台支持时（macOS、Windows、X11）保留鼠标悬停事件；
  其他平台上窗口直接忽略鼠标，不转发。
- 核心库用不上的参数会被接受但忽略：`maximize` 的 `vertically`、`setPosition` 和
  `setBounds` 的 `animate`、`setVisibleOnAllWorkspaces` 的 `visibleOnFullScreen`。
- `getId()` 返回的是 nativeapi 自己的窗口 id，不再是 `NSWindow` number 或 `HWND`。
- `setAsFrameless()` 只隐藏标题栏和它的按钮，不再去掉窗口边框。
- `setAlignment` 支持任意 `Alignment`，不再只认那九个常量。
- `WindowCaption` 的关闭按钮会关闭窗口，并先经过窗口的关闭监听器，所以 `setPreventClose`
  对它同样有效。在 Windows 11 上，它的最大化按钮会弹出贴靠布局。
- 全屏时 Windows 上的 `startDragging()`、`startResizing()` 不再被跳过：兼容层不保留自己的
  `Platform` 分支，交给核心库决定。
- `screen_retriever` 和 `path` 不再是依赖。
- 新示例只用 `package:flutter/widgets.dart`；完整示例是 nativeapi 的
  [window_example](https://github.com/libnativeapi/nativeapi/tree/main/examples/flutter_window_example)。

#### 迁移到原生 API

| 0.5.x（`legacy.dart`） | 原生 API（`window_manager.dart`） |
| --- | --- |
| `windowManager`（应用的那一个窗口） | `WindowManager.instance.getCurrent()`——还有 `get(id)`、`getAll()`、`getWindowAtPoint()`；每个窗口都是独立的 `Window` |
| `await windowManager.getSize()`、`setSize(size)` | `window.size.toSize()`、`window.setSize(size.toNative(), animate)`——同步，不需要 `await` |
| `getBounds()` / `setBounds(rect)` | `window.bounds.toRect()`、`window.bounds = rect.toNative()`；不含装饰的区域用 `window.contentBounds` |
| `getPosition()` / `setPosition(offset)` | `window.position.toOffset()`、`window.position = offset.toNative()` |
| `setMinimumSize` / `setMaximumSize` / `setAspectRatio` | `window.minimumSize`、`window.maximumSize`、`window.aspectRatio` |
| `show()` / `show(inactive: true)` / `hide()` | `window.show()` / `window.showInactive()` / `window.hide()` |
| `focus()`、`blur()`、`isFocused()` | `window.focus()`、`window.blur()`、`window.isFocused` |
| `maximize()`、`unmaximize()`、`minimize()`、`restore()` | `window` 上的同名方法，不需要 `await` |
| `setFullScreen(bool)` / `isFullScreen()` | `window.isFullScreen` |
| `setResizable`、`setMovable`、`setMinimizable`、`setMaximizable`、`setClosable` | `window.isResizable`、`isMovable`、`isMinimizable`、`isMaximizable`、`isClosable`——还有 `isFullScreenable` |
| `setAlwaysOnTop` / `setAlwaysOnBottom` | `window.isAlwaysOnTop` / `window.isAlwaysOnBottom` |
| `setSkipTaskbar(true)` | `window.isVisibleInTaskbar = false` |
| `setTitle` / `getTitle` | `window.title` |
| `setTitleBarStyle(style, windowButtonVisibility:)` | `window.titleBarStyle`、`window.isWindowControlButtonsVisible`——还有 `setTitleBarColors()` |
| `setHasShadow`、`setOpacity`、`setBackgroundColor` | `window.hasShadow`、`window.opacity`、`window.backgroundColor`——还有 `window.visualEffect` |
| `setIgnoreMouseEvents(ignore, forward:)` | `window.setIgnoreMouseEvents(ignore, forward)` |
| `close()` / `destroy()` | `window.close()`，会先询问窗口的关闭监听器 |
| `setPreventClose(true)` 配合 `onWindowClose` | `window.addListener((event) { if (event is WindowCloseRequestedEvent) event.request.cancel(); })` |
| `popUpWindowMenu()` | `window.showSystemMenu(position)`——用 `Window.isSystemMenuSupported()` 判断平台是否支持 |
| `setVisibleOnAllWorkspaces(bool)` | `window.isVisibleOnAllWorkspaces` |
| `startDragging()` / `startResizing(edge)` | `window` 上的同名方法；`DragToMoveArea`、`DragToResizeArea` 已经替你调用了 |
| `setProgressBar`、`setBadgeLabel`、`setIcon`、`setBrightness` | `Application.instance`——它们属于应用，不属于某一个窗口 |
| `WindowListener` | 单个窗口用 `window.addListener((event) { switch (event) { case WindowFocusedEvent(): … } })`，所有窗口用 `WindowManager.instance.addListener`——还有 `WindowBlurredEvent`、`WindowMinimizedEvent`、`WindowMaximizedEvent`、`WindowRestoredEvent`、`WindowMovedEvent`、`WindowResizedEvent`、`WindowEnteredFullScreenEvent`、`WindowExitedFullScreenEvent`、`WindowCreatedEvent`、`WindowClosedEvent` |
| `calcWindowPosition(size, alignment)` | `DisplayManager.instance`——`getAll()`、`getPrimary()`、`getCursorPosition()`，以及每个 `Display` 的 `workArea` |

`waitUntilReadyToShow`、`ensureInitialized`、`setAsFrameless`、`getDevicePixelRatio`
没有对应的原生 API：直接设好需要的属性，准备好了再调 `window.show()`。

## 文章

- [点击 Dock 图标在关闭窗口后恢复](https://leanflutter.org/blog/click-dock-icon-to-restore-after-closing-the-window)
- [让应用只运行一个实例](https://leanflutter.org/blog/making-the-app-single-instanced)

## 谁在使用

- [AuthPass](https://authpass.app/) - Password Manager based on Flutter for all platforms. Keepass 2.x (kdbx 3.x) compatible.
- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app written in dart / Flutter.
- [BlueBubbles](https://github.com/BlueBubblesApp/bluebubbles-app) - BlueBubbles is an ecosystem of apps bringing iMessage to Android, Windows, and Linux
- [LunaSea](https://github.com/CometTools/LunaSea) - A self-hosted controller for mobile and macOS built using the Flutter framework.
- [Linwood Butterfly](https://github.com/LinwoodCloud/Butterfly) - Open source note taking app written in Flutter
- [RustDesk](https://github.com/rustdesk/rustdesk) - Yet another remote desktop software, written in Rust. Works out of the box, no configuration required.
- [Ubuntu Desktop Installer](https://github.com/canonical/ubuntu-desktop-installer) - This project is a modern implementation of the Ubuntu Desktop installer.

## API

### 原生 API

`window_manager` 现在直接重新导出 `nativeapi` 的窗口 API——`Window`、`WindowManager`、
`TitleBarStyle`、`ResizeEdge`、`VisualEffect`、各种窗口事件以及用于响应关闭请求的
`EventRequest`，还有 `nativeapi_flutter` 的 `DragToMoveArea`、`DragToResizeArea`、
`MaximizeButtonArea` 三个 widget 和类型转换——再加上它自己的 `WindowCaption`、
`WindowCaptionButton` 和 `VirtualWindowFrame`。只有还在用 0.5.x API 的代码才需要导入
`package:window_manager/legacy.dart`。

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lijy91"><img src="https://avatars.githubusercontent.com/u/3889523?v=4?s=100" width="100px;" alt="LiJianying"/><br /><sub><b>LiJianying</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=lijy91" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/damywise"><img src="https://avatars.githubusercontent.com/u/25608913?v=4?s=100" width="100px;" alt=" A Arif A S"/><br /><sub><b> A Arif A S</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=damywise" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jpnurmi"><img src="https://avatars.githubusercontent.com/u/140617?v=4?s=100" width="100px;" alt="J-P Nurmi"/><br /><sub><b>J-P Nurmi</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=jpnurmi" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Dixeran"><img src="https://avatars.githubusercontent.com/u/22679810?v=4?s=100" width="100px;" alt="Dixeran"/><br /><sub><b>Dixeran</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=Dixeran" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nikitatg"><img src="https://avatars.githubusercontent.com/u/96043303?v=4?s=100" width="100px;" alt="nikitatg"/><br /><sub><b>nikitatg</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=nikitatg" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://merritt.codes/"><img src="https://avatars.githubusercontent.com/u/9575627?v=4?s=100" width="100px;" alt="Kristen McWilliam"/><br /><sub><b>Kristen McWilliam</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=Merrit" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Kingtous"><img src="https://avatars.githubusercontent.com/u/39793325?v=4?s=100" width="100px;" alt="Kingtous"/><br /><sub><b>Kingtous</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=Kingtous" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hlwhl"><img src="https://avatars.githubusercontent.com/u/7610615?v=4?s=100" width="100px;" alt="Prome"/><br /><sub><b>Prome</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=hlwhl" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://i.soit.tech/"><img src="https://avatars.githubusercontent.com/u/17426470?v=4?s=100" width="100px;" alt="Bin"/><br /><sub><b>Bin</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=boyan01" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/youxiachai"><img src="https://avatars.githubusercontent.com/u/929502?v=4?s=100" width="100px;" alt="youxiachai"/><br /><sub><b>youxiachai</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=youxiachai" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Allenxuxu"><img src="https://avatars.githubusercontent.com/u/20566897?v=4?s=100" width="100px;" alt="Allen Xu"/><br /><sub><b>Allen Xu</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=Allenxuxu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://linwood.dev/"><img src="https://avatars.githubusercontent.com/u/20452814?v=4?s=100" width="100px;" alt="CodeDoctor"/><br /><sub><b>CodeDoctor</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=CodeDoctorDE" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jcbinet"><img src="https://avatars.githubusercontent.com/u/17210882?v=4?s=100" width="100px;" alt="Jean-Christophe Binet"/><br /><sub><b>Jean-Christophe Binet</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=jcbinet" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Jon-Salmon"><img src="https://avatars.githubusercontent.com/u/26483285?v=4?s=100" width="100px;" alt="Jon Salmon"/><br /><sub><b>Jon Salmon</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=Jon-Salmon" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/koral--"><img src="https://avatars.githubusercontent.com/u/3340954?v=4?s=100" width="100px;" alt="Karol Wrótniak"/><br /><sub><b>Karol Wrótniak</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=koral--" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/laiiihz"><img src="https://avatars.githubusercontent.com/u/35956195?v=4?s=100" width="100px;" alt="LAIIIHZ"/><br /><sub><b>LAIIIHZ</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=laiiihz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/mikhailkulesh"><img src="https://avatars.githubusercontent.com/u/30557348?v=4?s=100" width="100px;" alt="Mikhail Kulesh"/><br /><sub><b>Mikhail Kulesh</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=mkulesh" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/prateekmedia"><img src="https://avatars.githubusercontent.com/u/41370460?v=4?s=100" width="100px;" alt="Prateek Sunal"/><br /><sub><b>Prateek Sunal</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=prateekmedia" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://ricardoboss.de/"><img src="https://avatars.githubusercontent.com/u/6266356?v=4?s=100" width="100px;" alt="Ricardo Boss"/><br /><sub><b>Ricardo Boss</b></sub></a><br /><a href="https://github.com/leanflutter/window_manager/commits?author=ricardoboss" title="Code">💻</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <img src="https://raw.githubusercontent.com/all-contributors/all-contributors-cli/1b8533af435da9854653492b1327a23a4dbd0a10/assets/logo-small.svg">
          <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
        </img>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## 许可证

[MIT](./LICENSE)
