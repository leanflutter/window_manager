import Cocoa
import FlutterMacOS

public class SubWindow: NSWindow {
    public override func awakeFromNib() {
        let windowFrame = self.frame
        self.setFrame(windowFrame, display: true)

        super.awakeFromNib()
    }
}
