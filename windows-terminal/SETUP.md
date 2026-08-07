# windows-terminal

The terminal for WSL. Stands in for `ghostty`/`kitty`, which can't run inside a
WSL distro.

## ⚠️ Not captured yet

There is no `settings.json` in this package. It lives on a Windows host and
couldn't be read from the machine this repo was built on.

**To capture it**, from a WSL shell:

```bash
WT="/mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
cp "$WT" ~/dotfiles/windows-terminal/settings.json
```

That path is for the Microsoft Store install. An unpackaged or Preview install
puts it at `…/AppData/Local/Microsoft/Windows Terminal/settings.json` instead —
check both.

Once it's committed, delete this section and fill in the table below.

## Files

| Repo | Destination (Windows) |
|---|---|
| `settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |

**Copy, don't symlink.** A symlink created from inside WSL isn't reliably
followed by a Windows process, and Windows Terminal rewrites this file whenever
settings change in the UI — it would detach immediately. Copy it in, and copy it
back out when you change something worth keeping.

Back up the existing file before overwriting. It contains machine-specific GUIDs
for installed profiles that won't match another machine.

## What matters in it

Three things carry the look; the rest is per-machine noise.

- **`font.face`** — must be `"JetBrainsMono Nerd Font"` or the p10k prompt,
  eza icons, and the ccstatusline segments all render as tofu boxes. The font
  must be installed **on Windows**, not in WSL — see `../shell/SETUP.md`.
- **`defaultProfile`** — point it at the WSL distro's GUID, not PowerShell,
  or you'll land in the wrong shell every time.
- **The WSL profile's `commandline`** — should launch the distro directly
  (`wsl.exe -d Ubuntu`). If it invokes `bash`, none of the zsh config loads and
  the machine looks completely unconfigured despite a correct setup.

Profile GUIDs are generated per machine. When transplanting this file, merge the
appearance settings into the existing profiles rather than replacing the whole
file, or Windows Terminal will show profiles that don't exist.

## Verify

Open a WSL tab. The p10k prompt should render with glyphs, `ls` should show
icons, and `echo $SHELL` should report zsh. Tofu means the Nerd Font isn't
installed on Windows or isn't selected in the profile.
