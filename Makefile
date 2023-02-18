SHELL := /bin/bash

DOCKER_NAME := libero-ubuntu-docker
DOCKER_TAG  := 20.04
DOCKER_REPO := ubuntu-20.04

PWD := $(shell pwd)
DISPLAY := ${DISPLAY}
XAUTH := ${HOME}/.Xauthority

.PHONY: vhs vhs-setup view \
		screen \
		debug \
		demo \
		venv freeze \
		setup run

vhs-setup:
	@[ -n "$(shell pacman -Qs vhs)" ] || sudo pacman -S vhs
	@[ -f ./demo.tape ] || (vhs new demo.tape; printf "Be sure to edit the demo.tape for your vhs use-case!\n")

vhs: vhs-setup
	vhs < demo.tape

view:
	@[ -f ./.github/assets/demo.gif ] && (mpv ./.github/assets/demo.gif)

screen:
	@screen /dev/ttyUSB0 57600

debug:
	@stty -F /dev/ttyUSB0 57600
	@python3 main.py --mode debug

demo:
	@python3 main.py

venv:
	python3 -m venv .venv
	pip3 install -r module/requirements.txt

freeze:
	pip3 freeze > module/requirements.txt

setup:
	docker build ./docker -t ${TAG}:${REPO}

run:
	touch ${XAUTH}
	docker run --name ${DOCKER_NAME} \
			   --network=host \
			   -e DISPLAY=${DISPLAY} \
			   -v ${PWD}:/home/project \
			   -v ${XAUTH}:/root/.Xauthority \
			   -v /etc/localtime:/etc/localtime \
			   --detach-keys="ctrl-@" \
			   -it ${DOCKER_TAG}:${DOCKER_REPO} \
			   --rm
