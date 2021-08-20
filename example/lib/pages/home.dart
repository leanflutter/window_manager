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
  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    WindowManager.instance.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('focus'),
              onTap: () {
                WindowManager.instance.focus();
              },
            ),
            PreferenceListItem(
              title: Text('blur'),
              onTap: () {
                WindowManager.instance.blur();
              },
            ),
            PreferenceListItem(
              title: Text('show'),
              onTap: () {
                WindowManager.instance.show();
              },
            ),
            PreferenceListItem(
              title: Text('hide'),
              onTap: () async {
                WindowManager.instance.hide();
              },
            ),
            PreferenceListItem(
              title: Text('minimize'),
              onTap: () {
                WindowManager.instance.minimize();
              },
            ),
            PreferenceListItem(
              title: Text('restore'),
              onTap: () {
                WindowManager.instance.restore();
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
                  Rect bounds = await WindowManager.instance.getBounds();
                  WindowManager.instance.setBounds(
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
                Rect bounds = await WindowManager.instance.getBounds();
                Size size = bounds.size;
                Offset origin = bounds.topLeft;
                BotToast.showText(
                  text: '${size.toString()}\n${origin.toString()}',
                );
              },
            ),
            PreferenceListItem(
              title: Text('getMinSize / setMinSize'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kMinSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) {
                  _minSize = _kMinSizes[index];
                  WindowManager.instance.setMinSize(_minSize!);
                  setState(() {});
                },
                isSelected: _kMinSizes.map((e) => e == _minSize).toList(),
              ),
            ),
            PreferenceListItem(
              title: Text('getMaxSize / setMaxSize'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kMaxSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) {
                  _maxSize = _kMaxSizes[index];
                  WindowManager.instance.setMaxSize(_maxSize!);
                  setState(() {});
                },
                isSelected: _kMaxSizes.map((e) => e == _maxSize).toList(),
              ),
            ),
            PreferenceListItem(
              title: Text('terminate'),
              onTap: () async {
                await WindowManager.instance.terminate();
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('Option'),
          children: [
            PreferenceListItem(
              title: Text('isAlwaysOnTop / setAlwaysOnTop'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  Text('YES'),
                  Text('NO'),
                ],
                onPressed: (int index) {
                  _isAlwaysOnTop = !_isAlwaysOnTop;
                  WindowManager.instance.setAlwaysOnTop(_isAlwaysOnTop);
                  setState(() {});
                },
                isSelected: [_isAlwaysOnTop, !_isAlwaysOnTop],
              ),
              onTap: () async {
                bool isAlwaysOnTop =
                    await WindowManager.instance.isAlwaysOnTop();
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
  void onWindowWillResize() {
    print('onWindowWillResize');
  }

  @override
  void onWindowDidResize() {
    print('onWindowDidResize');
  }

  @override
  void onWindowWillMiniaturize() {
    print('onWindowWillMiniaturize');
  }

  @override
  void onWindowDidMiniaturize() {
    print('onWindowDidMiniaturize');
  }

  @override
  void onWindowDidDeminiaturize() {
    print('onWindowDidDeminiaturize');
  }
}
