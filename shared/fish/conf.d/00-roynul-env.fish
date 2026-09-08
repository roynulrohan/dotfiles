# Environment shared by every machine. Sourced automatically by fish (conf.d).
# Keep platform bits guarded so the other OS skips them silently.

# Homebrew (macOS / Linuxbrew)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        eval ($brew shellenv)
        break
    end
end

# PATH
set -gx BUN_INSTALL $HOME/.bun
fish_add_path -g $HOME/.local/bin $BUN_INSTALL/bin

# Editors
command -q micro; and set -gx EDITOR micro
command -q nvim;  and set -gx VISUAL nvim

# Starship: one prompt config for every machine (see shared/starship)
set -gx STARSHIP_CONFIG $HOME/.config/starship/starship.toml

# SSH agent as a systemd user service (Linux). macOS ships its own agent.
if set -q XDG_RUNTIME_DIR; and test -S $XDG_RUNTIME_DIR/ssh-agent.socket
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
end
