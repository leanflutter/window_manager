import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import './pages/home.dart';
import 'themes/themes.dart';
import 'utilities/utilities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  runApp(const MyApp());

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  Window.setEffect(effect: WindowEffect.mica);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useNativeBackground = true;

  @override
  void initState() {
    sharedConfigManager.addListener(_configListen);
    super.initState();

    var window = WidgetsBinding.instance.platformDispatcher;
    window.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      windowManager.setBrightness(window.platformBrightness);
    };
  }

  @override
  void dispose() {
    sharedConfigManager.removeListener(_configListen);
    super.dispose();
  }

  void _configListen() {
    _themeMode = sharedConfig.themeMode;
    _useNativeBackground = sharedConfig.useNativeBackground;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    final botToastBuilder = BotToastInit();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightThemeData.copyWith(
        scaffoldBackgroundColor:
            _useNativeBackground ? Colors.transparent : null,
        canvasColor: _useNativeBackground ? Colors.white54 : null,
        cardColor: null,
      ),
      darkTheme: darkThemeData.copyWith(
        scaffoldBackgroundColor:
            _useNativeBackground ? Colors.transparent : null,
        canvasColor: _useNativeBackground ? Colors.black26 : null,
      ),
      themeMode: _themeMode,
      builder: (context, child) {
        child = virtualWindowFrameBuilder(context, child);
        child = botToastBuilder(context, child);
        return child;
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const HomePage(),
    );
  }
}
