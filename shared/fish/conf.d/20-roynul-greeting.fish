# Terminal greeting: fastfetch with the layout in ~/.config/fastfetch/greeting.jsonc
# and a random image from ~/.config/fastfetch/logo (any png/jpg/webp/icon).
# Needs a terminal with the kitty graphics protocol (kitty, Ghostty).
function fish_greeting
    command -q fastfetch; or return
    set -l cfg ~/.config/fastfetch/greeting.jsonc
    test -f $cfg; or return

    set -l logos ~/.config/fastfetch/logo/*.{icon,png,jpg,jpeg,webp}
    if test (count $logos) -eq 0
        fastfetch -c $cfg --logo none
        return
    end
    set -l logo (random choice $logos)

    # Fixed height; width follows the image's aspect ratio (a cell is ~2.2x
    # taller than wide). Capped so a wide image can't push the boxes off screen.
    set -l rows 18
    set -l cols 40
    if command -q magick
        set -l dims (magick identify -format '%w %h' "$logo" 2>/dev/null | string split ' ')
        if test (count $dims) -eq 2 -a $dims[2] -gt 0
            set cols (math "round($dims[1] / $dims[2] * $rows * 2.2)")
            test $cols -gt 44; and set cols 44
            test $cols -lt 8; and set cols 8
        end
    end

    fastfetch -c $cfg --logo $logo --logo-width $cols --logo-height $rows
end
