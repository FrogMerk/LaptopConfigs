.PHONY: help dots validate test check icons backup backup-test backup-status update push

help:
	@printf '%s\n' \
	  'dots          apply dotfiles with stow' \
	  'validate      validate niri and shell configs' \
	  'test          restore the repo into a temp HOME and validate' \
	  'check         run the monthly maintenance report' \
	  'icons         build the green Papirus folder overlay' \
	  'backup        run a restic backup now' \
	  'backup-test   restore sample files from the latest snapshot' \
	  'backup-status list restic snapshots' \
	  'update        full system upgrade' \
	  'push          push the config repo'

dots:
	./scripts/apply-dotfiles.sh

validate:
	niri validate
	bash -n bootstrap/*.sh scripts/*.sh post-install.sh

test:
	./scripts/test-restore.sh

check:
	./scripts/maintenance-check.sh

icons:
	./scripts/apply-everforest-icons.sh

backup:
	sudo systemctl start restic-backup.service

backup-test:
	sudo ./scripts/test-backup.sh

backup-status:
	sudo sh -c 'set -a; . /etc/restic/env; exec restic snapshots'

update:
	sudo pacman -Syu

push:
	git push
