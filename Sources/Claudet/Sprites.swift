import AppKit

// Pixel-art sprites for the Claudet pet, drawn on a 24×15 cell grid.
// Each cell renders as a square of `pixelSize` points (see PetView).
// Claudet pet'i için pixel-art sprite'lar, 24×15 hücreli grid üzerinde çizilir.
// Her hücre `pixelSize` puanlık bir kare olarak render edilir (bkz. PetView).

enum PetState: String {
    case idle
}

enum SpriteCell: Character {
    case empty = "."
    case body = "O"
    case eye = "E"
    case mouth = "M"
    case sparkle = "Z"
    case sparkleHi = "B"
}

struct SpriteFrame {
    let rows: [String]
    let durationMs: Int

    var width: Int { rows.first?.count ?? 0 }
    var height: Int { rows.count }

    func cell(x: Int, y: Int) -> SpriteCell {
        guard y >= 0, y < rows.count else { return .empty }
        let row = rows[y]
        guard x >= 0, x < row.count else { return .empty }
        let idx = row.index(row.startIndex, offsetBy: x)
        return SpriteCell(rawValue: row[idx]) ?? .empty
    }
}

enum Sprites {
    // ----- IDLE: standing forward, blink / Düz duruş, göz kırpma -----
    static let idle: [SpriteFrame] = [
        SpriteFrame(rows: [
            "........................",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 1400),
        // Blink — eyes filled with body color
        // Göz kırpma — gözler vücut rengiyle dolduruldu
        SpriteFrame(rows: [
            "........................",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 110),
    ]

    static func frames(for state: PetState) -> [SpriteFrame] {
        switch state {
        case .idle: return idle
        }
    }
}

// Three-color palette retained as a starting point for future sprites.
// Gelecekteki sprite'lar için başlangıç noktası olarak korunan 3 renkli palet.
enum Palette {
    static let body     = NSColor(srgbRed: 216.0/255, green: 118.0/255, blue: 85.0/255, alpha: 1.0)
    static let eye      = NSColor(srgbRed: 12.0/255,  green: 12.0/255,  blue: 12.0/255, alpha: 1.0)
    static let mouth    = NSColor(srgbRed: 12.0/255,  green: 12.0/255,  blue: 12.0/255, alpha: 1.0)
    static let sparkle  = NSColor(srgbRed: 1.00, green: 0.95, blue: 0.55, alpha: 1.0)
    static let sparkleH = NSColor(srgbRed: 1.00, green: 0.85, blue: 0.40, alpha: 1.0)

    static func color(for cell: SpriteCell) -> NSColor? {
        switch cell {
        case .empty:     return nil
        case .body:      return body
        case .eye:       return eye
        case .mouth:     return mouth
        case .sparkle:   return sparkle
        case .sparkleHi: return sparkleH
        }
    }
}
