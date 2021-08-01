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

class _HomePageState extends State<HomePage> {
  Size _size = _kSizes.first;
  Size? _minSize;
  Size? _maxSize;
  bool _isUseAnimator = false;
  bool _isAlwaysOnTop = false;

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('setTitle'),
              accessoryView: Container(
                width: 160,
                height: 40,
                child: CupertinoTextField(
                  onChanged: (newValue) async {
                    await WindowManager.instance.setTitle('$newValue');
                  },
                ),
              ),
              onTap: () async {
                await WindowManager.instance.setTitle('window manager example');
              },
            ),
            PreferenceListItem(
              title: Text('getSize / setSize'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  for (var size in _kSizes)
                    Text(' ${size.width.toInt()}x${size.height.toInt()} '),
                ],
                onPressed: (int index) {
                  _size = _kSizes[index];
                  WindowManager.instance.setSize(_size);
                  setState(() {});
                },
                isSelected: _kSizes.map((e) => e == _size).toList(),
              ),
              onTap: () async {
                Size size = await WindowManager.instance.getSize();
                BotToast.showText(
                  text: 'size: ${size.width.toInt()}x${size.height.toInt()}',
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
              title: Text('activate'),
              onTap: () async {
                await WindowManager.instance.activate();
              },
            ),
            PreferenceListItem(
              title: Text('deactivate'),
              onTap: () async {
                await WindowManager.instance.deactivate();
              },
            ),
            PreferenceListItem(
              title: Text('miniaturize'),
              onTap: () async {
                await WindowManager.instance.miniaturize();
              },
            ),
            PreferenceListItem(
              title: Text('deminiaturize'),
              onTap: () async {
                await WindowManager.instance.deminiaturize();
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('Option'),
          children: [
            PreferenceListItem(
              title: Text('isUseAnimator / setUseAnimator'),
              accessoryView: ToggleButtons(
                children: <Widget>[
                  Text('YES'),
                  Text('NO'),
                ],
                onPressed: (int index) {
                  _isUseAnimator = !_isUseAnimator;
                  WindowManager.instance.setUseAnimator(_isUseAnimator);
                  setState(() {});
                },
                isSelected: [_isUseAnimator, !_isUseAnimator],
              ),
              onTap: () async {
                bool isUseAnimator =
                    await WindowManager.instance.isUseAnimator();
                BotToast.showText(text: 'isUseAnimator: $isUseAnimator');
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
}
