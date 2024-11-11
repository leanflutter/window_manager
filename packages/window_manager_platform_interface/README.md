# window_manager_platform_interface

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/window_manager_platform_interface.svg
[pub-url]: https://pub.dev/packages/window_manager_platform_interface

A common platform interface for the [window_manager](https://pub.dev/packages/window_manager) plugin.

## Usage

To implement a new platform-specific implementation of window_manager, extend `WindowManagerPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `WindowManagerPlatform` by calling `WindowManagerPlatform.instance = MyPlatformWindowManager()`.

## License

[MIT](./LICENSE)
