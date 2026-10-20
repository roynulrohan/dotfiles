# OpenRGB

RGB control for the RAM, the graphics card, keyboards, controllers and
network lights, in one app. Its config here keeps it away from the Corsair
Commander hubs and the H100i RGB PRO XT cooler, which
[`linux/openlinkhub`](../openlinkhub/SETUP.md) controls.

## Files

| Repo | Destination |
|---|---|
| [`OpenRGB.json`](OpenRGB.json) | `~/.config/OpenRGB/OpenRGB.json` |

`OpenRGB.json` is a seed: it holds only the detector switches. OpenRGB adds
every other setting to the file at its first start and keeps the switches.

## Install

1. Install the package from the CachyOS repo or Arch's `extra` repo. It
   ships `udev` rules that give the logged-in user access to RGB devices. The
   trigger applies them to devices that are already plugged in:

   ```bash
   sudo pacman -S openrgb
   sudo udevadm control --reload-rules && sudo udevadm trigger --action=add --settle
   ```

2. Copy `OpenRGB.json` **before the first start** of OpenRGB, so detection
   never touches a Corsair hub or cooler.

## Notes

### Corsair hubs and coolers stay with OpenLinkHub

OpenRGB has drivers for Corsair Commander Core hubs and Hydro AIO coolers.
Two programs that talk to one device at the same time fight over it, and fan
or pump control can break. `OpenRGB.json` turns off these detectors:
"Corsair Commander Core", "Corsair Commander Core XT", "Corsair Hydro H100i
Pro XT" and "Corsair Hydro H100i Pro XT v2". OpenLinkHub sets the colours of
these devices and of the fans on them.

### MSI Mystic Light firmware

OpenRGB reads the firmware version of an MSI board's lighting chip and skips
the board if the version is too old. The MPG B550 Gaming Plus needs version
0.6 or newer. Below that, OpenRGB can't control the ARGB headers on the board,
and its log in `~/.config/OpenRGB/logs/` shows:

```text
[MSIMotherboard185] Controller firmware below minimum supported version, skipping
```

Colours set earlier stay stored on the chip.

The lighting chip has its own firmware. A BIOS update does not change it.
Only MSI Center on Windows updates it
([MSI's guide](https://download-2.msi.com/archive/mnu_exe/mb/MSI-Center-Update-LED-Firmware.pdf)).

Source: [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB).

## Verify

```bash
openrgb --list-devices | grep -E '^[0-9]+: '            # the RGB devices found
openrgb --list-devices | grep -i -E 'commander|hydro'   # nothing
grep -E '"Corsair (Commander Core|Hydro H100i Pro XT)' ~/.config/OpenRGB/OpenRGB.json   # all four false
```
