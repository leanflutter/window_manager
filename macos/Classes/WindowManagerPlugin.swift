import Cocoa
import FlutterMacOS

public class WindowManagerPlugin: NSObject, FlutterPlugin {
    
    var mainWindow: NSWindow {
        get {
            return NSApp.windows.first(where: { window in
                return String(describing: type(of: window)) == "MainFlutterWindow"
            })!;
        }
    }
    
    private var _useAnimator: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "setTitle":
            setTitle(call, result: result)
            break
        case "getSize":
            getSize(call, result: result)
            break
        case "setSize":
            setSize(call, result: result)
            break
        case "setMinSize":
            setMinSize(call, result: result)
            break
        case "setMaxSize":
            setMaxSize(call, result: result)
            break
        case "isUseAnimator":
            isUseAnimator(call, result: result)
            break
        case "setUseAnimator":
            setUseAnimator(call, result: result)
            break
        case "isAlwaysOnTop":
            isAlwaysOnTop(call, result: result)
            break
        case "setAlwaysOnTop":
            setAlwaysOnTop(call, result: result)
            break
        case "activate":
            activate(call, result: result)
            break
        case "deactivate":
            deactivate(call, result: result)
            break
        case "miniaturize":
            miniaturize(call, result: result)
            break
        case "deminiaturize":
            deminiaturize(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func setTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        mainWindow.title = args["title"] as! String
        result(true)
    }
    
    public func getSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let size: CGSize = mainWindow.frame.size;
        let resultData: NSDictionary = [
            "width": size.width,
            "height": size.height,
        ]
        result(resultData)
    }
    
    public func setSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let newSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        var frameRect = mainWindow.frame
        frameRect.origin.y += (frameRect.size.height - CGFloat(newSize.height))
        frameRect.size = newSize
        
        if (_useAnimator) {
            mainWindow.animator().setFrame(frameRect, display: true, animate: true)
        } else {
            mainWindow.setFrame(frameRect, display: true)
        }
        result(true)
    }
    
    public func setMinSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let minSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        if (_useAnimator) {
            mainWindow.animator().minSize = minSize
        } else {
            mainWindow.minSize = minSize
        }
        result(true)
    }
    
    public func setMaxSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let maxSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        if (_useAnimator) {
            mainWindow.animator().maxSize = maxSize
        } else {
            mainWindow.maxSize = maxSize
        }
        result(true)
    }
    
    public func isUseAnimator(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultData: NSDictionary = [
            "isUseAnimator": _useAnimator,
        ]
        result(resultData)
    }
    
    public func setUseAnimator(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        _useAnimator = args["isUseAnimator"] as! Bool
        result(true)
    }
    
    public func isAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultData: NSDictionary = [
            "isAlwaysOnTop": mainWindow.level == .floating,
        ]
        result(resultData)
    }
    
    public func setAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let isAlwaysOnTop: Bool = args["isAlwaysOnTop"] as! Bool
        
        if (_useAnimator) {
            mainWindow.animator().level = isAlwaysOnTop ? .floating : .normal
        } else {
            mainWindow.level = isAlwaysOnTop ? .floating : .normal
        }
        result(true)
    }
    
    public func activate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        result(true)
    }
    
    public func deactivate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSApp.deactivate()
        result(true)
    }
    
    public func miniaturize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.miniaturize(nil)
        result(true)
    }
    
    public func deminiaturize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.deminiaturize(nil)
        result(true)
    }
}
