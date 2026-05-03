# Claudet

A tiny macOS desktop pet that reacts to what Claude Code is doing.

A pixel-art Claude mascot sits in the lower-right corner of your screen. It hunches over while Claude Code is working on a prompt, then hops with a sparkle and pings you with a notification when it's done — so you can switch to another tab without missing the moment a long task finishes.

## Requirements

- macOS 13+
- Swift 5.9+ (Xcode command-line tools)
- Python 3 (only used by the hook installer script)

## Install

```sh
git clone <this repo> ~/Desktop/Claudet
cd ~/Desktop/Claudet

# Build the .app bundle
./scripts/make-app.sh

# Wire up the Claude Code hooks
./scripts/install-hooks.sh

# Launch
open build/Claudet.app
```

`make-app.sh` produces `build/Claudet.app` (bundle id `desktop.claudet.pet`, `LSUIElement` so it stays out of the Dock) and registers it with Launch Services.

`install-hooks.sh`:

1. Copies `scripts/claudet-state` to `~/.local/bin/claudet-state`.
2. Idempotently merges two hooks into `~/.claude/settings.json`:
   - `UserPromptSubmit` → `claudet-state working`
   - `Stop` → `claudet-state done`

For a quick dev run without bundling, use `./scripts/run.sh` — it builds with `swift build -c release` into `/tmp/claudet-build` and execs the binary directly.

## How it works

```
Claude Code hook  ->  ~/.local/bin/claudet-state working|done
                          |
                          v
                  ~/.config/claudet/state   (atomic mktemp + mv)
                          |
                          v
                StateWatcher (DispatchSource)
                          |
                          v
                    PetView.transition(...)
```

`StateWatcher` re-attaches across atomic renames, so it survives the helper's `mv` writes without losing events.

`ClaudeAppMonitor` separately watches `NSWorkspace` activation events. When the Claude desktop app comes forward, the pet snaps to the lower-right next to it; when Claude is hidden, it drifts toward the center of the screen.

## States

| State     | Trigger                               | Animation                         |
| --------- | ------------------------------------- | --------------------------------- |
| `idle`    | default; also after `done` finishes   | standing forward, slow blink      |
| `working` | `UserPromptSubmit` hook               | hunched, head dipping             |
| `done`    | `Stop` hook (only if previously working) | hop + sparkle + smile, then idle |
| `wander`  | manual / future use                   | walking, alternating legs         |
| `sleep`   | manual / future use                   | closed eyes, floating Z's         |

The status-bar menu and right-clicking the pet both expose Idle / Working / Done / Quit, which is enough to test all transitions without invoking Claude Code.

## Sprites

All sprites live in `Sources/Claudet/Sprites.swift` as plain string arrays on a 24×15 grid:

```
. = empty   O = body (coral)   E = eye/dark
M = mouth   Z = sparkle        B = sparkle highlight
```

Strict styling rules (do not break these when editing):

- One flat coral body color — **no rim, no inner shadow, no underside darkening**.
- Eyes are 2×2 dark blocks near the top of the head.
- Arms are 3×3 blocks at each side, just below the eye row.
- Legs are 1 cell wide × 2 rows tall, four legs with a wider middle gap.

The palette is three colors only: body `rgb(216, 118, 85)`, dark `rgb(12, 12, 12)`, sparkle yellow.

## Project layout

```
Package.swift                  Swift package manifest
Sources/Claudet/
  main.swift                   NSApplication entry
  AppDelegate.swift            wires up window, monitor, watcher, status item
  PetWindow.swift              borderless transparent floating NSWindow
  PetView.swift                pixel renderer + frame timer + right-click menu
  Sprites.swift                sprite frames + palette
  StateWatcher.swift           watches ~/.config/claudet/state
  ClaudeAppMonitor.swift       tracks Claude desktop app foreground
  Notifier.swift               osascript-based user notifications
hooks/settings.snippet.json    reference snippet for ~/.claude/settings.json
scripts/
  claudet-state                writes the state file
  install-hooks.sh             installs helper + merges hooks
  uninstall-hooks.sh           reverses install-hooks.sh
  run.sh                       build & run for development
  make-app.sh                  build the .app bundle
```

## Uninstall

```sh
./scripts/uninstall-hooks.sh
rm -rf build/Claudet.app ~/.config/claudet
```

`uninstall-hooks.sh` removes Claudet's hook entries from `~/.claude/settings.json` (leaving any other hooks alone) and deletes `~/.local/bin/claudet-state`. It also cleans up the legacy `friendly-claude-state` helper from earlier project names.

## Notes

- The build path defaults to `/tmp/claudet-build` because Spotlight/iCloud-managed folders can corrupt Swift's SQLite-backed build cache. Override with `CLAUDET_BUILD_DIR`.
- Notifications go through `osascript` rather than `UNUserNotificationCenter` so they work whether or not the binary is wrapped in an `.app` bundle.
- The window uses `[.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]` so the pet follows you across spaces without being captured by Mission Control or window cycling.
