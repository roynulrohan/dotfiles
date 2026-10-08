# caelestia's user hook. Everything of mine lives in ~/.config/fish/conf.d/
# (see roynulrohan/dotfiles, shared/fish), except what has to run after
# caelestia's config.fish, which sources this file last.

# caelestia's config.fish prints ~/.local/state/caelestia/sequences.txt into
# every new interactive shell: escape codes that repaint the terminal's palette,
# foreground, background and cursor with the wallpaper scheme. Orca's terminal
# keeps its own theme (One Dark, background blended into Orca's), so reset those
# colours there: OSC 104 palette, 110 foreground, 111 background, 112 cursor
# (all handled by xterm.js, Orca's terminal). conf.d runs before config.fish,
# so this can't live there.
# kitty takes its colours from Noctalia's theme now (themes/noctalia.conf), so
# reset caelestia's frozen colours there too.
if test "$TERM_PROGRAM" = Orca; or set -q KITTY_WINDOW_ID
    printf '\e]104\a\e]110\a\e]111\a\e]112\a'
end
