# Prompt and shell hooks. Interactive shells only.
status is-interactive; or exit

# macOS: mac/fish/config.fish runs these after its PATH and conda setup. conda's
# hook wraps whatever fish_prompt exists when it runs, so moving starship ahead
# of it would change the Mac's prompt.
test (uname) = Darwin; and exit

command -q starship; and starship init fish | source
command -q zoxide;   and zoxide init fish --cmd cd | source
command -q direnv;   and direnv hook fish | source
