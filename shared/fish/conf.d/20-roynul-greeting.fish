# Terminal greeting: runs the `fastfetch` wrapper from shared/fastfetch (installed
# as ~/.local/bin/fastfetch). It applies greeting.jsonc, picks a random logo and
# falls back to the ASCII logo where the terminal can't draw images, so typing
# `fastfetch` in any shell gives the same output as the greeting.
function fish_greeting
    command -q fastfetch; and fastfetch
end
