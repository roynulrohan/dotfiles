# Gaming PC

Commit tag `cachy-os`. It sits at the [desk](desk.md) and dual boots CachyOS
and Windows 11.

## Hardware

| Part | Model |
|---|---|
| CPU | AMD Ryzen 7 5800X |
| GPU | NVIDIA GeForce RTX 5070, 12 GB |
| RAM | 32 GB DDR4 |
| Motherboard | MSI MPG B550 Gaming Plus |
| Storage | Crucial P1 500 GB NVMe (CachyOS), Samsung 970 EVO Plus 1 TB NVMe (Windows 11), Seagate 2 TB HDD (shared by both) |

## Packages

In this order. Each package's `SETUP.md` has the steps and a Verify section.

1. Base: CachyOS, then [`linux/packages.md`](../../linux/packages.md).
2. Shell and git: [`shared/fish`](../../shared/fish/SETUP.md),
   [`linux/fish`](../../linux/fish/SETUP.md), [`shared/git`](../../shared/git/SETUP.md).
3. Terminal: [`shared/kitty`](../../shared/kitty/SETUP.md).
4. Prompt and greeting: [`shared/starship`](../../shared/starship/SETUP.md),
   [`shared/fastfetch`](../../shared/fastfetch/SETUP.md).
5. Coding agents: [`shared/agents`](../../shared/agents/SETUP.md),
   [`shared/claude`](../../shared/claude/SETUP.md),
   [`shared/ccstatusline`](../../shared/ccstatusline/SETUP.md). They come early
   because the agents do the rest of the setup.
6. Desktop: [`linux/hypr`](../../linux/hypr/SETUP.md) with
   [`linux/uwsm`](../../linux/uwsm/SETUP.md), [`linux/hyprmod`](../../linux/hyprmod/SETUP.md),
   [`linux/noctalia`](../../linux/noctalia/SETUP.md), [`linux/sddm`](../../linux/sddm/SETUP.md),
   [`linux/wallpaper`](../../linux/wallpaper/SETUP.md). Then log out and back in.
7. The rest: [`linux/hyprsunset`](../../linux/hyprsunset/SETUP.md),
   [`linux/pipewire`](../../linux/pipewire/SETUP.md), [`linux/mpv`](../../linux/mpv/SETUP.md),
   [`linux/btop`](../../linux/btop/SETUP.md), [`linux/equibop`](../../linux/equibop/SETUP.md),
   [`linux/ssh`](../../linux/ssh/SETUP.md), [`linux/snapshots`](../../linux/snapshots/SETUP.md),
   [`shared/nvim`](../../shared/nvim/SETUP.md), [`shared/vscode`](../../shared/vscode/SETUP.md),
   [`shared/orca`](../../shared/orca/SETUP.md).

Not on this machine: Cursor and Ghostty.

## My extras

- [ ] Sign in: `gh auth login` with a new SSH key, register the key for commit
      signing, then Claude Code and Orca.
- [ ] Restore my media from backup: wallpaper stills to `~/Pictures/Wallpapers`,
      the main wallpaper's still and `login.mp4` to `~/Pictures/Wallpapers/live`,
      lock-screen GIFs to `~/Pictures/lock-gifs`, `~/.face`, and the greeting's
      logo images to `~/.config/fastfetch/logo/`.
- [ ] Subscribe to my Workshop wallpapers in Wallpaper Engine, then make the
      local copies ([`linux/wallpaper`](../../linux/wallpaper/SETUP.md)).
- [ ] Answer the SSH key's passphrase dialog once and tick "Remember password".

## Things to know

- Windows 11 lives on the Samsung NVMe. Never write to it.
- The 2 TB HDD is shared with Windows and mounted at `/mnt/storage`. Steam's
  game library lives there.
