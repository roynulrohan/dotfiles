# macOS fish entry point. On Linux, caelestia ships its own config.fish that does
# the same job, so this file is macOS only. Everything shared lives in conf.d/.
if status is-interactive
    command -q starship; and starship init fish | source
    command -q zoxide;   and zoxide init fish --cmd cd | source
    command -q direnv;   and direnv hook fish | source
end
