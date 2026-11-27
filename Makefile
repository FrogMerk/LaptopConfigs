.PHONY: help dots validate test check wallpaper update push

help:
	@printf '%s\n' \
	  'dots       apply dotfiles with stow' \
	  'validate   validate niri and shell configs' \
	  'test       restore the repo into a temp HOME and validate' \
	  'check      run the monthly maintenance report' \
	  'wallpaper  regenerate the wallpaper' \
	  'update     full system upgrade' \
	  'push       push the config repo'

dots:
	./scripts/apply-dotfiles.sh

validate:
	niri validate
	bash -n bootstrap/*.sh scripts/*.sh post-install.sh

test:
	./scripts/test-restore.sh

check:
	./scripts/maintenance-check.sh

wallpaper:
	./scripts/make-wallpaper.py

update:
	sudo pacman -Syu

push:
	git push
