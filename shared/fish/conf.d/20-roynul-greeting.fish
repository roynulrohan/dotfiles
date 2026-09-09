# `fastfetch` = our layout (~/.config/fastfetch/greeting.jsonc) with a random
# image from ~/.config/fastfetch/logo (png/jpg/webp/icon, or an animated gif).
# The greeting just calls it, so typing `fastfetch` gives the same output.
# Any arguments bypass the wrapper and go straight to the real binary.
# Needs a terminal with the kitty graphics protocol (kitty, Ghostty).
function fastfetch
    if test (count $argv) -gt 0
        command fastfetch $argv
        return
    end
    set -l cfg ~/.config/fastfetch/greeting.jsonc
    if not test -f $cfg
        command fastfetch
        return
    end

    set -l logos ~/.config/fastfetch/logo/*.{icon,png,jpg,jpeg,webp,gif}
    if test (count $logos) -eq 0
        command fastfetch -c $cfg --logo none
        return
    end
    set -l logo (random choice $logos)

    # Fixed height; width follows the image's aspect ratio (a cell is ~2.2x
    # taller than wide). Capped so a wide image can't push the boxes off screen.
    # 18 rows suits the Linux layout; override per machine with
    # `set -U fastfetch_logo_rows N` (a universal variable, not in dotfiles).
    set -l rows 18
    set -q fastfetch_logo_rows; and set rows $fastfetch_logo_rows
    set -l cols 40
    if command -q magick
        set -l dims (magick identify -format '%w %h' "$logo[1]" 2>/dev/null | string split ' ')
        if test (count $dims) -eq 2 -a $dims[2] -gt 0
            set cols (math "round($dims[1] / $dims[2] * $rows * 2.2)")
            test $cols -gt 44; and set cols 44
            test $cols -lt 8; and set cols 8
        end
    end

    # Animated GIFs: fastfetch's own icat mode shows one frame. The working
    # recipe (fastfetch issue #1423) is to let kitten icat emit the animation
    # and feed it to fastfetch as a raw logo. --place is absolute, so it must
    # match greeting.jsonc's padding (2 left, 1 top) on a cleared screen.
    if string match -qi '*.gif' $logo; and command -q kitten
        clear
        kitten icat -n --align left --scale-up --transfer-mode=stream \
            --place {$cols}x{$rows}@2x1 $logo \
            | command fastfetch -c $cfg --logo-width $cols --logo-height $rows --raw -
        return
    end

    command fastfetch -c $cfg --logo $logo --logo-width $cols --logo-height $rows
end

function fish_greeting
    command -q fastfetch; and fastfetch
end
