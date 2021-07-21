import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const kSizes = [
  Size(400, 500),
  Size(500, 600),
  Size(600, 700),
  Size(700, 800),
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
  Size _size = kSizes.first;
  Size _minSize = kSizes.first;
  Size _maxSize = kSizes.last;
  bool _isUseAnimator = false;
  bool _isAlwaysOnTop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  _ListItem(
                    title: Text('Size'),
                    trailing: ToggleButtons(
                      children: <Widget>[
                        for (var size in kSizes)
                          Text(
                              ' ${size.width.toInt()}x${size.height.toInt()} '),
                      ],
                      onPressed: (int index) {
                        _size = kSizes[index];
                        WindowManager.instance.setSize(_size);
                        setState(() {});
                      },
                      isSelected: kSizes.map((e) => e == _size).toList(),
                    ),
                    onTap: () async {
                      Size size = await WindowManager.instance.getSize();
                      print(size);
                    },
                  ),
                  _ListItem(
                    title: Text('MinSize'),
                    trailing: ToggleButtons(
                      children: <Widget>[
                        for (var size in kSizes)
                          Text(
                              ' ${size.width.toInt()}x${size.height.toInt()} '),
                      ],
                      onPressed: (int index) {
                        _minSize = kSizes[index];
                        WindowManager.instance.setSize(_minSize);
                        setState(() {});
                      },
                      isSelected: kSizes.map((e) => e == _minSize).toList(),
                    ),
                  ),
                  _ListItem(
                    title: Text('MaxSize'),
                    trailing: ToggleButtons(
                      children: <Widget>[
                        for (var size in kSizes)
                          Text(
                              ' ${size.width.toInt()}x${size.height.toInt()} '),
                      ],
                      onPressed: (int index) {
                        _maxSize = kSizes[index];
                        WindowManager.instance.setMaxSize(_maxSize);
                        setState(() {});
                      },
                      isSelected: kSizes.map((e) => e == _maxSize).toList(),
                    ),
                  ),
                  _ListSection(
                    title: Text('Option'),
                  ),
                  _ListItem(
                    title: Text('isUseAnimator'),
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
                      bool isUseAnimator =
                          await WindowManager.instance.isUseAnimator();
                      print('isUseAnimator: $isUseAnimator');
                    },
                  ),
                  _ListItem(
                    title: Text('isAlwaysOnTop'),
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
                      bool isAlwaysOnTop =
                          await WindowManager.instance.isAlwaysOnTop();
                      print('isAlwaysOnTop: $isAlwaysOnTop');
                    },
                  ),
                  Divider(height: 0, indent: 16, endIndent: 16),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
