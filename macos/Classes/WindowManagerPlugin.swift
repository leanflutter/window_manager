import Cocoa
import FlutterMacOS

public class WindowManagerPlugin: NSObject, FlutterPlugin, NSWindowDelegate {
    var channel: FlutterMethodChannel!
    
    var mainWindow: NSWindow {
        get {
            return NSApp.windows.first(where: { window in
                return String(describing: type(of: window)) == "MainFlutterWindow"
            })!;
        }
    }
    
    public override init() {
        super.init()
        mainWindow.delegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "focus":
            focus(call, result: result)
            break
        case "blur":
            blur(call, result: result)
            break
        case "show":
            show(call, result: result)
            break
        case "hide":
            hide(call, result: result)
            break
        case "isVisible":
            isVisible(call, result: result)
            break
        case "maximize":
            maximize(call, result: result)
            break
        case "unmaximize":
            unmaximize(call, result: result)
            break
        case "minimize":
            minimize(call, result: result)
            break
        case "restore":
            restore(call, result: result)
            break
        case "isFullScreen":
            isFullScreen(call, result: result)
            break
        case "setFullScreen":
            setFullScreen(call, result: result)
            break
        case "getBounds":
            getBounds(call, result: result)
            break
        case "setBounds":
            setBounds(call, result: result)
            break
        case "setMinimumSize":
            setMinimumSize(call, result: result)
            break
        case "setMaximumSize":
            setMaximumSize(call, result: result)
            break
        case "isAlwaysOnTop":
            isAlwaysOnTop(call, result: result)
            break
        case "setAlwaysOnTop":
            setAlwaysOnTop(call, result: result)
            break
        case "terminate":
            terminate(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func show(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func focus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func blur(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSApp.deactivate()
    }
    
    public func hide(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.orderOut(self.mainWindow)
        result(true)
    }
    
    public func isVisible(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(self.mainWindow.isVisible)
    }
    
    public func maximize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
    }
    
    public func unmaximize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
    }
    
    public func minimize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.miniaturize(nil)
    }
    
    public func restore(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.mainWindow.deminiaturize(nil)
    }
    
    
    public func isFullScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultData: NSDictionary = [
            "isFullScreen": mainWindow.styleMask.contains(.fullScreen),
        ]
        result(resultData)
    }
    
    public func setFullScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let isFullScreen: Bool = args["isFullScreen"] as! Bool
        
        if (isFullScreen) {
            if (!mainWindow.styleMask.contains(.fullScreen)) {
                mainWindow.toggleFullScreen(nil)
            }
        } else {
            if (mainWindow.styleMask.contains(.fullScreen)) {
                mainWindow.toggleFullScreen(nil)
            }
        }
    }
    
    public func getBounds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let origin: CGPoint = mainWindow.frame.origin;
        let size: CGSize = mainWindow.frame.size;
        
        let resultData: NSDictionary = [
            "x": origin.x,
            "y": origin.y,
            "width": size.width,
            "height": size.height,
        ]
        result(resultData)
    }
    
    public func setBounds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        var newOrigin: NSPoint?
        var newSize: NSSize?
        let animate = args["animate"] as! Bool
        
        if (args["x"] != nil && args["y"] != nil) {
            newOrigin =  NSPoint(
                x: CGFloat(args["x"] as! Float),
                y: CGFloat(args["y"] as! Float)
            )
        }
        if (args["width"] != nil && args["height"] != nil) {
            newSize = NSSize(
                width: CGFloat(truncating: args["width"] as! NSNumber),
                height: CGFloat(truncating: args["height"] as! NSNumber)
            )
        }
        
        var frameRect = mainWindow.frame
        if (newSize != nil) {
            frameRect.size = newSize!
        }
        if (newOrigin != nil) {
            frameRect.origin = newOrigin!
        }
        
        if (animate) {
            mainWindow.animator().setFrame(frameRect, display: true, animate: true)
        } else {
            mainWindow.setFrame(frameRect, display: true)
        }
        result(true)
    }
    
    public func setMinimumSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let minSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        mainWindow.minSize = minSize
    }
    
    public func setMaximumSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let maxSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        mainWindow.maxSize = maxSize
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
        
        mainWindow.level = isAlwaysOnTop ? .floating : .normal
    }
    
    public func terminate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSApplication.shared.terminate(nil)
        result(true)
    }
    
    // NSWindowDelegate
    
    public func windowDidBecomeMain(_ notification: Notification) {
        _emitEvent("focus");
    }
    
    public func windowDidResignMain(_ notification: Notification){
        _emitEvent("blur");
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
