# Aliases and abbreviations. Interactive shells only.
status is-interactive; or exit

# Modern CLI replacements, only when the replacement exists
if command -q eza
    alias ls 'eza --icons --group-directories-first -1'
    alias ll 'eza -la --icons --git --group-directories-first --header'
    alias tree 'eza --tree --icons --level=2 --git-ignore --group-directories-first'
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

# JS: bun over npm/npx
abbr -a dev   'bun run dev'
abbr -a build 'bun run build'
abbr -a npx   bunx
