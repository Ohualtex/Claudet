import AppKit

// Pixel-art sprites for the Claudet pet, drawn on a 48×30 cell grid.
// Each cell renders as a square of `pixelSize` points (see PetView).
// Claudet pet'i için pixel-art sprite'lar, 48×30 hücreli grid üzerinde çizilir.
// Her hücre `pixelSize` puanlık bir kare olarak render edilir (bkz. PetView).
//
// 5-colour palette:  body / dark outline / light highlight / eye / eye-highlight
// 5 renkli palet:    body / koyu kenarlık / açık highlight / göz / göz parlaması

enum SpriteCell: Character {
    case empty = "."
    case body = "O"
    case dark = "D"          // outline + shadow / kenarlık + gölge
    case light = "L"         // top-edge highlight / üst kenar highlight
    case eye = "E"           // dark eye / koyu göz
    case eyeHighlight = "W"  // small white highlight in eye / gözdeki küçük beyaz parlaklık
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
            "................................................",
            "............DDDDDDDDDDDDDDDDDDDDDDDD............",
            "...........DLLLLLLLLLLLLLLLLLLLLLLLLD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOEEEWOOOOOOOOOOOOEEEWOOD...........",
            "...........DOOEEEEOOOOOOOOOOOOEEEEOOD...........",
            "...........DOOEEEEOOOOOOOOOOOOEEEEOOD...........",
            "......DDDDDDOOEEEEOOOOOOOOOOOOEEEEOODDDDDD......",
            ".....DLLLLLLOOOOOOOOOOOOOOOOOOOOOOOOLLLLLLD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            "......DDDDDDOOOOOOOOOOOOOOOOOOOOOOOODDDDDD......",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOODDDDOODDDDDDDDOODDDDOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "............DD....DD........DD....DD............",
            "................................................",
            "................................................",
            "................................................",
            "................................................",
            "................................................",
        ], durationMs: 1400),
        // Blink — eyes filled with body color
        // Göz kırpma — gözler vücut rengiyle dolduruldu
        SpriteFrame(rows: [
            "................................................",
            "............DDDDDDDDDDDDDDDDDDDDDDDD............",
            "...........DLLLLLLLLLLLLLLLLLLLLLLLLD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "......DDDDDDOOOOOOOOOOOOOOOOOOOOOOOODDDDDD......",
            ".....DLLLLLLOOOOOOOOOOOOOOOOOOOOOOOOLLLLLLD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            ".....DOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOD.....",
            "......DDDDDDOOOOOOOOOOOOOOOOOOOOOOOODDDDDD......",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            "...........DOODDDDOODDDDDDDDOODDDDOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "............DD....DD........DD....DD............",
            "................................................",
            "................................................",
            "................................................",
            "................................................",
            "................................................",
        ], durationMs: 110),
    ]
}

enum Palette {
    // Coral body / Coral vücut
    static let body         = NSColor(srgbRed: 216.0/255, green: 118.0/255, blue:  85.0/255, alpha: 1.0)
    // Darker coral for outline + bottom shadow / Kenarlık + alt gölge için daha koyu coral
    static let dark         = NSColor(srgbRed: 140.0/255, green:  65.0/255, blue:  35.0/255, alpha: 1.0)
    // Lighter coral for top-edge highlight / Üst kenar highlight için daha açık coral
    static let light        = NSColor(srgbRed: 252.0/255, green: 195.0/255, blue: 165.0/255, alpha: 1.0)
    // Near-black eye / Neredeyse siyah göz
    static let eye          = NSColor(srgbRed:  12.0/255, green:  12.0/255, blue:  12.0/255, alpha: 1.0)
    // Off-white eye highlight / Kırık beyaz göz parlaklığı
    static let eyeHighlight = NSColor(srgbRed: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)

    static func color(for cell: SpriteCell) -> NSColor? {
        switch cell {
        case .empty:        return nil
        case .body:         return body
        case .dark:         return dark
        case .light:        return light
        case .eye:          return eye
        case .eyeHighlight: return eyeHighlight
        }
    }
}
