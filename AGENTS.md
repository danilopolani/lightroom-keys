# AGENTS.md — LrKeys

LrKeys is a Lightroom Classic plugin for macOS that adds keyboard shortcuts for masking.
Read this before adding or changing a shortcut.

## How a shortcut works

Lightroom plugins can't register keys. Each shortcut has two halves:

1. **A menu command.** It's an entry in `LrKeys.lrplugin/Info.lua` under `LrExportMenuItems`, so it
   appears under **File › Plug-in Extras**, and it runs a Lua script.
2. **A key binding.** This is a macOS App Shortcut (`NSUserKeyEquivalents` in the
   `com.adobe.LightroomClassicCC7` defaults domain), matched against that menu command's **title**.

The title string is what ties the two together. It must be identical in `Info.lua`,
`install.sh`, `uninstall.sh` and `README.md`.

## Files

| File | Role |
|---|---|
| `LrKeys.lrplugin/Info.lua` | Plugin manifest; the list of menu commands (title → script) |
| `LrKeys.lrplugin/Develop.lua` | `Develop.run(name, fn)`: checks for a target photo, switches to Develop, runs `fn` in an async task, shows errors as a bezel/dialog. `Develop.ensureMaskingTool()` opens Masking |
| `LrKeys.lrplugin/MaskNavigation.lua` | Shared logic for Select Previous/Next Mask |
| `LrKeys.lrplugin/<Command>.lua` | One script per menu command |
| `install.sh` | Copies the plugin into Lightroom's Modules folder (when writable) and writes the key bindings |
| `uninstall.sh` | Removes the plugin and every binding it owns |
| `README.md` | User docs: shortcut table, manual setup table, Terminal command |

## Add a new shortcut

1. **Write the script** `LrKeys.lrplugin/<Command>.lua`. Follow the existing ones:
   ```lua
   -- <Key>: <what it does>.

   local LrDevelopController = import 'LrDevelopController'
   local Develop = require 'Develop'

   Develop.run('<Command Name>', function()
   	Develop.ensureMaskingTool() -- only if the action needs Masking open
   	LrDevelopController.<call>(...)
   end)
   ```
   Use `LrDialogs.showBezel('LrKeys: …')` for a non-error "nothing to do" situation, and let
   real errors throw: `Develop.run` catches them.
2. **Register it** in `Info.lua`:
   ```lua
   { title = 'LrKeys: <Command Name>', file = '<Command>.lua' },
   ```
   Keep the `LrKeys: ` prefix. It keeps titles unique, so macOS can't bind the key to one of
   Lightroom's own menu items by accident.
3. **Bind the key** in `install.sh`. Add **two** lines to the `defaults write … -dict-add` call:
   the plain title and the title with **three leading spaces**:
   ```bash
   "LrKeys: <Command Name>" '<key>' \
   "   LrKeys: <Command Name>" '<key>' \
   ```
   Lightroom indents Plug-in Extras items with three spaces. Without the spaced variant, macOS
   still shows the shortcut in the menu, but pressing it only beeps.
4. **Let uninstall remove it.** Add `"<Command Name>"` to the `for name in (…)` tuple in
   `uninstall.sh`.
5. **Document it** in `README.md`: the shortcut table at the top, the "Bind the shortcuts" table
   (with the three spaces), and the Terminal `defaults write` example.
6. **Update the header comment** in `install.sh` listing every shortcut.
7. **Check for clashes** (see below), then **apply and test** (see below).

## Change an existing shortcut's key

1. Change the key value on **both** lines (plain and three-space title) in `install.sh`.
2. Update the comment at the top of the command's `.lua` script, the `install.sh` header, and
   `README.md` (all three places).
3. Check for clashes, then apply and test.

`-dict-add` overwrites an existing title's value, so you don't need to remove the old key first.

## Rename a command (change its title)

The old title stays in the user's prefs unless it's removed. Rename the title everywhere it
appears: `Info.lua`, `install.sh` (both lines), `uninstall.sh` and `README.md`. Then delete the old
entries from the live prefs before re-applying. Lightroom must be quit first:

```bash
defaults export com.adobe.LightroomClassicCC7 - | /usr/bin/python3 -c '
import plistlib, sys
p = plistlib.loads(sys.stdin.buffer.read())
k = p.get("NSUserKeyEquivalents", {})
for t in ("LrKeys: <Old Name>", "   LrKeys: <Old Name>"):
    k.pop(t, None)
plistlib.dump(p, sys.stdout.buffer)
' | defaults import com.adobe.LightroomClassicCC7 -
```

Use `plistlib.loads(stdin.read())`, not `plistlib.load(stdin)`, because a pipe isn't seekable.
Don't edit the prefs with `PlistBuddy`: it treats the `:` in `LrKeys: …` as a path separator.

