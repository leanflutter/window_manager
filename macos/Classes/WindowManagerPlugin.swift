import Cocoa
import FlutterMacOS

public class WindowManagerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin(registrar, channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var registrar: FlutterPluginRegistrar!;
    private var channel: FlutterMethodChannel!
    
    private var mainWindow: NSWindow {
        get {
            return (self.registrar.view?.window)!;
        }
    }
    
    private var _inited: Bool = false
    private var windowManager: WindowManager = WindowManager()
    
    public init(_ registrar: FlutterPluginRegistrar, _ channel: FlutterMethodChannel) {
        super.init()
        self.registrar = registrar
        self.channel = channel
    }

    private func ensureInitialized() {
        if (!_inited) {
            windowManager.mainWindow = mainWindow
            windowManager.onEvent = {
                (eventName: String) in
                self._emitEvent(eventName)
            }
            _inited = true
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let methodName: String = call.method
        let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
        
        switch (methodName) {
        case "ensureInitialized":
            ensureInitialized()
            result(true)
            break
        case "waitUntilReadyToShow":
            windowManager.waitUntilReadyToShow()
            result(true)
            break
        case "setAsFrameless":
            windowManager.setAsFrameless()
            result(true)
            break
        case "focus":
            windowManager.focus()
            result(true)
            break
        case "blur":
            windowManager.blur()
            result(true)
            break
        case "show":
            windowManager.show()
            result(true)
            break
        case "hide":
            windowManager.hide()
            result(true)
            break
        case "isVisible":
            result(windowManager.isVisible())
            break
        case "isMaximized":
            result(windowManager.isMaximized())
            break
        case "maximize":
            windowManager.maximize()
            result(true)
            break
        case "unmaximize":
            windowManager.unmaximize()
            result(true)
            break
        case "isMinimized":
            result(windowManager.isMinimized())
            break
        case "minimize":
            windowManager.minimize()
            result(true)
            break
        case "restore":
            windowManager.restore()
            result(true)
            break
        case "isFullScreen":
            result(windowManager.isFullScreen())
            break
        case "setFullScreen":
            windowManager.setFullScreen(args)
            result(true)
            break
        case "setBackgroundColor":
            windowManager.setBackgroundColor(args)
            result(true)
            break
        case "center":
            windowManager.center()
            result(true)
            break
        case "getBounds":
            result(windowManager.getBounds())
            break
        case "setBounds":
            windowManager.setBounds(args)
            result(true)
            break
        case "setMinimumSize":
            windowManager.setMinimumSize(args)
            result(true)
            break
        case "setMaximumSize":
            windowManager.setMaximumSize(args)
            result(true)
            break
        case "isResizable":
            result(windowManager.isResizable())
            break
        case "setResizable":
            windowManager.setResizable(args)
            result(true)
            break
        case "isMovable":
            result(windowManager.isMovable())
            break
        case "setMovable":
            windowManager.setMovable(args)
            result(true)
            break
        case "isMinimizable":
            result(windowManager.isMinimizable())
            break
        case "setMinimizable":
            windowManager.setMinimizable(args)
            result(true)
            break
        case "isClosable":
            result(windowManager.isClosable())
            break
        case "setClosable":
            windowManager.setClosable(args)
            result(true)
            break
        case "isAlwaysOnTop":
            result(windowManager.isAlwaysOnTop())
            break
        case "setAlwaysOnTop":
            windowManager.setAlwaysOnTop(args)
            result(true)
            break
        case "getTitle":
            result(windowManager.getTitle())
            break
        case "setTitle":
            windowManager.setTitle(args)
            result(true)
            break
        case "setSkipTaskbar":
            windowManager.setSkipTaskbar(args)
            result(true)
            break
        case "hasShadow":
            result(windowManager.hasShadow())
            break
        case "setHasShadow":
            windowManager.setHasShadow(args)
            result(true)
            break
        case "startDragging":
            windowManager.startDragging()
            result(true)
            break
        case "terminate":
            windowManager.terminate()
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        channel.invokeMethod("onEvent", arguments: args, result: nil)
    }
}
