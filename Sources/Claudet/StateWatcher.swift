import Foundation

// Watches a small text file (the "state file") whose contents are one of:
//   working, done, idle
// Claude Code hooks write into this file to signal what's happening.
final class StateWatcher {
    static let stateDir: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/claudet", isDirectory: true)
    }()
    static let stateFile = stateDir.appendingPathComponent("state")

    var onState: ((PetState) -> Void)?

    private var fileHandle: FileHandle?
    private var source: DispatchSourceFileSystemObject?

    func start() {
        ensureFileExists()
        attach()
        emitCurrent()
    }

    func stop() {
        source?.cancel()
        source = nil
        try? fileHandle?.close()
        fileHandle = nil
    }

    private func ensureFileExists() {
        let fm = FileManager.default
        try? fm.createDirectory(at: Self.stateDir, withIntermediateDirectories: true)
        if !fm.fileExists(atPath: Self.stateFile.path) {
            try? "idle".write(to: Self.stateFile, atomically: true, encoding: .utf8)
        }
    }

    private func attach() {
        let fd = open(Self.stateFile.path, O_EVTONLY)
        guard fd >= 0 else { return }
        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .extend, .delete, .rename, .attrib],
            queue: .main
        )
        src.setEventHandler { [weak self] in
            guard let self else { return }
            // On rename/delete (atomic write replaces the inode) we need to
            // re-attach to the new file.
            let data = src.data
            if data.contains(.delete) || data.contains(.rename) {
                src.cancel()
                close(fd)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.attach()
                    self?.emitCurrent()
                }
                return
            }
            self.emitCurrent()
        }
        src.setCancelHandler { close(fd) }
        src.resume()
        self.source = src
    }

    private func emitCurrent() {
        guard let str = try? String(contentsOf: Self.stateFile, encoding: .utf8) else { return }
        let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if let s = PetState(rawValue: trimmed) {
            onState?(s)
        }
    }
}
