SHELL := /bin/bash
PWD := $(shell pwd)

.PHONY: run debug \
			screen \
			drivers \
			setup freeze \
			vhs vhs-setup view

vhs-setup:
	@[ -n "$(shell pacman -Qs vhs)" ] || sudo pacman -S vhs
	@[ -f ./demo.tape ] || (vhs new demo.tape; printf "Be sure to edit the demo.tape for your vhs use-case!\n")

vhs:
	vhs < demo.tape

view:
	@[ -f ./.github/assets/demo.gif ] && (mpv ./.github/assets/demo.gif)

freeze:
	pip3 freeze > module/requirements.txt

setup:
	python3 -m venv .venv
	pip3 install -r module/requirements.txt

screen:
	@screen /dev/ttyUSB0 57600

debug:
	@stty -F /dev/ttyUSB0 57600
	@python3 main.py --mode debug

run:
	@python3 main.py


