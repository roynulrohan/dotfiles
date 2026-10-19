# Aliases and abbreviations. Interactive shells only.
status is-interactive; or exit

# Modern CLI replacements, only when the replacement exists
if command -q eza
    alias ls 'eza --icons --group-directories-first -1'
    alias ll 'eza -la --icons --git --group-directories-first --header'
    alias tree 'eza --tree --icons --level=2 --git-ignore --group-directories-first'
end

# The matrix rain on the terminal's own see-through background (-D) in the
# theme's colours (16-colour mode); neo-matrix has no settings file, so the
# alias carries the options. cmatrix always paints a black background, so its
# name runs neo-matrix too. Arch's package names the program neo-matrix, not neo.
if command -q neo-matrix
    alias neo-matrix 'command neo-matrix -D --colormode=16'
    alias cmatrix neo-matrix
end

# Short ls forms. Linux only: on macOS `la` stays fish's own function (ls -lAh).
if test (uname) != Darwin
    abbr -a l   ls
    abbr -a la  'ls -a'
    abbr -a lla 'ls -la'
end

# Git
abbr -a lg  lazygit
abbr -a gs  'git status'
abbr -a gd  'git diff'
abbr -a ga  'git add .'
abbr -a gc  'git commit -am'
abbr -a gl  'git log --oneline --graph -20'
abbr -a gp  'git push'
abbr -a gpl 'git pull'
abbr -a gsw 'git switch'
abbr -a gco 'git checkout'
abbr -a gb  'git branch'
abbr -a gbd 'git branch -d'
abbr -a gsh 'git show'
abbr -a gst 'git stash'
abbr -a gsp 'git stash pop'
abbr -a gsm 'git switch main'

# JS: bun over npm/npx
abbr -a dev   'bun run dev'
abbr -a build 'bun run build'
abbr -a npx   bunx
