import AppKit

final class PetWindow: NSWindow {
    let petView: PetView

    init(size: NSSize) {
        let view = PetView(frame: NSRect(origin: .zero, size: size))
        // 1 cell = 2 actual screen pixels — sprite is 48×30 × 2 = 96×60 px,
        // same on-screen footprint as before but 4× as much detail per cell.
        // 1 hücre = 2 gerçek ekran pikseli — sprite 48×30 × 2 = 96×60 px,
        // ekrandaki boyut aynı ama hücre başına 4× detay.
        view.pixelSize = 2
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
