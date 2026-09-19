> **window_manager is built on [nativeapi](https://github.com/libnativeapi/nativeapi-flutter)**, a
> Flutter binding of one C++ core library ([libnativeapi/nativeapi](https://github.com/libnativeapi/nativeapi))
> shared by macOS, Windows and Linux. Coming from 0.5.x? See [Upgrading from 0.5.x](#upgrading-from-05x).

# window_manager

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] [![All Contributors][all-contributors-image]](#contributors)

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb
[all-contributors-image]: https://img.shields.io/github/all-contributors/leanflutter/window_manager?color=ee8449&style=flat-square

This package lets Flutter desktop apps size, move, show, hide and decorate their own
window.

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Quick Start](#quick-start)
  - [Installation](#installation)
    - [Requirements](#requirements)
  - [Usage](#usage)
    - [Upgrading from 0.5.x](#upgrading-from-05x)
    - [Moving to the native API](#moving-to-the-native-api)
- [Articles](#articles)
- [Who's using it?](#whos-using-it)
- [API](#api)
  - [Native API](#native-api)
- [Contributors](#contributors)
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
  window_manager: ^0.6.0
```

Or

```yaml
dependencies:
  window_manager:
    git:
      url: https://github.com/leanflutter/window_manager.git
      ref: main
```

#### Requirements

- Flutter 3.47 / Dart 3.13 or later, macOS 10.15 or later.
- Linux build machines need GTK 3, X11 and Xi development files:

```
sudo apt-get install libgtk-3-dev libx11-dev libxi-dev
```

### Usage

```dart
import 'package:window_manager/window_manager.dart';

final window = WindowManager.instance.getCurrent()!;

window.title = 'window_manager';
window.setSize(const Size(1000, 700), false);
window.minimumSize = const Size(640, 480);
window.center();
window.show();

// Every window event of every window of this app.
WindowManager.instance.addListener((event) {
  switch (event) {
    case WindowFocusedEvent():
      debugPrint('window ${event.windowId} focused');
    case WindowResizedEvent():
      debugPrint('window ${event.windowId} is now ${event.newSize}');
    default:
      break;
  }
});
```

A window with no title bar of its own, dragged and resized by widgets:

```dart
final window = WindowManager.instance.getCurrent()!;
window.titleBarStyle = TitleBarStyle.hidden;

// In the app:
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

> The [example app](./example) of this plugin covers the 0.5.x compatible API. For the
> full example — several windows at once, parent and child windows, every native
> property — see nativeapi's
> [window_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/window_example).

#### Upgrading from 0.5.x

Code written for `window_manager` 0.5.x keeps working by importing
`package:window_manager/legacy.dart` instead of
`package:window_manager/window_manager.dart`. It provides the old `windowManager`,
`WindowListener`, `WindowOptions` and `calcWindowPosition` on top of the native API.

The import has to change on purpose: `legacy.dart` is a bridge, not the future of this
package. Its classes are marked `@Deprecated` and **will be removed in a later
release** — move to the native API above when you can.

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

What differs from 0.5.x:

- Builds need Flutter 3.47 / Dart 3.13 and macOS 10.15 (0.5.x: Flutter 3.3, macOS 10.11),
  and no longer need the plugin's own setup in `MainFlutterWindow.swift`, `my_application.cc`
  or the Windows runner — there is no platform plugin code left.
- **`close()`, `destroy()` and `setPreventClose()` cannot close one window yet**: the core
  library has no per-window close. `destroy()` and an unprevented `close()` quit the
  application; with `setPreventClose(true)`, `close()` reports `onWindowClose` and leaves
  the window alone, as before. The system's own close button is **not** intercepted, so an
  app that asks "are you sure?" has to keep that dialog for its own close button until the
  core library grows a cancellable close event.
- `onWindowResized` and `onWindowMoved` arrive together with `onWindowResize` and
  `onWindowMove`: nativeapi reports one event per change, not a stream and a final one.
- `onWindowEnterFullScreen` and `onWindowLeaveFullScreen` are derived from the window's
  state after a resize, so a full-screen change that resizes nothing goes unreported.
- Aero-snap docking is gone: `isDockable()` answers false, `isDocked()` null, `dock()`
  does nothing, `undock()` answers false, and `onWindowDocked` / `onWindowUndocked` never
  fire. `grabKeyboard()` / `ungrabKeyboard()` (Linux) and `popUpWindowMenu()` are gone the
  same way.
- Arguments the core library has no use for are accepted and ignored: `vertically` of
  `maximize`, `animate` of `setPosition` and `setBounds`, `forward` of
  `setIgnoreMouseEvents`, `visibleOnFullScreen` of `setVisibleOnAllWorkspaces`.
- `getId()` answers nativeapi's own window id, not the `NSWindow` number or the `HWND`.
- `setAsFrameless()` hides the title bar and its buttons; it no longer removes the
  window's border.
- `setAlignment` handles any `Alignment`, not only the nine constants.
- `WindowCaption`'s close button quits the application, for the same reason `close()`
  does. Pass `onClose:` to do something else — `onClose: windowManager.close` keeps the
  0.5.x behaviour, `setPreventClose` included.
- `screen_retriever` and `path` are no longer dependencies.
- New example on `package:flutter/widgets.dart` alone; the full one is nativeapi's
  [window_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/window_example).

#### Moving to the native API

| 0.5.x (`legacy.dart`) | Native API (`window_manager.dart`) |
| --- | --- |
| `windowManager` (the app's one window) | `WindowManager.instance.getCurrent()` — or `get(id)`, `getAll()`, `getWindowAtPoint()`; every window is a `Window` of its own |
| `await windowManager.getSize()`, `setSize(size)` | `window.size`, `window.setSize(size, animate)` — synchronous, no `await` |
| `getBounds()` / `setBounds(rect)` | `window.bounds`; `window.contentBounds` for the area without decorations |
| `getPosition()` / `setPosition(offset)` | `window.position` |
| `setMinimumSize` / `setMaximumSize` / `setAspectRatio` | `window.minimumSize`, `window.maximumSize`, `window.aspectRatio` |
| `show()` / `show(inactive: true)` / `hide()` | `window.show()` / `window.showInactive()` / `window.hide()` |
| `focus()`, `blur()`, `isFocused()` | `window.focus()`, `window.blur()`, `window.isFocused` |
| `maximize()`, `unmaximize()`, `minimize()`, `restore()` | the same names on `window`, without `await` |
| `setFullScreen(bool)` / `isFullScreen()` | `window.isFullScreen` |
| `setResizable`, `setMovable`, `setMinimizable`, `setMaximizable`, `setClosable` | `window.isResizable`, `isMovable`, `isMinimizable`, `isMaximizable`, `isClosable` — also `isFullScreenable` |
| `setAlwaysOnTop` / `setAlwaysOnBottom` | `window.isAlwaysOnTop` / `window.isAlwaysOnBottom` |
| `setSkipTaskbar(true)` | `window.isVisibleInTaskbar = false` |
| `setTitle` / `getTitle` | `window.title` |
| `setTitleBarStyle(style, windowButtonVisibility:)` | `window.titleBarStyle`, `window.isWindowControlButtonsVisible` — also `setTitleBarColors()` |
| `setHasShadow`, `setOpacity`, `setBackgroundColor` | `window.hasShadow`, `window.opacity`, `window.backgroundColor` — also `window.visualEffect` |
| `setIgnoreMouseEvents(bool)` | `window.isIgnoreMouseEvents` |
| `setVisibleOnAllWorkspaces(bool)` | `window.isVisibleOnAllWorkspaces` |
| `startDragging()` / `startResizing(edge)` | the same names on `window`; `DragToMoveArea` and `DragToResizeArea` call them for you |
| `setProgressBar`, `setBadgeLabel`, `setIcon`, `setBrightness` | `Application.instance` — they belong to the app, not to one window |
| `WindowListener` | `WindowManager.instance.addListener((event) { switch (event) { case WindowFocusedEvent(): … } })` — also `WindowBlurredEvent`, `WindowMinimizedEvent`, `WindowMaximizedEvent`, `WindowRestoredEvent`, `WindowMovedEvent`, `WindowResizedEvent`, `WindowCreatedEvent`, `WindowClosedEvent` |
| `calcWindowPosition(size, alignment)` | `DisplayManager.instance` — `getAll()`, `getPrimary()`, `getCursorPosition()`, and each `Display`'s `workArea` |

`waitUntilReadyToShow`, `ensureInitialized`, `setAsFrameless` and `getDevicePixelRatio`
have no native counterpart: set the properties you want and call `window.show()` when
you are ready.

## Articles

- [Click the dock icon to restore after closing the window](https://leanflutter.org/blog/click-dock-icon-to-restore-after-closing-the-window)
- [Making the app single-instanced](https://leanflutter.org/blog/making-the-app-single-instanced)

## Who's using it?

- [AuthPass](https://authpass.app/) - Password Manager based on Flutter for all platforms. Keepass 2.x (kdbx 3.x) compatible.
- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app written in dart / Flutter.
- [BlueBubbles](https://github.com/BlueBubblesApp/bluebubbles-app) - BlueBubbles is an ecosystem of apps bringing iMessage to Android, Windows, and Linux
- [LunaSea](https://github.com/CometTools/LunaSea) - A self-hosted controller for mobile and macOS built using the Flutter framework.
- [Linwood Butterfly](https://github.com/LinwoodCloud/Butterfly) - Open source note taking app written in Flutter
- [RustDesk](https://github.com/rustdesk/rustdesk) - Yet another remote desktop software, written in Rust. Works out of the box, no configuration required. 
- [Ubuntu Desktop Installer](https://github.com/canonical/ubuntu-desktop-installer) - This project is a modern implementation of the Ubuntu Desktop installer.

## API

### Native API

`window_manager` now re-exports the windowing APIs of `nativeapi` — `Window`,
`WindowManager`, `TitleBarStyle`, `ResizeEdge`, `VisualEffect`, the window events, and
the `DragToMoveArea` / `DragToResizeArea` widgets — alongside its own
`WindowCaption`, `WindowCaptionButton` and `VirtualWindowFrame`. Import
`package:window_manager/legacy.dart` only for code that still uses the 0.5.x API.

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

## License

[MIT](./LICENSE)
