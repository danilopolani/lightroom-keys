#!/usr/bin/env bash
# Removes LrKeys and the shortcuts install.sh added (restores ⌘↑/⌘↓ to the flag commands).
set -euo pipefail

DOMAIN="com.adobe.LightroomClassicCC7"

if pgrep -xq "Adobe Lightroom Classic"; then
	echo "Quit Lightroom Classic first." >&2
	exit 1
fi

rm -rf "$HOME/Library/Application Support/Adobe/Lightroom/Modules/LrKeys.lrplugin" 2>/dev/null || true
echo "If you added LrKeys via Plug-in Manager, also click Remove there."

defaults export "$DOMAIN" - | /usr/bin/python3 -c '
import plistlib, sys
prefs = plistlib.loads(sys.stdin.buffer.read())
keys = prefs.get("NSUserKeyEquivalents", {})
for name in ("New Object Mask", "Toggle Mask Visibility", "Select Previous Mask", "Select Next Mask"):
  for title in ("LrKeys: " + name, "   LrKeys: " + name):
      keys.pop(title, None)
for title in ("Increase Flag Status", "Decrease Flag Status",
              "Aumenta stato segnalazione", "Riduci stato segnalazione"):
  keys.pop(title, None)
if not keys:
    prefs.pop("NSUserKeyEquivalents", None)
plistlib.dump(prefs, sys.stdout.buffer)
' | defaults import "$DOMAIN" -

echo "LrKeys removed. Restart Lightroom Classic."
