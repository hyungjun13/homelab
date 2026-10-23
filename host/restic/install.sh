#!/usr/bin/env bash
# Install or update the restic backup job. Run with sudo after git pull.
# Does not touch /etc/restic/env or /etc/restic/password.
set -euo pipefail
cd "$(dirname "$0")"
install -m 700 restic-backup.sh /usr/local/bin/
install -m 644 restic-backup.service restic-backup.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now restic-backup.timer
echo "Installed. Next run:"
systemctl list-timers restic-backup.timer --no-pager
