import AppKit

final class PetView: NSView {
    var pixelSize: CGFloat = 9.0 {
        didSet { needsDisplay = true }
    }

    private(set) var state: PetState = .idle
    private var frames: [SpriteFrame] = Sprites.frames(for: .idle)
    private var frameIndex: Int = 0
    private var frameTimer: Timer?
    private var doneStartedAt: Date?

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = .clear
        startAnimation()
    }

    required init?(coder: NSCoder) { fatalError() }

    func transition(to newState: PetState) {
        guard state != newState else { return }
        state = newState
        frames = Sprites.frames(for: newState)
        frameIndex = 0
        if newState == .done {
            doneStartedAt = Date()
        } else {
            doneStartedAt = nil
        }
        scheduleNextFrame()
        needsDisplay = true
    }

    private func startAnimation() {
        scheduleNextFrame()
    }

    private func scheduleNextFrame() {
        frameTimer?.invalidate()
        let frame = frames[frameIndex % frames.count]
        let interval = TimeInterval(frame.durationMs) / 1000.0
        frameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % self.frames.count

            // After playing "done" 2 full cycles, fall back to idle
            if self.state == .done,
               let started = self.doneStartedAt,
               Date().timeIntervalSince(started) > 3.0 {
                self.transition(to: .idle)
                return
            }
            self.needsDisplay = true
            self.scheduleNextFrame()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.clear(dirtyRect)

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
    override var mouseDownCanMoveWindow: Bool { true }

    // Right-click on the pet shows a small menu so it can be quit even
    // when the menu-bar item isn't visible.
    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()
        let idleItem = NSMenuItem(title: "Idle", action: #selector(setIdle), keyEquivalent: "")
        idleItem.target = self
        menu.addItem(idleItem)
        let workingItem = NSMenuItem(title: "Working", action: #selector(setWorking), keyEquivalent: "")
        workingItem.target = self
        menu.addItem(workingItem)
        let doneItem = NSMenuItem(title: "Done!", action: #selector(setDone), keyEquivalent: "")
        doneItem.target = self
        menu.addItem(doneItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit Claude\u{2019}t", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    @objc private func setIdle()    { transition(to: .idle) }
    @objc private func setWorking() { transition(to: .working) }
    @objc private func setDone()    { transition(to: .done) }
    @objc private func quitApp()    { NSApp.terminate(nil) }
}
