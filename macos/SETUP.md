# macos

Tiling window manager and status bar. **macOS only — skip this package entirely
on Linux.** There's no port; the equivalent would be i3/sway plus waybar or
polybar, which is a rewrite, not a translation.

## Files

| Repo | Destination |
|---|---|
| `yabai/yabairc` | `~/.config/yabai/yabairc` (must be `chmod +x`) |
| `yabai/create_spaces.sh` | `~/.config/yabai/create_spaces.sh` (`chmod +x`) |
| `sketchybar/` | `~/.config/sketchybar/` — all 20 files, scripts `chmod +x` |
| `borders/bordersrc` | `~/.config/borders/bordersrc` (`chmod +x`) |
| `linearmouse/linearmouse.json` | `~/.config/linearmouse/linearmouse.json` |

Symlink the directories rather than the individual files —
`ln -sfn ~/dotfiles/macos/sketchybar ~/.config/sketchybar`. sketchybar's
`sketchybarrc` sources `colors.sh`, `icons.sh`, and everything under `items/`
and `plugins/` by relative path, so the tree has to stay intact.

Execute bits do not survive a plain `cp`. After placing, run:

```bash
chmod +x ~/.config/yabai/* ~/.config/borders/bordersrc
find ~/.config/sketchybar -name '*.sh' -exec chmod +x {} +
```

## Install

```bash
brew install koekeishiya/formulae/yabai
brew install FelixKratz/formulae/sketchybar
brew install FelixKratz/formulae/borders
brew install --cask linearmouse
brew install --cask font-sketchybar-app-font   # sketchybar's app glyphs
```

Then start them: `yabai --start-service`, `brew services start sketchybar`,
`brew services start borders`.

## Gotchas

**yabai needs SIP partially disabled** for its scripting addition (space
manipulation, window opacity). Without it yabai runs but `create_spaces.sh` and
some layout features silently do nothing. Disabling SIP requires booting into
Recovery — it is not something to do unprompted. Ask first.

yabai also prompts for Accessibility permission on first launch; it won't manage
anything until that's granted in System Settings → Privacy & Security.

**`sketchybar/plugins/icon_map.sh` is generated**, not hand-written — it maps app
names to glyphs from the sketchybar-app-font. If the font version changes,
regenerate it from upstream rather than editing it.

**`plugins/yabai.sh` couples the two** — sketchybar's space indicators are driven
by yabai events. Installing sketchybar without yabai leaves those segments dead.

## Verify

```bash
yabai -m query --spaces | jq length     # non-zero
brew services list | grep -E 'sketchybar|borders'
```

Visually: windows tile automatically, status bar on top, coloured border on the
focused window.
