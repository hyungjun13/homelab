#!/usr/bin/env bash
# Nightly offsite backup: snapshot tank, mount the snapshot read-only,
# back it up to Backblaze B2 with restic, then clean up.
# Installed to /usr/local/bin by install.sh; run by restic-backup.timer.
set -euo pipefail
set -a; . /etc/restic/env; set +a

DATASETS=(appdata photos files media music)
SNAP=restic
MNT=/mnt/backup

cleanup() {
  for d in "${DATASETS[@]}"; do umount "$MNT/$d" 2>/dev/null || true; done
  zfs destroy -r "tank@$SNAP" 2>/dev/null || true
}
trap cleanup EXIT

cleanup                          # clear leftovers from a failed run
zfs snapshot -r "tank@$SNAP"     # consistent point-in-time across datasets
for d in "${DATASETS[@]}"; do
  mkdir -p "$MNT/$d"
  mount -t zfs "tank/$d@$SNAP" "$MNT/$d"
done

restic backup "${DATASETS[@]/#/$MNT/}" /opt/stacks \
  --host homeserver --exclude-caches

restic forget --host homeserver \
  --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# Tell Uptime Kuma the run succeeded (only reached if everything above did)
if [[ -n "${KUMA_PUSH_URL:-}" ]]; then
  curl -fsS -m 10 "$KUMA_PUSH_URL" >/dev/null
fi
