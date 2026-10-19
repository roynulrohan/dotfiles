#!/usr/bin/env bash
# Snapper setup: root timeline on (ArchWiki limits), new home config (12 hourly,
# 14 daily, 2 weekly, 1 monthly; user access as in the ArchWiki), timeline timer, updatedb prune. Run with sudo.
set -euo pipefail

echo "== root: enable timeline (limits already 5 hourly / 7 daily)"
snapper -c root set-config TIMELINE_CREATE=yes TIMELINE_MIN_AGE=1800

echo "== home: create config"
snapper -c home create-config /home
snapper -c home set-config \
    TIMELINE_CREATE=yes TIMELINE_MIN_AGE=1800 \
    TIMELINE_LIMIT_HOURLY=12 TIMELINE_LIMIT_DAILY=14 \
    TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=1 TIMELINE_LIMIT_YEARLY=0 \
    NUMBER_LIMIT=20 NUMBER_LIMIT_IMPORTANT=15 \
    ALLOW_USERS="${SUDO_USER:?run this with sudo from your own account}" SYNC_ACL=yes
chmod a+rx /home/.snapshots

echo "== timers"
systemctl enable --now snapper-timeline.timer
systemctl is-active snapper-cleanup.timer >/dev/null || systemctl enable --now snapper-cleanup.timer

echo "== keep locate out of snapshots"
if [ -f /etc/updatedb.conf ] && ! grep -q '\.snapshots' /etc/updatedb.conf; then
    sed -i 's/^PRUNENAMES = "\(.*\)"/PRUNENAMES = "\1 .snapshots"/' /etc/updatedb.conf
    grep -q '\.snapshots' /etc/updatedb.conf || echo 'PRUNENAMES = ".snapshots"' >> /etc/updatedb.conf
fi

echo "== first named snapshots"
snapper -c root create -d "baseline after snapshot setup"
snapper -c home create -d "baseline after snapshot setup"

echo; snapper list-configs; echo; snapper -c home list
