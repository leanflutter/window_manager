import Cocoa
import FlutterMacOS

public class WindowManagerPlugin: NSObject, FlutterPlugin, NSWindowDelegate {
    private var registrar: FlutterPluginRegistrar!;
    private var channel: FlutterMethodChannel!
    
    private var _nativeWindow: NativeWindow?
    private var nativeWindow: NativeWindow {
        get {
            if (_nativeWindow == nil) {
                _nativeWindow = NativeWindow(registrar: self.registrar)
            }
            return _nativeWindow!;
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        instance.registrar = registrar
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (nativeWindow.mainWindow.delegate == nil) {
            nativeWindow.mainWindow.delegate = self;
        }
        
        let methodName: String = call.method
        let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
        
        switch (methodName) {
        case "setCustomFrame":
            nativeWindow.setCustomFrame(args)
            result(true)
            break
        case "focus":
            nativeWindow.focus()
            result(true)
            break
        case "blur":
            nativeWindow.blur()
            result(true)
            break
        case "show":
            nativeWindow.show()
            result(true)
            break
        case "hide":
            nativeWindow.hide()
            result(true)
            break
        case "isVisible":
            result(nativeWindow.isVisible())
            break
        case "isMaximized":
            result(nativeWindow.isMaximized())
            break
        case "maximize":
            nativeWindow.maximize()
            result(true)
            break
        case "unmaximize":
            nativeWindow.unmaximize()
            result(true)
            break
        case "isMinimized":
            result(nativeWindow.isMinimized())
            break
        case "minimize":
            nativeWindow.minimize()
            result(true)
            break
        case "restore":
            nativeWindow.restore()
            result(true)
            break
        case "isFullScreen":
            result(nativeWindow.isFullScreen())
            break
        case "setFullScreen":
            nativeWindow.setFullScreen(args)
            result(true)
            break
        case "getBounds":
            result(nativeWindow.getBounds())
            break
        case "setBounds":
            nativeWindow.setBounds(args)
            result(true)
            break
        case "setMinimumSize":
            nativeWindow.setMinimumSize(args)
            result(true)
            break
        case "setMaximumSize":
            nativeWindow.setMaximumSize(args)
            result(true)
            break
        case "isResizable":
            result(nativeWindow.isResizable())
            break
        case "setResizable":
            nativeWindow.setResizable(args)
            result(true)
            break
        case "isMovable":
            result(nativeWindow.isMovable())
            break
        case "setMovable":
            nativeWindow.setMovable(args)
            result(true)
            break
        case "isMinimizable":
            result(nativeWindow.isMinimizable())
            break
        case "setMinimizable":
            nativeWindow.setMinimizable(args)
            result(true)
            break
        case "isClosable":
            result(nativeWindow.isClosable())
            break
        case "setClosable":
            nativeWindow.setClosable(args)
            result(true)
            break
        case "isAlwaysOnTop":
            result(nativeWindow.isAlwaysOnTop())
            break
        case "setAlwaysOnTop":
            nativeWindow.setAlwaysOnTop(args)
            result(true)
            break
        case "getTitle":
            result(nativeWindow.getTitle())
            break
        case "setTitle":
            nativeWindow.setTitle(args)
            result(true)
            break
        case "hasShadow":
            result(nativeWindow.hasShadow())
            break
        case "setHasShadow":
            nativeWindow.setHasShadow(args)
            result(true)
            break
        case "startDragging":
            nativeWindow.startDragging()
            result(true)
            break
        case "terminate":
            nativeWindow.terminate()
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // NSWindowDelegate
    public func windowDidBecomeMain(_ notification: Notification) {
        _emitEvent("focus");
    }
    
    public func windowDidResignMain(_ notification: Notification){
        _emitEvent("blur");
    }
    
    public func windowDidMiniaturize(_ notification: Notification) {
        _emitEvent("minimize");
    }
    
    public func windowDidDeminiaturize(_ notification: Notification) {
        _emitEvent("restore");
    }
    
    public func windowDidEnterFullScreen(_ notification: Notification){
        _emitEvent("enter-full-screen");
    }
    
    public func windowDidExitFullScreen(_ notification: Notification){
        _emitEvent("leave-full-screen");
    }
    
    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        channel.invokeMethod("onEvent", arguments: args, result: nil)
    }
}
