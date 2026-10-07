# PipeWire

A system-wide EQ for the Logitech G432 headset, built into PipeWire. No
EasyEffects, no other app: PipeWire's own `filter-chain` runs it.

| Repo | Destination |
|---|---|
| `g432-eq.conf` | `~/.config/pipewire/filter-chain.conf.d/g432-eq.conf` |

## Install

PipeWire and WirePlumber come with CachyOS. Copy the file, then start the
filter-chain daemon, which PipeWire ships as a user service:

```bash
systemctl --user enable --now filter-chain.service
```

Turn the EQ off with `systemctl --user disable --now filter-chain.service`.
After editing the file, `systemctl --user restart filter-chain.service`; apps
keep playing through the second of silence.

## Why it exists

On Windows, G HUB applies its EQ on the PC (the G432 has no onboard EQ;
HeadsetControl only supports sidetone for it). On Linux the headset plays
untouched and sounds flat and muffled. The curve is G HUB's "Bass Music/FPS"
preset: +12 +10 +8 −3 −2 +4 +4 +5 +8 +12 dB at 32 Hz…16 kHz.

- **Bands.** Ten peaking filters at the G HUB frequencies, Q 1.41 (one octave).
  Neighbouring bands add up, so the gains are fitted to make the summed curve
  hit the slider values at each frequency, peaking at +12.0 dB. G HUB's own
  filter shapes aren't published, so this is an approximation.
- **Preamp −6 dB.** A boost pushes loud music past digital full scale, and the
  G432 takes 16-bit audio only, so the overflow is clipped. That's the harsh,
  painfully loud result from EasyEffects. −12.1 dB removes clipping completely;
  0 dB crackled on heavy bass; −6 dB sounded right. The volume slider sits
  higher to make up for it. A high shelf at 0 Hz is PipeWire's flat gain
  (`biquad.c`).
- **Smart filter.** WirePlumber puts it in front of the G432 only
  (`filter.smart.target` is the headset's `node.name`). The headset stays the
  default output; HDMI and other outputs are untouched. A different headset
  needs its own `node.name` from `wpctl inspect @DEFAULT_AUDIO_SINK@`.

Tried and dropped: EasyEffects (removed), AutoEq's measured G432 correction
(Rtings data; sounded worse), and HeSuVi's DTS Headphone:X virtual surround.

## Verify

```bash
systemctl --user is-active filter-chain.service   # active
wpctl status                                       # "Filters" lists effect_input.g432_eq
pw-link -l | grep -A1 effect_output.g432_eq        # -> the G432 playback ports
```

Sources: [PipeWire filter-chain](https://docs.pipewire.org/page_module_filter_chain.html),
[WirePlumber smart filters](https://pipewire.pages.freedesktop.org/wireplumber/policies/smart_filters.html),
and the Arch Wiki's PipeWire page, "Systemwide parametric equalization".
