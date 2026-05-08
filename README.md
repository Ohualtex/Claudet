# Claudet

A tiny pixel-art pet that sits in the corner of your macOS desktop and quietly works alongside you.

The pet snaps to the lower-right of the screen when the Claude desktop app is in the foreground, and drifts toward the centre when Claude is hidden. It cycles through an `idle` loop (irregular blinks + side glances) by default, and can switch to a `working` loop traced from the official Claude Code marketing video. No hooks, no notifications — just decoration.

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

## Switching state

The pet exposes two animations:

- **Idle** — eyes-open with occasional blinks and left/right glances.
- **Working** — 42 frames traced cell-by-cell from the source video (kare\_0001..0235), played at the source's 30 fps timing.

Switch by right-clicking the pet, or via the menu-bar icon. To preview the working animation immediately on launch, set `CLAUDET_AUTO_WORKING=1`.

## How it works

`PetView` runs a frame timer and draws the active state's sprite frames. `ClaudeAppMonitor` watches `NSWorkspace` activation events and repositions the borderless floating window when the Claude desktop app comes forward or leaves the foreground.

## Sprites

All sprites live in `Sources/Claudet/Sprites.swift` (idle pose) and `Sources/Claudet/SpritesWorking.swift` (working frames) as plain string arrays on a 48×30 grid:

```
. = empty           O = body (coral)        D = outline (dark coral)
M = mid coral       N = deep coral          L = top highlight (light coral)
E = eye dark        W = eye highlight       G = laptop grey
K = laptop edge dark grey
```

The body shade `rgb(216, 118, 85)` is sampled from the original Claude Code marketing video; the rest of the palette extends that with shadow / highlight steps and laptop greys for the working sequence.

The working frames were re-traced from `~/Desktop/Claudetpng/kare_*.png` with `scripts/trace_working.py` — keep that tool around if you want to retune palette mapping or sample a different cell size.

## Project layout

```
Package.swift                  Swift package manifest
Sources/Claudet/
  main.swift                   NSApplication entry
  AppDelegate.swift            window + monitor + status item wiring
  PetWindow.swift              borderless transparent floating NSWindow
  PetView.swift                pixel renderer + frame timer + right-click menu
  ClaudeAppMonitor.swift       tracks Claude desktop app foreground
  Sprites.swift                shared types + idle frames + palette
  SpritesWorking.swift         42 traced working frames (auto-generated)
scripts/
  run.sh                       build & run for development
  make-app.sh                  build the .app bundle
  trace_working.py             re-trace SpritesWorking.swift from raw PNGs
reference/                     idle pose reference renders + palette swatch
```

## Quit

Right-click the pet → **Quit Claude't**, or click the menu-bar 🟧 icon → **Quit**.

## Notes

- The build path defaults to `/tmp/claudet-build` because Spotlight/iCloud-managed folders can corrupt Swift's SQLite-backed build cache. Override with `CLAUDET_BUILD_DIR`.
- The window uses `[.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]` so the pet follows you across spaces without being captured by Mission Control or window cycling.

---

# Claudet (Türkçe)

macOS masaüstünüzün köşesinde sessizce sizinle çalışan minik bir pixel-art evcil hayvan.

Pet, Claude masaüstü uygulaması ön plandayken ekranın sağ-altına yapışır; Claude gizliyken merkeze doğru kayar. Varsayılan olarak `idle` döngüsünü oynatır (düzensiz göz kırpmalar + yan bakışlar) ve resmi Claude Code tanıtım videosundan trace edilmiş `working` döngüsüne geçebilir. Hook yok, bildirim yok — sadece dekorasyon.

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

## Durum değiştirme

Pet'in iki animasyonu var:

- **Idle** — gözler açık, ara sıra göz kırpma ve sağa/sola bakış.
- **Working** — kaynak videodan (kare\_0001..0235) hücre-hücre trace edilmiş 42 kare, 30 fps tempoda.

Pet'e sağ-tıklayarak veya menü çubuğu ikonundan değiştirilir. Working animasyonunu uygulama açılır açılmaz görmek için `CLAUDET_AUTO_WORKING=1` ortam değişkenini ayarla.

## Nasıl çalışır

`PetView` bir frame timer çalıştırır ve aktif durumun sprite frame'lerini çizer. `ClaudeAppMonitor`, `NSWorkspace` aktivasyon olaylarını izler ve Claude masaüstü uygulaması ön plana geldiğinde veya ön plandan çıktığında borderless floating pencereyi yeniden konumlandırır.

## Sprite'lar

Tüm sprite'lar `Sources/Claudet/Sprites.swift` (idle) ve `Sources/Claudet/SpritesWorking.swift` (working) içinde, 48×30 grid üzerinde düz string array'leri olarak yer alır:

```
. = boş             O = vücut (coral)       D = kontur (koyu coral)
M = orta coral      N = en koyu coral       L = üst highlight (açık coral)
E = göz koyu        W = göz parlaması       G = laptop grisi
K = laptop kenarı koyu gri
```

Vücut tonu `rgb(216, 118, 85)` orijinal Claude Code tanıtım videosundan alınmıştır; paletin geri kalanı bunu gölge/highlight adımları ve working sekansı için laptop grileriyle genişletir.

Working frame'leri `~/Desktop/Claudetpng/kare_*.png` dosyalarından `scripts/trace_working.py` ile yeniden üretildi — palet eşlemesini ayarlamak veya farklı bir cell boyutu denemek istersen bu aracı sakla.

## Proje yapısı

```
Package.swift                  Swift package manifesti
Sources/Claudet/
  main.swift                   NSApplication giriş noktası
  AppDelegate.swift            pencere + monitor + status item bağlantıları
  PetWindow.swift              borderless transparan floating NSWindow
  PetView.swift                pixel render + frame timer + sağ-tık menü
  ClaudeAppMonitor.swift       Claude masaüstü uygulamasının ön planını izler
  Sprites.swift                ortak tipler + idle frame'ler + palet
  SpritesWorking.swift         42 trace edilmiş working frame (otomatik üretildi)
scripts/
  run.sh                       geliştirme için build & run
  make-app.sh                  .app bundle derler
  trace_working.py             SpritesWorking.swift'i ham PNG'lerden yeniden üretir
reference/                     idle poz referans render'ları + palet örneği
```

## Çıkış

Pet'e sağ-tık → **Quit Claude't**, ya da menü çubuğundaki 🟧 simgesine tıkla → **Quit**.

## Notlar

- Build yolu varsayılan olarak `/tmp/claudet-build`; Spotlight/iCloud-yönetimli klasörler Swift'in SQLite tabanlı build cache'ini bozabildiği için. `CLAUDET_BUILD_DIR` ile override edilebilir.
- Pencere `[.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]` collection behavior'ını kullanır; böylece pet Space'ler arasında seninle dolaşır, Mission Control'e veya pencere döngüsüne takılmaz.
