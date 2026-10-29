# Gaming PC

Commit tag `cachy-os`. It sits at the [desk](desk.md) and dual boots CachyOS
and Windows 11.

## Hardware

| Part | Model |
|---|---|
| CPU | AMD Ryzen 7 5800X |
| GPU | Gigabyte GeForce RTX 5070 Aero OC, 12 GB |
| RAM | 32 GB DDR4, 2× Corsair Vengeance RGB Pro SL |
| Motherboard | MSI MPG B550 Gaming Plus |
| CPU cooler | Corsair iCUE H100i RGB PRO XT, 240 mm AIO, on top in push-pull |
| Case | NZXT H6 Flow |
| Fan hub | Corsair iCUE Commander Core XT, with a third-party temperature probe |
| Mice | Logitech MX Master 3S (Bolt receiver), Logitech G502 X LIGHTSPEED and G Pro X Superlight (Lightspeed receivers) |
| Storage | Crucial P1 500 GB NVMe (CachyOS), Samsung 970 EVO Plus 1 TB NVMe (Windows 11), Seagate 2 TB HDD (shared by both) |

### Fans

[`linux/openlinkhub`](../../linux/openlinkhub/SETUP.md) has the curves and
the reason for the positive pressure.

| Place | Fans | Rated | Connected to | Curve |
|---|---|---|---|---|
| Radiator, above it (pull) | 3× Thermalright TL-M12QW-S, daisy-chained | 2000 RPM, 68.9 CFM | hub channel 4 (Fan 5) | `CoolantScriptCurve` |
| Radiator, below it (push) | the 2 fans from the earlier Thermalright Peerless Assassin cooler | | the H100i's fan splitter (Fan 1, Fan 2) | `CoolantCurve` |
| Rear exhaust | Corsair iCUE AR120 Digital RGB | 59 CFM | hub channel 0 (Fan 1) | `CaseRearCurve` |
| Bottom intakes, blowing onto the GPU | 2× Corsair RS140 ARGB | 95.5 CFM | hub channels 1, 2 (Fans 2, 3) | `CaseIntakeCurve` |
| Front intakes | 3× Thermalright TL-M12QRW-S (reverse), daisy-chained | 1500 RPM, 47.6 CFM | hub channel 3 (Fan 4) | `CaseFrontCurve` |
| Pump | the H100i | | USB and SATA power; its speed lead on CPU_FAN | Normal mode |

A daisy-chained set gives one RPM reading. When OpenLinkHub is not running,
the hub uses the curve that iCUE stored on it, which reads the temperature
probe: 30% up to 32 °C, 40% at 36 °C, 60% at 40 °C and 100% at 45 °C.

### Lighting

| Device | Lighting | Set by |
|---|---|---|
| Rear AR120 | green `#14C846`, full brightness (static) | OpenLinkHub |
| H100i pump | coolant thermometer: green to 35 °C, amber at 38 °C, red at 41 °C | OpenLinkHub ([`linux/openlinkhub`](../../linux/openlinkhub/SETUP.md)) |
| RAM | CPU and RAM usage as levels in the wallpaper accent | [`linux/case-lights`](../../linux/case-lights/SETUP.md) |
| Other fans | white, stored on the board's lighting chip | the motherboard's two JRAINBOW headers: one feeds a Thermalright ARGB hub, the other the bottom RS140s |

OpenRGB can't control the board's lighting chip yet
([`linux/openrgb`](../../linux/openrgb/SETUP.md)).

## BIOS

A CMOS clear or a BIOS update resets these settings. Set them again after
either.

| Setting | Value |
|---|---|
| A-XMP | On. The RAM runs at 3600 MT/s. |
| PBO | Auto, with no Curve Optimizer and no boost override. Tuning them gave no clear gain. |
| CPU_FAN | Carries only the pump's speed lead. Its fan curve controls nothing. |
| Boot order | "UEFI OS", then Windows |

"UEFI OS" is Limine, started from the fallback path `\EFI\BOOT\BOOTX64.EFI`
on the Crucial NVMe. A "Limine" entry also exists, after Windows.

## Packages

In this order. Each package's `SETUP.md` has the steps and a Verify section.

1. Base: CachyOS with its KDE Plasma desktop, which stays as the fallback
   ([`personal/preferences.md`](../preferences.md)). Then
   [`linux/packages.md`](../../linux/packages.md).
2. Shell and git: [`shared/fish`](../../shared/fish/SETUP.md),
   [`linux/fish`](../../linux/fish/SETUP.md), [`shared/git`](../../shared/git/SETUP.md).
3. Terminal: [`shared/kitty`](../../shared/kitty/SETUP.md).
4. Prompt and the fastfetch greeting: [`shared/starship`](../../shared/starship/SETUP.md),
   [`shared/fastfetch`](../../shared/fastfetch/SETUP.md).
5. Coding agents: [`shared/agents`](../../shared/agents/SETUP.md),
   [`shared/claude`](../../shared/claude/SETUP.md),
   [`shared/ccstatusline`](../../shared/ccstatusline/SETUP.md). They come early
   because the agents do the rest of the setup.
6. Desktop: [`linux/hypr`](../../linux/hypr/SETUP.md) with
   [`linux/uwsm`](../../linux/uwsm/SETUP.md), [`linux/hyprmod`](../../linux/hyprmod/SETUP.md),
   [`linux/noctalia`](../../linux/noctalia/SETUP.md), [`linux/sddm`](../../linux/sddm/SETUP.md),
   [`linux/wallpaper`](../../linux/wallpaper/SETUP.md). Then log out and back in.
7. The rest: [`linux/pipewire`](../../linux/pipewire/SETUP.md),
   [`linux/openlinkhub`](../../linux/openlinkhub/SETUP.md),
   [`linux/openrgb`](../../linux/openrgb/SETUP.md),
   [`linux/case-lights`](../../linux/case-lights/SETUP.md),
   [`linux/solaar`](../../linux/solaar/SETUP.md), [`linux/mpv`](../../linux/mpv/SETUP.md),
   [`linux/btop`](../../linux/btop/SETUP.md), [`linux/equibop`](../../linux/equibop/SETUP.md),
   [`linux/ssh`](../../linux/ssh/SETUP.md), [`linux/snapshots`](../../linux/snapshots/SETUP.md),
   [`shared/nvim`](../../shared/nvim/SETUP.md), [`shared/vscode`](../../shared/vscode/SETUP.md),
   [`shared/orca`](../../shared/orca/SETUP.md).

Not on this machine: Cursor and Ghostty.

## Outside the repo

- [ ] Sign in: `gh auth login` with a new SSH key, and register the key for
      commit signing. Then sign in to Claude Code and Orca.
- [ ] Set the power profile to performance: `powerprofilesctl set performance`.
      I prefer it to `balanced`.
- [ ] Set the BIOS settings in [BIOS](#bios).
- [ ] Set every mouse to 1600 DPI: `solaar config "MX Master 3S" dpi 1600`
      ([`linux/solaar`](../../linux/solaar/SETUP.md)). The G502 X and the
      Superlight keep 1600 in their onboard profiles.

## Things to know

- Windows 11 is on the Samsung NVMe. Never write to it.
- The 2 TB HDD is shared with Windows and mounted at `/mnt/storage`. Steam's
  game library is on it.
