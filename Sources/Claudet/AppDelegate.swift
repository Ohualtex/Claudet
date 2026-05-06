import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: PetWindow!
    private var statusItem: NSStatusItem!
    private let claudeMonitor = ClaudeAppMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
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
            button.title = "🟧"
            button.toolTip = "Claude't"
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
            .target = self
        statusItem.menu = menu
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
