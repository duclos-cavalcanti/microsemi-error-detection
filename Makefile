SHELL := /bin/bash

DOCKER_NAME 	:= libero-ubuntu-toolchain
DOCKER_TAG  	:= libero-ubuntu-tag
DOCKER_REPO 	:= libero-ubuntu-repo
IS_DOCKER_BUILT := $(shell docker images | tail -n +2 | awk '{print $2}' | grep ${DOCKER_TAG})

PWD := $(shell pwd)
DISPLAY := ${DISPLAY}
XAUTH := ${HOME}/.Xauthority

.PHONY: vhs vhs-setup view \
		screen \
		debug \
		demo \
		venv freeze \
		uninstall install clean \
		run

all: install

vhs-setup:
	@[ -n "$(shell pacman -Qs vhs)" ] || sudo pacman -S vhs
	@[ -f .github/assets/demo.tape ] || (vhs new demo.tape; printf "Be sure to edit the demo.tape for your vhs use-case!\n")

vhs: vhs-setup
	vhs < .github/assets/demo.tape

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

clean:
	@docker rmi $(shell docker images --filter dangling=true | tail -n +2 | awk '{print $$3}')

install-pre:
	@docker build ./docker -t ${DOCKER_REPO}:${DOCKER_TAG}

install-success:
	@printf "Docker has already been built!\n"
	@printf "Run 'make uninstall' to remove built docker.\n"

install: $(if ${IS_DOCKER_BUILT}, install-success, install-pre)

uninstall-pre:
	@docker rmi $(shell docker images | grep ${DOCKER_TAG} | awk '{print $$3}')

uninstall-success:
	@docker rmi $(shell docker images | grep ${DOCKER_TAG} | awk '{print $$3}')

uninstall: $(if ${IS_DOCKER_BUILT}, uninstall-pre, uninstall-success)

run:
	@[ -f ${XAUTH} ] || touch ${XAUTH}
	docker run --name ${DOCKER_NAME} \
			    -it ${DOCKER_REPO}:${DOCKER_TAG} \
			    --network=host \
			    -e DISPLAY=${DISPLAY} \
			    -v ${PWD}:/home/docker/repo \
			    -v ${XAUTH}:/root/.Xauthority \
			    -v /etc/localtime:/etc/localtime \
				--privileged \
				-v /dev/bus/usb:/dev/bus/usb:rw \
			    --detach-keys="ctrl-@" \
			    --rm true
