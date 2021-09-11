import Cocoa
import FlutterMacOS

extension NSRect {
    var topLeft: CGPoint {
        set {
            let screenFrameRect = NSScreen.main!.frame
            origin.x = newValue.x
            origin.y = screenFrameRect.height - newValue.y - size.height
        }
        get {
            let screenFrameRect = NSScreen.main!.frame
            return CGPoint(x: origin.x, y: screenFrameRect.height - origin.y - size.height)
        }
    }
}

public class NativeWindow: NSObject {
    var registrar: FlutterPluginRegistrar!;
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        self.registrar = registrar;
    }
    
    public var mainWindow: NSWindow {
        get {
            return (registrar.view?.window)!;
        }
    }
    
    public func setCustomFrame(_ args: [String: Any]) {
        let isFrameless: Bool = args["isFrameless"] as! Bool
        if (isFrameless) {
            mainWindow.styleMask.remove(.titled)
        }
    }
    
    public func focus() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func blur() {
        NSApp.deactivate()
    }
    
    public func show() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func hide() {
        mainWindow.orderOut(mainWindow)
    }
    
    public func isVisible() -> Bool {
        return mainWindow.isVisible
    }
    
    public func isMaximized() -> Bool {
        return mainWindow.isZoomed
    }
    
    public func maximize() {
        if (!isMaximized()) {
            mainWindow.zoom(nil);
        }
    }
    
    public func unmaximize() {
        if (isMaximized()) {
            mainWindow.zoom(nil);
        }
    }
    
    public func isMinimized() -> Bool {
        return mainWindow.isMiniaturized
    }
    
    public func minimize() {
        mainWindow.miniaturize(nil)
    }
    
    public func restore() {
        mainWindow.deminiaturize(nil)
    }
    
    public func isFullScreen() -> Bool {
        return mainWindow.styleMask.contains(.fullScreen)
    }
    
    public func setFullScreen(_ args: [String: Any]) {
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
    
    public func setBackgroundColor(_ args: [String: Any]) {
        let backgroundColorA = args["backgroundColorA"] as! Int
        let backgroundColorR = args["backgroundColorR"] as! Int
        let backgroundColorG = args["backgroundColorG"] as! Int
        let backgroundColorB = args["backgroundColorB"] as! Int
        
        let isTransparent: Bool = backgroundColorA == 0
            && backgroundColorR == 0
            && backgroundColorG == 0
            && backgroundColorB == 0;
        
        if (isTransparent) {
            mainWindow.backgroundColor = NSColor.clear
        } else {
            let rgbR = CGFloat(backgroundColorR) / 255
            let rgbG = CGFloat(backgroundColorG) / 255
            let rgbB = CGFloat(backgroundColorB) / 255
            let rgbA = CGFloat(backgroundColorA) / 255
            
            mainWindow.backgroundColor = NSColor(red: rgbR,
                                                 green: rgbG,
                                                 blue: rgbB,
                                                 alpha: rgbA)
        }
    }
    
    public func getBounds() -> NSDictionary {
        let frameRect: NSRect = mainWindow.frame;
        
        let data: NSDictionary = [
            "x": frameRect.topLeft.x,
            "y": frameRect.topLeft.y,
            "width": frameRect.size.width,
            "height": frameRect.size.height,
        ]
        return data;
    }
    
    public func setBounds(_ args: [String: Any]) {
        let animate = args["animate"] as! Bool
        
        var frameRect = mainWindow.frame
        if (args["width"] != nil) {
            frameRect.size.width = CGFloat(truncating: args["width"] as! NSNumber)
        }
        if (args["height"] != nil) {
            frameRect.size.height = CGFloat(truncating: args["height"] as! NSNumber)
        }
        if (args["x"] != nil) {
            frameRect.topLeft.x = CGFloat(args["x"] as! Float)
        }
        if (args["y"] != nil) {
            frameRect.topLeft.y = CGFloat(args["y"] as! Float)
        }
        
        if (animate) {
            mainWindow.animator().setFrame(frameRect, display: true, animate: true)
        } else {
            mainWindow.setFrame(frameRect, display: true)
        }
    }
    
    public func setMinimumSize(_ args: [String: Any]) {
        let minSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        mainWindow.minSize = minSize
    }
    
    public func setMaximumSize(_ args: [String: Any]) {
        let maxSize: NSSize = NSSize(
            width: CGFloat(args["width"] as! Float),
            height: CGFloat(args["height"] as! Float)
        )
        mainWindow.maxSize = maxSize
    }
    
    public func isResizable() -> Bool {
        return mainWindow.styleMask.contains(.resizable)
    }
    
    public func setResizable(_ args: [String: Any]) {
        let isResizable: Bool = args["isResizable"] as! Bool
        if (isResizable) {
            mainWindow.styleMask.insert(.resizable)
        } else {
            mainWindow.styleMask.remove(.resizable)
        }
    }
    
    public func isMovable() -> Bool {
        return mainWindow.isMovable
    }
    
    public func setMovable(_ args: [String: Any]) {
        let isMovable: Bool = args["isMovable"] as! Bool
        mainWindow.isMovable = isMovable
    }
    
    public func isMinimizable() -> Bool {
        return mainWindow.styleMask.contains(.miniaturizable)
    }
    
    public func setMinimizable(_ args: [String: Any]) {
        let isMinimizable: Bool = args["isMinimizable"] as! Bool
        if (isMinimizable) {
            mainWindow.styleMask.insert(.miniaturizable)
        } else {
            mainWindow.styleMask.remove(.miniaturizable)
        }
    }
    
    public func isClosable() -> Bool {
        return mainWindow.styleMask.contains(.closable)
    }
    
    public func setClosable(_ args: [String: Any]) {
        let isClosable: Bool = args["isClosable"] as! Bool
        if (isClosable) {
            mainWindow.styleMask.insert(.closable)
        } else {
            mainWindow.styleMask.remove(.closable)
        }
    }
    
    public func isAlwaysOnTop() -> Bool {
        return mainWindow.level == .floating
    }
    
    public func setAlwaysOnTop(_ args: [String: Any]) {
        let isAlwaysOnTop: Bool = args["isAlwaysOnTop"] as! Bool
        mainWindow.level = isAlwaysOnTop ? .floating : .normal
    }
    
    public func getTitleBarStyle() -> String {
        return mainWindow.styleMask.contains(.titled) ?"default": "hidden"
    }
    
    public func setTitleBarStyle(_ args: [String: Any]) {
        let titleBarStyle: String = args["titleBarStyle"] as! String
        
        if (titleBarStyle == "hidden") {
            mainWindow.styleMask.remove(.titled)
        } else {
            mainWindow.styleMask.insert(.titled)
        }
    }
    
    public func getTitle() -> String {
        return mainWindow.title
    }
    
    public func setTitle(_ args: [String: Any]) {
        let title: String = args["title"] as! String
        mainWindow.title = title;
    }
    
    public func hasShadow() -> Bool {
        return mainWindow.hasShadow
    }
    
    public func setHasShadow(_ args: [String: Any]) {
        let hasShadow: Bool = args["hasShadow"] as! Bool
        mainWindow.hasShadow = hasShadow;
        mainWindow.invalidateShadow();
    }
    
    public func startDragging() {
        DispatchQueue.main.async {
            let window: NSWindow  = self.mainWindow
            window.performDrag(with: window.currentEvent!)
        }
    }
    
    public func terminate() {
        NSApplication.shared.terminate(nil)
    }
}
