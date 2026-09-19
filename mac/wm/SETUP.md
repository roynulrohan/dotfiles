# mac/wm: AeroSpace, SketchyBar, Karabiner, LinearMouse

Tiling, the bar and the Super key on the Mac. **macOS only; skip this package on
Linux.** The binds are a minimal, Mac-only subset of the Hyprland binds in
`linux/`. Hyprland is never changed to match the Mac.

## Files

| Repo | Destination |
|---|---|
| `aerospace/aerospace.toml` | `~/.config/aerospace/aerospace.toml` |
| `sketchybar/` | `~/.config/sketchybar/`, the whole tree |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `linearmouse/linearmouse.json` | `~/.config/linearmouse/linearmouse.json` |
| `macos-settings.sh` | not copied; run it once |

Copy the SketchyBar tree whole: `sketchybarrc` sources `colors.sh`, `icons.sh`,
`items/` and `plugins/` by path. Execute bits don't survive a plain `cp`:

```bash
chmod +x ~/.config/sketchybar/sketchybarrc
find ~/.config/sketchybar -name '*.sh' -exec chmod +x {} +
```

## Install

```bash
brew install --cask nikitabobko/tap/aerospace
brew install felixkratz/formulae/sketchybar jq
brew install --cask font-sketchybar-app-font sf-symbols kitty raycast linearmouse
brew install --cask karabiner-elements
```

Run the Karabiner line in a real terminal: it installs a system package and asks
for your password, which a non-interactive shell can't do. If Homebrew refuses
the FelixKratz formula, run `brew trust felixkratz/formulae` first.

Then, in order:

1. `mac/wm/macos-settings.sh`, then log out and back in.
2. Open AeroSpace once and grant it Accessibility. It starts at login after that
   (`start-at-login = true`).
3. Open Karabiner-Elements and allow its driver and Input Monitoring when its
   setup window asks. If macOS asks for the keyboard type, pick ANSI.
4. `brew services start sketchybar`.

## The Super key

AeroSpace can't tell left from right modifiers
([nikitabobko/AeroSpace#28](https://github.com/nikitabobko/AeroSpace/issues/28)),
and every Cmd+key combo already belongs to macOS. So Super is a key Karabiner
turns into Ctrl+Option, and every AeroSpace bind is `ctrl-alt-...`.

| Keyboard | Super, held | Super, tapped alone | Also |
|---|---|---|---|
| AULA F75 on its 2.4G dongle (vendor 13652, product 64009) | Win key | Raycast (Cmd+Space) | its Alt key becomes Command |
| MacBook built-in | left Option | Raycast (Cmd+Space) | right Option stays Option |

That puts Super second from the spacebar on every keyboard, where Super sits on
Linux, and Command next to the spacebar, where it sits on any Mac.

The AULA stays in **Windows mode** (Fn+W) because it is also wired to the
Windows/CachyOS PC. Karabiner does the Mac-side swap in software, for that device
only. Mac mode (Fn+E) would swap Win and Alt in hardware instead; hold Fn to see
which mode key is lit.

Adding another keyboard: Karabiner-EventViewer, Devices tab, gives its vendor and
product ids. Add them to the AULA rule's `identifiers` for a PC-layout board, or
to the built-in rule for a Mac-layout one.

Super already contains Ctrl, so the Linux chord Ctrl+Super+Shift+arrows lands on
the same bind as Super+Shift+arrows.

## Binds

| Keys | Action |
|---|---|
| Super+T | new kitty window |
| Super+Q | close window |
| Super+F | fullscreen (AeroSpace's, keeps the bar) |
| Super+W | float toggle |
| Super+J | flip the split direction |
| Super+arrows | focus |
| Super+Shift+arrows | move window |
| Super+Minus, Super+Equal | resize |
| Super+1…0 | workspace 1-10 |
| Super+Shift+1…0 | send the window there and follow it |
| Super+Shift+S | snip to the clipboard |
| Super+Shift+Cmd+S | snip to the Desktop, open it in Preview |
| tap Super | Raycast |

Full-screen screenshots stay macOS's own Cmd+Shift+3. Cmd+H and Cmd+Option+H are
disabled: hidden apps' windows drop out of tiling (AeroSpace goodies).

## Things to know

- **Gaps and the bar are coupled.** `gaps.outer.top` is the bar's `y_offset` 4 +
  `height` 36 + the 4 px gap = 44, and 12 on the built-in panel, whose usable area
  already starts 32 px down. Change the bar and the gap together.
- **New windows open in a row, not a spiral.** AeroSpace inserts i3-style, next to
  the focused window; upstream has no Hyprland-style dwindle layout. Super+J
  flips a row into a column.
- **The bar follows AeroSpace, not macOS Spaces.** `exec-on-workspace-change` and
  `on-focus-changed` fire `aerospace_workspace_change` and
  `aerospace_focus_change`. `plugins/spaces.sh` repaints every workspace in one
  call, 80 ms after the last event, and hides workspaces with no windows unless
  focused. App icons come from `aerospace list-windows`, because SketchyBar's own
  window tracking misses kitty and Ghostty on macOS 26.
- **Super+T needs kitty's remote control** (`allow_remote_control` and
  `listen_on` in `shared/kitty/kitty.conf`). Without a running kitty it launches one.
- **The macOS menu bar is hidden, not gone.** Wifi, volume and battery are in it at
  the top edge. macOS's volume overlay stays on, since the bar has no volume item.
- **Keep "Displays have separate Spaces" on.** SketchyBar needs it.
- **Karabiner rewrites `karabiner.json`** when you change anything in its window,
  so `./status.sh` may report drift. Copy it back.
- `plugins/icon_map.sh` is generated from `sketchybar-app-font`. Regenerate it
  from upstream if the font version changes; don't hand-edit it.

## Verify

```bash
aerospace list-workspaces --all            # 1 … 10
brew services list | grep sketchybar       # started
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --show-current-profile-name
./status.sh                                # aerospace, sketchybar, karabiner: ok
```

By hand: hold Super and press T for a kitty window, tap Super for Raycast, and
Cmd+F in a browser should still find.
