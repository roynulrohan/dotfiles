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
| CPU cooler | Thermalright Peerless Assassin |
| Case | NZXT H6 Flow |
| Fan hub | Corsair iCUE Commander Core XT, with a third-party temperature probe |
| Case fans | rear: Corsair iCUE AR120 Digital RGB (59 CFM); bottom: 2× Corsair RS140 ARGB (95.5 CFM); front: 3× Thermalright TL-M12QRW-S, reverse (1500 RPM, 47.6 CFM); top: 3× Thermalright TL-M12QW-S (2000 RPM, 68.9 CFM) |
| RGB | 2× Corsair Vengeance RGB Pro SL, Gigabyte RTX 5070 Aero OC, AULA F75 keyboard; a Thermalright ARGB hub |
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
   [`linux/pipewire`](../../linux/pipewire/SETUP.md),
   [`linux/openlinkhub`](../../linux/openlinkhub/SETUP.md),
   [`linux/openrgb`](../../linux/openrgb/SETUP.md), [`linux/mpv`](../../linux/mpv/SETUP.md),
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
- [ ] Set the power profile to performance: `powerprofilesctl set performance`.
      `balanced` runs about 6 °C cooler at light desktop load at the same
      full-load speed; I prefer performance anyway.
- [ ] BIOS: A-XMP on (RAM at 3600), PBO Curve Optimizer all cores −20, CPU fan
      curve 30% to 40 °C, 45% at 60, 70% at 70, 100% at 80, boot order Limine
      first. A CMOS clear or a BIOS update resets all of it.

## Things to know

- Windows 11 lives on the Samsung NVMe. Never write to it.
- The 2 TB HDD is shared with Windows and mounted at `/mnt/storage`. Steam's
  game library lives there.
- Fans on the Commander Core XT, with their curves from
  [`linux/openlinkhub`](../../linux/openlinkhub/SETUP.md):

  | Channel | Fans | Curve |
  |---|---|---|
  | 0 (Fan 1) | rear exhaust (AR120), behind the CPU cooler | `CpuCurve` |
  | 1, 2 (Fans 2, 3) | bottom intakes (RS140), blowing onto the GPU | `IntakeCurve` |
  | 3 (Fan 4) | front intakes (3× TL-M12QRW-S), daisy-chained; one RPM reading | `SystemCurve` |
  | 4 (Fan 5) | top exhausts (3× TL-M12QW-S), daisy-chained; one RPM reading | `ExhaustCurve` |

  The case runs at positive pressure: about 175 CFM in against 105 out at
  desktop load, and 330 against 195 under full CPU load (estimates from rated
  airflow). The temperature probe sits in the CPU cooler's exhaust. The hub's
  stored curve from iCUE uses it when OpenLinkHub isn't running: 30% to 32 °C,
  40% at 36, 60% at 40, 100% at 45. Only the two CPU cooler fans are on a
  motherboard header, under the BIOS fan curve.
- RGB: the rear AR120 gets its colour from OpenLinkHub. All other fans take
  ARGB from the motherboard: the Thermalright hub on one JRAINBOW header, the
  bottom RS140s on the other. They are white, stored on the board's lighting
  chip. OpenRGB can't control them: the chip runs firmware 0.2 and OpenRGB
  needs 0.6 for this board ([`linux/openrgb`](../../linux/openrgb/SETUP.md)).
- Spare live wallpapers, kept as local copies next to the ones in use:
  `ayanami-rei-minimal` and `3314492008`.
