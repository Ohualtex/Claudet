# Claudet

A tiny pixel-art pet that sits in the corner of your macOS desktop and blinks at you.

The pet snaps to the lower-right of the screen when the Claude desktop app is in the foreground, and drifts toward the centre when Claude is hidden. There are no other behaviours — no hooks, no notifications, no state machine. Pure decoration.

## Requirements

- macOS 13+
- Swift 5.9+ (Xcode command-line tools)

## Install

```sh
git clone https://github.com/Ohualtex/Claudet.git ~/Desktop/Claudet
cd ~/Desktop/Claudet

# Build the .app bundle
./scripts/make-app.sh

# Launch
open build/Claudet.app
```

`make-app.sh` produces `build/Claudet.app` (bundle id `desktop.claudet.pet`, `LSUIElement` so it stays out of the Dock) and registers it with Launch Services.

For a quick dev run without bundling, use `./scripts/run.sh` — it builds with `swift build -c release` into `/tmp/claudet-build` and execs the binary directly.

## How it works

`PetView` runs a frame timer and cycles through the `idle` sprite frames forever (eyes-open ↔ blink ↔ side glance). `ClaudeAppMonitor` watches `NSWorkspace` activation events and repositions the borderless floating window when the Claude desktop app comes forward or leaves the foreground.

## Sprites

All sprites live in `Sources/Claudet/Sprites.swift` as plain string arrays on a 48×30 grid:

```
. = empty           O = body (coral)        D = outline (dark coral)
L = top highlight   E = eye dark            W = eye highlight
```

The body shade `rgb(216, 118, 85)` is sampled from the original Claude Code marketing video; the dark/light coral pair frames the silhouette, and the eye dark + eye-highlight give the pet its expression.

The idle loop is built by combining 4 eye-row variants (forward, look-right, look-left, blink) with a single shared body template — see the `idleFrame` helper.

## Project layout

```
Package.swift                  Swift package manifest
Sources/Claudet/
  main.swift                   NSApplication entry
  AppDelegate.swift            window + monitor + status item wiring
  PetWindow.swift              borderless transparent floating NSWindow
  PetView.swift                pixel renderer + frame timer + right-click menu
  ClaudeAppMonitor.swift       tracks Claude desktop app foreground
  Sprites.swift                shared types, palette, idle frames
scripts/
  run.sh                       build & run for development
  make-app.sh                  build the .app bundle
reference/                     idle pose reference renders + palette swatch
```

## Quit

Right-click the pet → **Quit Claude't**, or click the menu-bar 🟧 icon → **Quit**.

## Notes

- The build path defaults to `/tmp/claudet-build` because Spotlight/iCloud-managed folders can corrupt Swift's SQLite-backed build cache. Override with `CLAUDET_BUILD_DIR`.
- The window uses `[.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]` so the pet follows you across spaces without being captured by Mission Control or window cycling.

---

# Claudet (Türkçe)

macOS masaüstünüzün köşesinde durup size göz kırpan minik bir pixel-art evcil hayvan.

Pet, Claude masaüstü uygulaması ön plandayken ekranın sağ-altına yapışır; Claude gizliyken merkeze doğru kayar. Başka hiçbir davranış yok — hook yok, bildirim yok, durum makinesi yok. Tamamen dekorasyon.

## Gereksinimler

- macOS 13+
- Swift 5.9+ (Xcode komut satırı araçları)

## Kurulum

```sh
git clone https://github.com/Ohualtex/Claudet.git ~/Desktop/Claudet
cd ~/Desktop/Claudet

# .app bundle'ını derle
./scripts/make-app.sh

# Başlat
open build/Claudet.app
```

`make-app.sh`, `build/Claudet.app` dosyasını üretir (bundle id `desktop.claudet.pet`, Dock'ta görünmemesi için `LSUIElement`) ve Launch Services'e kaydeder.

Bundle yapmadan hızlı geliştirme için `./scripts/run.sh` kullan — `swift build -c release` ile `/tmp/claudet-build` altında derler ve binary'yi doğrudan çalıştırır.

## Nasıl çalışır

`PetView` bir frame timer çalıştırır ve `idle` sprite frame'lerini sonsuza kadar döndürür (gözler açık ↔ göz kırpma ↔ yan bakış). `ClaudeAppMonitor`, `NSWorkspace` aktivasyon olaylarını izler ve Claude masaüstü uygulaması ön plana geldiğinde veya ön plandan çıktığında borderless floating pencereyi yeniden konumlandırır.

## Sprite'lar

Tüm sprite'lar `Sources/Claudet/Sprites.swift` içinde, 48×30 grid üzerinde düz string array'leri olarak yer alır:

```
. = boş             O = vücut (coral)       D = kontur (koyu coral)
L = üst highlight   E = göz koyu            W = göz parlaması
```

Vücut tonu `rgb(216, 118, 85)` orijinal Claude Code tanıtım videosundan alınmıştır; koyu/açık coral çifti silueti çerçeveler, göz koyu + parlama ise pet'e ifadesini verir.

Idle döngüsü 4 göz-satırı varyantını (düz, sağa, sola, kırp) tek bir ortak vücut şablonuyla birleştirilerek kurulur — `idleFrame` yardımcısına bak.

## Proje yapısı

```
Package.swift                  Swift package manifesti
Sources/Claudet/
  main.swift                   NSApplication giriş noktası
  AppDelegate.swift            pencere + monitor + status item bağlantıları
  PetWindow.swift              borderless transparan floating NSWindow
  PetView.swift                pixel render + frame timer + sağ-tık menü
  ClaudeAppMonitor.swift       Claude masaüstü uygulamasının ön planını izler
  Sprites.swift                ortak tipler, palet, idle frame'leri
scripts/
  run.sh                       geliştirme için build & run
  make-app.sh                  .app bundle derler
reference/                     idle poz referans render'ları + palet örneği
```

## Çıkış

Pet'e sağ-tık → **Quit Claude't**, ya da menü çubuğundaki 🟧 simgesine tıkla → **Quit**.

## Notlar

- Build yolu varsayılan olarak `/tmp/claudet-build`; Spotlight/iCloud-yönetimli klasörler Swift'in SQLite tabanlı build cache'ini bozabildiği için. `CLAUDET_BUILD_DIR` ile override edilebilir.
- Pencere `[.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]` collection behavior'ını kullanır; böylece pet Space'ler arasında seninle dolaşır, Mission Control'e veya pencere döngüsüne takılmaz.
