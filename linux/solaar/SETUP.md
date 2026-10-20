# Solaar

Settings for Logitech mice on Bolt, Unifying and Lightspeed receivers: DPI,
SmartShift, button remaps and gestures. It runs in the tray from login and
applies the saved settings each time a mouse connects.

## Files

| Repo | Destination |
|---|---|
| [`solaar.desktop`](solaar.desktop) | `~/.config/autostart/solaar.desktop` |

Outside the repo: Solaar's settings, in `~/.config/solaar/config.yaml`. The
file holds each device's serial number, so it stays out of this public repo.
Set the values again on a new machine (Install, step 3).

## Install

1. Install the package from Arch's `extra` repo. Its `udev` rules give the
   logged-in user access to the receivers. The trigger applies them to
   receivers that are already plugged in:

   ```bash
   sudo pacman -S solaar
   sudo udevadm control --reload-rules && sudo udevadm trigger --action=add --settle
   ```

2. Copy the autostart entry. The package ships none. The session starts the
   entry at each login (uwsm runs XDG autostart entries). To start it now:

   ```bash
   systemctl --user daemon-reload
   systemctl --user start app-solaar@autostart.service
   ```

3. Set each mouse's values, in the window from the tray icon or with
   `solaar config`. A mouse must be on and connected:

   ```bash
   solaar config "MX Master 3S" dpi 1600
   ```

## Notes

A mouse with onboard profiles, such as a G502 X, keeps its DPI and report
rate in its own memory. Solaar shows them, and changing them can need
`onboard_profiles` set to `Disable` first.

## Verify

```bash
systemctl --user is-active app-solaar@autostart.service   # active
solaar config "MX Master 3S" dpi                          # dpi = 1600
```
