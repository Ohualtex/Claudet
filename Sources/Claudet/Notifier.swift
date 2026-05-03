import Foundation

// Lightweight notifier that shells out to osascript so it works whether or
// not the binary is wrapped in a .app bundle. UNUserNotificationCenter
// would be nicer but requires a bundle identifier to even initialize.
enum Notifier {
    static func requestAuthIfNeeded() {
        // No-op for AppleScript notifications.
    }

    static func notify(title: String, body: String) {
        func esc(_ s: String) -> String {
            s.replacingOccurrences(of: "\\", with: "\\\\")
             .replacingOccurrences(of: "\"", with: "\\\"")
        }
        let script = "display notification \"\(esc(body))\" with title \"\(esc(title))\""
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        try? task.run()
    }
}
