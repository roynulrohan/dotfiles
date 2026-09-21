# Syntax colours, on top of fish's default theme. Interactive shells only.
status is-interactive; or exit

# fish paints autosuggestions in brblack. Both terminals here run a transparent
# background, so there is no dark surface behind that dark grey, only the
# wallpaper through the blur, and the suggestion washes out. Dimmed white is the
# foreground the terminal already picked, at lower intensity, so it stays legible
# whatever the palette is and still reads as unconfirmed text.
set -g fish_color_autosuggestion white --dim
