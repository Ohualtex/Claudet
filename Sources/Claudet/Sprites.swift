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
    // Eye row patterns. Open eyes span 4 rows (indices 4-7) — the bottom row
    // sits at the arm-outline transition. Only these 4 rows differ between gaze states.
    // Göz satırı paternleri. Açık gözler 4 satıra yayılır (indeks 4-7) —
    // alttaki satır kol-kenarlık geçişine denk gelir. Sadece bu 4 satır
    // bakış durumlarına göre değişir.

    // Forward gaze: eyes centered on the head.
    // Düz bakış: gözler kafanın merkezinde.
    private static let fwdR4 = "...........DOOEEEWOOOOOOOOOOOOEEEWOOD..........."
    private static let fwdR5 = "...........DOOEEEEOOOOOOOOOOOOEEEEOOD..........."
    private static let fwdR6 = "...........DOOEEEEOOOOOOOOOOOOEEEEOOD..........."
    private static let fwdR7 = "......DDDDDDOOEEEEOOOOOOOOOOOOEEEEOODDDDDD......"

    // Blink: a single-row dark line where the eyes used to be (instead of vanishing).
    // Göz kırpma: gözlerin olduğu yerde tek satırlık koyu çizgi (kaybolmak yerine).
    private static let blinkClosed = "...........DOOOOOOOOOOOOOOOOOOOOOOOOD..........."
    private static let blinkLine   = "...........DOOEEEEOOOOOOOOOOOOEEEEOOD..........."
    private static let blinkArm    = "......DDDDDDOOOOOOOOOOOOOOOOOOOOOOOODDDDDD......"

    // Look right: both eye blocks shift 2 cells to the right.
    // Sağa bak: her iki göz bloğu 2 hücre sağa kayar.
    private static let rgtR4 = "...........DOOOOEEEWOOOOOOOOOOOOEEEWD..........."
    private static let rgtR5 = "...........DOOOOEEEEOOOOOOOOOOOOEEEED..........."
    private static let rgtR6 = "...........DOOOOEEEEOOOOOOOOOOOOEEEED..........."
    private static let rgtR7 = "......DDDDDDOOOOEEEEOOOOOOOOOOOOEEEEDDDDDD......"

    // Look left: both eye blocks shift 2 cells to the left.
    // Sola bak: her iki göz bloğu 2 hücre sola kayar.
    private static let lftR4 = "...........DEEEWOOOOOOOOOOOOEEEWOOOOD..........."
    private static let lftR5 = "...........DEEEEOOOOOOOOOOOOEEEEOOOOD..........."
    private static let lftR6 = "...........DEEEEOOOOOOOOOOOOEEEEOOOOD..........."
    private static let lftR7 = "......DDDDDDEEEEOOOOOOOOOOOOEEEEOOOODDDDDD......"

    // Build a full 48×30 frame from the 4 eye rows + a duration.
    // 4 göz satırından + süreden tam 48×30 frame üretir.
    private static func frame(_ r4: String, _ r5: String, _ r6: String, _ r7: String, ms: Int) -> SpriteFrame {
        SpriteFrame(rows: [
            "................................................",
            "............DDDDDDDDDDDDDDDDDDDDDDDD............",
            "...........DLLLLLLLLLLLLLLLLLLLLLLLLD...........",
            "...........DOOOOOOOOOOOOOOOOOOOOOOOOD...........",
            r4, r5, r6, r7,
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
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "...........DOOD..DOOD......DOOD..DOOD...........",
            "............DD....DD........DD....DD............",
            "................................................",
            "................................................",
        ], durationMs: ms)
    }

    // ----- IDLE: irregular blinks + occasional left/right glances.
    // ----- IDLE: düzensiz göz kırpmalar + ara sıra sağa-sola bakış.
    // Frame timings vary intentionally so the loop doesn't feel mechanical.
    // Frame süreleri kasıtlı olarak değişken — döngü mekanik hissetmesin diye.
    static let idle: [SpriteFrame] = [
        frame(fwdR4,        fwdR5,      fwdR6,      fwdR7,      ms: 1800),  // long stare / uzun bakış
        frame(blinkClosed,  blinkLine,  blinkClosed, blinkArm,  ms: 130),   // blink / göz kırp
        frame(fwdR4,        fwdR5,      fwdR6,      fwdR7,      ms: 1200),  // medium stare / orta bakış
        frame(rgtR4,        rgtR5,      rgtR6,      rgtR7,      ms: 380),   // glance right / sağa bakış
        frame(fwdR4,        fwdR5,      fwdR6,      fwdR7,      ms: 2200),  // long stare / uzun bakış
        frame(blinkClosed,  blinkLine,  blinkClosed, blinkArm,  ms: 110),   // quick blink / hızlı kırp
        frame(fwdR4,        fwdR5,      fwdR6,      fwdR7,      ms: 900),   // short stare / kısa bakış
        frame(lftR4,        lftR5,      lftR6,      lftR7,      ms: 420),   // glance left / sola bakış
        frame(fwdR4,        fwdR5,      fwdR6,      fwdR7,      ms: 1500),  // medium stare / orta bakış
        frame(blinkClosed,  blinkLine,  blinkClosed, blinkArm,  ms: 150),   // slow blink / yavaş kırp
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
