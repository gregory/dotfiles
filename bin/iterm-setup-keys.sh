#!/usr/bin/env bash
# Idempotently install iTerm2 GlobalKeyMap entries that forward
# Ctrl+Tab / Ctrl+Shift+Tab / Ctrl+PageDown / Ctrl+PageUp to the terminal
# as CSI-u-style escape sequences, so nvim (and tmux) can bind them.
#
# Why this script exists: iTerm2 swallows <C-Tab> by default (cycles its
# own tabs). Without forwarding, mappings like `nnoremap <C-Tab> :bnext`
# in nvim never fire. We rewrite the plist directly so the setting survives
# fresh installs / new machines.
#
# Safety notes:
#   - iTerm2 holds prefs in memory and rewrites the plist on quit, which
#     would CLOBBER anything we wrote while it was running. We therefore
#     refuse to run while iTerm is open and ask the user to ⌘Q first.
#   - `killall cfprefsd` is required after a direct plist edit so the
#     macOS prefs cache picks up the new values.
#   - Re-running is safe: we use PlistBuddy Add, fall back to Set.

set -euo pipefail

PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
PB=/usr/libexec/PlistBuddy

if [[ ! -f "$PLIST" ]]; then
  echo "iterm-setup-keys: $PLIST not found — install iTerm2 first." >&2
  exit 1
fi

if pgrep -x iTerm2 >/dev/null || pgrep -x iTerm >/dev/null; then
  echo "iterm-setup-keys: iTerm2 is running."
  echo "  → quit iTerm2 completely (⌘Q) and re-run this script."
  echo "  → running from inside iTerm will have the edits overwritten on quit."
  exit 2
fi

# Ensure the GlobalKeyMap dict exists (no-op if already present).
$PB -c "Add :GlobalKeyMap dict" "$PLIST" 2>/dev/null || true

# Key format: 0x<char>-0x<modifiers>
#   0x9          Tab
#   0xf72d       Page Up    (NSPageUpFunctionKey)
#   0xf72c       Page Down  (NSPageDownFunctionKey)
#   0x20000      Shift
#   0x40000      Control
#   0x200000     NumericPad (auto-set on function keys, including PageUp/Down)
#
# Action 10 = "Send Escape Sequence"; Text is the sequence sent AFTER ESC,
# so "[27;5;9~" produces ESC[27;5;9~ — the standard xterm modifyOtherKeys
# encoding for Ctrl+Tab. nvim ≥0.10 decodes these via libtermkey.
#
# Layout: KEY | MODS | ESC-SEQ TEXT | HUMAN LABEL
entries=(
  "0x9|0x40000|[27;5;9~|Ctrl+Tab"
  "0x9|0x60000|[27;6;9~|Ctrl+Shift+Tab"
  "0xf72c|0x240000|[6;5~|Ctrl+PageDown"
  "0xf72d|0x240000|[5;5~|Ctrl+PageUp"
)

for entry in "${entries[@]}"; do
  IFS='|' read -r key mods text label <<< "$entry"
  path=":GlobalKeyMap:${key}-${mods}"

  # Add the dict; ignore if it exists. Then Set each field (Set works on
  # both new and existing dicts).
  $PB -c "Add ${path} dict" "$PLIST" 2>/dev/null || true
  $PB -c "Add ${path}:Action integer 10" "$PLIST" 2>/dev/null || \
    $PB -c "Set ${path}:Action 10" "$PLIST"
  $PB -c "Add ${path}:Text string ${text}" "$PLIST" 2>/dev/null || \
    $PB -c "Set ${path}:Text ${text}" "$PLIST"
  $PB -c "Add ${path}:Label string ${label}" "$PLIST" 2>/dev/null || \
    $PB -c "Set ${path}:Label ${label}" "$PLIST"

  echo "  ✓ ${label}  →  ESC${text}"
done

# Flush the prefs cache so iTerm sees the new values on next launch.
killall cfprefsd 2>/dev/null || true

echo
echo "iterm-setup-keys: done. Relaunch iTerm2 and the sequences will be"
echo "forwarded. nvim mappings for <C-Tab>/<C-S-Tab>/<C-PageDown>/<C-PageUp>"
echo "will now fire correctly."
