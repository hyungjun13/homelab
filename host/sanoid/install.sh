#!/usr/bin/env bash
# Install or update the sanoid config. Run with sudo after git pull.
set -euo pipefail
cd "$(dirname "$0")"
install -d -m 755 /etc/sanoid
install -m 644 sanoid.conf /etc/sanoid/sanoid.conf
systemctl enable --now sanoid.timer
echo "Installed. Next run:"
systemctl list-timers sanoid.timer --no-pager
