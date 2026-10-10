#!/usr/bin/env bash
# Installs LrKeys and binds its menu commands to keyboard shortcuts via macOS
# App Shortcuts (NSUserKeyEquivalents) for Lightroom Classic.
#
#   ⌘O  LrKeys: New Object Mask
#   ⌘.  LrKeys: Toggle Mask Visibility
#   ⌘↑  LrKeys: Select Previous Mask
#   ⌘↓  LrKeys: Select Next Mask
#
# ⌘O and ⌘. are unused by Lightroom on Mac (Open Catalog is ⇧⌘O). ⌘↑/⌘↓ belong to
# Photo › Set Flag › Increase/Decrease Flag Status, which win the tie, so those two
# are moved to ⌃⌥⇧⌘↑/⌃⌥⇧⌘↓.
set -euo pipefail

DOMAIN="com.adobe.LightroomClassicCC7"
MODULES="$HOME/Library/Application Support/Adobe/Lightroom/Modules"
SRC="$(cd "$(dirname "$0")" && pwd)/LrKeys.lrplugin"

if pgrep -xq "Adobe Lightroom Classic"; then
	echo "Quit Lightroom Classic first (shortcuts are read at launch)." >&2
	exit 1
fi

mkdir -p "$MODULES" 2>/dev/null || true
if [ -w "$MODULES" ]; then
	rm -rf "$MODULES/LrKeys.lrplugin"
	cp -R "$SRC" "$MODULES/"
	echo "Installed plugin to $MODULES/LrKeys.lrplugin"
else
	# e.g. another plugin's installer created Modules as root
	echo "Modules folder is not writable; add the plugin manually:"
	echo "  Lightroom > File > Plug-in Manager > Add > $SRC"
fi

# @ = Cmd, $ = Shift, ~ = Option, ^ = Control
# Arrow keys are the private-use characters U+F700 (up) and U+F701 (down).
UP="$(printf '\xef\x9c\x80')"
DOWN="$(printf '\xef\x9c\x81')"

# Lightroom indents Plug-in Extras items with three spaces; the key press only
# fires when the title matches exactly, so bind both spellings.
defaults write "$DOMAIN" NSUserKeyEquivalents -dict-add \
	"LrKeys: New Object Mask" '@o' \
	"   LrKeys: New Object Mask" '@o' \
	"LrKeys: Toggle Mask Visibility" '@.' \
	"   LrKeys: Toggle Mask Visibility" '@.' \
	"LrKeys: Select Previous Mask" "@$UP" \
	"   LrKeys: Select Previous Mask" "@$UP" \
	"LrKeys: Select Next Mask" "@$DOWN" \
	"   LrKeys: Select Next Mask" "@$DOWN" \
	"Increase Flag Status" "^~\$@$UP" \
	"Decrease Flag Status" "^~\$@$DOWN" \
	"Aumenta stato segnalazione" "^~\$@$UP" \
	"Riduci stato segnalazione" "^~\$@$DOWN"

echo "Shortcuts bound. Start Lightroom Classic."
