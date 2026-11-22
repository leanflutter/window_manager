// Event delivery of package:window_manager/legacy.dart. With prevent-close on
// and no native window, close() reports onWindowClose, which drives delivery
// without a window.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/legacy.dart';

class _OnClose with WindowListener {
  _OnClose(this.action);

  final void Function() action;
  int closes = 0;

  @override
  void onWindowEvent(String eventName) {
    if (eventName == kWindowEventClose) action();
  }

  @override
  void onWindowClose() => closes++;
}

void main() {
  setUp(() => windowManager.setPreventClose(true));
  tearDown(() => windowManager.setPreventClose(false));

  test('the named callback follows onWindowEvent once per event', () async {
    final events = <String>[];
    final listener = _OnClose(() => events.add('event'));
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));

    await windowManager.close();
    await windowManager.close();
    expect(events, ['event', 'event']);
    expect(listener.closes, 2);
  });

  test(
    'removing a listener during delivery does not starve later listeners',
    () async {
      final events = <String>[];
      late final _OnClose removed;
      final first = _OnClose(() => windowManager.removeListener(removed));
      removed = _OnClose(() => events.add('removed'));
      final last = _OnClose(() => events.add('last'));
      windowManager.addListener(first);
      windowManager.addListener(removed);
      windowManager.addListener(last);
      addTearDown(() {
        windowManager.removeListener(first);
        windowManager.removeListener(removed);
        windowManager.removeListener(last);
      });

      await windowManager.close();
      expect(events, ['last']);
      expect(removed.closes, 0);
    },
  );

  test('a listener added during delivery joins the next event only', () async {
    final received = <String>[];
    late final _OnClose newlyAdded;
    var added = false;
    final first = _OnClose(() {
      if (!added) {
        added = true;
        windowManager.addListener(newlyAdded);
      }
    });
    newlyAdded = _OnClose(() => received.add('new'));
    final tail = _OnClose(() => received.add('tail'));
    windowManager.addListener(first);
    windowManager.addListener(tail);
    addTearDown(() {
      windowManager.removeListener(first);
      windowManager.removeListener(tail);
      windowManager.removeListener(newlyAdded);
    });

    await windowManager.close();
    expect(received, ['tail']);
    await windowManager.close();
    expect(received, ['tail', 'tail', 'new']);
  });

  test('listeners returns a copy', () {
    final listener = _OnClose(() {});
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));

    windowManager.listeners.clear();
    expect(windowManager.listeners, [listener]);
    expect(windowManager.hasListeners, isTrue);
  });
}
