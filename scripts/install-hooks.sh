#!/usr/bin/env bash
# Install the claudet-state helper into ~/.local/bin and merge the
# working/done hooks into ~/.claude/settings.json.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1) Install the state-setter helper on PATH
mkdir -p "$HOME/.local/bin"
install -m 0755 "$repo_dir/scripts/claudet-state" "$HOME/.local/bin/claudet-state"
echo "Installed: $HOME/.local/bin/claudet-state"

# 2) Merge hooks into ~/.claude/settings.json (creating it if needed)
settings="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
if [ ! -f "$settings" ]; then
  echo '{}' > "$settings"
fi

python3 - "$settings" <<'PY'
import json, os, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
hooks = cfg.setdefault("hooks", {})

helper = os.path.expandvars("$HOME/.local/bin/claudet-state")
def ensure(event, arg):
    arr = hooks.setdefault(event, [])
    cmd = f"{helper} {arg}"
    for group in arr:
        for h in group.get("hooks", []):
            if h.get("type") == "command" and h.get("command") == cmd:
                return
    arr.append({"hooks": [{"type": "command", "command": cmd}]})

ensure("UserPromptSubmit", "working")
ensure("Stop", "done")

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print(f"Updated: {path}")
PY

echo "Done. Now run: ./scripts/run.sh  (or open ~/Applications/Claudet.app)"
