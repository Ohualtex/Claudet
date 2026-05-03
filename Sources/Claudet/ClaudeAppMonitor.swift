import AppKit

// Watches frontmost-app changes and reports whether the Claude desktop
// app is currently active. Also exposes the bundle identifier list we
// recognize as "Claude" so the same logic is used everywhere.
final class ClaudeAppMonitor {
    static let claudeBundleIDs: Set<String> = [
        "com.anthropic.claudefordesktop",
        "com.anthropic.claude",
        "ai.claude.desktop"
    ]

    var onChange: ((Bool, NSRunningApplication?) -> Void)?
    private var observers: [NSObjectProtocol] = []

    func start() {
        let center = NSWorkspace.shared.notificationCenter
        let activate = center.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil, queue: .main
        ) { [weak self] note in
            self?.handle(note: note)
        }
        let deactivate = center.addObserver(
            forName: NSWorkspace.didDeactivateApplicationNotification,
            object: nil, queue: .main
        ) { [weak self] note in
            self?.handle(note: note)
        }
        observers = [activate, deactivate]

        // Emit the current state immediately
        let frontmost = NSWorkspace.shared.frontmostApplication
        emit(for: frontmost)
    }

    func stop() {
        let center = NSWorkspace.shared.notificationCenter
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
    }

    private func handle(note: Notification) {
        let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        // For activate, this app is now frontmost. For deactivate, we
        // need to ask who the frontmost is now.
        let frontmost: NSRunningApplication?
        if note.name == NSWorkspace.didActivateApplicationNotification {
            frontmost = app
        } else {
            frontmost = NSWorkspace.shared.frontmostApplication
        }
        emit(for: frontmost)
    }

    private func emit(for app: NSRunningApplication?) {
        let isClaude = isClaudeApp(app)
        onChange?(isClaude, app)
    }

    private func isClaudeApp(_ app: NSRunningApplication?) -> Bool {
        guard let id = app?.bundleIdentifier?.lowercased() else { return false }
        return ClaudeAppMonitor.claudeBundleIDs.contains(id)
    }
}
