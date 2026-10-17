# OpenLinkHub

Fan control for Corsair hubs, such as the iCUE Commander Core XT, without
iCUE. It runs as a system service with a web UI at `http://127.0.0.1:27003`.
The case fans follow the CPU and GPU temperatures, not the hub's temperature
probe.

## Files

| Repo | Destination |
|---|---|
| [`temperatures/CpuCurve.json`](temperatures/CpuCurve.json) | `/var/lib/openlinkhub/database/temperatures/CpuCurve.json` |
| [`temperatures/ExhaustCurve.json`](temperatures/ExhaustCurve.json) | `/var/lib/openlinkhub/database/temperatures/ExhaustCurve.json` |
| [`temperatures/GpuCurve.json`](temperatures/GpuCurve.json) | `/var/lib/openlinkhub/database/temperatures/GpuCurve.json` |
| [`temperatures/IntakeCurve.json`](temperatures/IntakeCurve.json) | `/var/lib/openlinkhub/database/temperatures/IntakeCurve.json` |
| [`temperatures/SystemCurve.json`](temperatures/SystemCurve.json) | `/var/lib/openlinkhub/database/temperatures/SystemCurve.json` |
| [`openlinkhub-reenable.hook`](openlinkhub-reenable.hook) | `/etc/pacman.d/hooks/openlinkhub-reenable.hook` |
| [`openlinkhub.desktop`](openlinkhub.desktop) | `~/.local/share/applications/openlinkhub.desktop` |

Outside the repo: which curve each fan uses. OpenLinkHub keeps that in a
profile named after the hub's serial number (Install, step 4).

## Install

1. Install the package. It is in the CachyOS repo; on plain Arch it comes from
   the AUR (`paru -S openlinkhub`).

   ```bash
   sudo pacman -S openlinkhub
   ```

2. Give the service access to the hub, then start it. The package's `udev`
   rule makes the `openlinkhub` user the owner of the hub. On the first
   install, `udev` can load that rule before the package creates the user,
   and then it drops the owner. Restarting `udev` reads the rule again:

   ```bash
   sudo systemctl restart systemd-udevd
   sudo udevadm trigger --action=add --subsystem-match=hidraw --settle
   sudo systemctl enable --now openlinkhub
   ```

3. Copy the hook and the launcher entry. Copy the curves as the service's
   user, then restart the service so it loads them:

   ```bash
   sudo install -o openlinkhub -g openlinkhub -m644 temperatures/*.json /var/lib/openlinkhub/database/temperatures/
   sudo systemctl restart openlinkhub
   ```

4. Give each fan channel a curve, in the web UI or through the API. The hub's
   serial is the key in `curl -sL 127.0.0.1:27003/api/devices/`:

   ```bash
   curl -s -X POST 127.0.0.1:27003/api/speed -H 'Content-Type: application/json' \
     -d '{"deviceId":"<serial>","channelId":0,"profile":"CpuCurve"}'
   ```

   Which curve fits which fan depends on the wiring (Notes, "Curves").

## Notes

### Curves

Each curve is a set of points (temperature → fan %), with straight lines
between them. OpenLinkHub reads the sensors every 3 seconds.

| Curve | Sensor | Points |
|---|---|---|
| `CpuCurve` | CPU (`k10temp` Tctl) | 35% at 0 °C, 60: 45, 66: 60, 72: 80, 77: 100 |
| `IntakeCurve` | CPU + GPU, the higher of the two | 50% at 0 °C, 60: 55, 66: 65, 72: 85, 76: 100 |
| `SystemCurve` | CPU + GPU, the higher of the two | 35% at 0 °C, 60: 40, 66: 55, 72: 70, 78: 90, 81: 100 |
| `ExhaustCurve` | CPU + GPU, the higher of the two | 25% at 0 °C, 60: 28, 66: 36, 72: 45, 78: 58, 81: 65; never above 65% |
| `GpuCurve` | GPU (NVIDIA, through `nvidia-smi`) | 35% to 50 °C, 60: 50, 66: 65, 72: 90, 75: 100 |

- `CpuCurve` is for the exhaust fan right behind the CPU cooler.
- `IntakeCurve` is for strong intakes, such as 140 mm fans under the
  graphics card.
- `SystemCurve` is for the other intakes.
- `ExhaustCurve` is for strong exhausts, such as a row of top fans.
- `GpuCurve` is for fans that should follow the graphics card only.

A Ryzen 5000 CPU's Tctl jumps by several degrees at light desktop load. The
flat part up to 60 °C keeps the fans from following those jumps.

### Positive pressure

The curves keep more air coming in than going out, so the case stays at
positive pressure. Air then leaves through every unfiltered gap instead of
pulling dust in, and all incoming air passes the intake filters. Two rules
do this:

- **Intakes run high.** `IntakeCurve` never drops below 50%.
- **Strong exhausts are capped.** `ExhaustCurve` stops at 65%.

Airflow scales roughly with fan speed, so the balance can be estimated from
each fan's rated airflow and its speed as a share of its maximum. To check
it, hold a tissue near a gap in the case, such as the slot covers: it must
blow outwards.

### Why not the temperature probe

The hub keeps its own fan curves in its memory (iCUE's device memory mode). It
runs them when no software controls it. Those curves can only use the hub's
own temperature probes. A probe measures air, which warms slowly: in a full
CPU load, a probe in the CPU cooler's exhaust rose 1 °C while the CPU rose
27 °C. So a probe curve can't react to load.

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
ls -l /dev/hidraw* | grep openlinkhub                                                # the hub's nodes, owner openlinkhub
curl -sL 127.0.0.1:27003/api/devices/ | grep -o '"Product":"[^"]*"' | sort -u        # the hub's name
curl -sL 127.0.0.1:27003/api/temperatures/ | grep -o '"[A-Za-z]*Curve"' | sort -u    # CpuCurve, ExhaustCurve, GpuCurve, IntakeCurve, SystemCurve
curl -sL 127.0.0.1:27003/api/devices/<serial> | grep -o '"profile":"[^"]*"'         # each fan's curve, not "Normal"
```
