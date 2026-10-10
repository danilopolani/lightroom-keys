# LrKeys

Keyboard shortcuts for Lightroom Classic masking (macOS).

| Shortcut | Command | What it does |
|---|---|---|
| ⌘O | LrKeys: New Object Mask | Opens Develop › Masking and starts a new Objects AI mask |
| ⌘. | LrKeys: Toggle Mask Visibility | Hides/shows the selected mask (the eye icon in the Masks panel) |
| ⌘↑ | LrKeys: Select Previous Mask | Selects the mask above the current one in the Masks panel (wraps around) |
| ⌘↓ | LrKeys: Select Next Mask | Selects the mask below the current one (wraps around) |
| — | LrKeys: Toggle Mask Overlay | Toggles the colored mask overlay (unbound by default) |

## How it works

Lightroom doesn't let plugins register keyboard shortcuts. LrKeys only adds commands to
**File › Plug-in Extras**. The keys are bound to those menu titles with macOS App Shortcuts
(`NSUserKeyEquivalents`), so there's no background app and no Accessibility permission.

LrSuperKeys works differently: a helper app (`LrSK.app`) captures keys system-wide and sends
them to its Lua plugin over a socket. That's what lets it override Lightroom's own keys.

⌘↑ / ⌘↓ normally belong to **Photo › Set Flag › Increase / Decrease Flag Status**, and those
menu items win the tie. `install.sh` therefore moves them to ⌃⌥⇧⌘↑ / ⌃⌥⇧⌘↓, and `uninstall.sh`
restores them.
Neither ⌘O nor ⌘. is used by Lightroom on Mac. Open Catalog is ⇧⌘O: Lightroom stores it
as `Cmd+O` with a capital O, and macOS turns a capital letter into Shift.

This holds for Lightroom's English interface. In some other languages Lightroom uses ⌘.
itself: German binds it to Rotate Right, Italian to Book › Next View Mode, and Japanese to
Zoom In. If you switch language, pick another key for Toggle Mask Visibility.

Built-in masking keys worth knowing (with Masking open): ⌥↑ / ⌥↓ select the previous / next
mask, and ⌥← / ⌥→ step through the selected mask's components. The **?** button in the Masks
panel lists the rest.

Requires Lightroom Classic 12 or later (the SDK added the `objects` mask type in 12).

## Automatic setup

1. Quit Lightroom Classic (⌘Q).
2. Run:
   ```bash
   ./install.sh
   ```
   It copies the plugin into `~/Library/Application Support/Adobe/Lightroom/Modules` and binds
   the shortcuts.
3. If it prints `Modules folder is not writable`, add the plugin by hand (see step 1 of
   [Manual setup](#manual-setup)). The shortcuts are still bound. This happens when another
   installer (e.g. LrSuperKeys) created the Modules folder as root.
4. Start Lightroom.

To remove everything: quit Lightroom, run `./uninstall.sh`, and, if you added the plugin via
Plug-in Manager, click **Remove** there.

## Manual setup

### 1. Add the plugin

1. In Lightroom, open **File › Plug-in Manager… › Add**.
2. Select the `LrKeys.lrplugin` folder (in the picker, ⇧⌘G lets you paste a path), then click **Done**.

Lightroom loads the plugin from that location, so don't move or rename the folder afterwards.
To install it like the other plugins instead, copy `LrKeys.lrplugin` into
`~/Library/Application Support/Adobe/Lightroom/Modules` and restart Lightroom.

### 2. Bind the shortcuts

1. Open **System Settings › Keyboard › Keyboard Shortcuts… › App Shortcuts** and click **+**.
2. Set **Application** to **Adobe Lightroom Classic** (choose **Other…** if it isn't listed).
3. Set **Menu Title** to the command name **with three leading spaces**, then pick the shortcut:

   | Menu Title (note the 3 spaces) | Shortcut |
   |---|---|
   | `   LrKeys: New Object Mask` | ⌘O |
   | `   LrKeys: Toggle Mask Visibility` | ⌘. |
   | `   LrKeys: Select Previous Mask` | ⌘↑ |
   | `   LrKeys: Select Next Mask` | ⌘↓ |
   | `Increase Flag Status` (no spaces; Lightroom's own item) | ⌃⌥⇧⌘↑ |
   | `Decrease Flag Status` (no spaces; Lightroom's own item) | ⌃⌥⇧⌘↓ |

4. Restart Lightroom.

Lightroom indents Plug-in Extras items with three spaces. Without them, macOS may still show
the shortcut in the menu, but pressing it only makes the "not allowed" beep.

Terminal equivalent of step 2:

```bash
defaults write com.adobe.LightroomClassicCC7 NSUserKeyEquivalents -dict-add \
  "   LrKeys: New Object Mask" '@o' \
  "   LrKeys: Toggle Mask Visibility" '@.' \
  "   LrKeys: Select Previous Mask" "@$(printf '\xef\x9c\x80')" \
  "   LrKeys: Select Next Mask" "@$(printf '\xef\x9c\x81')" \
  "Increase Flag Status" "^~\$@$(printf '\xef\x9c\x80')" \
  "Decrease Flag Status" "^~\$@$(printf '\xef\x9c\x81')"
```

(`@` = ⌘, `$` = ⇧, `~` = ⌥, `^` = ⌃. The arrow keys are the characters U+F700 (up) and
U+F701 (down), which `printf` writes as raw UTF-8.)

## Troubleshooting

- **Shortcut beeps:** the menu title doesn't match exactly. Check the three leading spaces, then restart Lightroom.
- **Nothing in File › Plug-in Extras:** the plugin isn't loaded. Check **File › Plug-in Manager** for LrKeys and make sure it's enabled.
- **"LrKeys: unexpected mask list":** the Lightroom API returned masks in a format the plugin
  doesn't recognise. The dialog shows what it got; send that over so the parsing can be fixed.
- **"LrKeys: no photo selected" / "no mask selected":** select a photo, or click a mask in the Masks panel, first.
- **To check the current bindings:**
  ```bash
  defaults read com.adobe.LightroomClassicCC7 NSUserKeyEquivalents
  ```
- **LrSuperKeys:** if its helper app is running and has an action on ⌘O or ⌘., it catches the key before macOS does.
