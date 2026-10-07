#!/usr/bin/env bash
# Orca stores its settings inside orca-data.json together with repos, worktrees,
# sessions and account credentials, so the file can't be copied whole. This
# script moves only the keys listed in settings.json between the repo and Orca.
#   ./orca-settings.sh diff     show where live values differ from settings.json
#   ./orca-settings.sh apply    merge settings.json into Orca (Orca must be quit)
#   ./orca-settings.sh export   copy the live values of those keys into settings.json
set -euo pipefail
cd "$(dirname "$0")"
repo=settings.json

userdata="$HOME/Library/Application Support/Orca"
[[ -d "$userdata" ]] || { echo "Orca data dir not found: $userdata" >&2; exit 1; }

profile=$(jq -r '.activeProfileId // "local-default"' "$userdata/orca-profile-index.json" 2>/dev/null || echo local-default)
live="$userdata/profiles/$profile/orca-data.json"
[[ -f "$live" ]] || { echo "not found: $live" >&2; exit 1; }

# The live values of exactly the keys settings.json tracks.
tracked() { jq --slurpfile r "$repo" '.settings | with_entries(select(.key as $k | $r[0] | has($k)))' "$live"; }

case "${1:-}" in
    diff)
        diff -u --label repo <(jq -S . "$repo") --label live <(tracked | jq -S .) && echo "in sync"
        ;;
    apply)
        # Orca rewrites orca-data.json from memory, so a merge made while it
        # runs is lost.
        if pgrep -xi orca >/dev/null; then echo "quit Orca first" >&2; exit 1; fi
        cp "$live" "$live.dotfiles-bak"
        jq --slurpfile r "$repo" '.settings += $r[0]' "$live" > "$live.tmp"
        mv "$live.tmp" "$live"
        echo "merged $repo into $live (backup: $live.dotfiles-bak)"
        ;;
    export)
        tracked | jq --slurpfile r "$repo" '. as $l | $r[0] | with_entries(.value = $l[.key])' > "$repo.tmp"
        mv "$repo.tmp" "$repo"
        echo "updated $repo from $live"
        ;;
    *) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
