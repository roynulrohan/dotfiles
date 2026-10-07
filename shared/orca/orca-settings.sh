#!/usr/bin/env bash
# Orca stores its settings inside orca-data.json together with repos, worktrees,
# sessions and account credentials, so the file can't be copied whole. This
# script moves only the keys listed in settings.json plus this OS's
# settings.<os>.json between the repo and Orca.
#   ./orca-settings.sh diff     show where live values differ from the repo
#   ./orca-settings.sh apply    merge the repo settings into Orca (Orca must be quit)
#   ./orca-settings.sh export   copy the live values of those keys back into the repo
set -euo pipefail
cd "$(dirname "$0")"

# settings.json holds what both machines share; settings.<os>.json holds values
# that differ per OS (font name, blur, opacity) and wins over it.
case "$(uname -s)" in
    Darwin) os=macos; userdata="$HOME/Library/Application Support/Orca" ;;
    Linux)  os=linux; userdata="${XDG_CONFIG_HOME:-$HOME/.config}/orca" ;;
    *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
files=(settings.json)
[[ -f "settings.$os.json" ]] && files+=("settings.$os.json")
[[ -d "$userdata" ]] || { echo "Orca data dir not found: $userdata" >&2; exit 1; }

profile=$(jq -r '.activeProfileId // "local-default"' "$userdata/orca-profile-index.json" 2>/dev/null || echo local-default)
live="$userdata/profiles/$profile/orca-data.json"
[[ -f "$live" ]] || { echo "not found: $live" >&2; exit 1; }

# The repo settings for this OS, with the OS file winning.
repo() { jq -s 'add' "${files[@]}"; }
# The live values of exactly the keys a given object tracks.
tracked() { jq --argjson r "$1" '.settings | with_entries(select(.key as $k | $r | has($k)))' "$live"; }

case "${1:-}" in
    diff)
        diff -u --label repo <(repo | jq -S .) --label live <(tracked "$(repo)" | jq -S .) && echo "in sync"
        ;;
    apply)
        # Orca rewrites orca-data.json from memory, so a merge made while it
        # runs is lost.
        if pgrep -xi orca >/dev/null; then echo "quit Orca first" >&2; exit 1; fi
        cp "$live" "$live.dotfiles-bak"
        jq --argjson r "$(repo)" '.settings += $r' "$live" > "$live.tmp"
        mv "$live.tmp" "$live"
        echo "merged ${files[*]} into $live (backup: $live.dotfiles-bak)"
        ;;
    export)
        # Each file keeps its own keys, so per-OS values never land in settings.json.
        for f in "${files[@]}"; do
            tracked "$(cat "$f")" | jq --slurpfile r "$f" '. as $l | $r[0] | with_entries(.value = $l[.key])' > "$f.tmp"
            mv "$f.tmp" "$f"
        done
        echo "updated ${files[*]} from $live"
        ;;
    *) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
