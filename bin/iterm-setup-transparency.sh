#!/usr/bin/env bash
# Idempotently configure iTerm2 profiles so nvim splits get the
# "floating windows" look:
#
#   - Window-level Transparency is forced to 0 (so buffer cells stay
#     fully opaque — essential for readable theme backgrounds).
#   - Background Image is set to the macOS current desktop wallpaper,
#     with Blend near 1.0 so the terminal background is mostly solid
#     but the wallpaper shows through any cell that uses the default
#     terminal bg (nvim's WinSeparator with bg=NONE).
#
# Net effect in nvim: each split renders as an opaque rectangle of the
# theme's bg color, with a 1-column "gap" between splits (WinSeparator)
# showing the wallpaper — like tiled windows on a desktop.
#
# Invoked from `rake iterm` together with bin/iterm-setup-keys.sh.
#
# Safety notes:
#   - iTerm2 rewrites the plist on quit; writing while it's running
#     would be clobbered. We refuse to run in that case.
#   - `killall cfprefsd` after the edit so macOS prefs cache reloads.
#   - Re-running is safe: PlistBuddy Add falls back to Set.

set -euo pipefail

PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
PB=/usr/libexec/PlistBuddy

# Tunables — tweak + re-run if the effect is too strong/subtle.
#   BLEND=1.0 → wallpaper hidden, pure terminal bg
#   BLEND=0.0 → wallpaper shows at full strength through every cell
#   0.85 gives a readable terminal, wallpaper clearly visible in gaps.
BLEND="0.85"
IMAGE_MODE="2"   # 0=stretch 1=tile 2=fill 3=fit

if [[ ! -f "$PLIST" ]]; then
  echo "iterm-setup-transparency: $PLIST not found — install iTerm2 first." >&2
  exit 1
fi

if pgrep -x iTerm2 >/dev/null || pgrep -x iTerm >/dev/null; then
  echo "iterm-setup-transparency: iTerm2 is running."
  echo "  → quit iTerm2 completely (⌘Q) and re-run this script."
  echo "  → running from inside iTerm will have the edits overwritten on quit."
  exit 2
fi

# Resolve macOS current desktop wallpaper. Two fallbacks since the right
# AppleScript path depends on the macOS version + Finder/System Events
# availability. If both fail we fall back to the Sonoma/Ventura default.
WALLPAPER="$(osascript -e 'tell application "System Events" to tell current desktop to get picture' 2>/dev/null || true)"
if [[ -z "${WALLPAPER}" || ! -f "${WALLPAPER}" ]]; then
  WALLPAPER="$(osascript -e 'tell application "Finder" to get POSIX path of (desktop picture as alias)' 2>/dev/null || true)"
fi
if [[ -z "${WALLPAPER}" || ! -f "${WALLPAPER}" ]]; then
  # Ship-it-anyway default — recent macOS has this one.
  for candidate in \
    "/System/Library/Desktop Pictures/Sonoma.heic" \
    "/System/Library/Desktop Pictures/Ventura Graphic.heic" \
    "/System/Library/Desktop Pictures/Monterey Graphic.heic" \
    "/System/Library/Desktop Pictures/BigSur.heic"
  do
    if [[ -f "$candidate" ]]; then WALLPAPER="$candidate"; break; fi
  done
fi

if [[ -z "${WALLPAPER}" || ! -f "${WALLPAPER}" ]]; then
  echo "iterm-setup-transparency: could not resolve a desktop wallpaper." >&2
  echo "  Set one manually via System Settings → Wallpaper and re-run," >&2
  echo "  or pass a path explicitly by editing the script." >&2
  exit 3
fi

echo "Using wallpaper: ${WALLPAPER}"

# Iterate over every profile under "New Bookmarks".
i=0
while $PB -c "Print :'New Bookmarks':${i}:Name" "$PLIST" >/dev/null 2>&1; do
  name=$($PB -c "Print :'New Bookmarks':${i}:Name" "$PLIST")

  # Force window transparency off (opaque buffers), then wire the image.
  for entry in \
    "Transparency|real|0.0" \
    "Blur|bool|false" \
    "Background Image Location|string|${WALLPAPER}" \
    "Background Image Mode|integer|${IMAGE_MODE}" \
    "Blend|real|${BLEND}"
  do
    IFS='|' read -r key typ val <<< "$entry"
    path=":'New Bookmarks':${i}:'${key}'"
    $PB -c "Add ${path} ${typ} ${val}" "$PLIST" 2>/dev/null || \
      $PB -c "Set ${path} ${val}" "$PLIST"
  done

  echo "  ✓ profile ${i} (${name}): blend=${BLEND}, transparency=0"
  i=$((i + 1))
done

if [[ $i -eq 0 ]]; then
  echo "iterm-setup-transparency: no profiles found in 'New Bookmarks'." >&2
  exit 4
fi

# Flush the prefs cache so iTerm sees the new values on next launch.
killall cfprefsd 2>/dev/null || true

echo
echo "iterm-setup-transparency: done. Relaunch iTerm2 to see the effect."
echo "Buffers will be opaque; gaps between nvim splits will show the wallpaper."
