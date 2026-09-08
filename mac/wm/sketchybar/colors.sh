#!/bin/bash
# ~/.config/sketchybar/colors.sh
# Palette: Catppuccin Macchiato (https://catppuccin.com/palette)
# Format: 0xAARRGGBB (AA = alpha; RR/GG/BB = 8-bit channels)

# Base palette
export BLACK=0xff181926
export WHITE=0xffcad3f5
export RED=0xffed8796
export GREEN=0xffa6da95
export BLUE=0xff8aadf4
export YELLOW=0xffeed49f
export ORANGE=0xfff5a97f
export MAGENTA=0xffc6a0f6
export GREY=0xff939ab7
export TRANSPARENT=0x00000000

# Bar surface colors
# BAR_COLOR uses alpha 0xa0 (~63%) so the blur shows through.
export BAR_COLOR=0xa024273a
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE

# Background swatches for item pills (used by spaces bracket and volume bracket).
export BACKGROUND_1=0x903c3e4f
export BACKGROUND_2=0x90494d64

# Popup window (Apple menu, Spotify controls, volume device list).
export POPUP_BACKGROUND_COLOR=0xff24273a
export POPUP_BORDER_COLOR=$WHITE

export SHADOW_COLOR=$BLACK
