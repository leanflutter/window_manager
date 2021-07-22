import Cocoa
import FlutterMacOS

public class ArgumentReader {
    var arguments:[String: Any]
    
    init(_ arguments:Any?) {
        self.arguments = (arguments as! [String: Any]);
    }
    
    public func getInt(_ key: String)-> Int {
        let intValue: Int = arguments[key] as! Int
        return intValue
    }
    
    public func getFloat(_ key: String)-> Float {
        let floatValue: Float = arguments[key] as! Float
        return floatValue
    }
    
    public func getDouble(_ key: String)-> Double {
        let doubleValue: Double = arguments[key] as! Double
        return doubleValue
    }
    
    public func getBool(_ key: String)-> Bool {
        let boolValue: Bool = arguments[key] as! Bool
        return boolValue
    }
    
    public func getString(_ key: String)-> String {
        let stringValue: String = arguments[key] as! String
        return stringValue
    }
}

public class WindowManagerPlugin: NSObject, FlutterPlugin {
    
    var mainWindow: NSWindow {
        get { return NSApplication.shared.mainWindow!; }
    }
    
    private var _useAnimator: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (NSApplication.shared.mainWindow == nil) {
            result("mainWindow not found")  // should return error or throw exception here.
            return
        }
        
        switch (call.method) {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func setTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ar: ArgumentReader = _argumentReader(call.arguments);
        mainWindow.title = ar.getString("title")
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
        let ar: ArgumentReader = _argumentReader(call.arguments);
        let newSize: NSSize = NSSize(
            width: CGFloat(ar.getFloat("width")),
            height: CGFloat(ar.getFloat("height"))
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
        let ar: ArgumentReader = _argumentReader(call.arguments);
        let minSize: NSSize = NSSize(
            width: CGFloat(ar.getFloat("width")),
            height: CGFloat(ar.getFloat("height"))
        )
        
        if (_useAnimator) {
            mainWindow.animator().minSize = minSize
        } else {
            mainWindow.minSize = minSize
        }
        result(true)
    }
    
    public func setMaxSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ar: ArgumentReader = _argumentReader(call.arguments);
        let maxSize: NSSize = NSSize(
            width: CGFloat(ar.getFloat("width")),
            height: CGFloat(ar.getFloat("height"))
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
        let ar: ArgumentReader = _argumentReader(call.arguments);
        
        _useAnimator = ar.getBool("isUseAnimator")
        result(true)
    }
    
    public func isAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultData: NSDictionary = [
            "isAlwaysOnTop": mainWindow.level == .floating,
        ]
        result(resultData)
    }
    
    public func setAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let ar: ArgumentReader = _argumentReader(call.arguments);
        let isAlwaysOnTop: Bool = ar.getBool("isAlwaysOnTop")
        
        if (_useAnimator) {
            mainWindow.animator().level = isAlwaysOnTop ? .floating : .normal
        } else {
            mainWindow.level = isAlwaysOnTop ? .floating : .normal
        }
        result(true)
    }
    
    public func _argumentReader(_ arguments: Any?) -> ArgumentReader {
        return ArgumentReader(arguments)
    }
}
