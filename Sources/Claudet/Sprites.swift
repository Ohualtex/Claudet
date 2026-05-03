import AppKit

// Pixel-art sprites of the official Claude Code mascot, traced from the
// marketing video frames in /tmp/ref2_close/char_f*.png.
//
// Strict styling (per user feedback):
//   - One flat coral body color. NO rim, NO inner shadow, NO underside
//     darkening.
//   - Eyes are simple 2×2 dark blocks, near the top of the head.
//   - Arms are 3×3 dark-coral blocks extending from each side of the
//     body, sitting just below the eye row.
//   - Legs are 1 cell wide × 2 rows tall, four legs with a wider middle gap.
//
// Layout (canvas 24 cols × 15 rows, each cell ≈ 1 art-pixel of source):
//   Body proper: cols 6-17 (12 wide).
//   Eyes (2×2): cols 7-8 and 15-16, rows 2-3.
//   Arms (3×3 each side): cols 3-5 (left) and 18-20 (right), rows 4-6.
//   Legs (1 cell × 2 rows × 4 legs): cols 6, 9, 14, 17, rows 10-11.

enum PetState: String {
    case idle
    case working
    case done
    case wander
    case sleep
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
    // ----- IDLE: standing forward, blink -----
    static let idle: [SpriteFrame] = [
        // Eyes open
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

    // ----- WORKING: hunched / squashed posture -----
    static let working: [SpriteFrame] = [
        // Frame 1 — hunched (whole sprite shifted 1 row down)
        SpriteFrame(rows: [
            "........................",
            "........................",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 320),
        // Frame 2 — head dipped further (concentration)
        SpriteFrame(rows: [
            "........................",
            "........................",
            "........................",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 280),
        // Frame 3 — back to neutral hunch
        SpriteFrame(rows: [
            "........................",
            "........................",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 320),
    ]

    // ----- DONE: hops with a sparkle, smiles -----
    static let done: [SpriteFrame] = [
        SpriteFrame(rows: [
            "...........Z............",
            "..........ZBZ...........",
            "...........Z............",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOMMMMMMMMOOO....",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O........O........",
            "........................",
            "........................",
            "........................",
            "........................",
        ], durationMs: 260),
        SpriteFrame(rows: [
            ".........ZBBZ...........",
            "........ZBBBBZ..........",
            "........ZBBBBZ..........",
            ".........ZBBZ...........",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOMMMMMMMMOOO....",
            "...OOOOOOOOOOOOOOOOOO...",
            ".......O............O...",
            "........................",
            "........................",
            "........................",
            "........................",
            "........................",
        ], durationMs: 260),
        SpriteFrame(rows: [
            "........................",
            "...........Z............",
            "........................",
            "......OOOOOOOOOOOO......",
            "......OEEOOOOOOEEO......",
            "......OEEOOOOOOEEO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOMMMMOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 480),
    ]

    // ----- WANDER: walking, alternating legs -----
    static let wander: [SpriteFrame] = [
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
            "......O..O....O.........",
            "......O..O....O.........",
            "........................",
            "........................",
            "........................",
        ], durationMs: 240),
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
            ".........O....O..O......",
            ".........O....O..O......",
            "........................",
            "........................",
            "........................",
        ], durationMs: 240),
    ]

    // ----- SLEEP: closed eyes, floating Zs -----
    static let sleep: [SpriteFrame] = [
        SpriteFrame(rows: [
            "........................",
            ".............Z..........",
            "............Z...........",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
        ], durationMs: 800),
        SpriteFrame(rows: [
            "........................",
            "............Z...........",
            "...........Z............",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "...OOOOOOOOOOOOOOOOOO...",
            "......OOOOOOOOOOOO......",
            "......OOOOOOOOOOOO......",
            "......O..O....O..O......",
            "......O..O....O..O......",
            "........................",
            "........................",
        ], durationMs: 800),
    ]

    static func frames(for state: PetState) -> [SpriteFrame] {
        switch state {
        case .idle: return idle
        case .working: return working
        case .done: return done
        case .wander: return wander
        case .sleep: return sleep
        }
    }
}

// Three-color palette: body, eye/mouth, sparkle. Body is the literal
// rgb(216, 118, 85) sample from the source video.
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
