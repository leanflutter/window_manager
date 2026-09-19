# window_manager_example

`window_manager` through its 0.5.x compatible API
(`package:window_manager/legacy.dart`): one window driven by the classic
`windowManager` calls and a `WindowListener`.

That API is deprecated and will be removed in a later release; it is shown here for apps
that are still on their way to the native API.

- `lib/window_controller.dart` — every `windowManager` call and the listener
- `lib/main.dart`, `lib/widgets/` — the window: one row of choices per group of calls,
  the geometry read back from the system, and a log of the listener callbacks. Built on
  `package:flutter/widgets.dart` alone.

```sh
flutter run -d macos
flutter run -d linux
flutter run -d windows
```

## Looking for the full example?

This one is deliberately small. Several windows at once, parent and child windows and
every native property with read-back are in nativeapi's
[window_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/window_example).
