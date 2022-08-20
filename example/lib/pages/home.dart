import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:flutter/material.dart' hide MenuItem;
import 'package:preference_list/preference_list.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../utilities/utilities.dart';

const _kSizes = [
  Size(400, 400),
  Size(600, 600),
  Size(800, 800),
];

const _kMinSizes = [
  Size(400, 400),
  Size(600, 600),
];

const _kMaxSizes = [
  Size(600, 600),
  Size(800, 800),
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

const _kIconTypeDefault = 'default';
const _kIconTypeOriginal = 'original';

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  bool _isPreventClose = false;
  Size _size = _kSizes.first;
  Size? _minSize;
  Size? _maxSize;
  bool _isFullScreen = false;
  bool _isResizable = true;
  bool _isMovable = true;
  bool _isMinimizable = true;
  bool _isMaximizable = true;
  bool _isClosable = true;
  bool _isAlwaysOnTop = false;
  bool _isAlwaysOnBottom = false;
  bool _isSkipTaskbar = false;
  double _progress = 0;
  bool _hasShadow = true;
  double _opacity = 1;
  bool _isIgnoreMouseEvents = false;
  String _iconType = _kIconTypeOriginal;

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem(
          key: 'set_ignore_mouse_events',
          label: 'setIgnoreMouseEvents(false)',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    setState(() {});
  }

  void _handleSetIcon(String iconType) async {
    _iconType = iconType;
    String iconPath =
        Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png';

    if (_iconType == 'original') {
      iconPath = Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png';
    }

    await windowManager.setIcon(iconPath);
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('ThemeMode'),
              detailText: Text('${sharedConfig.themeMode}'),
              onTap: () async {
                ThemeMode newThemeMode =
                    sharedConfig.themeMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;

                await sharedConfigManager.setThemeMode(newThemeMode);
                await windowManager.setBrightness(
                  newThemeMode == ThemeMode.light
                      ? Brightness.light
                      : Brightness.dark,
                );
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('METHODS'),
          children: [
            PreferenceListItem(
              title: Text('setAsFrameless'),
              onTap: () async {
                await windowManager.setAsFrameless();
              },
            ),
            PreferenceListItem(
              title: Text('close'),
              onTap: () async {
                await windowManager.close();
                await Future.delayed(Duration(seconds: 2));
                await windowManager.show();
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isPreventClose / setPreventClose'),
              onTap: () async {
                _isPreventClose = await windowManager.isPreventClose();
                BotToast.showText(text: 'isPreventClose: $_isPreventClose');
              },
              value: _isPreventClose,
              onChanged: (newValue) async {
                _isPreventClose = newValue;
                await windowManager.setPreventClose(_isPreventClose);
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('focus / blur'),
              onTap: () async {
                await windowManager.blur();
                await Future.delayed(Duration(seconds: 2));
                print('isFocused: ${await windowManager.isFocused()}');
                await Future.delayed(Duration(seconds: 2));
                await windowManager.focus();
                await Future.delayed(Duration(seconds: 2));
                print('isFocused: ${await windowManager.isFocused()}');
              },
            ),
            PreferenceListItem(
              title: Text('show / hide'),
              onTap: () async {
                await windowManager.hide();
                await Future.delayed(Duration(seconds: 2));
                await windowManager.show();
                await windowManager.focus();
              },
            ),
            PreferenceListItem(
              title: Text('isVisible'),
              onTap: () async {
                bool isVisible = await windowManager.isVisible();
                BotToast.showText(
                  text: 'isVisible: $isVisible',
                );

                await Future.delayed(Duration(seconds: 2));
                windowManager.hide();
                isVisible = await windowManager.isVisible();
                print('isVisible: $isVisible');
                await Future.delayed(Duration(seconds: 2));
                windowManager.show();
              },
            ),
            PreferenceListItem(
              title: Text('isMaximized'),
              onTap: () async {
                bool isMaximized = await windowManager.isMaximized();
                BotToast.showText(
                  text: 'isMaximized: $isMaximized',
                );
              },
            ),
            PreferenceListItem(
              title: Text('maximize / unmaximize'),
              onTap: () async {
                windowManager.maximize();
                await Future.delayed(Duration(seconds: 2));
                windowManager.unmaximize();
              },
            ),
            PreferenceListItem(
              title: Text('isMinimized'),
              onTap: () async {
                bool isMinimized = await windowManager.isMinimized();
                BotToast.showText(
                  text: 'isMinimized: $isMinimized',
                );

                await Future.delayed(Duration(seconds: 2));
                windowManager.minimize();
                await Future.delayed(Duration(seconds: 2));
                isMinimized = await windowManager.isMinimized();
                print('isMinimized: $isMinimized');
                windowManager.restore();
              },
            ),
            PreferenceListItem(
              title: Text('minimize / restore'),
              onTap: () async {
                windowManager.minimize();
                await Future.delayed(Duration(seconds: 2));
                windowManager.restore();
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isFullScreen / setFullScreen'),
              onTap: () async {
                bool isFullScreen = await windowManager.isFullScreen();
                BotToast.showText(text: 'isFullScreen: $isFullScreen');
              },
              value: _isFullScreen,
              onChanged: (newValue) {
                _isFullScreen = newValue;
                windowManager.setFullScreen(_isFullScreen);
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('setAspectRatio'),
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('reset'),
                    onPressed: () async {
                      windowManager.setAspectRatio(0);
                    },
                  ),
                  CupertinoButton(
                    child: Text('1:1'),
                    onPressed: () async {
                      windowManager.setAspectRatio(1);
                    },
                  ),
                  CupertinoButton(
                    child: Text('16:9'),
                    onPressed: () async {
                      windowManager.setAspectRatio(16 / 9);
                    },
                  ),
                  CupertinoButton(
                    child: Text('4:3'),
                    onPressed: () async {
                      windowManager.setAspectRatio(4 / 3);
                    },
                  ),
                ],
              ),
            ),
            PreferenceListItem(
              title: Text('setBackgroundColor'),
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('transparent'),
                    onPressed: () async {
                      windowManager.setBackgroundColor(Colors.transparent);
                    },
                  ),
                  CupertinoButton(
                    child: Text('red'),
                    onPressed: () async {
                      windowManager.setBackgroundColor(Colors.red);
                    },
                  ),
                  CupertinoButton(
                    child: Text('green'),
                    onPressed: () async {
                      windowManager.setBackgroundColor(Colors.green);
                    },
                  ),
                  CupertinoButton(
                    child: Text('blue'),
                    onPressed: () async {
                      windowManager.setBackgroundColor(Colors.blue);
                    },
                  ),
                ],
              ),
            ),
            PreferenceListItem(
              title: Text('setBounds / setBounds'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) async {
                  _size = _kSizes[index];
                  Offset newPosition = await calcWindowPosition(
                    _size,
                    Alignment.center,
                  );
                  await windowManager.setBounds(
                    // Rect.fromLTWH(
                    //   bounds.left + 10,
                    //   bounds.top + 10,
                    //   _size.width,
                    //   _size.height,
                    // ),
                    null,
                    position: newPosition,
                    size: _size,
                    animate: true,
                  );
                  setState(() {});
                },
                isSelected: _kSizes.map((e) => e == _size).toList(),
              ),
              onTap: () async {
                Rect bounds = await windowManager.getBounds();
                Size size = bounds.size;
                Offset origin = bounds.topLeft;
                BotToast.showText(
                  text: '${size.toString()}\n${origin.toString()}',
                );
              },
            ),
            PreferenceListItem(
              title: Text('setAlignment'),
              accessoryView: Container(
                width: 300,
                child: Wrap(
                  children: [
                    CupertinoButton(
                      child: Text('topLeft'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.topLeft,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('topCenter'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.topCenter,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('topRight'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.topRight,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('centerLeft'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.centerLeft,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('center'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.center,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('centerRight'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.centerRight,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('bottomLeft'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.bottomLeft,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('bottomCenter'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.bottomCenter,
                          animate: true,
                        );
                      },
                    ),
                    CupertinoButton(
                      child: Text('bottomRight'),
                      onPressed: () async {
                        await windowManager.setAlignment(
                          Alignment.bottomRight,
                          animate: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
              onTap: () async {},
            ),
            PreferenceListItem(
              title: Text('center'),
              onTap: () async {
                await windowManager.center();
              },
            ),
            PreferenceListItem(
              title: Text('getPosition / setPosition'),
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('xy>zero'),
                    onPressed: () async {
                      windowManager.setPosition(Offset(0, 0));
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('x+20'),
                    onPressed: () async {
                      Offset p = await windowManager.getPosition();
                      windowManager.setPosition(Offset(p.dx + 20, p.dy));
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('x-20'),
                    onPressed: () async {
                      Offset p = await windowManager.getPosition();
                      windowManager.setPosition(Offset(p.dx - 20, p.dy));
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('y+20'),
                    onPressed: () async {
                      Offset p = await windowManager.getPosition();
                      windowManager.setPosition(Offset(p.dx, p.dy + 20));
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('y-20'),
                    onPressed: () async {
                      Offset p = await windowManager.getPosition();
                      windowManager.setPosition(Offset(p.dx, p.dy - 20));
                      setState(() {});
                    },
                  ),
                ],
              ),
              onTap: () async {
                Offset position = await windowManager.getPosition();
                BotToast.showText(
                  text: '${position.toString()}',
                );
              },
            ),
            PreferenceListItem(
              title: Text('getSize / setSize'),
              accessoryView: CupertinoButton(
                child: Text('Set'),
                onPressed: () async {
                  Size size = await windowManager.getSize();
                  windowManager.setSize(
                    Size(size.width + 100, size.height + 100),
                  );
                  setState(() {});
                },
              ),
              onTap: () async {
                Size size = await windowManager.getSize();
                BotToast.showText(
                  text: '${size.toString()}',
                );
              },
            ),
            PreferenceListItem(
              title: Text('getMinimumSize / setMinimumSize'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kMinSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) {
                  _minSize = _kMinSizes[index];
                  windowManager.setMinimumSize(_minSize!);
                  setState(() {});
                },
                isSelected: _kMinSizes.map((e) => e == _minSize).toList(),
              ),
            ),
            PreferenceListItem(
              title: Text('getMaximumSize / setMaximumSize'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kMaxSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) {
                  _maxSize = _kMaxSizes[index];
                  windowManager.setMaximumSize(_maxSize!);
                  setState(() {});
                },
                isSelected: _kMaxSizes.map((e) => e == _maxSize).toList(),
              ),
            ),
            PreferenceListSwitchItem(
              title: Text('isResizable / setResizable'),
              onTap: () async {
                bool isResizable = await windowManager.isResizable();
                BotToast.showText(text: 'isResizable: $isResizable');
              },
              value: _isResizable,
              onChanged: (newValue) {
                _isResizable = newValue;
                windowManager.setResizable(_isResizable);
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isMovable / setMovable'),
              onTap: () async {
                bool isMovable = await windowManager.isMovable();
                BotToast.showText(text: 'isMovable: $isMovable');
              },
              value: _isMovable,
              onChanged: (newValue) {
                _isMovable = newValue;
                windowManager.setMovable(_isMovable);
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isMinimizable / setMinimizable'),
              onTap: () async {
                _isMinimizable = await windowManager.isMinimizable();
                setState(() {});
                BotToast.showText(text: 'isMinimizable: $_isMinimizable');
              },
              value: _isMinimizable,
              onChanged: (newValue) async {
                await windowManager.setMinimizable(newValue);
                _isMinimizable = await windowManager.isMinimizable();
                print('isMinimizable: $_isMinimizable');
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isMaximizable / setMaximizable'),
              onTap: () async {
                _isMaximizable = await windowManager.isMaximizable();
                setState(() {});
                BotToast.showText(text: 'isClosable: $_isMaximizable');
              },
              value: _isMaximizable,
              onChanged: (newValue) async {
                await windowManager.setMaximizable(newValue);
                _isMaximizable = await windowManager.isMaximizable();
                print('isMaximizable: $_isMaximizable');
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isClosable / setClosable'),
              onTap: () async {
                _isClosable = await windowManager.isClosable();
                setState(() {});
                BotToast.showText(text: 'isClosable: $_isClosable');
              },
              value: _isClosable,
              onChanged: (newValue) async {
                await windowManager.setClosable(newValue);
                _isClosable = await windowManager.isClosable();
                print('isClosable: $_isClosable');
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isAlwaysOnTop / setAlwaysOnTop'),
              onTap: () async {
                bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();
                BotToast.showText(text: 'isAlwaysOnTop: $isAlwaysOnTop');
              },
              value: _isAlwaysOnTop,
              onChanged: (newValue) {
                _isAlwaysOnTop = newValue;
                windowManager.setAlwaysOnTop(_isAlwaysOnTop);
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isAlwaysOnBottom / setAlwaysOnBottom'),
              onTap: () async {
                bool isAlwaysOnBottom = await windowManager.isAlwaysOnBottom();
                BotToast.showText(text: 'isAlwaysOnBottom: $isAlwaysOnBottom');
              },
              value: _isAlwaysOnBottom,
              onChanged: (newValue) {
                _isAlwaysOnBottom = newValue;
                windowManager.setAlwaysOnBottom(_isAlwaysOnBottom);
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('getTitle / setTitle'),
              onTap: () async {
                String title = await windowManager.getTitle();
                BotToast.showText(
                  text: '${title.toString()}',
                );
                title =
                    'window_manager_example - ${DateTime.now().millisecondsSinceEpoch}';
                await windowManager.setTitle(title);
              },
            ),
            PreferenceListItem(
              title: Text('setTitleBarStyle'),
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('normal'),
                    onPressed: () async {
                      windowManager.setTitleBarStyle(
                        TitleBarStyle.normal,
                        windowButtonVisibility: true,
                      );
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('hidden'),
                    onPressed: () async {
                      windowManager.setTitleBarStyle(
                        TitleBarStyle.hidden,
                        windowButtonVisibility: false,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
              onTap: () {},
            ),
            PreferenceListItem(
              title: Text('getTitleBarHeight'),
              onTap: () async {
                int titleBarHeight = await windowManager.getTitleBarHeight();
                BotToast.showText(
                  text: 'titleBarHeight: $titleBarHeight',
                );
              },
            ),
            PreferenceListItem(
              title: Text('isSkipTaskbar'),
              onTap: () async {
                bool isSkipping = await windowManager.isSkipTaskbar();
                BotToast.showText(
                  text: 'isSkipTaskbar: $isSkipping',
                );
              },
            ),
            PreferenceListItem(
              title: Text('setSkipTaskbar'),
              onTap: () async {
                setState(() {
                  _isSkipTaskbar = !_isSkipTaskbar;
                });
                await windowManager.setSkipTaskbar(_isSkipTaskbar);
                await Future.delayed(Duration(seconds: 3));
                windowManager.show();
              },
            ),
            PreferenceListItem(
              title: Text('setProgressBar'),
              onTap: () async {
                for (var i = 0; i <= 100; i++) {
                  setState(() {
                    _progress = i / 100;
                  });
                  print(_progress);
                  await windowManager.setProgressBar(_progress);
                  await Future.delayed(Duration(milliseconds: 100));
                }
                await Future.delayed(Duration(milliseconds: 1000));
                await windowManager.setProgressBar(-1);
              },
            ),
            PreferenceListItem(
              title: Text('setIcon'),
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('Default'),
                    onPressed: () => _handleSetIcon(_kIconTypeDefault),
                  ),
                  CupertinoButton(
                    child: Text('Original'),
                    onPressed: () => _handleSetIcon(_kIconTypeOriginal),
                  ),
                ],
              ),
              onTap: () => _handleSetIcon(_kIconTypeDefault),
            ),
            PreferenceListSwitchItem(
              title: Text('hasShadow / setHasShadow'),
              onTap: () async {
                bool hasShadow = await windowManager.hasShadow();
                BotToast.showText(
                  text: 'hasShadow: $hasShadow',
                );
              },
              value: _hasShadow,
              onChanged: (newValue) {
                _hasShadow = newValue;
                windowManager.setHasShadow(_hasShadow);
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('getOpacity / setOpacity'),
              onTap: () async {
                double opacity = await windowManager.getOpacity();
                BotToast.showText(
                  text: 'opacity: $opacity',
                );
              },
              accessoryView: Row(
                children: [
                  CupertinoButton(
                    child: Text('1'),
                    onPressed: () async {
                      _opacity = 1;
                      windowManager.setOpacity(_opacity);
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('0.8'),
                    onPressed: () async {
                      _opacity = 0.8;
                      windowManager.setOpacity(_opacity);
                      setState(() {});
                    },
                  ),
                  CupertinoButton(
                    child: Text('0.6'),
                    onPressed: () async {
                      _opacity = 0.5;
                      windowManager.setOpacity(_opacity);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            PreferenceListSwitchItem(
              title: Text('setIgnoreMouseEvents'),
              value: _isIgnoreMouseEvents,
              onChanged: (newValue) async {
                _isIgnoreMouseEvents = newValue;
                await windowManager.setIgnoreMouseEvents(
                  _isIgnoreMouseEvents,
                  forward: false,
                );
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: Text('popUpWindowMenu'),
              onTap: () async {
                await windowManager.popUpWindowMenu();
              },
            ),
            PreferenceListItem(
              title: Text('createSubWindow'),
              onTap: () async {
                SubWindow subWindow = await SubWindow.create(
                  size: Size(800, 600),
                  center: true,
                  title: 'title',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            // border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
            // boxShadow: <BoxShadow>[
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2),
            //     offset: Offset(1.0, 1.0),
            //     blurRadius: 6.0,
            //   ),
            // ],
          ),
          child: Scaffold(
            appBar: PreferredSize(
              child: WindowCaption(
                brightness: Theme.of(context).brightness,
                title: Text('window_manager_example'),
              ),
              preferredSize: const Size.fromHeight(kWindowCaptionHeight),
            ),
            body: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    windowManager.startDragging();
                  },
                  onDoubleTap: () async {
                    bool isMaximized = await windowManager.isMaximized();
                    if (!isMaximized) {
                      windowManager.maximize();
                    } else {
                      windowManager.unmaximize();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(0),
                    width: double.infinity,
                    height: 54,
                    color: Colors.grey.withOpacity(0.3),
                    child: Center(
                      child: Text('DragToMoveArea'),
                    ),
                  ),
                ),
                if (Platform.isLinux || Platform.isWindows)
                  Container(
                    height: 100,
                    margin: EdgeInsets.all(20),
                    child: DragToResizeArea(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.withOpacity(0.3),
                        child: Center(
                          child: GestureDetector(
                            child: Text('DragToResizeArea'),
                            onTap: () {
                              BotToast.showText(
                                  text: 'DragToResizeArea example');
                            },
                          ),
                        ),
                      ),
                      resizeEdgeSize: 6,
                      resizeEdgeColor: Colors.red.withOpacity(0.2),
                    ),
                  ),
                Expanded(
                  child: _buildBody(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (_isIgnoreMouseEvents) {
          windowManager.setOpacity(1.0);
        }
      },
      onExit: (_) {
        if (_isIgnoreMouseEvents) {
          windowManager.setOpacity(0.5);
        }
      },
      child: _build(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.focus();
        break;
      case 'set_ignore_mouse_events':
        _isIgnoreMouseEvents = false;
        await windowManager.setIgnoreMouseEvents(_isIgnoreMouseEvents);
        setState(() {});
        break;
    }
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  @override
  void onWindowClose() {
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
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }
}
