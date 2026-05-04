import AppKit

final class PetWindow: NSWindow {
    let petView: PetView

    init(size: NSSize) {
        let view = PetView(frame: NSRect(origin: .zero, size: size))
        // 1 cell = 1 art-pixel of the source character. pixelSize = 6
        // keeps the rendered character around marketing-video size.
        // 1 hücre = kaynak karakterin 1 sanat-pikseli. pixelSize = 6
        // render edilen karakteri tanıtım videosu boyutuna yakın tutar.
        view.pixelSize = 6
        self.petView = view
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .floating
        ignoresMouseEvents = false
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        contentView = view
        // Place in lower-right area of the main screen by default.
        // Varsayılan olarak ana ekranın sağ-alt bölgesine yerleştir.
        if let screen = NSScreen.main {
            let frame = screen.visibleFrame
            let x = frame.maxX - size.width - 40
            let y = frame.minY + 40
            setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
