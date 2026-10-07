#!/usr/bin/env bash
# Orca stores its settings together with repos, worktrees, sessions and account
# credentials, so its data can't be copied whole. This script moves only the
# keys listed in settings.json plus this OS's settings.<os>.json between the
# repo and Orca.
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
dir="$userdata/profiles/$profile"

# Newer Orca (1.4.222 here) keeps the profile in profile-state.db, one row per
# top-level section, and writes orca-data.json only as an export it checks by
# hash: editing that JSON makes Orca ask which copy to keep on every launch.
# Older Orca (1.4.206) keeps everything in orca-data.json.
db="$dir/profile-state.db"
json="$dir/orca-data.json"
if [[ -f "$db" ]]; then store=db; else store=json; fi
[[ $store == db || -f "$json" ]] || { echo "no Orca profile data in $dir" >&2; exit 1; }

sql() { sqlite3 -batch -bail "$@"; }
orca_running() {
    ps -axo comm=,args= | awk '{ c = tolower($1); sub(/.*\//, "", c) }
        (c == "orca" || c == "orca-ide") && !/daemon-entry/ { found = 1 } END { exit !found }'
}
live_settings() {
    if [[ $store == db ]]; then
        sql "file:$db?mode=ro" "SELECT payload FROM profile_state_documents WHERE domain = 'settings';"
    else
        jq '.settings' "$json"
    fi
}
# The repo settings for this OS, with the OS file winning.
repo() { jq -s 'add' "${files[@]}"; }
# The live values of exactly the keys a given object tracks.
tracked() { live_settings | jq --argjson r "$1" 'with_entries(select(.key as $k | $r | has($k)))'; }

case "${1:-}" in
    diff)
        diff -u --label repo <(repo | jq -S .) --label live <(tracked "$(repo)" | jq -S .) && echo "in sync"
        ;;
    apply)
        # Orca rewrites its data from memory, so a merge made while it runs is
        # lost. The Linux AppImage's processes are named orca-ide. Orca's
        # background daemon (daemon-entry.js) keeps terminal sessions alive after
        # the window closes; it doesn't open the profile data, so it's ignored.
        if orca_running; then echo "quit Orca first" >&2; exit 1; fi
        merged=$(live_settings | jq -c --argjson r "$(repo)" '. * $r')  # deep: keeps nested keys newer Orca adds
        if [[ $store == db ]]; then
            # Write the section the way Orca saves one: compact JSON, SHA-256 of
            # the payload, the next profile revision on the row and in the meta
            # table. orca-data.json and its acceptance marker stay untouched, so
            # Orca reads it as an older accepted export and rewrites it itself.
            sql "$db" ".backup '$db.dotfiles-bak'"
            hash=$(printf '%s' "$merged" | sha256sum | cut -d' ' -f1)
            rev=$(sql "$db" "SELECT value FROM profile_state_meta WHERE key = 'revision';")
            new=$((rev + 1))
            sql "$db" <<SQL
BEGIN IMMEDIATE;
UPDATE profile_state_documents
   SET payload = '${merged//\'/\'\'}', content_hash = '$hash', revision = $new, updated_at = $(date +%s%3N)
 WHERE domain = 'settings' AND (SELECT value FROM profile_state_meta WHERE key = 'revision') = '$rev';
UPDATE profile_state_meta SET value = '$new' WHERE key = 'revision' AND value = '$rev';
COMMIT;
SQL
            [[ $(sql "file:$db?mode=ro" "SELECT content_hash FROM profile_state_documents WHERE domain = 'settings';") == "$hash" ]] \
                || { echo "settings row not updated; backup: $db.dotfiles-bak" >&2; exit 1; }
            echo "merged ${files[*]} into $db at revision $new (backup: $db.dotfiles-bak)"
        else
            cp "$json" "$json.dotfiles-bak"
            jq --argjson s "$merged" '.settings = $s' "$json" > "$json.tmp"
            mv "$json.tmp" "$json"
            echo "merged ${files[*]} into $json (backup: $json.dotfiles-bak)"
        fi
        ;;
    export)
        # Each file keeps its own keys, so per-OS values never land in settings.json.
        for f in "${files[@]}"; do
            tracked "$(cat "$f")" | jq --slurpfile r "$f" '. as $l | $r[0] | with_entries(.value = $l[.key])' > "$f.tmp"
            mv "$f.tmp" "$f"
        done
        echo "updated ${files[*]} from $store"
        ;;
    *) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
