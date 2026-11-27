# Backups

Backups use [restic](https://restic.net/) with an encrypted repository. The
default target is **`/var/backups/restic` on the internal disk** as a staging
baseline: it protects against accidental deletion, but not against disk failure
or theft. Copy the repository to an external disk or remote target for real
off-device protection.

## What is backed up

- `/home/eddo` (dotfiles, projects, pictures, keys and configs)
- `/etc` (system config, including the restic setup itself)

Caches, trash, Flatpak/Steam data, browser profiles and build caches are
excluded in `etc/restic/exclude`. The repository is outside both paths, so it
never backs itself up.

## Install

```bash
cd ~/LaptopConfigs
sudo ./scripts/install-backups.sh
# or a different repository:
sudo ./scripts/install-backups.sh /mnt/backup/restic
```

This installs `restic`, creates `/etc/restic/{password,env,include,exclude}`,
initialises the repository, enables the timer and runs the first backup plus a
restore drill.

Then copy the repository password into NordPass immediately:

```bash
sudo cat /etc/restic/password
```

The password file is root-only, inside `/etc/restic`. **Without this password
the repository cannot be restored.** It is not in git.

## Schedule

`restic-backup.timer` runs daily at 03:00, with a 15-minute random delay and
`Persistent=true`, so a missed run catches up after boot or wake.

```bash
systemctl list-timers restic-backup.timer
systemctl status restic-backup.service
journalctl -u restic-backup.service
```

`restic-backup.service` keeps 7 daily, 4 weekly and 6 monthly snapshots tagged
`automatic`, then prunes.

## Commands

```bash
make backup           # run a backup now
make backup-status    # list snapshots
make backup-test      # check integrity + restore sample files
```

Manual snapshots and restores:

```bash
sudo sh -c 'set -a; . /etc/restic/env; exec restic snapshots'
sudo sh -c 'set -a; . /etc/restic/env; exec restic snapshots --latest 1'
sudo sh -c 'set -a; . /etc/restic/env; exec restic restore latest --target /tmp/restore'
```

`restic restore` recreates absolute paths under the target directory, e.g.
`/tmp/restore/home/eddo/...`. To restore one path:

```bash
sudo sh -c 'set -a; . /etc/restic/env; exec restic restore latest \
  --target /tmp/restore --include /home/eddo/Documents'
```

## Moving off-device

Stop the timer while copying, then point the environment file at the new repo:

```bash
sudo systemctl stop restic-backup.timer
sudo rsync -a /var/backups/restic/ /mnt/backup/restic/
sudo sed -i 's|^RESTIC_REPOSITORY=.*|RESTIC_REPOSITORY=/mnt/backup/restic|' /etc/restic/env
sudo systemctl start restic-backup.timer
sudo systemctl start restic-backup.service
```

For a remote repository, set `RESTIC_REPOSITORY` to an `sftp:` or S3 URL and
provide credentials in `/etc/restic/env` (for example `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`). Keep the environment file mode `600`.

If the target is an external disk, mount it before the timer runs. The service
will fail safely if the path is unavailable; check the journal.

## Restore drill

`sudo ./scripts/test-backup.sh` runs `restic check` with a 1% data sample,
restores `/etc/hostname`, `/etc/os-release` and a known home file from the
latest snapshot, and compares them. Run it after the first backup and
periodically after changing the target.

## Limitations

- A local repository on the same disk is not a disaster-recovery backup.
- Losing `/etc/restic/password` makes the repository unrecoverable.
- `restic forget --prune` runs with each automatic backup; watch the journal on
  a slow external disk.
