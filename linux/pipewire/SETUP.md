# PipeWire

A system-wide EQ for the Logitech G432 headset, built into PipeWire: its own
`filter-chain` runs it, so no other app is needed. Plus a fixed buffer size,
so apps can't make music stutter by changing it.

## Files

| Repo | Destination |
|---|---|
| [`g432-eq.conf`](g432-eq.conf) | `~/.config/pipewire/filter-chain.conf.d/g432-eq.conf` |
| [`quantum.conf`](quantum.conf) | `~/.config/pipewire/pipewire.conf.d/quantum.conf` |

## Install

CachyOS preinstalls `pipewire` and `wireplumber`. On plain Arch:

```bash
sudo pacman -S pipewire wireplumber
```

Copy the files, then start the filter-chain daemon, which PipeWire ships as a
user service:

```bash
systemctl --user enable --now filter-chain.service
```

`quantum.conf` takes effect at the next login, or at once with
`pw-metadata -n settings 0 clock.force-quantum 1024` (until logout).

## Notes

### The EQ

On Windows, G HUB applies its EQ on the PC (the G432 has no onboard EQ;
HeadsetControl only supports sidetone for it). On Linux the headset plays
untouched and sounds flat and muffled. The curve is G HUB's "Bass Music/FPS"
preset: +12 +10 +8 −3 −2 +4 +4 +5 +8 +12 dB at 32 Hz…16 kHz.

- **Bands.** Ten peaking filters at the G HUB frequencies, Q 1.41 (one octave).
  Neighbouring bands add up, so the gains are fitted to make the summed curve
  hit the slider values at each frequency, peaking at +12.0 dB. G HUB's own
  filter shapes aren't published, so this is an approximation.
- **Preamp −6 dB.** A boost pushes loud music past digital full scale. The
  G432 takes 16-bit audio only, so the overflow clips and sounds harsh and
  painfully loud. −12.1 dB removes clipping completely; 0 dB crackles on heavy
  bass; −6 dB sounds right. The volume slider sits higher to make up for it. A
  high shelf at 0 Hz is PipeWire's flat gain (`biquad.c`).
- **Smart filter.** WirePlumber puts it in front of the G432 only
  (`filter.smart.target` is the headset's `node.name`). The headset stays the
  default output; HDMI and other outputs are untouched. A different headset
  needs its own `node.name` from `wpctl inspect @DEFAULT_AUDIO_SINK@`.

Turn the EQ off with `systemctl --user disable --now filter-chain.service`.
After editing the file, run `systemctl --user restart filter-chain.service`;
apps keep playing through the second of silence.

### Fixed buffer size

`quantum.conf` sets PipeWire's quantum (the number of samples processed per
cycle) to 1024 and stops apps from changing it: default, minimum and maximum
are all 1024. Each change interrupts playback for a moment, so an app that
asks for its own quantum, such as an audio visualiser, makes music stutter.
These are quantum switches, not dropouts: PipeWire's error counters
(`pw-top`, ERR) stay at 0.

1024 at 48 kHz is about 21 ms of delay. 512 (about 11 ms) also plays without
stutter.

Sources: [PipeWire filter-chain](https://docs.pipewire.org/page_module_filter_chain.html),
[WirePlumber smart filters](https://pipewire.pages.freedesktop.org/wireplumber/policies/smart_filters.html),
and the Arch Wiki's PipeWire page, "Systemwide parametric equalization".

## Verify

```bash
systemctl --user is-active filter-chain.service   # active
wpctl status                                       # "Filters" lists effect_input.g432_eq
pw-link -l | grep -A1 effect_output.g432_eq        # -> the G432 playback ports
pw-config -n pipewire.conf merge context.properties | grep clock   # 1024 three times
```
