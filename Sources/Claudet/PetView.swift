import AppKit

final class PetView: NSView {
    // 1 sprite cell = 2 screen points by default. PetWindow currently
    // sets the same value explicitly; keep the default in sync so the
    // view renders correctly even if it's instantiated elsewhere.
    // 1 sprite hücresi = varsayılan 2 ekran puanı. PetWindow şu anda
    // aynı değeri açıkça atıyor; başka bir yerden oluşturulsa bile
    // doğru render etsin diye varsayılanı senkron tutuyoruz.
    var pixelSize: CGFloat = 2.0 {
        didSet { needsDisplay = true }
    }

    private let frames: [SpriteFrame] = Sprites.idle
    private var frameIndex: Int = 0
    private var frameTimer: Timer?

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = .clear
        scheduleNextFrame()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func scheduleNextFrame() {
        frameTimer?.invalidate()
        guard !frames.isEmpty else { return }
        let frame = frames[frameIndex % frames.count]
        let interval = TimeInterval(frame.durationMs) / 1000.0
        frameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % self.frames.count
            self.needsDisplay = true
            self.scheduleNextFrame()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.clear(dirtyRect)
        guard !frames.isEmpty else { return }

        let frame = frames[frameIndex % frames.count]
        let cols = frame.width
        let rows = frame.height
        let totalW = CGFloat(cols) * pixelSize
        let totalH = CGFloat(rows) * pixelSize
        let originX = (bounds.width - totalW) / 2
        let originY = (bounds.height - totalH) / 2

        for y in 0..<rows {
            for x in 0..<cols {
                let cell = frame.cell(x: x, y: y)
                guard let color = Palette.color(for: cell) else { continue }
                color.setFill()
                let pxRect = NSRect(
                    x: originX + CGFloat(x) * pixelSize,
                    y: originY + CGFloat(y) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                pxRect.fill()
            }
        }
    }

    // Required for window dragging via the view
    // View üzerinden pencere sürükleme için gerekli
    override var mouseDownCanMoveWindow: Bool { true }

    // Right-click on the pet shows a small menu so it can be quit even
    // when the menu-bar item isn't visible.
    // Pet'e sağ-tıklayınca küçük bir menü açılır; menü çubuğu öğesi
    // görünmese bile uygulamadan çıkılabilsin diye.
    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit Claude\u{2019}t", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    @objc private func quitApp() { NSApp.terminate(nil) }
}
