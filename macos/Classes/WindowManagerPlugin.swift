import Cocoa
import FlutterMacOS

public class WindowManagerPlugin: NSObject, FlutterPlugin, NSWindowDelegate {
    var registrar: FlutterPluginRegistrar!;
    var channel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window_manager", binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        instance.registrar = registrar
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (getMainWindow().delegate == nil) {
            getMainWindow().delegate = self;
        }
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
        case "isMaximized":
            isMaximized(call, result: result)
            break
        case "maximize":
            maximize(call, result: result)
            break
        case "unmaximize":
            unmaximize(call, result: result)
            break
        case "isMinimized":
            isMinimized(call, result: result)
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
        case "getTitle":
            getTitle(call, result: result)
            break
        case "setTitle":
            setTitle(call, result: result)
            break
        case "hasShadow":
            hasShadow(call, result: result)
            break
        case "setHasShadow":
            setHasShadow(call, result: result)
            break
        case "terminate":
            terminate(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func getFlutterView() -> NSView {
        return (registrar.view)!
    }
    
    public func getMainWindow() -> NSWindow {
        return (registrar.view?.window)!
    }
    
    public func focus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getMainWindow().makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func blur(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSApp.deactivate()
    }
    
    public func show(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getMainWindow().makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func hide(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getMainWindow().orderOut(getMainWindow())
        result(true)
    }
    
    public func isVisible(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().isVisible)
    }
    
    public func isMaximized(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().isZoomed)
    }
    
    public func maximize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (!getMainWindow().isZoomed) {
            getMainWindow().zoom(nil);
        }
    }

    public func unmaximize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (getMainWindow().isZoomed) {
            getMainWindow().zoom(nil);
        }
    }
    
    public func isMinimized(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().isMiniaturized)
    }
    
    public func minimize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getMainWindow().miniaturize(nil)
    }
    
    public func restore(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getMainWindow().deminiaturize(nil)
    }
    
    public func isFullScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().styleMask.contains(.fullScreen))
    }
    
    public func setFullScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let isFullScreen: Bool = args["isFullScreen"] as! Bool
        
        if (isFullScreen) {
            if (!getMainWindow().styleMask.contains(.fullScreen)) {
                getMainWindow().toggleFullScreen(nil)
            }
        } else {
            if (getMainWindow().styleMask.contains(.fullScreen)) {
                getMainWindow().toggleFullScreen(nil)
            }
        }
    }
    
    public func getBounds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let origin: CGPoint = getMainWindow().frame.origin;
        let size: CGSize = getMainWindow().frame.size;
        
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
        
        var frameRect = getMainWindow().frame
        if (newSize != nil) {
            frameRect.size = newSize!
        }
        if (newOrigin != nil) {
            frameRect.origin = newOrigin!
        }
        
        if (animate) {
            getMainWindow().animator().setFrame(frameRect, display: true, animate: true)
        } else {
            getMainWindow().setFrame(frameRect, display: true)
        }
        result(true)
    }
    
    public func setMinimumSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let minSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        getMainWindow().minSize = minSize
    }
    
    public func setMaximumSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let maxSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        
        getMainWindow().maxSize = maxSize
    }
    
    public func isAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let resultData: NSDictionary = [
            "isAlwaysOnTop": getMainWindow().level == .floating,
        ]
        result(resultData)
    }
    
    public func setAlwaysOnTop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let isAlwaysOnTop: Bool = args["isAlwaysOnTop"] as! Bool
        
        getMainWindow().level = isAlwaysOnTop ? .floating : .normal
    }
    
    public func getTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().title)
    }
    
    public func setTitle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let title: String = args["title"] as! String
        
        getMainWindow().title = title;
    }

    public func hasShadow(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args:[String: Any] = call.arguments as! [String: Any]
        let hasShadow: Bool = args["hasShadow"] as! Bool
        getMainWindow().hasShadow = hasShadow;
        getMainWindow().invalidateShadow();
    }

    public func setHasShadow(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(getMainWindow().hasShadow)
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
