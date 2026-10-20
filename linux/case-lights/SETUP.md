# case-lights

CPU and RAM usage as floating levels on the RAM sticks. Each stick is white,
filled from the bottom with the wallpaper's accent colour: the stick nearer
the CPU shows CPU usage, the other one RAM usage. The level glides to new
values and its surface bobs a little.

## Files

| Repo | Destination |
|---|---|
| [`case-lights`](case-lights) | `~/.local/bin/case-lights` |
| [`case-lights.service`](case-lights.service) | `~/.config/systemd/user/case-lights.service` |

It needs two files from other packages: OpenRGB's server service
([`linux/openrgb`](../openrgb/SETUP.md)) and the `rgb-accent.txt` colour
template ([`linux/noctalia`](../noctalia/SETUP.md)).

## Install

1. Install the OpenRGB SDK library for Python. It is in the AUR:

   ```bash
   paru -S python-openrgb
   ```

2. Set up [`linux/openrgb`](../openrgb/SETUP.md), including its server
   service, and [`linux/noctalia`](../noctalia/SETUP.md).

3. Copy the files, then start the service. It starts after OpenRGB's server,
   with the graphical session:

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now case-lights.service
   ```

## Notes

### Sticks and LEDs

The script takes the two devices whose name contains "Vengeance" (Corsair
Vengeance RGB Pro SL, 10 LEDs each), ordered by OpenRGB's device number.
Device 0 is the stick nearer the CPU, and LED 1 is at the top. Other RAM
needs its name, its LED count (`LEDS`) or the order changed in the script.

### Colour

Noctalia's accent colours are soft pastels, which LEDs show as near-white.
The script keeps the accent's hue and sets its saturation to 90%
(`SATURATION`). It reads `~/.config/case-lights/accent` every second, so a
new wallpaper reaches the RAM within a second.

### Movement and cost

The script draws 25 frames a second. Each frame closes 6% of the gap to the
new value (`EASE`), and the surface bobs by a quarter of an LED (`BOB`).
CPU usage is sampled every 0.24 s, RAM usage every second. The script uses
under 1% of one CPU core and OpenRGB's server about 1%.

If OpenRGB's server is not up yet, or restarts, the script logs the error
and tries again every 3 seconds.

## Verify

```bash
systemctl --user is-active openrgb-server.service case-lights.service   # active, active
journalctl --user -u case-lights -n 5 --no-pager                          # no error after "Started"
cat ~/.config/case-lights/accent                                          # a hex colour
```
