import Cocoa
import FlutterMacOS

extension NSWindow {
    private struct AssociatedKeys {
        static var configured: Bool = false
    }
    var configured: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.configured) as? Bool ?? false
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.configured, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public func hiddenWindowAtLaunch() {
        if (!configured) {
            setIsVisible(false)
            configured = true
        }
    }
}

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

public class WindowManager: NSObject, NSWindowDelegate {
    public var onEvent:((String) -> Void)?
    
    private var _mainWindow: NSWindow?
    public var mainWindow: NSWindow {
        get {
            return _mainWindow!
        }
        set {
            _mainWindow = newValue
            _mainWindow?.delegate = self
        }
    }
    
    private var _isMaximized: Bool = false

    override public init() {
        super.init()
    }

    public func setAsFrameless() {
        mainWindow.styleMask.insert(.fullSizeContentView)
        mainWindow.titleVisibility = .hidden
        mainWindow.isOpaque = true
        mainWindow.hasShadow = false
        mainWindow.backgroundColor = NSColor.clear

        if (mainWindow.styleMask.contains(.titled)) {
            let titleBarView: NSView = (mainWindow.standardWindowButton(.closeButton)?.superview)!.superview!
            titleBarView.isHidden = true
        }
    }
    
    public func waitUntilReadyToShow() {
        // nothing
    }
    
    public func focus() {
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func blur() {
        NSApp.deactivate()
    }
    
    public func show() {
        mainWindow.setIsVisible(true)
        DispatchQueue.main.async {
            self.mainWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            self.mainWindow.orderOut(nil)
        }
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
    
    public func center() {
        let screenFrame = NSScreen.main!.frame
        var frameRect: NSRect = mainWindow.frame;
        
        let width: CGFloat = frameRect.size.width
        let height: CGFloat = frameRect.size.height
        
        frameRect.topLeft.x = CGFloat((screenFrame.width - width) / 2)
        frameRect.topLeft.y = CGFloat((screenFrame.height - height) / 2)
        
        mainWindow.setFrame(frameRect, display: true)
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
        let animate = args["animate"] as? Bool ?? false
        
        var frameRect = mainWindow.frame
        if (args["width"] != nil && args["height"] != nil) {
            frameRect.size.width = CGFloat(truncating: args["width"] as! NSNumber)
            frameRect.size.height = CGFloat(truncating: args["height"] as! NSNumber)
        }
        if (args["x"] != nil && args["y"] != nil) {
            frameRect.topLeft.x = CGFloat(args["x"] as! Float)
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
    
    public func getTitle() -> String {
        return mainWindow.title
    }
    
    public func setTitle(_ args: [String: Any]) {
        let title: String = args["title"] as! String
        mainWindow.title = title;
    }
    
    public func setSkipTaskbar(_ args: [String: Any]) {
        let isSkipTaskbar: Bool = args["isSkipTaskbar"] as! Bool
        NSApplication.shared.setActivationPolicy(isSkipTaskbar ? .accessory : .regular)
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
    
    // NSWindowDelegate
    
    public func windowDidResize(_ notification: Notification) {
        _emitEvent("resize")
        if (!_isMaximized && mainWindow.isZoomed) {
            _isMaximized = true
            _emitEvent("maximize")
        }
        if (_isMaximized && !mainWindow.isZoomed) {
            _isMaximized = false
            _emitEvent("unmaximize")
        }
    }

    public func windowDidMove(_ notification: Notification) {
        _emitEvent("move")
    }

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
        if (onEvent != nil) {
            onEvent!(eventName)
        }
    }
}
