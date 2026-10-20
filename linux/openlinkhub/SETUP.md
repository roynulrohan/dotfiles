# OpenLinkHub

Fan control for Corsair hubs and AIO coolers, such as the iCUE Commander
Core XT and the iCUE H100i RGB PRO XT, without iCUE. It runs as a system
service with a web UI at `http://127.0.0.1:27003`. The fans follow the
coolant and GPU temperatures, not the CPU temperature or the hub's probe.

## Files

| Repo | Destination |
|---|---|
| [`temperatures/CoolantCurve.json`](temperatures/CoolantCurve.json) | `/var/lib/openlinkhub/database/temperatures/CoolantCurve.json` |
| [`temperatures/CoolantScriptCurve.json`](temperatures/CoolantScriptCurve.json) | `/var/lib/openlinkhub/database/temperatures/CoolantScriptCurve.json` |
| [`temperatures/CaseRearCurve.json`](temperatures/CaseRearCurve.json) | `/var/lib/openlinkhub/database/temperatures/CaseRearCurve.json` |
| [`temperatures/CaseIntakeCurve.json`](temperatures/CaseIntakeCurve.json) | `/var/lib/openlinkhub/database/temperatures/CaseIntakeCurve.json` |
| [`temperatures/CaseFrontCurve.json`](temperatures/CaseFrontCurve.json) | `/var/lib/openlinkhub/database/temperatures/CaseFrontCurve.json` |
| [`olh-coolant-temp`](olh-coolant-temp) | `/usr/local/bin/olh-coolant-temp` |
| [`olh-case-heat`](olh-case-heat) | `/usr/local/bin/olh-case-heat` |
| [`openlinkhub-reenable.hook`](openlinkhub-reenable.hook) | `/etc/pacman.d/hooks/openlinkhub-reenable.hook` |
| [`openlinkhub.desktop`](openlinkhub.desktop) | `~/.local/share/applications/openlinkhub.desktop` |

Outside the repo: which curve each fan uses, and the pump mode. OpenLinkHub
keeps them in a profile per device (Install, step 4).

## Install

1. Install the package. It is in the CachyOS repo. On plain Arch, it comes
   from the AUR (`paru -S openlinkhub`).

   ```bash
   sudo pacman -S openlinkhub
   ```

2. Give the service access to the devices, then start it. The package's
   `udev` rule makes the `openlinkhub` user the owner of the devices. On the
   first install, `udev` can load that rule before the package creates the
   user, and then it drops the owner. Restarting `udev` reads the rule again:

   ```bash
   sudo systemctl restart systemd-udevd
   sudo udevadm trigger --action=add --subsystem-match=hidraw --settle
   sudo systemctl enable --now openlinkhub
   ```

3. Copy the hook and the launcher entry. Install the two scripts, then copy
   the curves as the service's user. Restart the service so it loads them:

   ```bash
   sudo install -m755 olh-coolant-temp olh-case-heat /usr/local/bin/
   sudo install -o openlinkhub -g openlinkhub -m644 temperatures/*.json /var/lib/openlinkhub/database/temperatures/
   sudo systemctl restart openlinkhub
   ```

4. Give each fan channel a curve, in the web UI or through the API. Each
   device's key is in `curl -sL 127.0.0.1:27003/api/devices/`: the hub's
   serial, or a number for the AIO. Set the pump's mode the same way, with a
   profile named `Quiet`, `Normal` or `Performance` (Notes, "Pump"):

   ```bash
   curl -s -X POST 127.0.0.1:27003/api/speed -H 'Content-Type: application/json' \
     -d '{"deviceId":"<key>","channelId":0,"profile":"CaseRearCurve"}'
   ```

   Assign one channel per request on the AIO. A list of channels in one
   request fails there. Which curve fits which fan depends on the wiring
   (Notes, "Curves").

## Notes

### Curves

Each curve is a set of points (temperature → fan %), with straight lines
between them. OpenLinkHub reads the sensors every 3 seconds.

| Curve | Sensor | Points |
|---|---|---|
| `CoolantCurve` | the AIO's coolant (Liquid) | 40% to 32 °C, 34: 48, 36: 60, 38: 78, 40: 95, 41: 100 |
| `CoolantScriptCurve` | `olh-coolant-temp` (External Executable) | the same as `CoolantCurve` |
| `CaseRearCurve` | `olh-case-heat` (External Executable) | 30% to 55, 60: 45, 66: 65, 72: 85, 76: 100 |
| `CaseIntakeCurve` | `olh-case-heat` | 40% to 55, 60: 52, 66: 70, 72: 88, 76: 100 |
| `CaseFrontCurve` | `olh-case-heat` | 32% to 55, 60: 45, 66: 62, 72: 82, 76: 100 |

- `CoolantCurve` is for the radiator fans that the AIO drives itself.
- `CoolantScriptCurve` is for radiator fans on the hub.
- `CaseRearCurve` is for the rear exhaust.
- `CaseIntakeCurve` is for strong intakes, such as 140 mm fans under the
  graphics card.
