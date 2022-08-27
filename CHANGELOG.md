## 0.2.7

* [linux] fix bottom edge resizing (#209)
* [linux] fix: cannot resize again after startResizing (#205)

## 0.2.6

* [windows] Added `vertically` param to the `maximize` method.
* [Linux] implementation of methods: setIcon, isFocused (#186)
* [macos] fix crash lead by fast clicks (#198)
* Remove decoration for maximized window (#191)
* [linux] fix: cannot drag again after startDragging (#203)
* [windows] Implement isMaximizable and setMaximizable (#200)
* [windows] Implement SetResizable for windows (#204)

## 0.2.5

* [linux] fix method response memory leaks (#159)
* [linux] Implement destroy #158
* [linux] Implement getOpacity & setOpacity #157
* [macos] Reimplement setBounds & getBounds method. #156
* Make WindowOptions constructor to const constructor. #147
* [windows] fix window overflow #131
* [macos] Add the animate parameter to setBounds method #142
* [linux] fix popUpWindowMenu() on Wayland #145

## 0.2.3

* Fixed cannot convert type Double to type CGFloat #138
* [linux & windows] Implement `popUpWindowMenu` metnod #141

## 0.2.2

* Fixed overflow error after minimize #55, #119, #125 
* Implement `isSkipTaskbar` method #117
* [windows] Implement setIcon method #129
* The `waitUntilReadyToShow` method adds options, callback parameters #111

## 0.2.1

* Compatible with lower versions of dart #98
* [macos & windows] Add `resized`, `moved` events. #28
* [linux] Implement `getTitleBarHeight` metnod #49
* [linux] Implement `getOpacity` metnod #44
* Add `TitleBarStyle` enum #99
* [linux] Implement `setAlwaysOnBottom` method #100
* [windows] Removes crazy jittering when resizing window #103
* [windows] Fix overflow on fullscreen and maximize #105
* [windows] Implement `setHasShadow` and `hasShadow` methods #110
* [windows] Fix setAlignment(Alignment.bottomRight) display position is not correct #112 #113

## 0.2.0

* [linux] Implement `setTitleBarStyle` method
* [linux] Implement `startResizing` method
* [windows] Implement `setProgressBar` method #42
* [macos & windows] Implement `setIgnoreMouseEvents` metnod #89
* Update `DragToResizeArea` widget
* Add `VirtualWindowFrame` widget
* Update `WindowCaption` widget

## 0.1.9

* Fixed Visual bug in fullScreen #83
* Update `WindowCaption` widget.

## 0.1.8

* Add `WindowCaption` widget. #81
* [macos & windows] Implement `destroy` method

## 0.1.7

* Implement `setAspectRatio` method #74
* [windows] Reimplement `getTitleBarHeight` method #33
* [windows] Implement `startResizing` method
* [windows] Add `DragToResizeArea` widget
* [windows] Fix maximize and minimize animation not working when there is title bar hidden

## 0.1.6

* Implement `isPreventClose` & `setPreventClose` methods #69
* Implement `close` event
* [macos & windows] Reimplement `close` method
* [windows] Fix Horizontal resizing not working on secondary display. #71
* [macos] Implement `isFocused` method
* Implement `setAlignment` method #52

## 0.1.5

* Implement `close` method #56
* Implement `center` method #59

## 0.1.4

* [macos & windows] Implemented getOpacity & setOpacity methods #37 #45
* [macos] Implement setProgressBar method #40
* [windows] Fix `focus`, `blur` event not responding
* [windows] Implement `focus` & `blur` methods
* [macos & windows] Implement getTitleBarHeight methods #34

## 0.1.3

* [windows] #31 Optimize setTitleBarStyle method.

## 0.1.2

* [macos] Add setTitleBarStyle method.
* [windows] Add setTitleBarStyle method (**Experiment**).
* [windows] #24 Updated windows fullscreen handling.
* [windows] #26 Make `maximize`, `unmaximize`, `minimize`, `restore` methods have native animation effects.

## 0.1.1

* [macos] Fixed `setSize` coordinate error.

## 0.1.0

* Implemented `isResizable`, `setResizable` Methods.
* Implemented `isClosable`, `setClosable` Methods.
* Removed `terminate` Method.
* [windows] Implemented `isMinimizable`, `setMinimizable` Methods.

## 0.0.5

* Implemented `setAsFrameless` Method.
* Implemented `setSkipTaskbar` Method.
* Implemented `focus`, `blur`, `maximize`, `unmaximize`, `minimize`, `restore`, `resize`, `move`, `enter-full-screen`, `leave-full-screen` Events.
* [macos] Implemented `hiddenWindowAtLaunch` Method.
* Fixed #10 

## 0.0.4

* Implemented `setCustomFrame`, `setBackgroundColor` Methods.

## 0.0.3

* Implemented `isMinimized`, `minimize`, `restore` Methods.
* Implemented `setMinimumSize`, `setMaximumSize` Methods.
* [windows] [#4](https://github.com/leanflutter/window_manager/issues/4) Do not set `HWND_TOPMOST` flag in `setFullScreen`

## 0.0.2

* Implemented `show`, `hide`, `isVisible` Methods.
* Implemented `isMaximized`, `maximize`, `unmaximize` Methods.
* Implemented `isFullScreen`, `setFullScreen` Methods.
* Implemented `getBounds`, `setBounds` Methods.
* Implemented `getPosition`, `setPosition` Methods.
* Implemented `getSize`, `setSize` Methods.
* Implemented `isAlwaysOnTop`, `setAlwaysOnTop` Methods.
* Implemented `terminate` Method.

## 0.0.1

* First release.
