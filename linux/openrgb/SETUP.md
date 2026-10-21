# OpenRGB

RGB control for the RAM, the graphics card and network lights, in one app. Its config here keeps it away from the Corsair Commander hubs and
the H100i RGB PRO XT cooler, which
[`linux/openlinkhub`](../openlinkhub/SETUP.md) controls, and away from the
keyboard and the DualSense controller, which run their own lighting.

## Files

| Repo | Destination |
|---|---|
| [`OpenRGB.json`](OpenRGB.json) | `~/.config/OpenRGB/OpenRGB.json` |
| [`openrgb-server.service`](openrgb-server.service) | `~/.config/systemd/user/openrgb-server.service` |

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
   never touches a Corsair hub, the cooler, the keyboard or the DualSense.

3. Copy the service, then start it. It runs OpenRGB's SDK server without a
   window, for scripts such as [`linux/case-lights`](../case-lights/SETUP.md):

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now openrgb-server.service
   ```

   While the server runs, `openrgb` connects to it and doesn't scan the
   hardware itself. Don't start it with `--noautoconnect`: it then scans as
   well, reads the devices at the same time as the server, and logs errors
   such as `Corsair DRAM ReadDeviceInfo CRC Mismatch`.

## Notes

### Corsair hubs and coolers stay with OpenLinkHub

OpenRGB has drivers for Corsair Commander Core hubs and Hydro AIO coolers.
Two programs that talk to one device at the same time fight over it, and fan
or pump control can break. `OpenRGB.json` turns off these detectors:
"Corsair Commander Core", "Corsair Commander Core XT", "Corsair Hydro H100i
Pro XT" and "Corsair Hydro H100i Pro XT v2". OpenLinkHub sets the colours of
these devices and of the fans on them.

### The keyboard and the DualSense keep their own lighting

OpenRGB's Sinowealth driver matches the keyboard (USB `258a:010c`, shown as
"AULA F75"). That driver has only two modes, Off and Direct, no hardware
effects. On detection it switches the keyboard to Direct, which stops the
firmware's own effects, and nothing sends colours, so every key goes dark.
`OpenRGB.json` turns off the "Sinowealth Keyboard" detector, so the firmware
stays in charge and the keyboard's own effects and shortcuts work.

The DualSense gets the same treatment: OpenRGB held its lightbar in Direct
mode at black. With the "Sony DualSense" detector off, the controller's
firmware and the game set the lightbar.

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
systemctl --user is-active openrgb-server.service      # active
ss -ltn | grep ':6742 '                                 # the SDK server listens
openrgb --list-devices | grep -E '^[0-9]+: '              # each RGB device once
openrgb --list-devices | grep -i -E 'commander|hydro'     # nothing
grep -E '"Corsair (Commander Core|Hydro H100i Pro XT)' ~/.config/OpenRGB/OpenRGB.json   # all four false
grep -E '"(Sinowealth Keyboard|Sony DualSense)"' ~/.config/OpenRGB/OpenRGB.json   # both false
openrgb --list-devices | grep -iE 'aula|dualsense'            # nothing
```
