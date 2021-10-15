import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:window_manager/window_manager.dart';

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

class _HomePageState extends State<HomePage> with WindowListener {
  Size _size = _kSizes.first;
  Size? _minSize;
  Size? _maxSize;
  bool _isFullScreen = false;
  bool _isResizable = true;
  bool _isMovable = true;
  bool _isMinimizable = true;
  bool _isClosable = true;
  bool _isAlwaysOnTop = false;
  bool _isSkipTaskbar = false;
  bool _hasShadow = true;

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

  void _init() {}

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: Text('METHODS'),
          children: [
            PreferenceListItem(
              title: Text('focus / blur'),
              onTap: () async {
                windowManager.blur();
                await Future.delayed(Duration(seconds: 2));
                windowManager.focus();
              },
            ),
            PreferenceListItem(
              title: Text('show / hide'),
              onTap: () async {
                windowManager.hide();
                await Future.delayed(Duration(seconds: 2));
                windowManager.show();
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
              title: Text('center'),
              onTap: () {
                windowManager.center();
              },
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
                  Rect bounds = await windowManager.getBounds();
                  windowManager.setBounds(
                    Rect.fromLTWH(
                      bounds.left,
                      bounds.top,
                      _size.width,
                      _size.height,
                    ),
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
                bool isMinimizable = await windowManager.isClosable();
                BotToast.showText(text: 'isMinimizable: $isMinimizable');
              },
              value: _isMinimizable,
              onChanged: (newValue) {
                _isMinimizable = newValue;
                windowManager.setMinimizable(_isMinimizable);
                setState(() {});
              },
            ),
            PreferenceListSwitchItem(
              title: Text('isClosable / setClosable'),
              onTap: () async {
                bool isClosable = await windowManager.isClosable();
                BotToast.showText(text: 'isClosable: $isClosable');
              },
              value: _isClosable,
              onChanged: (newValue) {
                _isClosable = newValue;
                windowManager.setClosable(_isClosable);
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
              title: Text('terminate'),
              onTap: () async {
                await windowManager.terminate();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(1.0, 1.0),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text("window_manager_example"),
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
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }
}
