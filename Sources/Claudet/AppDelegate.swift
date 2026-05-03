import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: PetWindow!
    private var statusItem: NSStatusItem!
    private let claudeMonitor = ClaudeAppMonitor()
    private let stateWatcher = StateWatcher()

    private var lastWorkingAt: Date?
    private var doneFromHook: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide Dock icon — this is a desktop accessory, not a regular app.
        NSApp.setActivationPolicy(.accessory)

        // Sized for 24×15 sprite canvas at pixelSize = 6 (144×90 render).
        let size = NSSize(width: 170, height: 130)
        window = PetWindow(size: size)
        window.orderFrontRegardless()

        Notifier.requestAuthIfNeeded()

        setupStatusItem()

        // Watch Claude desktop app foreground state.
        claudeMonitor.onChange = { [weak self] isClaude, app in
            self?.handleClaudeForegroundChange(isClaude: isClaude, app: app)
        }
        claudeMonitor.start()

        // Watch the hook-driven state file.
        stateWatcher.onState = { [weak self] state in
            self?.handleHookState(state)
        }
        stateWatcher.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stateWatcher.stop()
        claudeMonitor.stop()
    }

    // MARK: - Behavior

    private func handleHookState(_ state: PetState) {
        switch state {
        case .working:
            lastWorkingAt = Date()
            doneFromHook = true
            window.petView.transition(to: .working)
        case .done:
            // Only celebrate if we were actually working (don't pop up
            // confetti every time Claude Code starts up cold).
            if doneFromHook {
                window.petView.transition(to: .done)
                let elapsed = lastWorkingAt.map { Int(Date().timeIntervalSince($0)) } ?? 0
                let body = elapsed > 0
                    ? "Done in ~\(elapsed)s — come check it out!"
                    : "All done — come check it out!"
                Notifier.notify(title: "Claude finished", body: body)
                doneFromHook = false
                lastWorkingAt = nil
            } else {
                window.petView.transition(to: .idle)
            }
        case .idle:
            window.petView.transition(to: .idle)
        case .wander, .sleep:
            window.petView.transition(to: state)
        }
    }

    private func handleClaudeForegroundChange(isClaude: Bool, app: NSRunningApplication?) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        var origin = window.frame.origin

        if isClaude {
            // Snug to the lower-right of the screen — visually next to Claude.
            origin = NSPoint(
                x: visible.maxX - window.frame.width - 24,
                y: visible.minY + 24
            )
        } else {
            // Wander to a slightly more central spot when Claude is hidden,
            // so the pet feels like it stepped out onto the desktop.
            origin = NSPoint(
                x: visible.midX - window.frame.width / 2,
                y: visible.minY + 80
            )
        }
        window.animator().setFrameOrigin(origin)
    }

    // MARK: - Status item (menu bar)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "🟧"
            button.toolTip = "Claude't"
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "Say hi (test idle)", action: #selector(testIdle), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Pretend Claude is working", action: #selector(testWorking), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Celebrate done!", action: #selector(testDone), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
            .target = self
        statusItem.menu = menu
    }

    @objc private func testIdle() {
        window.petView.transition(to: .idle)
    }
    @objc private func testWorking() {
        lastWorkingAt = Date()
        doneFromHook = true
        window.petView.transition(to: .working)
    }
    @objc private func testDone() {
        if !doneFromHook { lastWorkingAt = Date(); doneFromHook = true }
        handleHookState(.done)
    }
    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
