# Coolant

A Noctalia bar plugin, `roynul/coolant`. It shows the coolant temperature of a
Corsair iCUE H100i RGB PRO XT, as [`linux/openlinkhub`](../../../openlinkhub/SETUP.md)
reads it. The droplet and the number stay monotone like the other stats. From
38 °C they turn amber, and red at 41 °C, the same points as the pump's
lighting. The tooltip lists the case air and every fan and pump speed. A click
opens the OpenLinkHub web UI. Install and enable it with
[`linux/noctalia`](../../SETUP.md).

## On the bar

`config.toml` defines it as `[widget.coolant]` and puts `"coolant"` last in the
`stats` capsule group.

## How it reads the values

Every 3 seconds it runs a short Python program that asks OpenLinkHub's API at
`127.0.0.1:27003`. It finds the AIO and the Commander Core XT hub by product
name, so no serial number is stored. The channel numbers match the wiring in
the [gaming PC's fan table](../../../../personal/machines/gaming-pc.md#fans).

- If OpenLinkHub doesn't answer, the widget shows `--` and the tooltip says
  so.
- If OpenLinkHub doesn't see the AIO, the tooltip says that instead.
- A fan that the hub doesn't report shows "not seen" in the tooltip.

## Files

| File | What |
|---|---|
| [`plugin.toml`](plugin.toml) | The manifest |
| [`coolant.luau`](coolant.luau) | The widget: the reader, the colours and the tooltip |
