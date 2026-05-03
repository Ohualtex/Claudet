#!/usr/bin/env bash
# Remove claudet hooks from ~/.claude/settings.json and uninstall the
# helper script. Leaves any other hooks alone. Also removes any legacy
# friendly-claude-state hooks installed under earlier project names.
set -euo pipefail

settings="$HOME/.claude/settings.json"
if [ -f "$settings" ]; then
python3 - "$settings" <<'PY'
import json, os, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
hooks = cfg.get("hooks", {})
helpers = [
    os.path.expandvars("$HOME/.local/bin/claudet-state"),
    os.path.expandvars("$HOME/.local/bin/friendly-claude-state"),  # legacy
]
removed = 0
for event in list(hooks.keys()):
    new_groups = []
    for group in hooks[event]:
        new_hooks = [
            h for h in group.get("hooks", [])
            if not (
                h.get("type") == "command"
                and any(helper in (h.get("command") or "") for helper in helpers)
            )
        ]
        if new_hooks:
            new_groups.append({**group, "hooks": new_hooks})
        else:
            removed += 1
    if new_groups:
        hooks[event] = new_groups
    else:
        del hooks[event]
        removed += 1
if not hooks:
    cfg.pop("hooks", None)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print(f"Removed {removed} claudet hook entries from {path}")
PY
fi

rm -f "$HOME/.local/bin/claudet-state" "$HOME/.local/bin/friendly-claude-state"
echo "Uninstalled helper from ~/.local/bin/"