- `CaseFrontCurve` is for the other intakes.

No fan follows the CPU temperature. A Ryzen CPU's Tctl jumps by 10 °C or
more within a second when an app starts, so CPU curves make the fans rise
and fall all day. The coolant warms only with heat that stays: two minutes
of full CPU load raise it by less than 1 °C.

### The two scripts

The hub's driver refuses Liquid curves, because the hub has no pump of its
own. `olh-coolant-temp` works around that. It reads the AIO's coolant
temperature from the OpenLinkHub API and prints it, so a curve on the hub
can follow it.

`olh-case-heat` prints the GPU temperature or the coolant temperature on a
GPU scale, whichever is higher. On that scale, 31 °C coolant counts as 45
and 40 °C as 75. The case fans then follow GPU heat while gaming and
lasting CPU heat during long work, but not short CPU spikes.

- Both scripts read the AIO under the key `3117`, the iCUE H100i RGB PRO
  XT. For another AIO, change the key in both.
- `olh-case-heat` reads the GPU through `nvidia-smi`, so it needs an NVIDIA
  GPU.
- On any error, `olh-coolant-temp` prints 50 and `olh-case-heat` prints 80.
  The fans then run fast instead of slow.
- The service runs as the `openlinkhub` user, which can't run files in a
  home folder. Keep the scripts in `/usr/local/bin`, in a path without
  spaces.

### Positive pressure

The curves keep more air coming in than going out, so the case stays at
positive pressure. Air then leaves through every unfiltered gap instead of
pulling dust in, and all incoming air passes the intake filters. Three rules
do this:

- **The intakes and the rear exhaust follow one signal,** `olh-case-heat`,
  so they rise together.
- **The intakes have the higher floors** (40% and 32% against the rear's
  30%), and the bigger fans.
- **The radiator slows the top fans.** They move clearly less air than
  their rating.

Airflow scales roughly with fan speed, so the balance can be estimated from
each fan's rated airflow and its speed as a share of its maximum. To check
it, hold a tissue near a gap in the case, such as the slot covers: it must
blow outwards.

### Pump

The iCUE H100i RGB PRO XT's pump has three fixed modes: Quiet, Normal and
Performance. OpenLinkHub picks the mode by the name of the profile on the
pump channel. Use Normal. Quiet lowers the coolant flow, so the CPU runs
about 2 °C hotter and the radiator fans spin faster. Performance gains
nothing over Normal.

### Why not the temperature probe

The hub keeps its own fan curves in its memory (iCUE's device memory mode). It
runs them when no software controls it. Those curves can only use the hub's
own temperature probes. A probe measures air, which warms much more slowly
than the CPU. So a probe curve can't react to load.

When the OpenLinkHub service stops, the hub goes back to its stored curves.
They also run in the BIOS and during boot. OpenLinkHub can switch between
the stored curves and its own, but it can't write the stored curves. Only
iCUE's device memory mode can, on Windows. Store a calm curve there,
because a probe curve that ramps near the probe's idle temperature makes
the fans loud whenever OpenLinkHub isn't running.

### Upgrade hook

Before every upgrade, the package's install script runs
`systemctl disable --now openlinkhub` and never enables it again. The fans
then fall back to the hub's stored curves without warning. The hook enables
and starts the service after every transaction that upgrades the package.

### Editing the curves

Edit them in the web UI. The service rewrites the files in
`/var/lib/openlinkhub/database/temperatures/`, so copy them back to the repo
after a change. The built-in curves (Quiet, Normal, Performance) are not
files.

Fans on the motherboard's headers are not part of this package. They stay on
the BIOS fan curves.

### Assignments lost after a BIOS update

On the first boot after a BIOS update, OpenLinkHub can start with every fan
on its built-in Normal curve and save that over the assignments, without an
error in its log. The curves themselves stay. Check the fans after a BIOS
update (Verify) and repeat Install, step 4 if needed.

Source: [OpenLinkHub](https://github.com/jurkovic-nikola/OpenLinkHub).

## Verify

```bash
systemctl is-active openlinkhub                                                      # active
ls -l /dev/hidraw* | grep openlinkhub                                                # the devices' nodes, owner openlinkhub
curl -sL 127.0.0.1:27003/api/devices/ | grep -o '"Product":"[^"]*"' | sort -u        # the hub and the AIO
curl -sL 127.0.0.1:27003/api/temperatures/ | grep -o '"C[a-zA-Z]*Curve"' | sort -u   # CaseFrontCurve, CaseIntakeCurve, CaseRearCurve, CoolantCurve, CoolantScriptCurve
/usr/local/bin/olh-coolant-temp                                                      # the coolant temperature, such as 32.4
/usr/local/bin/olh-case-heat                                                         # about 45 to 80, never 80 at an idle desktop
curl -sL 127.0.0.1:27003/api/devices/<key> | grep -o '"profile":"[^"]*"'            # each fan's curve, not "Normal" (the pump: "Normal")
```