## Key encoding (`NSUserKeyEquivalents`)

Modifiers come first, then the key: `@` = ⌘, `$` = ⇧, `~` = ⌥, `^` = ⌃. Use a lowercase letter
for the key, e.g. `'@o'` = ⌘O and `'@$o'` = ⇧⌘O.

Special keys are private-use Unicode characters. Write them as raw UTF-8 with `printf` (as
`install.sh` does for the arrows), because `defaults` doesn't interpret `\U` escapes:

| Key | Code point | `printf` |
|---|---|---|
| ↑ | U+F700 | `'\xef\x9c\x80'` |
| ↓ | U+F701 | `'\xef\x9c\x81'` |
| ← | U+F702 | `'\xef\x9c\x82'` |
| → | U+F703 | `'\xef\x9c\x83'` |
| F1–F12 | U+F704–U+F70F | `'\xef\x9c\x84'` … `'\xef\x9c\x8f'` |

## Check for clashes with Lightroom

Lightroom's default bindings live in its own resources, not in Adobe's online table (which is
incomplete). Search them:

```bash
A="/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app/Contents/Resources"
grep -rIaohE '\$\$\$/[A-Za-z0-9/_]+/Key[A-Za-z/]*=Cmd\+o\b' "$A"/*.lua | sort -u
```

Change the `=Cmd\+o\b` part to the key you're checking. Watch for these:

- **A capital letter means Shift on Mac.** `OpenCatalog/Key=Cmd+O` is ⇧⌘O, not ⌘O.
- **Bindings change by language.** `"$A/<lang>.lproj/TranslatedStrings.txt"` can override them.
  For example, ⌘. is Rotate Right in German. The user's Lightroom is in English; check `en`
  first and mention any other language that clashes.
- **Not every built-in key is a menu binding.** Masking keys like ⌥↑/⌥↓ (select mask) are
  handled inside the Masks panel and don't appear in these files. The **?** button in the Masks
  panel lists them.
- **Overriding a Lightroom key is allowed** when the user asks for it, but just binding the same
  key isn't enough: Lightroom's own menu item wins the tie. You also have to move Lightroom's
  item to another key by adding its title to the `defaults write` call. ⌘↑/⌘↓ do this:
  `Increase/Decrease Flag Status` move to ⌃⌥⇧⌘↑/↓. Bind both the English title and the
  Italian one from `it.lproj/TranslatedStrings.txt` (drop the `&` mnemonic). Lightroom's own
  items don't take the three-space prefix. Add the titles to the second loop in `uninstall.sh`
  so they're restored, and note the move in the `install.sh` header and the README.

## Apply and test

1. Lightroom reads `NSUserKeyEquivalents` and the menu list only at launch, so quit it (⌘Q).
   `install.sh` refuses to run while Lightroom is open.
2. Run `./install.sh`. On this machine the Modules folder is owned by root, so the installer only
   writes the bindings. The plugin is loaded in place from `~/lrkeys/LrKeys.lrplugin` via
   Plug-in Manager, so edits to the `.lua` files are picked up directly. Don't move the folder.
3. Start Lightroom. Check that **File › Plug-in Extras** shows the command with its shortcut.
4. Press the key:
   - **Beep:** the title doesn't match. Check the three-space variant.
   - **Nothing in the menu:** the plugin isn't loaded. Check **File › Plug-in Manager**.
   - **An `LrKeys: …` bezel or dialog:** the script ran and hit an error or an empty state.
5. For script-only changes (no new or renamed menu items), **File › Plug-in Manager › Reload
   Plug-in** is enough; you don't need to restart Lightroom.

To inspect the current bindings:

```bash
defaults read com.adobe.LightroomClassicCC7 NSUserKeyEquivalents
```

## Constraints and gotchas

- There's no Lua compiler on this machine, so syntax errors only show up when Lightroom loads
  the plugin. Write carefully and test in Lightroom.
- The Lightroom SDK is Lua 5.1 and the minimum is SDK 12 (needed for the `objects` mask type).
- `LrDevelopController` masking API: `createNewMask(type, subtype)` (e.g.
  `'aiSelection', 'objects'`), `getSelectedMask()`, `toggleHideMask(id)`, `toggleOverlay()`,
  `getAllMasks()`, `selectMask(id)`. The shape `getAllMasks()` returns isn't documented;
  `MaskNavigation.lua` handles the likely formats and shows a dialog with the raw value when it
  doesn't recognise it.
- Never call `Develop.run` from inside another `Develop.run`; each one starts its own async task.
- Don't bind keys through any mechanism other than `NSUserKeyEquivalents`. The project
  deliberately has no helper app and needs no Accessibility permission (unlike LrSuperKeys).
