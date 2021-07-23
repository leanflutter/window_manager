import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _ListSection extends StatelessWidget {
  final Widget? title;

  const _ListSection({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                child: title!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ListItem({
    Key? key,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minHeight: 48),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  child: title!,
                ),
                Expanded(child: Container()),
                if (trailing != null) SizedBox(height: 34, child: trailing),
              ],
            ),
            if (subtitle != null) Container(child: subtitle),
          ],
        ),
      ),
      onTap: this.onTap,
    );
  }
}

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
    return Column(
      children: <Widget>[
        _ListItem(
          title: Text('setTitle'),
          trailing: Container(
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
        _ListItem(
          title: Text('getSize / setSize'),
          trailing: ToggleButtons(
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
        _ListItem(
          title: Text('getMinSize / setMinSize'),
          trailing: ToggleButtons(
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
        _ListItem(
          title: Text('getMaxSize / setMaxSize'),
          trailing: ToggleButtons(
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
        _ListItem(
          title: Text('activate'),
          onTap: () async {
            await WindowManager.instance.activate();
          },
        ),
        _ListItem(
          title: Text('deactivate'),
          onTap: () async {
            await WindowManager.instance.deactivate();
          },
        ),
        _ListSection(
          title: Text('Option'),
        ),
        _ListItem(
          title: Text('isUseAnimator / setUseAnimator'),
          trailing: ToggleButtons(
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
            bool isUseAnimator = await WindowManager.instance.isUseAnimator();
            BotToast.showText(text: 'isUseAnimator: $isUseAnimator');
          },
        ),
        _ListItem(
          title: Text('isAlwaysOnTop / setAlwaysOnTop'),
          trailing: ToggleButtons(
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
            bool isAlwaysOnTop = await WindowManager.instance.isAlwaysOnTop();
            BotToast.showText(text: 'isAlwaysOnTop: $isAlwaysOnTop');
          },
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
