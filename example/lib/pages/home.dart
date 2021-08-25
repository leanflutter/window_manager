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

final windowManager = WindowManager.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  Size _size = _kSizes.first;
  Size? _minSize;
  Size? _maxSize;
  bool _isFullScreen = false;
  bool _isAlwaysOnTop = false;

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

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
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
              accessoryView: CupertinoButton(
                child: Text('Set'),
                onPressed: () async {
                  Offset position = await windowManager.getPosition();
                  windowManager.setPosition(
                    Offset(position.dx + 100, position.dy + 100),
                  );
                  setState(() {});
                },
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
                Offset position = await windowManager.getPosition();
                BotToast.showText(
                  text: '${position.toString()}',
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
            PreferenceListItem(
              title: Text('terminate'),
              onTap: () async {
                await windowManager.terminate();
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('Option'),
          children: [
            PreferenceListItem(
              title: Text('isFullScreen / setFullScreen'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  Text('YES'),
                  Text('NO'),
                ],
                onPressed: (int index) {
                  _isFullScreen = !_isFullScreen;
                  windowManager.setFullScreen(_isFullScreen);
                  setState(() {});
                },
                isSelected: [_isFullScreen, !_isFullScreen],
              ),
              onTap: () async {
                bool isFullScreen = await windowManager.isFullScreen();
                BotToast.showText(text: 'isFullScreen: $isFullScreen');
              },
            ),
            PreferenceListItem(
              title: Text('isAlwaysOnTop / setAlwaysOnTop'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  Text('YES'),
                  Text('NO'),
                ],
                onPressed: (int index) {
                  _isAlwaysOnTop = !_isAlwaysOnTop;
                  windowManager.setAlwaysOnTop(_isAlwaysOnTop);
                  setState(() {});
                },
                isSelected: [_isAlwaysOnTop, !_isAlwaysOnTop],
              ),
              onTap: () async {
                bool isAlwaysOnTop = await windowManager.isAlwaysOnTop();
                BotToast.showText(text: 'isAlwaysOnTop: $isAlwaysOnTop');
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }
}
