import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: PetWindow!
    private var statusItem: NSStatusItem!
    private let claudeMonitor = ClaudeAppMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Auto-transition to working after launch when CLAUDET_AUTO_WORKING is set.
        // Useful for previewing the working animation without driving the menu.
        // CLAUDET_AUTO_WORKING set edildiğinde lansmandan sonra otomatik
        // working'e geç. Menüyü tetiklemeden working animasyonunu önizleme için.
        if ProcessInfo.processInfo.environment["CLAUDET_AUTO_WORKING"] != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.window.petView.transition(to: .working)
            }
        }
        // Hide Dock icon — this is a desktop accessory, not a regular app.
        // Dock simgesini gizle — bu bir masaüstü aksesuarı, normal uygulama değil.
        NSApp.setActivationPolicy(.accessory)

        // Tight fit around 24×15 × pixelSize 4 = 96×60 sprite, plus a bit of padding.
        // 24×15 × pixelSize 4 = 96×60 sprite'a sıkı oturuyor, biraz dolgu payı var.
        let size = NSSize(width: 110, height: 75)
        window = PetWindow(size: size)
        window.orderFrontRegardless()

        setupStatusItem()

        // Watch Claude desktop app foreground state to reposition the pet.
        // Pet'i yeniden konumlandırmak için Claude masaüstü uygulamasının ön plan durumunu izle.
        claudeMonitor.onChange = { [weak self] isClaude, app in
            self?.handleClaudeForegroundChange(isClaude: isClaude, app: app)
        }
        claudeMonitor.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        claudeMonitor.stop()
    }

    // MARK: - Behavior / Davranış

    private func handleClaudeForegroundChange(isClaude: Bool, app: NSRunningApplication?) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        var origin = window.frame.origin

        if isClaude {
            // Snug to the lower-right of the screen — visually next to Claude.
            // Ekranın sağ-altına yapıştır — görsel olarak Claude'un yanında.
            origin = NSPoint(
                x: visible.maxX - window.frame.width - 24,
                y: visible.minY + 24
            )
        } else {
            // Wander to a slightly more central spot when Claude is hidden,
            // so the pet feels like it stepped out onto the desktop.
            // Claude gizliyken biraz daha merkezi bir noktaya kay,
            // böylece pet sanki masaüstüne çıkmış gibi hissedilsin.
            origin = NSPoint(
                x: visible.midX - window.frame.width / 2,
                y: visible.minY + 80
            )
        }
        window.animator().setFrameOrigin(origin)
    }

    // MARK: - Status item (menu bar) / Durum öğesi (menü çubuğu)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = makeMenuBarIcon()
            button.toolTip = "Claude't"
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "Idle", action: #selector(setIdle), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Working", action: #selector(setWorking), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
            .target = self
        statusItem.menu = menu
    }

    // Render the pet's idle frame as a small NSImage suitable for the
    // menu bar status item. The shape stays identical to the desktop
    // sprite, but the palette is collapsed to monochrome — body, outline
    // and highlight all become white; eyes stay black. This matches the
    // black-and-white style of other menu-bar icons.
    // Pet'in idle frame'ini menü bar status item için küçük bir NSImage
    // olarak render eder. Şekil masaüstü sprite'ıyla aynı kalır, palet
    // monokroma indirgenir — vücut, kenarlık ve highlight beyaza, gözler
    // siyaha düşer. Diğer menü bar ikonlarının siyah-beyaz tarzına uyar.
    private func makeMenuBarIcon() -> NSImage {
        let frame = Sprites.idle[0]
        let pxSize = 2
        let w = frame.width * pxSize
        let h = frame.height * pxSize
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: w, height: h, bitsPerComponent: 8,
            bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return NSImage() }

        for y in 0..<frame.height {
            for x in 0..<frame.width {
                let cell = frame.cell(x: x, y: y)
                let color: NSColor?
                switch cell {
                case .empty:
                    color = nil
                case .body, .dark, .light, .bodyMid, .bodyDeep, .gray, .grayDark:
                    color = .white
                case .eye:
                    color = .black
                case .eyeHighlight:
                    color = .white
                }
                guard let c = color else { continue }
                ctx.setFillColor(c.cgColor)
                ctx.fill(CGRect(
                    x: x * pxSize,
                    y: (frame.height - 1 - y) * pxSize,
                    width: pxSize, height: pxSize
                ))
            }
        }

        guard let cg = ctx.makeImage() else { return NSImage() }
        let displayH: CGFloat = 18
        let displayW = displayH * CGFloat(frame.width) / CGFloat(frame.height)
        return NSImage(cgImage: cg, size: NSSize(width: displayW, height: displayH))
    }

    @objc private func setIdle()    { window.petView.transition(to: .idle) }
    @objc private func setWorking() { window.petView.transition(to: .working) }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
