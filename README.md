# window_manager

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] [![All Contributors][all-contributors-image]](#contributors)

[pub-image]: https://img.shields.io/pub/v/window_manager.svg
[pub-url]: https://pub.dev/packages/window_manager

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.window_manager/visits
[all-contributors-image]: https://img.shields.io/github/all-contributors/leanflutter/window_manager?color=ee8449&style=flat-square

This plugin allows Flutter desktop apps to resizing and repositioning the window.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Listening events](#listening-events)
    - [Quit on close](#quit-on-close)
      - [macOS](#macos)
    - [Confirm before closing](#confirm-before-closing)
    - [Hidden at launch](#hidden-at-launch)
      - [Linux](#linux)
      - [macOS](#macos-1)
      - [Windows](#windows)
- [Articles](#articles)
- [Who's using it?](#whos-using-it)
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
      - [isMaximizable `macos` `windows`](#ismaximizable--macos--windows)
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
      - [setProgressBar  `macos`  `windows`](#setprogressbar--macos--windows)
      - [setIcon  `windows`](#seticon--windows)
      - [hasShadow  `macos`  `windows`](#hasshadow--macos--windows)
      - [setHasShadow  `macos`  `windows`](#sethasshadow--macos--windows)
      - [getOpacity](#getopacity)
      - [setOpacity](#setopacity)
      - [setBrightness](#setbrightness)
      - [setIgnoreMouseEvents](#setignoremouseevents)
      - [startDragging](#startdragging)
      - [startResizing  `linux`  `windows`](#startresizing--linux--windows)
      - [grabKeyboard  `linux`](#grabkeyboard--linux)
      - [ungrabKeyboard  `linux`](#ungrabkeyboard--linux)
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
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## Quick Start

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  window_manager: ^0.3.1
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

#### Quit on close

If you need to use the hide method, you need to disable `QuitOnClose`.

##### macOS

Change the file `macos/Runner/AppDelegate.swift` as follows:

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

#### Confirm before closing

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
    // Add this line to override the default close handler
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

#### Hidden at launch

##### Linux

Change the file `linux/my_application.cc` as follows:

```diff

...

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  
  ...

  gtk_window_set_default_size(window, 1280, 720);
-  gtk_widget_show(GTK_WIDGET(window));
+  gtk_widget_realize(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

...

```

##### macOS

Change the file `macos/Runner/MainFlutterWindow.swift` as follows:

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

Change the file `windows/runner/win32_window.cpp` as follows:

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

Since flutter 3.7 new windows project
Change the file `windows/runner/flutter_window.cpp` as follows:
```diff
bool FlutterWindow::OnCreate() {
  ...
  flutter_controller_->engine()->SetNextFrameCallback([&]() {
-   this->Show();
+   "" //delete this->Show()
  });
```

Make sure to call `setState` once on the `onWindowFocus` event.

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

##### setProgressBar  `macos`  `windows`

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

##### setBrightness

Sets the brightness of the window.

##### setIgnoreMouseEvents

Makes the window ignore all mouse events.

All mouse events happened in this window will be passed to the window below this window, but if this window has focus, it will still receive keyboard events.

##### startDragging

Starts a window drag based on the specified mouse-down event.

##### startResizing  `linux`  `windows`

Starts a window resize based on the specified mouse-down & mouse-move event.


##### grabKeyboard  `linux`

Grabs the keyboard.

##### ungrabKeyboard  `linux`

Ungrabs the keyboard.

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
